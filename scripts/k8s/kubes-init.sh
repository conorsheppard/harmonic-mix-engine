#!/bin/bash
set -e

APP_NAME=harmonic-mix-engine
FRONTEND_NAME=harmonic-mix-engine-frontend
NAMESPACE=default

BACKEND_IMAGE=conorsheppard/harmonic-mix-engine:latest
FRONTEND_IMAGE=conorsheppard/harmonic-mix-engine-frontend:latest

minikube start \
  --driver=docker \
  --cpus=2 \
  --memory=1800m \
  --addons= \
  --extra-config=kubelet.housekeeping-interval=60s

echo "Configuring Docker to use Minikube's daemon..."
eval $(minikube docker-env)

ensure_image() {
  local image=$1
  local build_cmd=$2

  if docker image inspect "$image" > /dev/null 2>&1; then
    echo "Image $image found locally, skipping build."
  # elif docker pull "$image" > /dev/null 2>&1; then
  #   echo "Image $image pulled from remote."
  else
    echo "Building $image..."
    eval "$build_cmd"
  fi
}

ensure_image "$BACKEND_IMAGE" \
  "docker build -f backend/Dockerfile -t $BACKEND_IMAGE ."

ensure_image "$FRONTEND_IMAGE" \
  "docker build frontend/ -t $FRONTEND_IMAGE"

echo "Applying Kubernetes manifests..."
kubectl apply -f k8s/

echo "Waiting for backend deployment to become ready..."
kubectl wait \
  --namespace "$NAMESPACE" \
  --for=condition=available \
  --timeout=120s \
  deployment/"$APP_NAME"

echo "Waiting for frontend deployment to become ready..."
kubectl wait \
  --namespace "$NAMESPACE" \
  --for=condition=available \
  --timeout=120s \
  deployment/"$FRONTEND_NAME"

echo "Starting port-forwarding..."
echo "  Backend:  http://localhost:8080"
echo "  Frontend: http://localhost:3000"
kubectl port-forward svc/"$APP_NAME" 8080:8080 &
kubectl port-forward svc/"$FRONTEND_NAME" 3000:3000
