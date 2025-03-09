# Tailscale Ansible Role

This role installs and configures Tailscale on your hosts and applies the necessary tags for access control.

## Requirements

- Ansible 2.9 or higher
- Ubuntu/Debian or RHEL/CentOS hosts
- Tailscale account

## Role Variables

All variables are defined in `defaults/main.yml` and can be overridden:

```yaml
# Tailscale installation
tailscale_repo_key_url: "https://pkgs.tailscale.com/stable/ubuntu/focal.gpg"
tailscale_repo_url: "https://pkgs.tailscale.com/stable/ubuntu/focal.list"
tailscale_package: "tailscale"

# Tailscale configuration
tailscale_domain: "tail9b2ce8.ts.net"
tailscale_auth_key: "" # Should be provided in vault or vars, not here
tailscale_advertise_tags: []
tailscale_accept_routes: yes
tailscale_exit_node: no
tailscale_exit_node_allow_lan_access: no
tailscale_advertise_exit_node: no
tailscale_advertise_routes: []

# ACL Configuration
tailscale_acl_file: "tailscale-acl.json"
tailscale_apply_acl: yes
```

## Dependencies

None.

## Example Playbook

```yaml
- hosts: all
  become: true
  roles:
    - role: tailscale
      vars:
        tailscale_advertise_tags:
          - "tag:server"
          - "tag:minio"
        tailscale_accept_routes: true
```

## Usage

1. Place your `tailscale-acl.json` file in the role's `files` directory
2. Run the playbook:

```
ansible-playbook -i inventory.ini deploy_tailscale.yaml
```

## Additional Notes

- If you have an authentication key from Tailscale, you can set it via `tailscale_auth_key`
- Tags are automatically applied based on host group membership
- The playbook will verify connectivity between hosts after configuration

## License

MIT
