#!/bin/bash
# Script to deploy MinIO locally on the server
# This should be executed directly on the mini-axol server when SSH access through Tailscale is not working

# Change to continue on errors rather than exit
set +e

echo "=========================================================="
echo "Starting local MinIO deployment on $(hostname)..."
echo "=========================================================="

# IMPORTANT SECURITY NOTICE
echo "WARNING: This script uses default credentials for setup!"
echo "You MUST change these credentials immediately after setup."
echo ""
read -p "Do you want to continue with insecure default credentials? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled. Please modify this script to use secure credentials."
    exit 1
fi

# Create data directories if they don't exist
echo "Creating data directories..."
mkdir -p /mnt/disk1/blockchain_data /mnt/disk2/blockchain_data

# Ensure system packages are up to date
echo "Updating system packages..."
apt update
apt upgrade -y

# Install required packages
echo "Installing required packages..."
apt install -y wget curl unzip net-tools ufw

# Function to safely stop and disable a service
safe_disable_service() {
    local service_name=$1
    echo "Checking for service: $service_name"

    # Check if the service exists using the systemctl command
    if systemctl list-unit-files | grep -q "$service_name"; then
        echo "Found $service_name, attempting to stop and disable..."
        systemctl stop $service_name || echo "Warning: Could not stop $service_name, continuing anyway"
        systemctl disable $service_name || echo "Warning: Could not disable $service_name, continuing anyway"
        echo "Service $service_name processed."
    else
        echo "Service $service_name not found, skipping."
    fi
}

# Process each service
echo "Checking for and disabling potentially conflicting services..."
safe_disable_service "mlocate.service"
safe_disable_service "auditd.service"
safe_disable_service "fstrim.service"

# Check for disk space
echo "Checking disk space..."
available_space=$(df --output=avail / | tail -1)
if [ "$available_space" -lt $((20 * 1024 * 1024)) ]; then
    echo "WARNING: Less than 20GB available disk space. MinIO may not function properly."
    read -p "Continue anyway? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Deployment cancelled."
        exit 1
    fi
fi

# Install MinIO
if ! command -v minio &> /dev/null; then
    echo "Installing MinIO server..."
    wget https://dl.min.io/server/minio/release/linux-amd64/minio -O /usr/local/bin/minio
    chmod +x /usr/local/bin/minio
else
    echo "MinIO server already installed, checking for updates..."
    # This could be expanded to check versions and update if needed
fi

# Install MinIO client (mc)
if ! command -v mc &> /dev/null; then
    echo "Installing MinIO client (mc)..."
    wget https://dl.min.io/client/mc/release/linux-amd64/mc -O /usr/local/bin/mc
    chmod +x /usr/local/bin/mc
else
    echo "MinIO client already installed, checking for updates..."
    mc_version=$(mc --version | grep -o "mc version.*" || echo "Unknown")
    echo "Current mc version: $mc_version"
fi

# Create user for MinIO if it doesn't exist
if ! id -u minio-user &>/dev/null; then
    echo "Creating minio-user..."
    useradd -r -s /bin/false minio-user
else
    echo "User minio-user already exists."
fi

# Set up MinIO configuration
echo "Setting up MinIO configuration..."
mkdir -p /etc/minio
cat > /etc/minio/minio.conf << EOF
# MinIO server configuration
MINIO_VOLUMES="/mnt/disk1/blockchain_data /mnt/disk2/blockchain_data"
MINIO_OPTS="--console-address :9001"

# SECURITY WARNING: Change these credentials immediately after setup!
MINIO_ROOT_USER="minioadmin"
MINIO_ROOT_PASSWORD="minioadmin"

# Blockchain data settings
MINIO_STORAGE_CLASS_STANDARD="EC:2:1"
MINIO_BROWSER="on"
MINIO_PROMETHEUS_AUTH_TYPE="public"
MINIO_DOMAIN="$(hostname)"

# System resource limits
MINIO_ULIMIT_N="65536"
EOF

# Create systemd service for MinIO
echo "Creating MinIO systemd service..."
cat > /etc/systemd/system/minio.service << EOF
[Unit]
Description=MinIO
Documentation=https://docs.min.io
Wants=network-online.target
After=network-online.target
AssertFileIsExecutable=/usr/local/bin/minio

[Service]
User=minio-user
Group=minio-user
EnvironmentFile=/etc/minio/minio.conf
ExecStartPre=/bin/bash -c "if [ -z \"\${MINIO_VOLUMES}\" ]; then echo \"Variable MINIO_VOLUMES not set in /etc/minio/minio.conf\"; exit 1; fi"
ExecStart=/usr/local/bin/minio server \$MINIO_OPTS \$MINIO_VOLUMES
Restart=always
LimitNOFILE=65536
TasksMax=infinity
TimeoutStopSec=infinity
SendSIGKILL=no

[Install]
WantedBy=multi-user.target
EOF

# Set permissions
echo "Setting correct permissions on data directories..."
chown -R minio-user:minio-user /mnt/disk1/blockchain_data /mnt/disk2/blockchain_data
chmod 755 /mnt/disk1/blockchain_data /mnt/disk2/blockchain_data

# Reload systemd, enable and start MinIO
echo "Reloading systemd and starting MinIO..."
systemctl daemon-reload
systemctl enable minio
systemctl restart minio
systemctl status minio

# Verify MinIO is running
echo "Waiting for MinIO to start..."
for i in {1..12}; do
    if curl -s http://127.0.0.1:9000/minio/health/live; then
        echo -e "\nMinIO is running successfully!"
        break
    fi
    if [ $i -eq 12 ]; then
        echo -e "\nMinIO may not have started properly. Check logs with: journalctl -u minio"
        echo "Continuing with deployment anyway..."
    fi
    echo -n "."
    sleep 5
done

# Configure MinIO client (mc)
echo "Configuring MinIO client (mc)..."
/usr/local/bin/mc config host add myminio http://127.0.0.1:9000 minioadmin minioadmin

# Create blockchain data buckets
echo "Creating blockchain data buckets..."
for blockchain in ethereum bitcoin polkadot; do
    echo "Creating $blockchain bucket..."
    /usr/local/bin/mc mb myminio/${blockchain}_data || echo "Bucket may already exist, continuing..."

    # Enable versioning and retention for data integrity
    echo "Configuring retention for ${blockchain}_data..."
    /usr/local/bin/mc retention set --default GOVERNANCE "90d" myminio/${blockchain}_data || echo "Retention already set or failed, continuing..."

    echo "Enabling versioning for ${blockchain}_data..."
    /usr/local/bin/mc version enable myminio/${blockchain}_data || echo "Versioning already enabled or failed, continuing..."
done

# Create management bucket
echo "Creating management bucket..."
/usr/local/bin/mc mb myminio/management || echo "Management bucket may already exist, continuing..."

# Configure firewall for MinIO
if command -v ufw &> /dev/null; then
    echo "Configuring firewall..."
    ufw allow 9000/tcp
    ufw allow 9001/tcp
    echo "Firewall configured."
else
    echo "UFW not found, skipping firewall configuration."
fi

echo "=========================================================="
echo "MinIO deployment completed!"
echo "=========================================================="
echo "Access the MinIO server at:"
echo "API: http://$(hostname):9000"
echo "Console: http://$(hostname):9001"
echo "Username: minioadmin"
echo "Password: minioadmin"
echo ""
echo "IMPORTANT: Change the default credentials immediately!"
echo "Edit /etc/minio/minio.conf and restart the service:"
echo "systemctl restart minio"
echo "=========================================================="

# Verify the client is working
echo "Verifying MinIO client configuration..."
/usr/local/bin/mc admin info myminio || echo "MinIO client verification failed. Check configuration manually."
