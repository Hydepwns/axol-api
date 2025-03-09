#!/bin/bash
#
# Tailscale nftables Configuration Script for MinIO Server
# This script configures nftables to allow Tailscale traffic and MinIO access
#

# Exit on error
set -e

# Must run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Try using sudo."
    exit 1
fi

echo "===== Tailscale nftables Configuration Script ====="
echo "This script will configure nftables to allow Tailscale traffic and MinIO access."
echo

# Check if Tailscale is installed and running
if ! command -v tailscale &> /dev/null; then
    echo "Error: Tailscale is not installed. Please install Tailscale first."
    exit 1
fi

# Check if tailscale0 interface exists
if ! ip link show tailscale0 &> /dev/null; then
    echo "Error: tailscale0 interface not found. Make sure Tailscale is properly connected."
    echo "Try running 'sudo tailscale up' first."
    exit 1
fi

# Check if nftables is installed
if ! command -v nft &> /dev/null; then
    echo "Installing nftables..."
    apt-get update
    apt-get install -y nftables
fi

# Backup current nftables configuration
echo "Backing up current nftables configuration..."
if [ -f /etc/nftables.conf ]; then
    cp /etc/nftables.conf /etc/nftables.conf.backup.$(date +%Y%m%d%H%M%S)
    echo "Backup saved to /etc/nftables.conf.backup.$(date +%Y%m%d%H%M%S)"
else
    echo "No existing nftables configuration found."
fi

# Create a complete nftables configuration with Tailscale rules
echo "Creating a complete nftables configuration with Tailscale rules..."
cat <<'EOF' > /etc/nftables.conf
#!/usr/sbin/nft -f

flush ruleset

table inet filter {
    chain input {
        type filter hook input priority 0; policy drop;

        # Allow established/related connections
        ct state established,related accept

        # Allow loopback
        iifname "lo" accept

        # Allow ICMP and IGMP
        ip protocol icmp accept
        ip6 nexthdr icmpv6 accept
        ip protocol igmp accept

        # Allow Tailscale traffic
        iifname "tailscale0" counter accept

        # Allow SSH
        tcp dport 22 counter accept

        # Allow MinIO ports
        tcp dport 9000 counter accept
        tcp dport 9001 counter accept
    }

    chain forward {
        type filter hook forward priority 0; policy drop;

        # Allow Tailscale forwarding
        iifname "tailscale0" counter accept
    }

    chain output {
        type filter hook output priority 0; policy accept;
    }
}
EOF

# Apply the configuration
echo "Applying nftables configuration..."
nft -f /etc/nftables.conf

# Enable and restart nftables service
echo "Enabling and restarting nftables service..."
systemctl enable nftables
systemctl restart nftables

# Verify the rules
echo
echo "Verifying tailscale-related rules:"
nft list ruleset | grep -i tailscale

echo
echo "Verifying port rules:"
nft list ruleset | grep -E 'dport (22|9000|9001)'

echo
echo "===== Configuration Complete ====="
echo "The nftables firewall has been configured to allow Tailscale traffic."
echo "Your MinIO server ports (9000, 9001) and SSH (22) should now be accessible through Tailscale."
echo
echo "To verify Tailscale connectivity, run: tailscale ping <your-client-device>"
echo
echo "If you still can't connect, try these troubleshooting steps:"
echo "1. Check if SSH service is running: systemctl status sshd"
echo "2. Check if MinIO service is running: systemctl status minio"
echo "3. Verify Tailscale is connected: tailscale status"
echo "4. Check the logs: journalctl -u tailscaled -n 50"
echo
echo "If you need to revert these changes, use the backup at /etc/nftables.conf.backup.*"
