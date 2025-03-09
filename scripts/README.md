# Utility Scripts

This directory contains utility scripts for the Axol-API project.

## Available Scripts

### Tailscale Configuration

- **`setup_miniaxol_ssh.sh`**: Comprehensive setup script for Mini-Axol server
  - Installs and configures OpenSSH
  - Sets up firewall rules
  - Applies Tailscale tags
  - Verifies the configuration

  Usage:
  ```bash
  # Copy to server
  scp setup_miniaxol_ssh.sh root@mini-axol:/tmp/

  # Execute on server
  ssh root@mini-axol "chmod +x /tmp/setup_miniaxol_ssh.sh && /tmp/setup_miniaxol_ssh.sh"
  ```

- **`fix_mini_axol_acl.sh`**: Fixes SSH access issues on Mini-Axol
  - Resets Tailscale configuration
  - Applies proper tags for ACL-based access
  - Verifies SSH configuration

  Usage:
  ```bash
  # Run directly on the mini-axol server
  sudo ./fix_mini_axol_acl.sh
  ```

### Grafana Installation

- **`install-grafana.sh`**: Installs Grafana directly on the host
  - Sets up repositories
  - Installs dependencies
  - Configures the service

  Usage:
  ```bash
  sudo ./install-grafana.sh
  ```

- **`install-grafana-docker.sh`**: Installs Grafana using Docker
  - Installs Docker if needed
  - Pulls Grafana image
  - Sets up persistent storage
  - Configures the container

  Usage:
  ```bash
  sudo ./install-grafana-docker.sh
  ```

## Adding New Scripts

When adding new scripts:

1. Use clear, descriptive naming
2. Include comprehensive comments
3. Add error handling
4. Document in this README
5. Make scripts executable (`chmod +x script.sh`)
