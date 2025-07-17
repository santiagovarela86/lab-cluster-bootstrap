#!/bin/bash
set -e

PROJECT_ROOT=$(dirname "$0")
SSH_DIR="$HOME/.ssh"
INVENTORY="$PROJECT_ROOT/inventory.yaml"

# Step 1: Extract IPs from inventory.yaml
echo "[+] Extracting host IPs from inventory..."
HOST_IPS=$(yq -r '.all.children[].hosts[].ansible_host' "$PROJECT_ROOT/inventory.yaml")
HOSTNAMES=$(yq -r '.all.children[].hosts | keys[]' "$PROJECT_ROOT/inventory.yaml")

# Step 2: Ping each host until reachable
echo "[+] Waiting for VM network connectivity..."
for ip in $HOST_IPS; do
  echo -n "  > Pinging $ip..."
  until ping -c1 -W1 "$ip" &>/dev/null; do
    echo -n "."
    sleep 1
  done
  echo " OK"
done

# Step 3: Clean up old keys and known_hosts
echo "[+] Cleaning up old SSH keys and known_hosts..."
rm -f "$SSH_DIR/known_hosts"
for NODE in $HOSTNAMES; do
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