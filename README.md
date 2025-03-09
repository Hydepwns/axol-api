# Axol API Infrastructure

This repository contains infrastructure configurations and deployment scripts for the Axol API ecosystem.

## Components

### MinIO Object Storage

A MinIO setup for blockchain data storage on a dedicated API Server.

- [MinIO Deployment Documentation](docs/minio/README.md)
- [Blockchain Data Management](docs/minio/blockchain-data.md)
- **Recent Improvements**:
  - Enhanced idempotent deployments
  - Better variable validation
  - Improved error handling in MinIO client configuration
  - Automated backup and restore capabilities
  - Support for multiple blockchain data types
  - Configurable system requirements
  - Robust MinIO client installation and version checking
  - Advanced bucket management with versioning and retention policies
  - Security validation preventing default credentials in production
  - Improved connectivity for blockchain nodes and compute clusters
  - Local deployment option for emergency scenarios
  - Dedicated backup/restore playbook
  - Consolidated roles with comprehensive task organization
  - Storage tier setup with ILM policies
  - Pool expansion capabilities

### Tailscale Networking

Secure networking between all components using Tailscale.

- [Tailscale Setup Guide](docs/tailscale/tailscale-setup.md)
- [ACL Configuration](docs/tailscale/tailscale-acl-README.md)
- [Mini-Axol Server Setup](docs/tailscale/miniaxol_tailscale_setup.md)

### Deployment Options

The infrastructure includes several deployment options:

1. **MinIO Storage**
   - Dedicated API Server with MinIO installation
   - Erasure coding for data protection
   - Prometheus and Grafana monitoring
   - Blockchain-specific buckets with retention policies
   - Secure credential management with Ansible Vault
   - Automated ILM policies for data lifecycle management
   - Storage tiering for cost-effective long-term storage
   - Backup and restore functionality

2. **Blockchain Nodes**
   - Mini PC 1 running Dappnode
   - Mini PC 2 running Avadao
   - Tailscale networking
   - Automated client configuration for MinIO access

3. **Compute Nodes**
   - Turing Pi cluster with 4 compute modules
   - Distributed processing capabilities
   - MinIO client connectivity verification

## Documentation

- [Complete Documentation](docs/README.md): Overview of all documentation
- [Product Requirements](docs/prd/README.md): Detailed project specifications
- [Repository Structure](docs/repository-structure.md): Codebase organization
- [Utility Scripts](scripts/README.md): Available automation scripts
- [Quick Start Guide](docs/quick-start.md): Fast deployment instructions
- [Deployment Report](docs/deployment-report.md): Analysis and recommendations

## Repository Structure

The repository is organized by component with clear separation between code, documentation, and infrastructure. For a detailed overview of the directory structure and organization, see the [Repository Structure](docs/repository-structure.md) document.

## Testing

All Ansible roles include Molecule tests to ensure functionality and reliability:

```bash
# Run tests for the MinIO role
cd ansible/roles/minio
molecule test
```

To run specific test scenarios:

```bash
# Test single-node setup
molecule test -s default

# Test distributed setup
molecule test -s distributed
```

## Getting Started

### Prerequisites

- Ansible 2.9+
- Target machines running Ubuntu/Debian
- SSH access to all target machines
- Tailscale installed on all hosts
- Minimum system requirements:
  - 20GB disk space (configurable)
  - 2GB RAM minimum
  - Network access for ports 9000 and 9001 (configurable)

### Environment Preparation

Before deployment, ensure:

1. All target machines have base OS installed and SSH access configured
2. Tailscale is installed and configured on all hosts
3. Storage volumes are prepared for blockchain data
4. Create and encrypt your secrets file from the provided template:
   ```bash
   cp ansible/group_vars/all/secrets_example.yml ansible/group_vars/all/secrets.yml
   ansible-vault encrypt ansible/group_vars/all/secrets.yml
   ```

### Deployment

Deploy MinIO object storage for blockchain data:

```bash
# Using Ansible Vault password prompt
ansible-playbook -i ansible/inventory.ini ansible/deploy_minio_complete.yaml --ask-vault-pass

# Using Ansible Vault password file
ansible-playbook -i ansible/inventory.ini ansible/deploy_minio_complete.yaml --vault-password-file=~/.ansible-vault-password
```

For emergency local deployment without Ansible:

```bash
bash scripts/deploy_minio_local.sh
```

### Backup and Recovery

The infrastructure includes comprehensive backup and restore capabilities:

```bash
# Create a MinIO configuration backup
ansible-playbook -i ansible/inventory.ini ansible/backup_restore_minio.yaml --tags backup

# Restore from a backup file
ansible-playbook -i ansible/inventory.ini ansible/backup_restore_minio.yaml --tags restore -e "restore_file=/path/to/backup.tar.gz"
```

See the [MinIO documentation](docs/minio/README.md) for detailed backup and recovery procedures.

## Security

All sensitive information is stored in encrypted Ansible Vault files. The deployment process includes automatic validation to prevent using default credentials in production. See the [MinIO documentation](docs/minio/README.md) for details on managing secrets.

## Architecture

The infrastructure uses a Tailscale-based network for secure communication between components:

```ruby
┌─────────────┐     ┌─────────────┐
│  Mini PC 1  │     │  Mini PC 2  │
│  (Dappnode) │◄────►  (Avadao)   │
└─────┬───────┘     └─────┬───────┘
      │                   │
      │    Tailscale      │
      │    Network        │
      │                   │
┌─────▼───────┐     ┌─────▼───────┐
│ Turing      │     │ API Server  │
│ Pi x 4      │◄────► Minio       │
└─────────────┘     └─────────────┘
```

## Recent Updates

- **Documentation Improvements**:
  - Added [Quick Start Guide](docs/quick-start.md) for streamlined deployment
  - Created [Deployment Report](docs/deployment-report.md) with analysis and recommendations
  - Enhanced troubleshooting documentation

- **Infrastructure Enhancements**:
  - Consolidated MinIO-related functionality into a single comprehensive role
  - Implemented dedicated backup and restore playbook
  - Added storage tiering and ILM policy capabilities
  - Improved error handling across all playbooks
  - Added more robust health checks for services
  - Enhanced network validation between components

## Known Issues and Solutions

For a comprehensive list of known issues and their solutions, please refer to the [Deployment Report](docs/deployment-report.md).

## Contribution

To contribute to this infrastructure:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

See the LICENSE file for details.
