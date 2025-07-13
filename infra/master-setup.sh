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
  kubectl label node "$HOSTNAME" monitoring=enabled || true
  echo "[✓] Node $HOSTNAME labeled."
}

echo "[+] Installing K3s on master node ($HOSTNAME)..."
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--tls-san $MASTER_IP --write-kubeconfig-mode=644 --disable=traefik" sh -

echo "[+] Saving K3s join token and kubeconfig to shared folder..."
mkdir -p "$SHARED_PATH"
sudo cat /var/lib/rancher/k3s/server/node-token > "$SHARED_TOKEN_PATH"
sudo cp /etc/rancher/k3s/k3s.yaml "$SHARED_KUBECONFIG_PATH"
sudo chown vagrant:vagrant "$SHARED_KUBECONFIG_PATH"
kubectl config set-cluster default --server="https://$MASTER_IP:6443" --kubeconfig="$SHARED_KUBECONFIG_PATH"

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
wait_for_node_ready
label_node