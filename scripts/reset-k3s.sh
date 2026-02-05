#!/usr/bin/env bash
set -euo pipefail

echo "🛑 Stopping k3s"
sudo systemctl stop k3s
sleep 3

echo "♻️ Running k3s cluster reset"
sudo k3s server --cluster-reset

echo "▶️ Starting k3s"
sudo systemctl start k3s

echo "⏳ Waiting for Kubernetes API"
until kubectl get nodes >/dev/null 2>&1; do
  sleep 3
done

kubectl wait --for=condition=Ready node --all --timeout=120s
echo "✅ Kubernetes API is ready"

# -------------------------------------------------
# CLEAN ALL NON-DEFAULT RESOURCES
# -------------------------------------------------

echo "🧹 Removing cert-manager and ingress-nginx (if present)"
kubectl delete -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.4/cert-manager.yaml --ignore-not-found
kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.1/deploy/static/provider/cloud/deploy.yaml --ignore-not-found

echo "🧹 Deleting all resources from non-system namespaces"
SYSTEM_NAMESPACES="kube-system kube-public kube-node-lease default"

for ns in $(kubectl get ns -o jsonpath='{.items[*].metadata.name}'); do
  if [[ " ${SYSTEM_NAMESPACES} " == *" ${ns} "* ]]; then
    continue
  fi

  echo "  • Clearing namespace: ${ns}"
  kubectl delete $(kubectl api-resources --namespaced=true --verbs=delete -o name | paste -sd, -) \
    --all -n "${ns}" --ignore-not-found --wait=false
done

echo "🧹 Deleting non-system namespaces"
for ns in $(kubectl get ns -o jsonpath='{.items[*].metadata.name}'); do
  if [[ " ${SYSTEM_NAMESPACES} " == *" ${ns} "* ]]; then
    continue
  fi
  kubectl delete namespace "${ns}" --ignore-not-found --wait=false
done

echo "✅ Cluster reset complete (system namespaces only)"
