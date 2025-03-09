# Axolotl Analytics Ansible Configuration

This directory contains Ansible roles and playbooks for deploying and managing the Axolotl Analytics infrastructure.

## Directory Structure

```bash
ansible/
├── deploy_grafana_complete.yaml     # Complete Grafana deployment playbook
├── deploy_minio_complete.yaml       # Complete MinIO deployment playbook
├── deploy_tailscale_complete.yaml   # Complete Tailscale deployment playbook
├── backup_restore_minio.yaml        # Dedicated MinIO backup/restore playbook
├── group_vars/                      # Group-specific variables
├── host_vars/                       # Host-specific variables
├── inventory.ini                    # Inventory file
├── meta/                            # Metadata directory
├── roles/                           # Ansible roles
│   ├── grafana/                     # Grafana monitoring role
│   ├── minio/                       # MinIO object storage role
│   │   ├── tasks/                   # MinIO role tasks
│   │   │   ├── main.yaml            # Main task entry point
│   │   │   ├── install.yaml         # MinIO server installation
│   │   │   ├── service.yaml         # SystemD service configuration
│   │   │   ├── configure.yaml       # Basic MinIO configuration
│   │   │   ├── client.yaml          # MinIO client installation/config
│   │   │   ├── disk_setup.yaml      # Disk preparation and mounting
│   │   │   ├── tier_setup.yaml      # Storage tier configuration
│   │   │   ├── ilm.yaml             # ILM policy application
│   │   │   ├── backup_restore.yaml  # Backup and restore operations
│   │   │   └── expand_pool.yaml     # Storage pool expansion
│   ├── prometheus/                  # Prometheus metrics role
│   └── tailscale/                   # Tailscale networking role
├── tasks/                           # Shared tasks (currently empty)
└── templates/                       # Templates for configuration files
```

## Consolidated Roles

We have consolidated our Ansible setup to use the following main roles:

| Role | Purpose | Main Playbook |
|------|---------|--------------|
| `minio` | Object storage for blockchain data | `deploy_minio_complete.yaml` |
| `grafana` | Monitoring dashboards | `deploy_grafana_complete.yaml` |
| `prometheus` | Metrics collection | (Used with Grafana) |
| `tailscale` | Secure networking | `deploy_tailscale_complete.yaml` |

## Deployment Playbooks

### MinIO Deployment

```bash
# Full MinIO deployment
ansible-playbook -i inventory.ini deploy_minio_complete.yaml

# Just setup disks
ansible-playbook -i inventory.ini deploy_minio_complete.yaml --tags disks

# Configure tiering
ansible-playbook -i inventory.ini deploy_minio_complete.yaml --tags tier

# Apply ILM policies
ansible-playbook -i inventory.ini deploy_minio_complete.yaml --tags ilm
```

### MinIO Backup and Restore

For backup and restore operations, we have a dedicated playbook:

```bash
# Backup MinIO
ansible-playbook -i inventory.ini backup_restore_minio.yaml --tags backup

# Restore MinIO
ansible-playbook -i inventory.ini backup_restore_minio.yaml --tags restore -e "restore_file=/path/to/backup.tar.gz"
```

You can also use the MinIO role directly with appropriate tags:

```bash
# Backup MinIO with the role
ansible-playbook -i inventory.ini deploy_minio_complete.yaml --tags backup -e "minio_backup=true"

# Restore MinIO with the role
ansible-playbook -i inventory.ini deploy_minio_complete.yaml --tags restore -e "restore_backup=/path/to/backup.tar.gz"

# Expand MinIO storage
ansible-playbook -i inventory.ini deploy_minio_complete.yaml --tags expand -e "expand_existing=true"
```

### Grafana Deployment

```bash
# Full Grafana deployment
ansible-playbook -i inventory.ini deploy_grafana_complete.yaml

# Only setup datasources
ansible-playbook -i inventory.ini deploy_grafana_complete.yaml --tags datasources
```

### Tailscale Deployment

```bash
# Full Tailscale deployment
ansible-playbook -i inventory.ini deploy_tailscale_complete.yaml

# Only apply tags to existing installations
ansible-playbook -i inventory.ini deploy_tailscale_complete.yaml --tags apply_tags
```

## Role Variables

Each role has its own set of variables. See the README.md in each role directory for details:

- [MinIO Role Documentation](roles/minio/README.md)
- [Grafana Role Documentation](roles/grafana/README.md)
- [Prometheus Role Documentation](roles/prometheus/README.md)
- [Tailscale Role Documentation](roles/tailscale/README.md)

## Inventory Groups

The following inventory groups are used:

- `minio_servers`: Servers running MinIO for object storage
- `axol_api_servers`: Servers running the Axol API
- `blockchain_nodes`: Blockchain node servers connecting to MinIO
- `compute_nodes`: Compute cluster nodes (e.g., Turing Pi)
- `grafana_targets`: Servers running Grafana dashboards
- `prometheus_targets`: Servers that should be monitored by Prometheus

## Common Variables

Some variables are shared across multiple roles:

- `ansible_env`: Environment designation (`development`, `staging`, `production`)
- `blockchain_data_types`: Types of blockchain data to process (`ethereum`, `holesky`, etc.)
- `minio_data_dirs`: Directories used for MinIO storage across roles

## Tags Reference

| Role | Tag | Description |
|------|-----|-------------|
| MinIO | `setup`, `disks` | Disk preparation and mounting |
| MinIO | `install` | MinIO server installation |
| MinIO | `service` | SystemD service configuration |
| MinIO | `configure` | Basic MinIO configuration |
| MinIO | `client` | MinIO client setup |
| MinIO | `tier` | Storage tier configuration |
| MinIO | `ilm` | ILM policy application |
| MinIO | `backup` | Backup MinIO configuration and data |
| MinIO | `restore` | Restore MinIO from a backup |
| MinIO | `expand` | Expand MinIO storage with additional disks/pools |
| MinIO | `verification` | Verify installation and configuration |
| Grafana | `datasources` | Configure Grafana data sources |
| Grafana | `dashboards` | Setup Grafana dashboards |
| Tailscale | `apply_tags` | Apply tags to Tailscale nodes |

## Author Information

Axolotl Analytics Team
