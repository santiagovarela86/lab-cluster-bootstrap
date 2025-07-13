#!/bin/bash
set -e

MASTER_IP="192.168.56.11"
SHARED_PATH="/shared"
SHARED_TOKEN_PATH="$SHARED_PATH/token"
SHARED_KUBECONFIG_PATH="$SHARED_PATH/kubeconfig.yaml"

wait_for_node_ready() {
  echo "[+] Waiting for node $HOSTNAME to be registered in the cluster..."
  until kubectl get node "$HOSTNAME" &>/dev/null; do
    echo "[ ] Node $HOSTNAME not ready yet, sleeping 5s..."
    sleep 5
  done
}

label_node() {
  echo "[+] Labeling node $HOSTNAME..."
  kubectl label node "$HOSTNAME" monitoring=enabled node-role.kubernetes.io/worker= || true
  echo "[✓] Node $HOSTNAME labeled."
}

echo "[+] Waiting for token and kubeconfig file from master..."
while [ ! -f "$SHARED_TOKEN_PATH" ] || [ ! -f "$SHARED_KUBECONFIG_PATH" ]; do
  echo "[ ] Required files not yet available, retrying in 3s..."
  sleep 3
done

echo "[+] Files found. Installing K3s agent on $HOSTNAME..."
TOKEN=$(cat "$SHARED_TOKEN_PATH")
curl -sfL https://get.k3s.io | K3S_URL="https://$MASTER_IP:6443" K3S_TOKEN="$TOKEN" sh -

export KUBECONFIG="$SHARED_KUBECONFIG_PATH"
echo 'export KUBECONFIG=/shared/kubeconfig.yaml' | sudo tee -a /home/vagrant/.bashrc > /dev/null
echo 'export KUBECONFIG=/shared/kubeconfig.yaml' | sudo tee -a /home/vagrant/.profile > /dev/null
sudo chown vagrant:vagrant /home/vagrant/.bashrc /home/vagrant/.profile

# Wait for API server to become available
echo "[+] Waiting for API server to become reachable..."
until kubectl cluster-info &>/dev/null; do
  echo "[ ] API server not ready yet, sleeping 5s..."
  sleep 5
done

kubectl config set-cluster default --server="https://$MASTER_IP:6443" --kubeconfig="$KUBECONFIG"

wait_for_node_ready
label_node
