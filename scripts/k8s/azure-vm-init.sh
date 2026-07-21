#!/bin/bash
# Non-blocking cluster bring-up for the Azure VM + Minikube + Nginx setup.
#
# Unlike scripts/k8s/kubes-init.sh (which port-forwards and blocks, suited to a
# local dev machine), this exposes the app through the Minikube ingress addon
# behind an Nginx reverse proxy on port 80 - the model documented in the Azure
# setup notes. It is invoked by Terraform's cloud-init on first boot and is safe
# to re-run.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_DIR"

echo "==> Starting Minikube (docker driver)..."
minikube start \
  --driver=docker \
  --cpus=2 \
  --memory=1800m \
  --extra-config=kubelet.housekeeping-interval=60s

echo "==> Enabling ingress addon..."
minikube addons enable ingress

echo "==> Waiting for ingress controller to be ready..."
kubectl -n ingress-nginx wait \
  --for=condition=available \
  --timeout=180s \
  deployment/ingress-nginx-controller

echo "==> Applying Kubernetes manifests..."
# Images (conorsheppard/harmonic-mix-engine[-frontend]:latest) are public on
# Docker Hub; with imagePullPolicy: IfNotPresent the kubelet pulls them, so no
# build is required on the VM.
kubectl apply -f k8s/

echo "==> Waiting for application deployments..."
kubectl wait --for=condition=available --timeout=300s \
  deployment/harmonic-mix-engine
kubectl wait --for=condition=available --timeout=300s \
  deployment/harmonic-mix-engine-frontend

echo "==> Configuring Nginx reverse proxy..."
"$REPO_DIR/scripts/nginx/create-config.sh"

sudo rm -f /etc/nginx/sites-enabled/default
sudo ln -sf /etc/nginx/sites-available/minikube-ingress \
            /etc/nginx/sites-enabled/minikube-ingress

sudo nginx -t && sudo systemctl restart nginx

echo "==> Done. App available on port 80 (e.g. http://<vm-public-ip>/songs?key=C)"
