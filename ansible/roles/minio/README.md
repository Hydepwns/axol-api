# MinIO Ansible Role

This role provides a comprehensive setup for MinIO object storage, including:

- Installation and basic configuration
- Disk setup and mounting
- Service management
- Client (mc) setup
- Storage tiering for data lifecycle management
- Information Lifecycle Management (ILM) policy application
- Backup and restore operations
- Storage pool expansion

## Requirements

- Ansible 2.9 or higher
- Linux host with SystemD
- Sufficient disk space for object storage

## Role Variables

### Basic Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `minio_install` | Whether to install MinIO server | `true` |
| `minio_configure` | Whether to configure MinIO server | `true` |
| `minio_configure_service` | Whether to configure the MinIO systemd service | `true` |
| `minio_setup_client` | Whether to install and configure MinIO client (mc) | `true` |
| `minio_server_url` | MinIO server URL | `http://localhost:9000` |
| `minio_console_url` | MinIO console URL | `http://localhost:9001` |
| `minio_access_key` | MinIO root user access key | `minioadmin` |
| `minio_secret_key` | MinIO root user secret key | `minioadmin` |

### Disk Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `minio_setup_disks` | Whether to format and mount disks | `true` |
| `disk_devices` | List of disk devices to format and mount | `["/dev/sda", "/dev/sdb"]` |
| `mount_points` | List of mount points for disks | `["/mnt/disk1", "/mnt/disk2"]` |
| `data_dir_name` | Directory name for storing MinIO data | `"blockchain_data"` |
| `additional_disk` | Optional additional disk for tier storage | Not defined |
| `additional_mount` | Mount point for additional disk | `"/mnt/disk3"` |

### Tier and ILM Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `minio_setup_tier` | Whether to setup a MinIO storage tier | `false` |
| `minio_apply_ilm` | Whether to apply ILM policies | `false` |
| `tier_name` | Name for the storage tier | `"ARCHIVE-TIER"` |
| `tier_port` | Port for the tier MinIO instance | `9010` |
| `tier_console_port` | Console port for tier MinIO instance | `9011` |
| `transition_days` | Days after which data transitions to archive tier | `90` |
| `minio_buckets` | List of buckets to create and configure | `["arbitrumdata", "ethereumdata", "holeskydata", "optimismdata", "ephemerydata", "management"]` |

### Backup and Restore Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `minio_backup` | Whether to perform a backup | `false` |
| `backup_timestamp` | Timestamp for the backup | Current time |
| `backup_dir` | Temporary directory for the backup | `/tmp/minio_backup_<timestamp>` |
| `backup_file` | Archive file for the backup | `/tmp/minio_backup_<timestamp>.tar.gz` |
| `remote_backup_location` | Where to store backups | `/mnt/backups` |
| `backup_config_only` | Whether to backup only configuration files | `false` |
| `restore_backup` | Path to backup file to restore | Not defined |

### Storage Expansion

| Variable | Description | Default |
|----------|-------------|---------|
| `create_new_pool` | Whether to create a new MinIO server pool | `false` |
| `expand_existing` | Whether to expand an existing pool with new disk | `false` |
| `pool_name` | Name for the new server pool | `"new-pool"` |
| `pool_port` | Base port for the new server pool | `9020` |
| `pool_console_port` | Console port for the new server pool | `9021` |
| `expand_disk_path` | Path to the new disk/directory to add | `/mnt/disk3/blockchain_data` |

## Role Structure

- `tasks/main.yaml`: Main entrypoint
- `tasks/install.yaml`: MinIO server installation
- `tasks/service.yaml`: SystemD service configuration
- `tasks/configure.yaml`: Basic MinIO configuration
- `tasks/client.yaml`: MinIO client installation and configuration
- `tasks/disk_setup.yaml`: Disk preparation and mounting
- `tasks/tier_setup.yaml`: Storage tier configuration
- `tasks/ilm.yaml`: ILM policy application
- `tasks/backup_restore.yaml`: Backup and restore operations
- `tasks/expand_pool.yaml`: Storage pool expansion

## Example Playbook

```yaml
# Basic MinIO deployment
- name: Deploy MinIO with basic configuration
  hosts: minio_servers
  become: true
  vars:
    minio_access_key: "secure_access_key"
    minio_secret_key: "secure_secret_key"
  roles:
    - role: minio

# MinIO with tiering and ILM
- name: Deploy MinIO with tiering
  hosts: minio_servers
  become: true
  vars:
    minio_access_key: "secure_access_key"
    minio_secret_key: "secure_secret_key"
    minio_setup_tier: true
    minio_apply_ilm: true
    transition_days: 30
  roles:
    - role: minio

# Backup MinIO
- name: Backup MinIO configuration and data
  hosts: minio_servers
  become: true
  vars:
    minio_backup: true
    remote_backup_location: "/storage/backups"
  roles:
    - role: minio
  tags: [backup]

# Restore MinIO
- name: Restore MinIO from backup
  hosts: minio_servers
  become: true
  vars:
    restore_backup: "/storage/backups/minio_backup_20230315-120000.tar.gz"
  roles:
    - role: minio
  tags: [restore]

# Expand MinIO with new disk
- name: Expand MinIO storage
  hosts: minio_servers
  become: true
  vars:
    expand_existing: true
    expand_disk_path: "/mnt/disk4/blockchain_data"
  roles:
    - role: minio
  tags: [expand]
```

## Tags

| Tag | Description |
|-----|-------------|
| `setup`, `disks` | Disk preparation and mounting |
| `install` | MinIO server installation |
| `service` | SystemD service configuration |
| `configure` | Basic MinIO configuration |
| `client` | MinIO client setup |
| `tier` | Storage tier configuration |
| `ilm` | ILM policy application |
| `backup` | Backup MinIO configuration and data |
| `restore` | Restore MinIO from a backup |
| `expand` | Expand MinIO storage with additional disks or pools |
| `verification` | Verify installation and configuration |

## License

MIT

## Author Information

Axolotl Analytics Team
