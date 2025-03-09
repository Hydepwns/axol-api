#!/bin/bash
#
# Grafana Docker Installation Script
# ----------------------------------
# Run this script as root on the target server
#

set -e

echo "================================================="
echo "Grafana Docker Installation Script"
echo "================================================="

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

echo "Updating package lists..."
apt-get update

echo "Installing Docker and dependencies..."
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

echo "Adding Docker GPG key..."
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "Adding Docker repository..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "Updating package lists with Docker repository..."
apt-get update

echo "Installing Docker..."
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

echo "Creating Grafana directories..."
mkdir -p /opt/grafana/data
mkdir -p /opt/grafana/config

echo "Creating docker-compose.yml file..."
cat > /opt/grafana/docker-compose.yml << EOF
version: '3'

services:
  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - ./data:/var/lib/grafana
    restart: always
EOF

echo "Starting Grafana container..."
cd /opt/grafana
docker compose up -d

echo "Waiting for Grafana to start..."
sleep 10

echo "Checking Docker container status..."
docker ps | grep grafana

echo "Verifying Grafana API health..."
curl -s http://localhost:3000/api/health

echo "================================================="
echo "Grafana Docker installation completed!"
echo "Access Grafana at: http://$(hostname -f):3000"
echo "Default username: admin"
echo "Default password: admin"
echo "================================================="

# Display listening ports
echo "Listening ports:"
ss -tuln | grep :3000
