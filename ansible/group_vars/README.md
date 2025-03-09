# Ansible Group Variables

This directory contains group variables for our Ansible infrastructure. The structure follows Ansible best practices for variable hierarchy and inheritance.

## Directory Structure

```bash
group_vars/
├── all/                 # Variables that apply to all hosts
│   ├── main.yml         # Common configuration
│   └── secrets.yml      # Encrypted credentials (vault)
├── minio_servers/       # Variables for all MinIO servers
│   └── main.yml
├── axol_api_servers/    # Variables specific to API servers
│   └── main.yml
├── blockchain_nodes/    # Variables specific to blockchain nodes
│   └── main.yml
├── compute_nodes/       # Variables specific to compute nodes
│   └── main.yml
└── README.md            # This file
```

## Variable Precedence

Variables follow Ansible's [variable precedence](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable) rules:

1. Variables in `all/` apply to all hosts
2. Group-specific variables override `all/` variables
3. Host-specific variables (in `host_vars/`) override group variables

## Secret Management

Secrets are stored in `all/secrets.yml` and should be encrypted using Ansible Vault:

```bash
# Encrypt the secrets file
ansible-vault encrypt ansible/group_vars/all/secrets.yml

# Edit the encrypted file
ansible-vault edit ansible/group_vars/all/secrets.yml

# Run playbooks with vault password
ansible-playbook -i inventory.ini playbook.yml --ask-vault-pass
```

## Variable Naming Conventions

- Group-specific variables are prefixed with the service name (e.g., `minio_`, `api_`, etc.)
- Common variables use a general prefix (e.g., `system_`, `network_`, etc.)
- Boolean variables use `enable_` or `is_` prefixes
