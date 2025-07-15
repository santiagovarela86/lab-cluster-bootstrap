#!/bin/bash
set -e

PROJECT_ROOT=$(dirname "$0")
SSH_DIR="$HOME/.ssh"

# Clean up old keys and known_hosts
echo "[+] Cleaning up old SSH keys and known_hosts..."
rm -f "$SSH_DIR/known_hosts"
for NODE in node1 node2 node3; do
  rm -f "$SSH_DIR/${NODE}_key"
  KEY_PATH="$PROJECT_ROOT/.vagrant/machines/$NODE/virtualbox/private_key"
  TARGET_KEY="$SSH_DIR/${NODE}_key"

  if [[ -f "$KEY_PATH" ]]; then
    echo "[+] Copying SSH private key for $NODE..."
    cp "$KEY_PATH" "$TARGET_KEY"
    chmod 600 "$TARGET_KEY"
  else
    echo "[!] Private key for $NODE not found at $KEY_PATH"
    exit 1
  fi

done

# Run Ansible playbook
echo "[+] Running Ansible playbook..."
ansible-playbook -i inventory.yaml site.yaml