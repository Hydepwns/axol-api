#!/bin/bash
#
# Grafana Installation Script
# ---------------------------
# Run this script as root on the target server
#

set -e

echo "================================================="
echo "Grafana Server Installation Script"
echo "================================================="

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Check if Grafana is already installed and running
if systemctl is-active grafana-server; then
  echo "Grafana is already running on this system. Aborting to prevent disruption."
  exit 1
fi

echo "Updating package lists..."
apt-get update

echo "Installing dependencies..."
apt-get install -y apt-transport-https software-properties-common curl gnupg

echo "Adding Grafana GPG key..."
curl -fsSL https://packages.grafana.com/gpg.key | gpg --dearmor -o /usr/share/keyrings/grafana-archive-keyring.gpg

echo "Adding Grafana repository..."
echo "deb [signed-by=/usr/share/keyrings/grafana-archive-keyring.gpg] https://packages.grafana.com/oss/deb stable main" | tee /etc/apt/sources.list.d/grafana.list

echo "Updating package lists with Grafana repository..."
apt-get update

echo "Installing Grafana..."
apt-get install -y grafana

echo "Starting Grafana service..."
systemctl start grafana-server
systemctl enable grafana-server

echo "Waiting for Grafana to start..."
sleep 10

echo "Checking Grafana status..."
systemctl status grafana-server --no-pager

echo "Verifying Grafana API health..."
curl -s http://localhost:3000/api/health

echo "================================================="
echo "Grafana installation completed!"
echo "Access Grafana at: http://$(hostname -f):3000"
echo "Default username: admin"
echo "Default password: admin"
echo "================================================="

# Display listening ports
echo "Listening ports:"
ss -tuln | grep :3000
