# Tailscale Configuration for Turing Pi Cluster

This document describes how to securely connect your Turing Pi cluster nodes using Tailscale with SSH access enabled.

## Prerequisites

Before proceeding, ensure you have:

1. A Turing Pi cluster with all nodes booted and accessible on your local network
2. An account on [Tailscale](https://login.tailscale.com/)
3. Basic knowledge of Ansible for automation
4. SSH access to all nodes in your cluster

## Automated Setup with Ansible

We've provided an Ansible playbook for configuring Tailscale on your entire Turing Pi cluster.

### 1. Prepare Authentication Key

1. Log in to your [Tailscale admin console](https://login.tailscale.com/admin/settings/keys)
2. Generate a new authentication key
   - Set an expiry date appropriate for your deployment
   - Consider enabling key reuse if you'll be setting up multiple nodes
   - Add any necessary [key tags](https://tailscale.com/kb/1085/auth-keys/#using-tagged-auth-keys) for ACL enforcement
3. Copy the generated key - it will look like `tskey-abcd1234...`

### 2. Securely Store the Authentication Key

Add your Tailscale authentication key to your encrypted secrets file:

```bash
# If you haven't created a secrets file yet
cp ansible/group_vars/all/secrets_example.yml ansible/group_vars/all/secrets.yml

# Encrypt the file
ansible-vault encrypt ansible/group_vars/all/secrets.yml

# Edit the encrypted file to add your key
ansible-vault edit ansible/group_vars/all/secrets.yml
```

In the secrets file, add or modify the Tailscale section:

```yaml
# Tailscale credentials
tailscale_auth_key: "your-tailscale-auth-key-here"
```

### 3. Configure Inventory

Ensure your Turing Pi nodes are defined in your inventory file:

```ini
# Compute Nodes (Turing Pi cluster)
[turingpi]
node1 ansible_host=192.168.1.101 ansible_user=pi
node2 ansible_host=192.168.1.102 ansible_user=pi
node3 ansible_host=192.168.1.103 ansible_user=pi
node4 ansible_host=192.168.1.104 ansible_user=pi

# Turing Pi specific variables
[turingpi:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_connection=ssh
ansible_become=true
tailscale_hostname_prefix=turingpi-node
```

### 4. Run the Playbook

Execute the Tailscale deployment playbook:

```bash
# Using Ansible Vault password prompt
ansible-playbook -i ansible/inventory.ini ansible/deploy_tailscale_turing_pi.yaml --ask-vault-pass

# Using Ansible Vault password file
ansible-playbook -i ansible/inventory.ini ansible/deploy_tailscale_turing_pi.yaml --vault-password-file=~/.ansible-vault-password
```

## Features Enabled

The deployment includes:

1. **SSH Access**: Tailscale SSH for secure connections between nodes
2. **Automatic Hostname Assignment**: Nodes will appear as `turingpi-node-X` in Tailscale
3. **Node Tagging**: Automatic tagging for ACL management
4. **Firewall Configuration**: Proper iptables rules for Tailscale connectivity

## Accessing Your Nodes

After deployment, you can connect to your nodes using:

```bash
# Direct SSH via Tailscale
ssh turingpi-node-node1
ssh turingpi-node-node2
# etc.

# View node status
tailscale status
```

## Security Considerations

1. **Auth Key Management**:
   - Never commit your auth key to version control
   - Set appropriate key expiry times
   - Rotate keys periodically

2. **Access Controls**:
   - Configure [Tailscale ACLs](https://tailscale.com/kb/1018/acls/) to restrict which devices can access your nodes
   - Set up user-based access if applicable

3. **SSH Hardening**:
   - Consider disabling password authentication
   - Use key-based authentication only

## Troubleshooting

### Common Issues

1. **Connection Problems**:
   ```bash
   # Check Tailscale status
   sudo tailscale status

   # View logs
   sudo journalctl -u tailscaled -f
   ```

2. **SSH Access Denied**:
   - Verify Tailscale is running (`tailscale status`)
   - Check SSH server configuration
   - Verify Tailscale ACLs allow access

3. **Missing Nodes**:
   - Ensure all nodes completed the Tailscale setup
   - Check for firewall rules blocking Tailscale traffic

## Additional Resources

- [Tailscale Documentation](https://tailscale.com/kb/)
- [Tailscale SSH Documentation](https://tailscale.com/kb/1193/tailscale-ssh/)
- [Turing Pi Documentation](https://docs.turingpi.com/)
