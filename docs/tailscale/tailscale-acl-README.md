# Tailscale ACL Configuration

This document explains the Access Control List (ACL) settings for the Axol API infrastructure Tailscale network.

## Overview

The Tailscale ACL defines:
- Who can access which services
- SSH access permissions between hosts
- User groups and their permissions
- Network routing rules
- Special node attributes

## Recent Updates

The Tailscale ACL has been updated with several improvements:

1. **Enhanced Monitoring Access**:
   - Added specific rules for Prometheus metrics access (port 9100)
   - Created dedicated monitoring user group
   - Configured read-only access to monitoring endpoints

2. **Blockchain Node Security**:
   - Added a new `tag:blockchain` for blockchain nodes
   - Limited admin-only SSH access to blockchain nodes
   - Improved separation between infrastructure components

3. **ACL Testing Configuration**:
   - Added test sections to validate ACL rules
   - Explicitly defined acceptance and denial paths for each user group
   - Improved documentation and validation of rules

4. **JSON Compatibility**:
   - Removed comments from JSON file to ensure compatibility
   - Moved documentation to this README file

## ACL Structure

The main `tailscale-acl.json` file is structured into several key sections:

### Network Access Rules

```json
"acls": [
  {
    "action": "accept",
    "users":  ["group:admins", "group:developers"],
    "ports":  ["mini-axol:9000", "mini-axol:9001"]
  },
  {"action": "accept", "users": ["group:admins"], "ports": ["*:22"]},
  {
    "action": "accept",
    "users": ["group:readonly", "group:admins", "group:developers"],
    "ports": ["mini-axol:3000", "mini-axol:9090", "mini-axol:9100"]
  },
  {
    "action": "accept",
    "users": ["group:readonly"],
    "ports": ["dappnode-droo:9100", "dravado:9100"]
  },
  {
    "action": "accept",
    "users": ["tag:monitoring"],
    "ports": ["*:9100"]
  }
]
```

These rules grant:
- Admin and developer access to MinIO service (ports 9000 and 9001) on the mini-axol server
- Admin SSH access to all hosts on port 22
- Admin, developer, and read-only user access to monitoring services (ports 3000, 9090, 9100)
- Read-only user access to Prometheus metrics on blockchain nodes
- Monitoring tag access to metrics ports on all hosts

### User Groups

```json
"groups": {
  "group:admins": ["Hydepwns@github"],
  "group:developers": ["droo@github"],
  "group:readonly": ["readonly-user@github"],
  "group:monitoring": ["prometheus@github", "grafana-alerts@github"]
}
```

The defined groups are:
- **Admins**: Users with full administrative access
- **Developers**: Development team members
- **ReadOnly**: Users with restricted monitoring-only access
- **Monitoring**: Service accounts for monitoring systems

### Host Definitions

```json
"hosts": {
  "droos-macbook-pro": "100.126.125.65",
  "dappnode-droo":     "100.103.77.100",
  "dravado":           "100.103.31.23",
  "mini-axol":         "100.117.205.87"
}
```

Key infrastructure hosts:
- **droos-macbook-pro**: Development machine
- **dappnode-droo**: Blockchain node 1 (Dappnode)
- **dravado**: Blockchain node 2 (Avadao)
- **mini-axol**: Main API server with MinIO

### Tag Ownership

```json
"tagOwners": {
  "tag:server":            ["group:admins"],
  "tag:minio":             ["group:admins"],
  "tag:monitoring":        ["group:admins"],
  "tag:blockchain":        ["group:admins"],
  "tag:droos-macbook-pro": ["group:admins"],
  "tag:mini-axol":         ["group:admins"]
}
```

Defines which groups can apply specific tags to devices.

### Route Approvals

```json
"autoApprovers": {
  "routes": {
    "10.0.0.0/16":    ["group:admins"],
    "192.168.0.0/24": ["group:admins"]
  },
  "exitNode": ["group:admins"]
}
```

Controls:
- Which subnets can be routed (10.0.0.0/16 and 192.168.0.0/24)
- Who can use nodes as exit nodes (admins only)

### SSH Access Rules

```json
"ssh": [
  {
    "action": "accept",
    "src":    ["tag:server", "tag:minio"],
    "dst":    ["tag:mini-axol"],
    "users":  ["droo", "minio-user"]
  },
  {
    "action": "accept",
    "src":    ["group:admins"],
    "dst":    ["tag:mini-axol"],
    "users":  ["root", "ubuntu", "droo"]
  },
  {
    "action": "accept",
    "src":    ["tag:server"],
    "dst":    ["tag:droos-macbook-pro"],
    "users":  ["droo"]
  },
  {
    "action": "check",
    "src":    ["group:admins"],
    "dst":    ["tag:minio"],
    "users":  ["minio-user"]
  },
  {
    "action": "accept",
    "src":    ["group:admins"],
    "dst":    ["tag:blockchain"],
    "users":  ["root", "ubuntu"]
  }
]
```

These rules define SSH access patterns:
1. Service-to-service SSH access between servers and MinIO
2. Admin access to API servers
3. Server access to development machines
4. Verification rules for admin to MinIO
5. Admin-only access to blockchain nodes

### Node Attributes

```json
"nodeAttrs": [
  {
    "target": ["tag:mini-axol"],
    "attr":   ["funnel"]
  }
]
```

Special attributes for nodes:
- **funnel**: Enables Tailscale funnel for public HTTPS access on mini-axol

### Testing Configuration

```json
"tests": [
  {
    "src": "group:admins",
    "accept": ["dappnode-droo:22", "dravado:22", "mini-axol:22", "mini-axol:9000", "mini-axol:9001"]
  },
  {
    "src": "group:developers",
    "accept": ["mini-axol:9000", "mini-axol:9001", "mini-axol:3000"],
    "deny": ["dappnode-droo:22", "dravado:22"]
  },
  {
    "src": "group:readonly",
    "accept": ["mini-axol:3000", "mini-axol:9090", "dappnode-droo:9100"],
    "deny": ["mini-axol:22", "mini-axol:9000"]
  }
]
```

The tests section defines validation rules:
- Verify admin access to SSH and MinIO
- Ensure developers can access MinIO but not blockchain nodes directly
- Confirm read-only users can only access monitoring endpoints

## Blockchain Infrastructure Best Practices

### Secure Access Patterns

For blockchain nodes:

1. **Limit Direct Node Access**
   - Only admins should have direct SSH access to blockchain nodes
   - API access should be proxied through the mini-axol server
   - Use the Tailscale SSH feature rather than opening port 22 externally

2. **Node Communication Isolation**
   - Blockchain nodes should only communicate with specific authorized hosts
   - Dappnode and Avadao need access to mini-axol for data storage
   - Prevent direct internet access to blockchain nodes

3. **Network Segmentation**
   - Create separate ACL rules for different components:
     - Blockchain node access
     - Storage access
     - Monitoring access
     - Development access

### Monitoring Access

For secure monitoring:

1. **Read-Only User Access**
   - Configure read-only access for monitoring users
   - Implement separate ACL rules for metrics collection
   - Added specific rules for Prometheus metrics on port 9100

2. **Alerting Configuration**
   - Added a dedicated monitoring group for service accounts
   - Allows automated systems to collect metrics without full access

## Making Changes

When updating the ACL:

1. Test changes in a staging environment first
2. Verify all required connections still work
3. Apply to production using:

```bash
tailscale up --reset --ssh --advertise-tags=tag:server,tag:minio,tag:blockchain
```

## Updating the ACL

To update the ACL in the Tailscale admin interface:

1. Edit the `tailscale-acl.json` file
2. Validate the JSON syntax (ensure no comments are present)
3. Upload to the Tailscale admin console
4. Apply changes

## Security Considerations

- Keep the ACL as restrictive as possible
- Regularly review and audit access patterns
- Remove users who no longer require access
- Use separate admin accounts for critical functions
- Implement time-based access controls for sensitive operations
- Consider using ephemeral/temporary access grants for contractors
- Audit all SSH access logs regularly
- Implement least-privilege principles for all access rules

## Verification and Testing

After applying ACL changes:

1. Test all expected access patterns
2. Verify denied patterns are properly blocked
3. Check SSH access between components
4. Confirm MinIO access works for authorized users only
5. Verify monitoring systems can collect metrics

## Related Documentation

- [Tailscale Setup Guide](tailscale-setup.md)
- [Mini-Axol Server Setup](miniaxol_tailscale_setup.md)
- [Tailscale Official Documentation](https://tailscale.com/kb/1018/acls/)
