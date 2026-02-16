#!/bin/bash
set -e

APP_NAME=harmonic-mix-engine
NAMESPACE=default

minikube start

echo "Applying Kubernetes manifests..."
kubectl apply -f k8s/

echo "Waiting for deployment to become ready..."
kubectl wait \
  --namespace "$NAMESPACE" \
  --for=condition=available \
  --timeout=120s \
  deployment/"$APP_NAME"

echo "Starting port-forwarding on service/$APP_NAME..."
kubectl port-forward svc/"$APP_NAME" 8080:8080
