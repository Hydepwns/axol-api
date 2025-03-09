# MinIO Deployment Guide

This guide explains how to deploy a distributed MinIO object storage system for blockchain data using Ansible.

## Overview

This deployment sets up a MinIO object storage system on a dedicated API Server to store blockchain data, with configuration for external access and monitoring. The infrastructure connects to blockchain nodes running on Mini PCs and a Turing Pi compute cluster.

### Features

- MinIO setup with erasure coding for data protection
- Configuration for storing blockchain data
- Integration with Prometheus and Grafana for monitoring
- TLS/SSL support for secure access
- Tailscale network integration for secure remote access
- Storage tiering with ILM policies for data lifecycle management
- Automated backup and restore capabilities
- Storage pool expansion for scaling capacity
- Improved installation process with better idempotency and error handling
- Automated variable validation to prevent deployment issues
- Support for multiple blockchain data types
- Configurable disk space requirements
- Dynamic port configuration
- Enhanced health checking
- Robust MinIO client (mc) installation and configuration
- Data retention and versioning for blockchain buckets
- Security validation to prevent default credentials in production
- Improved error handling with retry mechanisms

## Prerequisites

- Dedicated API Server with Ubuntu/Debian installed
- Two Mini PCs running Dappnode and Avadao
- Turing Pi cluster with compute modules
- Tailscale installed and configured on all hosts
- Sufficient storage for blockchain data
- SSH access to all hosts

## Architecture

The deployment uses the following architecture:

- **MinIO Servers**: Dedicated API Server with MinIO installation
- **Blockchain Nodes**: Mini PCs running Dappnode and Avadao
- **Compute Nodes**: Turing Pi cluster with 4 compute modules
- **Network**: Tailscale for secure networking
- **Monitoring**: Prometheus and Grafana

## Configuration

### Inventory Setup

The deployment uses an Ansible inventory file to define the servers:

```ini
[minio_servers]
mini-axol ansible_host=100.117.205.87 minio_node_id=0 ansible_user=root

[blockchain_nodes]
dravado.tail9b2ce8.ts.net  node_type=dappnode
dappnode-droo.tail9b2ce8.ts.net  node_type=avadao

[compute_nodes]
turing.tail9b2ce8.ts.net
```

### Secret Management

Sensitive information is stored in an encrypted secrets file. A template is provided at `ansible/group_vars/all/secrets_example.yml`:

```yaml
# MinIO authentication
minio_root_user: "admin"
minio_root_password: "change_me_to_a_secure_password"
minio_access_key: "optional_access_key"
minio_secret_key: "optional_secret_key"

# SSL certificates paths (for production)
minio_ssl_certificate: "/etc/minio/certs/public.crt"
minio_ssl_key: "/etc/minio/certs/private.key"

# Tailscale credentials if needed
tailscale_auth_key: "your_tailscale_auth_key"
```

Copy this template and encrypt it using:

```bash
cp ansible/group_vars/all/secrets_example.yml ansible/group_vars/all/secrets.yml
ansible-vault encrypt ansible/group_vars/all/secrets.yml
```

The deployment will automatically validate that you're not using default credentials in production environments.

### Configuration Variables

The main configuration variables are in `ansible/roles/minio/vars/main.yaml`:

```yaml
# General MinIO Configuration
minio_version: "20241218131544.0.0"
minio_user: "minio-user"
minio_group: "minio-group"

# Storage configuration
minio_directories: ["/mnt/minio"]
minio_min_disk_space_gb: 20

# Network settings
minio_server_port: 9000
minio_console_port: 9001
minio_bind_address: "0.0.0.0"

# Cluster configuration
minio_cluster_mode: false
minio_server_count: 1
minio_server_urls: ""  # For distributed mode

# Blockchain data configuration
blockchain_data_type: "ethereum"  # Legacy support
blockchain_data_types:            # Preferred approach
  - "ethereum"
  - "holesky"
  - "ephemery"
  - "optimism"
  - "arbitrum"
```

## Deployment

To deploy the MinIO cluster with all security features:

```bash
ansible-playbook -i ansible/inventory.ini ansible/deploy_minio_complete.yaml --ask-vault-pass
```

With vault password file:

```bash
ansible-playbook -i ansible/inventory.ini ansible/deploy_minio_complete.yaml --vault-password-file=~/.ansible-vault-password
```

To recreate buckets during redeployment:

```bash
ansible-playbook -i ansible/inventory.ini ansible/deploy_minio_complete.yaml --extra-vars "recreate_buckets=true"
```

### Selective Task Execution

The deployment playbook supports tags to selectively execute specific tasks:

```bash
# Just setup disks
ansible-playbook -i ansible/inventory.ini ansible/deploy_minio_complete.yaml --tags disks

# Configure tiering
ansible-playbook -i ansible/inventory.ini ansible/deploy_minio_complete.yaml --tags tier

# Apply ILM policies
ansible-playbook -i ansible/inventory.ini ansible/deploy_minio_complete.yaml --tags ilm

# Expand MinIO storage
ansible-playbook -i ansible/inventory.ini ansible/deploy_minio_complete.yaml --tags expand -e "expand_existing=true"
```

### Backup and Restore

For backup and restore operations, we have a dedicated playbook:

```bash
# Backup MinIO
ansible-playbook -i ansible/inventory.ini ansible/backup_restore_minio.yaml --tags backup

# Restore MinIO
ansible-playbook -i ansible/inventory.ini ansible/backup_restore_minio.yaml --tags restore -e "restore_file=/path/to/backup.tar.gz"
```

### MinIO Client Installation and Configuration

The deployment process now includes robust MinIO client (mc) installation:

1. **Version Checking**: Verifies if mc is already installed and checks for updates
2. **Automated Installation**: Installs the latest version with proper permissions
3. **Configuration Validation**: Tests the connection to ensure proper setup
4. **Bucket Management**: Creates and configures blockchain data buckets
5. **Data Protection**: Sets up retention policies and versioning for all buckets

You can verify the client installation with:

```bash
mc admin info myminio
```

For detailed information about the MinIO client usage, administration commands, and troubleshooting, see the [MinIO Client Guide](minio-client.md).

### Storage Tiering and ILM Policies

The deployment now supports storage tiering and Information Lifecycle Management (ILM) policies:

1. **Storage Tier Setup**:
   - Creates a separate storage tier for archive data
   - Configures a separate MinIO instance for the tier
   - Sets up proper authentication between primary and tier instances

2. **ILM Policy Application**:
   - Applies transition rules to move data to archive tier after a configurable period
   - Supports different policies for different blockchain data types
   - Automated verification of policy application

To configure tiering and ILM:

```bash
ansible-playbook -i ansible/inventory.ini ansible/deploy_minio_complete.yaml --tags "tier,ilm" -e "transition_days=90"
```

### Storage Pool Expansion

To expand storage capacity, the deployment supports adding new disks or pools:

1. **Expand Existing Pool**:
   - Adds new disks to an existing MinIO deployment
   - Maintains data integrity during expansion
   - Verifies successful expansion

2. **Create New Pool**:
   - Sets up a new, separate MinIO server pool
   - Configures proper networking between pools
   - Sets up load balancing if required

To expand storage:

```bash
ansible-playbook -i ansible/inventory.ini ansible/deploy_minio_complete.yaml --tags expand -e "expand_existing=true expand_disk_path=/mnt/disk3/blockchain_data"
```

### Local Deployment Option

For situations where Ansible deployment isn't possible, a local deployment script is provided:

```bash
bash scripts/deploy_minio_local.sh
```

This script includes:

- Interactive security warnings for default credentials
- System package updates
- MinIO server and client installation
- Service configuration with SystemD
- Bucket creation with versioning and retention policies
- Firewall configuration for proper access

### Deployment Improvements

The deployment process includes several improvements:

1. **Security Validation**:
   - Checks for default credentials in production
   - Validates password strength
   - Ensures proper SSL configuration

2. **Installation Enhancements**:
   - Version checking for both server and client
   - Idempotent installation with proper error handling
   - Disk space requirements verification

3. **Bucket Management**:
   - Support for multiple blockchain data types
   - Proper bucket versioning and retention policies
   - Improved handling of bucket recreation

4. **Connectivity**:
   - Complete configuration for blockchain nodes
   - Connectivity verification for compute cluster
   - Tailscale integration for secure access

5. **Monitoring**:
   - Detailed deployment status reporting
   - Health checks for all components
   - Verification of client functionality

## Post-Deployment

After deployment:

1. Access the MinIO console at `http://minipc1.tail9b2ce8.ts.net:9001`
2. Log in with the root credentials defined in the secrets file
3. Verify blockchain data buckets are created with proper retention and versioning
4. Check the management bucket for status information

## Accessing MinIO Externally

MinIO is configured to be accessible externally through:

1. Direct access via Tailscale domains
2. SSL/TLS encrypted connections if enabled
3. Standard S3-compatible API access on port 9000

## Blockchain Nodes Configuration

The deployment now includes proper configuration for blockchain nodes:

1. Each node gets a tailored configuration file at `/etc/minio/client.conf`
2. The configuration includes connection details and credentials
3. Node-specific settings based on the blockchain type
4. Helper functions for quick connection setup

## Compute Cluster Configuration

Compute nodes are configured with:

1. Connectivity checks to ensure they can reach the MinIO server
2. Client configuration for accessing blockchain data
3. Proper error handling and reporting for network issues

## Monitoring

The deployment includes:

1. Prometheus for metrics collection
2. Grafana for visualization
3. Default dashboards for MinIO monitoring

Access Grafana at `http://minipc1.tail9b2ce8.ts.net:3000`.

## Troubleshooting

Common issues and solutions:

- **Service not starting**: Check logs with `journalctl -u minio`
- **Access issues**: Verify firewall rules and Tailscale connectivity
- **Storage problems**: Ensure directories exist and have proper permissions
- **Client configuration failures**: Check `/root/.mc/config.json` and verify credentials
- **Bucket creation issues**: Check for existing buckets with `mc ls myminio`
- **Security validation failures**: Ensure you're using secure credentials in vault files

## Related Documentation

- [MinIO Client Guide](minio-client.md): Detailed instructions for using the MinIO client
- [Blockchain Data Management](blockchain-data.md): Information about blockchain data handling

## Backup and Recovery

### Automated Backup

A dedicated playbook is available for backing up and restoring MinIO configuration:

```bash
# Backup MinIO configuration and data
ansible-playbook -i ansible/inventory.ini ansible/backup_restore_minio.yaml
```

This will create a backup including:

- MinIO service configuration files
- MinIO client configuration
- Essential system settings
- Bucket policies and retention settings

By default, backups are stored in `/tmp/minio_backup_<timestamp>.tar.gz` and then moved to a remote backup location if specified.

### Custom Backup Location

You can specify a custom backup location:

```bash
ansible-playbook -i ansible/inventory.ini ansible/backup_restore_minio.yaml -e "remote_backup_location=/path/to/backup/storage"
```

### Restoring from Backup

To restore MinIO from a backup:

```bash
ansible-playbook -i ansible/inventory.ini ansible/backup_restore_minio.yaml --tags restore -e "restore_file=/path/to/minio_backup.tar.gz"
```

The restore process:

1. Extracts the backup archive
2. Stops the MinIO service
3. Restores configuration files
4. Restores MinIO client configuration
5. Restarts the MinIO service
6. Verifies the restoration was successful

For data backup, MinIO's built-in replication features are recommended for production environments alongside the retention policies and versioning now enabled by default.
