#!/bin/bash
set -e

echo "Validating Kustomize resources..."

# Install kustomize
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash

# Validate each kustomization directory individually
echo "Validating flux-system kustomization"
./kustomize build ./clusters/my-cluster/flux-system > /dev/null

echo "Validating kestra kustomization"
./kustomize build ./clusters/my-cluster/kestra > /dev/null

echo "Validating migrations kustomization"
./kustomize build ./clusters/my-cluster/migrations > /dev/null

# Validate kustomization referencing files
echo "Validating kestra-kustomization.yaml"
./kustomize build --load-restrictor=LoadRestrictionsNone ./clusters/my-cluster/kestra-kustomization.yaml > /dev/null

echo "Validating migrations-kustomization.yaml"
./kustomize build --load-restrictor=LoadRestrictionsNone ./clusters/my-cluster/migrations-kustomization.yaml > /dev/null

echo "✅ All Kustomize resources are valid"