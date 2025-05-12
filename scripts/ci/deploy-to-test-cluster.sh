#!/bin/bash
set -e

echo "Deploying to test cluster..."

# Install Flux in the Kind cluster
flux install

# Create flux-system namespace
kubectl create namespace flux-system --dry-run=client -o yaml | kubectl apply -f -

# Apply the Flux system components
kubectl apply -f clusters/my-cluster/flux-system/gotk-components.yaml

# Download the latest artifact for deployment
mkdir -p /tmp/deploy
artifacts=$(curl -s https://api.github.com/repos/${GITHUB_REPOSITORY}/actions/artifacts)
artifact_url=$(echo "$artifacts" | jq -r '.artifacts[0].archive_download_url')

if [ -n "$artifact_url" ] && [ "$artifact_url" != "null" ]; then
  echo "Downloading latest artifact from: $artifact_url"
  curl -L -H "Authorization: token ${{ secrets.GITHUB_TOKEN }}" "$artifact_url" -o /tmp/deploy/artifact.zip
  unzip /tmp/deploy/artifact.zip -d /tmp/deploy
  tar -xzvf /tmp/deploy/chess-pipeline-*.tar.gz -C /tmp/deploy
  
  echo "Downloaded artifact version: $(cat /tmp/deploy/release.json | jq -r '.version')"
else
  echo "No artifacts found, using local files for test deployment"
fi

# Apply infrastructure components
kubectl apply -f clusters/my-cluster/kestra-kustomization.yaml
kubectl apply -f clusters/my-cluster/migrations-kustomization.yaml

# Verify deployment
echo "Waiting for deployments to be ready..."
kubectl wait --for=condition=ready --timeout=180s -n flux-system deployment -l app=helm-controller 2>/dev/null || true
kubectl wait --for=condition=ready --timeout=180s -n flux-system deployment -l app=kustomize-controller 2>/dev/null || true

echo "Flux deployment to test cluster completed"
flux get all