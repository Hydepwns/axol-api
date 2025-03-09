# Tailscale Configuration

This directory contains documentation for Tailscale networking setup in the Axol-API project.

## Documentation Files

- **[Tailscale Setup](./tailscale-setup.md)**: General guide for configuring Tailscale with MinIO
  - Installation instructions
  - Network configuration
  - Security settings
  - MinIO integration

- **[ACL Configuration](./tailscale-acl-README.md)**: Detailed guide for Tailscale access control
  - ACL structure
  - User groups
  - Host mapping
  - SSH access rules
  - Tag-based permissions

- **[Mini-Axol Setup](./miniaxol_tailscale_setup.md)**: Specific setup for the Mini-Axol server
  - Prerequisites
  - Step-by-step configuration
  - Tag application
  - Troubleshooting

## Related Files

- **Configuration**: `tailscale-acl.json` (root directory)
- **Scripts**:
  - `scripts/setup_miniaxol_ssh.sh`: Configure SSH and Tailscale on Mini-Axol
  - `scripts/fix_mini_axol_acl.sh`: Fix ACL issues on Mini-Axol
- **Ansible**:
  - `ansible/deploy_tailscale.yaml`: Deploy Tailscale
  - `ansible/deploy_tailscale_local.yaml`: Local deployment
  - `ansible/apply_tailscale_tags.yaml`: Apply tags to hosts

## Quick Start

1. Read [Tailscale Setup](./tailscale-setup.md) for basic configuration
2. Configure ACLs using [ACL Configuration](./tailscale-acl-README.md)
3. For Mini-Axol server, follow [Mini-Axol Setup](./miniaxol_tailscale_setup.md)
