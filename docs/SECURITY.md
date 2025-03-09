# Security Best Practices for Axol API Infrastructure

This document outlines essential security practices for managing and deploying the Axol API infrastructure, with special attention to preventing sensitive information leakage.

## Credential Management

### Ansible Vault

**All sensitive information must be encrypted with Ansible Vault:**

```bash
# Create a new secrets file from the example template
cp ansible/group_vars/all/secrets_example.yml ansible/group_vars/all/secrets.yml

# Encrypt the file BEFORE adding real credentials
ansible-vault encrypt ansible/group_vars/all/secrets.yml

# Edit the encrypted file
ansible-vault edit ansible/group_vars/all/secrets.yml

# View the encrypted file
ansible-vault view ansible/group_vars/all/secrets.yml
```

### Vault Password Management

Choose one of these methods to manage your vault password:

1. **Prompt for password** (more secure, less convenient):
   ```bash
   ansible-playbook -i inventory.ini your_playbook.yml --ask-vault-pass
   ```

2. **Use a password file** (more convenient, requires file protection):
   ```bash
   # Create a password file
   echo "your-secure-vault-password" > ~/.vault_pass
   chmod 600 ~/.vault_pass

   # Use it with playbooks
   ansible-playbook -i inventory.ini your_playbook.yml --vault-password-file=~/.vault_pass
   ```

3. **Environment variable** (for CI/CD environments):
   ```bash
   # Store password in environment variable
   export ANSIBLE_VAULT_PASSWORD="your-secure-vault-password"

   # Create a password script
   echo '#!/bin/bash
   echo "$ANSIBLE_VAULT_PASSWORD"' > ~/.vault_pass.sh
   chmod 700 ~/.vault_pass.sh

   # Use with playbooks
   ansible-playbook -i inventory.ini your_playbook.yml --vault-password-file=~/.vault_pass.sh
   ```

## Preventing Sensitive Information Leakage

### Pre-commit Hooks

This repository includes pre-commit hooks to help prevent accidental commits of sensitive information:

```bash
# Install pre-commit
pip install pre-commit

# Install the hooks
pre-commit install

# Run hooks manually (recommended before committing)
pre-commit run --all-files
```

### What to Keep Secret

**Always encrypt and never commit:**

1. **Credentials**:
   - Passwords, API keys, tokens
   - Database connection strings
   - MinIO access and secret keys
   - Admin credentials for any service

2. **Network Information**:
   - Production IP addresses
   - Private network details
   - Tailscale auth keys

3. **Cryptographic Material**:
   - SSL/TLS certificates and private keys
   - SSH private keys
   - Signing keys

### Never Hardcode Sensitive Values

**Bad practice** (NEVER do this):
```yaml
minio_access_key: "minioadmin"
minio_secret_key: "my-actual-password-123"
```

**Good practice**:
```yaml
minio_access_key: "{{ minio_credentials.access_key }}"
minio_secret_key: "{{ minio_credentials.secret_key }}"
```

### Variable Consistency

Use consistent variable naming to avoid confusion and potential leaks:

```yaml
# Structured credentials in secrets.yml
minio_credentials:
  root_user: "admin"
  root_password: "secure-password-here"
  access_key: "access-key-here"
  secret_key: "secret-key-here"

# Referencing these variables in playbooks
minio_root_user: "{{ minio_credentials.root_user }}"
minio_root_password: "{{ minio_credentials.root_password }}"
```

## Secure Deployment

### Production vs. Development

Always validate that production environments use proper security settings:

```yaml
- name: Validate credentials for production
  fail:
    msg: |
      ERROR: Default or empty credentials detected in a production environment.
      Please set secure credentials in your encrypted secrets file.
  when:
    - (minio_access_key == "" or minio_access_key == "minioadmin")
    - ansible_host != "localhost"
```

### Tailscale Security

When using Tailscale:

1. Generate auth keys with expirations
2. Use ACLs to restrict access between nodes
3. Enable MagicDNS for more secure hostname resolution
4. Consider setting up key rotation

```yaml
# Properly reference the Tailscale auth key from encrypted secrets
tailscale_auth_key: "{{ tailscale_auth_key }}"
```

## Monitoring for Security Issues

### Logs and Alerts

Set up monitoring for security-related events:

1. Configure log collection for authentication failures
2. Set up alerts for unusual access patterns
3. Regularly review MinIO audit logs

### Regular Audits

Perform periodic security audits:

1. Run `pre-commit run --all-files` to check for leaked secrets
2. Validate that Ansible Vault is being used correctly
3. Review permission settings on all systems
4. Check for any hardcoded credentials in playbooks

## Incident Response

If you discover sensitive information has been leaked:

1. **Revoke and rotate all affected credentials immediately**
2. Remove the sensitive data from Git history (if applicable)
3. Investigate how the leak occurred
4. Implement additional safeguards

## Additional Resources

- [Ansible Vault Documentation](https://docs.ansible.com/ansible/latest/vault_guide/index.html)
- [Tailscale Security](https://tailscale.com/security/)
- [MinIO Security Best Practices](https://min.io/docs/minio/linux/operations/security.html)
