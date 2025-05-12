#!/bin/bash
set -e

echo "Deploying to test cluster..."

# Install Flux in the Kind cluster
flux install

# Create flux-system namespace
kubectl create namespace flux-system --dry-run=client -o yaml | kubectl apply -f -

# Apply the Flux system components
kubectl apply -f clusters/my-cluster/flux-system/gotk-components.yaml

# Apply infrastructure components
kubectl apply -f clusters/my-cluster/kestra-kustomization.yaml
kubectl apply -f clusters/my-cluster/migrations-kustomization.yaml

# Verify deployment
echo "Waiting for deployments to be ready..."
kubectl wait --for=condition=ready --timeout=180s -n flux-system deployment -l app=helm-controller 2>/dev/null || true
kubectl wait --for=condition=ready --timeout=180s -n flux-system deployment -l app=kustomize-controller 2>/dev/null || true

echo "Flux deployment to test cluster completed"
flux get all