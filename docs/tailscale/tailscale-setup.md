# Tailscale Configuration for MinIO

This guide explains how to set up Tailscale for secure MinIO remote access.

## Installation

```bash
# Add Tailscale repository
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.gpg | sudo apt-key add -
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.list | sudo tee /etc/apt/sources.list.d/tailscale.list

# Install and start
sudo apt-get update && sudo apt-get install tailscale
sudo tailscale up
```

## Network Configuration

### Hostnames

Use full Tailscale domain in Ansible inventory:

```ini
minipc1.tail9b2ce8.ts.net
```

Verify connectivity: `tailscale status`

## Security Configuration

### Access Controls

```json
{
  "acls": [
    {"action": "accept", "users": ["*"], "ports": ["minipc1:9000", "minipc2:9000", "minipc1:9001", "minipc2:9001"]}
  ]
}
```

### SSH Access

```json
{
  "ssh": [
    {"action": "check", "src": ["group:admins"], "dst": ["tag:server"], "users": ["root", "ubuntu"]},
    {"action": "check", "src": ["group:developers"], "dst": ["tag:minio"], "users": ["minio-user"]}
  ]
}
```

Apply tags:

```bash
sudo tailscale up --reset --ssh --advertise-tags=tag:server,tag:minio,tag:monitoring
```

Enable MagicDNS in admin console for short hostnames.

## MinIO Integration

- Web console: `http://minipc1.tail9b2ce8.ts.net:9001`
- S3 API: `http://minipc1.tail9b2ce8.ts.net:9000`

## Troubleshooting

- Connection issues: `tailscale status`
- DNS problems: Check MagicDNS
- Permission denied: Review ACLs

## Resources

- [Tailscale Documentation](https://tailscale.com/kb/)
- [Tailscale ACL Examples](https://tailscale.com/kb/1018/acls/)
