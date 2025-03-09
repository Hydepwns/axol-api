# MinIO Client (mc) Installation and Usage

This document covers the installation, configuration, and usage of the MinIO Client (mc) for administering MinIO object storage in the Axol infrastructure.

## Overview

The MinIO Client (mc) is a command-line tool that provides a modern alternative to UNIX commands like ls, cat, cp, mirror, diff, etc. It supports filesystems and Amazon S3-compatible cloud storage services like MinIO.

In the Axol API infrastructure, we use mc to:

1. Administer the MinIO server
2. Create and manage buckets for blockchain data
3. Set up retention policies and versioning
4. Perform health checks and monitoring
5. Enable client access from blockchain nodes and compute clusters

## Automated Installation

The Ansible playbook automatically installs and configures the MinIO client with the following enhancements:

1. **Version Checking**: Determines if mc is already installed and if an update is available
2. **Robust Download**: Uses retry mechanisms to ensure reliable installation
3. **Proper Permissions**: Sets executable permissions for all users
4. **Configuration Verification**: Tests connectivity after configuration

The installation task (in `ansible/roles/minio/tasks/client.yaml`) includes:

```yaml
- name: Check if mc (MinIO client) is already installed
  ansible.builtin.command: mc --version
  register: mc_installed
  changed_when: false
  failed_when: false

- name: Get latest MinIO client version
  ansible.builtin.uri:
    url: https://dl.min.io/client/mc/release/linux-amd64/mc.latest.version
    return_content: yes
  register: mc_latest_version
  failed_when: false
  when: mc_installed.rc != 0 or 'upgrade' in mc_installed.stdout

- name: Install mc (MinIO client) for administration
  ansible.builtin.get_url:
    url: https://dl.min.io/client/mc/release/linux-amd64/mc
    dest: /usr/local/bin/mc
    mode: '0755'
  register: mc_download
  retries: 3
  delay: 5
  until: mc_download is not failed
  when: mc_installed.rc != 0 or 'upgrade' in mc_installed.stdout
```

## Client Configuration

After installation, the MinIO client is configured to connect to the local or remote MinIO server:

```yaml
- name: Configure mc
  ansible.builtin.command: >
    mc config host add myminio
    http://127.0.0.1:{{ minio_server_port }}
    {{ minio_root_user }} {{ minio_root_password }}
  args:
    creates: /root/.mc/config.json
  register: mc_config
  retries: 3
  delay: 10
  until: mc_config is not failed
```

This creates a configuration alias called `myminio` that can be used in all subsequent commands.

The configuration is verified with:

```yaml
- name: Verify mc configuration
  ansible.builtin.command: mc admin info myminio
  register: mc_verify
  retries: 3
  delay: 5
  until: mc_verify is not failed
```

## Bucket Management

The Ansible playbook automatically creates and configures buckets for each blockchain data type:

### Creating Buckets

```yaml
- name: Create blockchain data bucket
  ansible.builtin.command: >
    mc mb myminio/{{ item }}_data
  args:
    creates: "/tmp/bucket_{{ item }}_created"
  register: bucket_created
  with_items: "{{ blockchain_data_types | default([blockchain_data_type]) | list }}"
  when: >
    (blockchain_data_type is defined or blockchain_data_types is defined) and
    ((recreate_buckets | default(false)) or
     (item ~ '_data' not in existing_buckets.stdout))
```

### Configuring Retention Policies

Data retention policies ensure blockchain data is preserved for a specified period:

```yaml
- name: Set bucket retention to ensure data persistence
  ansible.builtin.command: >
    mc retention set --default GOVERNANCE "90d" myminio/{{ item }}_data
  register: bucket_retention
  with_items: "{{ blockchain_data_types | default([blockchain_data_type]) | list }}"
```

### Enabling Versioning

Versioning prevents accidental deletion and keeps history of changes:

```yaml
- name: Enable bucket versioning
  ansible.builtin.command: >
    mc version enable myminio/{{ item }}_data
  register: bucket_versioning
  with_items: "{{ blockchain_data_types | default([blockchain_data_type]) | list }}"
```

## Manual Installation

If you need to install the MinIO client manually:

```bash
# Download mc
wget https://dl.min.io/client/mc/release/linux-amd64/mc -O /usr/local/bin/mc

# Make it executable
chmod +x /usr/local/bin/mc

# Configure (replace with your actual credentials and endpoint)
mc config host add myminio http://your-minio-server:9000 your-access-key your-secret-key
```

## Common Usage Examples

### Administrative Commands

```bash
# List all buckets
mc ls myminio

# Check server information
mc admin info myminio

# Server diagnostics
mc admin diagnostic myminio

# Display MinIO server health
mc admin health myminio
```

### Bucket and Object Management

```bash
# List objects in a bucket
mc ls myminio/ethereum_data

# Copy a file to MinIO
mc cp local-file.json myminio/ethereum_data/

# Make a bucket public (if needed)
mc policy set download myminio/public-data

# Check bucket size
mc du myminio/ethereum_data
```

### Retention and Versioning

```bash
# Check current retention settings
mc retention info myminio/ethereum_data

# List versions of an object
mc ls --versions myminio/ethereum_data/block-1234.json

# Restore a previous version
mc cp --rewind 7d myminio/ethereum_data/block-1234.json ./restored-block.json
```

## Client Configuration on Remote Nodes

The Ansible playbook creates a configuration file at `/etc/minio/client.conf` on all blockchain nodes and compute nodes. This configuration includes:

1. Connection details for the MinIO server
2. Authentication credentials
3. Protocol (HTTP/HTTPS) settings
4. Node-specific bucket information

Example:

```bash
# MinIO Client Configuration for blockchain-node-1
# Generated by Ansible - Do not edit manually

# Connection details for MinIO server
MINIO_SERVER=mini-axol.tail9b2ce8.ts.net
MINIO_SERVER_PORT=9000
MINIO_CONSOLE_PORT=9001

# Credentials
MINIO_ACCESS_KEY=your-access-key
MINIO_SECRET_KEY=your-secret-key

# Connection protocol
MINIO_PROTOCOL=http

# Client configuration
MINIO_API_URL=${MINIO_PROTOCOL}://${MINIO_SERVER}:${MINIO_SERVER_PORT}
MINIO_CONSOLE_URL=${MINIO_PROTOCOL}://${MINIO_SERVER}:${MINIO_CONSOLE_PORT}

# Node-specific settings
NODE_TYPE=dappnode
BLOCKCHAIN_DATA_TYPES=ethereum,holesky,ephemery,optimism,arbitrum
```

The configuration also includes a helper function to quickly set up the MinIO client:

```bash
# Example shell function to quickly connect to MinIO with mc
# Add to /etc/profile.d/minio-client.sh:
function mcsetup() {
  mc config host add myminio ${MINIO_API_URL} ${MINIO_ACCESS_KEY} ${MINIO_SECRET_KEY}
  echo "MinIO client configured for ${MINIO_API_URL}"
}
```

## Security Considerations

1. **Credential Management**:
   - Never use default credentials in production
   - Use Ansible Vault to secure all sensitive information
   - Change credentials using `mc admin user` commands if needed

2. **Access Control**:
   - MinIO supports fine-grained access control
   - Use `mc admin policy` to create custom policies
   - Assign policies to users with `mc admin policy set`

3. **SSL/TLS**:
   - For secure connections, enable SSL in the MinIO configuration
   - Update client configuration to use HTTPS protocol

## Troubleshooting

Common issues and their solutions:

1. **Connection Problems**:

   ```bash
   # Check connectivity
   telnet mini-axol.tail9b2ce8.ts.net 9000

   # Verify configuration
   cat /root/.mc/config.json
   ```

2. **Authentication Issues**:

   ```bash
   # Reset configuration
   rm /root/.mc/config.json
   mc config host add myminio http://your-server:9000 your-access-key your-secret-key
   ```

3. **Permission Problems**:

   ```bash
   # Verify executable permissions
   ls -la /usr/local/bin/mc
   chmod +x /usr/local/bin/mc
   ```

## Further Resources

- [Official MinIO Client Documentation](https://min.io/docs/minio/linux/reference/minio-mc.html)
- [MinIO Client GitHub Repository](https://github.com/minio/mc)
- [MinIO Client Cookbook](https://min.io/docs/minio/linux/reference/minio-mc/mc-cookbook.html)
