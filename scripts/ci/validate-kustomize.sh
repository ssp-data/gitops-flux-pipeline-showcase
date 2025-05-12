#!/bin/bash
set -e

echo "Validating Kustomize resources..."

# Install kustomize
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash

# Find all kustomization directories and validate them
for dir in $(find ./clusters -type f -name kustomization.yaml -exec dirname {} \;); do
  echo "Validating kustomization in $dir"
  ./kustomize build $dir > /dev/null
done

echo "✅ All Kustomize resources are valid"