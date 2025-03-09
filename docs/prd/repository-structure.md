# Repository Structure

This document outlines the structure of the Axol API infrastructure repository.

## Overview

The repository is organized according to Ansible best practices, with separate directories for roles, playbooks, and infrastructure configuration. Molecule is used for testing roles.

## Directory Structure

```
axol-api/
├── ansible/
│   ├── deploy_minio_complete.yaml      # Complete MinIO deployment playbook
│   ├── deploy_grafana_complete.yaml    # Complete Grafana deployment playbook
│   ├── deploy_tailscale_complete.yaml  # Complete Tailscale deployment playbook
│   ├── backup_restore_minio.yaml       # Dedicated MinIO backup/restore playbook
│   ├── group_vars/                     # Group-specific variables
│   ├── host_vars/                      # Host-specific variables
│   ├── inventory.ini                   # Inventory file
│   ├── meta/                           # Metadata directory
│   ├── roles/                          # Ansible roles
│   │   ├── minio/                      # MinIO object storage role
│   │   │   ├── defaults/               # Default variables
│   │   │   ├── files/                  # Static files
│   │   │   ├── handlers/               # Handlers
│   │   │   ├── meta/                   # Role metadata
│   │   │   ├── molecule/               # Molecule tests
│   │   │   │   ├── default/            # Default test scenario
│   │   │   │   └── distributed/        # Distributed test scenario
│   │   │   ├── tasks/                  # Role tasks
│   │   │   │   ├── main.yaml           # Main task entry point
│   │   │   │   ├── install.yaml        # MinIO server installation
│   │   │   │   ├── service.yaml        # SystemD service configuration
│   │   │   │   ├── configure.yaml      # Basic MinIO configuration
│   │   │   │   ├── client.yaml         # MinIO client installation/config
│   │   │   │   ├── disk_setup.yaml     # Disk preparation and mounting
│   │   │   │   ├── tier_setup.yaml     # Storage tier configuration
│   │   │   │   ├── ilm.yaml            # ILM policy application
│   │   │   │   ├── backup_restore.yaml # Backup and restore operations
│   │   │   │   └── expand_pool.yaml    # Storage pool expansion
│   │   │   ├── templates/              # Jinja2 templates
│   │   │   └── vars/                   # Role variables
│   │   ├── grafana/                    # Grafana monitoring role
│   │   ├── prometheus/                 # Prometheus metrics role
│   │   └── tailscale/                  # Tailscale networking role
│   ├── tasks/                          # Shared tasks (currently empty)
│   └── templates/                      # Templates for configuration files
├── docs/                               # Documentation
│   ├── minio/                          # MinIO documentation
│   │   ├── README.md                   # Main MinIO guide
│   │   ├── blockchain-data.md          # Blockchain data guide
│   │   └── tailscale-setup.md          # Tailscale guide
│   ├── tailscale/                      # Tailscale documentation
│   │   ├── tailscale-setup.md          # Tailscale setup guide
│   │   ├── tailscale-acl-README.md     # Tailscale ACL guide
│   │   └── miniaxol_tailscale_setup.md # Mini-Axol server setup
│   ├── prd/                            # Product Requirements Documents
│   │   └── README.md                   # Main PRD
│   ├── quick-start.md                  # Quick start guide
│   ├── deployment-report.md            # Deployment analysis and recommendations
│   └── repository-structure.md         # This document
├── scripts/                            # Utility scripts
│   ├── deploy_minio_local.sh           # Local MinIO deployment script
│   └── README.md                       # Scripts documentation
├── .ansible/                           # Ansible local config
├── .github/                            # GitHub workflows
├── .gitignore                          # Git ignore file
├── Gemfile                             # Ruby dependencies
├── README.md                           # Main README
└── _config.yaml                        # Configuration
```

## Consolidated Roles

The repository has been consolidated to have fewer, more comprehensive roles:

1. **MinIO Role**: Handles all MinIO-related tasks including:
   - Server installation and configuration
   - Disk setup and management
   - Client configuration
   - Storage tiering
   - ILM policy management
   - Backup and restore operations
   - Storage pool expansion

2. **Grafana Role**: Handles monitoring visualization
   - Dashboard setup
   - Data source configuration

3. **Prometheus Role**: Handles metrics collection
   - Exporter configuration
   - Alert rules

4. **Tailscale Role**: Handles secure networking
   - Installation and configuration
   - ACL management
   - Node tagging

## Playbook Structure

The playbooks have been organized to provide complete deployment options:

1. **deploy_minio_complete.yaml**: Complete MinIO deployment
2. **deploy_grafana_complete.yaml**: Complete Grafana deployment
3. **deploy_tailscale_complete.yaml**: Complete Tailscale deployment
4. **backup_restore_minio.yaml**: Dedicated backup/restore operations

Each playbook includes appropriate tags to allow selective execution of specific tasks.

## Inventory Structure

The inventory is organized to clearly define server roles:

- `minio_servers`: Servers running MinIO for object storage
- `axol_api_servers`: Servers running the Axol API
- `blockchain_nodes`: Blockchain node servers connecting to MinIO
- `compute_nodes`: Compute cluster nodes (e.g., Turing Pi)
- `grafana_targets`: Servers running Grafana dashboards
- `prometheus_targets`: Servers that should be monitored by Prometheus

## Testing Structure

Molecule is used for testing Ansible roles. Each role includes:

### Default Scenario

Tests basic role functionality:
- Single-node setup
- Default configuration
- Basic functionality tests

### Distributed Scenario

Tests distributed configuration:
- Multi-node setup
- Cluster functionality
- Failover testing

## Molecule Configuration

Each scenario includes:

1. **molecule.yml**: Defines test infrastructure
2. **converge.yml**: Applies the role
3. **verify.yml**: Validates the deployment
4. **prepare.yml** (optional): Prepares test environment

## Adding New Roles

When adding a new role:

1. Create the standard role structure
2. Add molecule directory with test scenarios
3. Include appropriate tests
4. Document in the repository structure

## CI/CD Integration

GitHub Actions workflows are configured to:
- Run linting on all roles
- Execute molecule tests
- Generate documentation

## Best Practices

- Keep roles focused on a single responsibility
- Include comprehensive tests for all roles
- Document role variables and dependencies
- Use parameterized tests where possible
- Use dedicated task files for complex functionality
- Apply consistent tagging across playbooks
