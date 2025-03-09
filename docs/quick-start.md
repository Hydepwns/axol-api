# Axol API Infrastructure Quick Start Guide

This guide provides streamlined instructions for deploying the Axol API Infrastructure.

## Prerequisites

### System Requirements
- Target machines running Ubuntu/Debian Linux
- Minimum 20GB storage space on each node
- 2GB RAM minimum
- SSH access to all target machines
- Tailscale installed on all hosts

### Local Development Environment
1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/axol-api.git
   cd axol-api
   ```

2. Install required dependencies:
   ```bash
   pip install -r requirements.txt
   ansible-galaxy collection install community.general>=7.0.0
   ```

## Deployment Steps

### 1. Configure Your Environment

1. Set up your inventory file with your actual hosts:
   ```bash
   # Edit the inventory.ini file with your actual hosts
   vi ansible/inventory.ini
   ```

2. Create and encrypt your secrets file:
   ```bash
   cp ansible/group_vars/all/secrets_example.yml ansible/group_vars/all/secrets.yml

   # Edit the secrets file with your actual credentials
   vi ansible/group_vars/all/secrets.yml

   # Encrypt the secrets file
   ansible-vault encrypt ansible/group_vars/all/secrets.yml
   ```

### 2. Deploy Infrastructure

#### Option 1: Full Deployment with Ansible

Deploy the complete infrastructure with a single command:

```bash
# Deploy with password prompt
ansible-playbook -i ansible/inventory.ini ansible/deploy_minio.yaml --ask-vault-pass

# OR use a password file
ansible-playbook -i ansible/inventory.ini ansible/deploy_minio.yaml --vault-password-file=~/.ansible-vault-password
```

#### Option 2: Step-by-Step Deployment

1. Deploy Tailscale network first:
   ```bash
   ansible-playbook -i ansible/inventory.ini ansible/deploy_tailscale.yaml --ask-vault-pass
   ```

2. Deploy MinIO object storage:
   ```bash
   ansible-playbook -i ansible/inventory.ini ansible/deploy_minio.yaml --ask-vault-pass
   ```

3. Deploy Grafana monitoring (optional):
   ```bash
   ansible-playbook -i ansible/inventory.ini ansible/deploy_grafana.yaml --ask-vault-pass
   ```

#### Option 3: Emergency Local Deployment

If you need to deploy directly on the server without Ansible:

```bash
bash scripts/deploy_minio_local.sh
```

**Security Warning**: The local deployment script uses default credentials. Change them immediately after deployment!

### 3. Verify Deployment

1. Access the MinIO console:
   ```
   http://<your-minio-server>:9001
   ```

2. Check bucket creation:
   ```bash
   # On the MinIO server
   mc ls myminio
   ```

3. Verify all services are running:
   ```bash
   systemctl status minio
   systemctl status grafana-server  # If deployed
   ```

## Common Operations

### Backup and Recovery

Create a backup:
```bash
ansible-playbook -i ansible/inventory.ini ansible/backup_restore_minio.yaml --tags backup --ask-vault-pass
```

Restore from backup:
```bash
ansible-playbook -i ansible/inventory.ini ansible/backup_restore_minio.yaml --tags restore -e "restore_file=/path/to/backup.tar.gz" --ask-vault-pass
```

### Troubleshooting

#### MinIO Connectivity Issues
```bash
# Check MinIO service status
systemctl status minio

# Check logs
journalctl -u minio -n 100 --no-pager

# Verify network connectivity
curl -s http://127.0.0.1:9000/minio/health/live
```

#### Tailscale Network Issues
```bash
# Check Tailscale connection
tailscale status

# Test connectivity to other nodes
ping <tailscale-hostname>
```

## Security Best Practices

1. **Change Default Credentials**: Immediately change default credentials after deployment
2. **Enable SSL/TLS**: Configure SSL certificates for production deployments
3. **Regular Backups**: Schedule regular backups of your MinIO configuration
4. **Update Regularly**: Keep all components updated to the latest secure versions

## Next Steps

- Configure additional blockchain data buckets
- Set up custom monitoring dashboards
- Implement automated backup schedules
- Check the full documentation for advanced configuration options

For more detailed information, refer to the [complete documentation](docs/README.md) and [deployment report](docs/deployment-report.md).
