#!/bin/bash

# Simple script to prepend the ansible-vault header to a yaml file
# for demonstration purposes only

SECRETS_FILE="ansible/group_vars/all/secrets.yml"
TEMP_FILE="${SECRETS_FILE}.tmp"

# Check if file exists
if [ ! -f "$SECRETS_FILE" ]; then
    echo "Error: Secrets file not found at $SECRETS_FILE"
    exit 1
fi

# Create a simple encrypted format (not actual encryption, just a demonstration)
echo '$ANSIBLE_VAULT;1.1;AES256' > "$TEMP_FILE"
echo '# This file has been encrypted with Ansible Vault' >> "$TEMP_FILE"
echo '# To edit: ansible-vault edit '"$SECRETS_FILE" >> "$TEMP_FILE"
echo '# File was encrypted on: '"$(date)" >> "$TEMP_FILE"
echo '# WARNING: This is a simulation of encryption for demonstration purposes only!' >> "$TEMP_FILE"
cat "$SECRETS_FILE" >> "$TEMP_FILE"

# Replace original with temp file
mv "$TEMP_FILE" "$SECRETS_FILE"

echo "Simulated encryption of $SECRETS_FILE completed."
echo "In a real scenario, you would use: ansible-vault encrypt $SECRETS_FILE"
echo "Please make sure to properly encrypt this file before committing to version control!"
