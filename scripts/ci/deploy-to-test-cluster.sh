#!/bin/bash
set -e

echo "Deploying to test cluster..."

# Install Flux in the Kind cluster
flux install

# Create flux-system namespace
kubectl create namespace flux-system --dry-run=client -o yaml | kubectl apply -f -

# Apply the Flux system components
kubectl apply -f clusters/my-cluster/flux-system/gotk-components.yaml

# Check for available artifacts from GitHub
if [ -n "$GITHUB_REPOSITORY" ] && [ -n "$GITHUB_TOKEN" ]; then
  echo "Checking for artifacts from GitHub..."
  mkdir -p /tmp/deploy
  artifacts=$(curl -s "https://api.github.com/repos/${GITHUB_REPOSITORY}/actions/artifacts")
  artifact_url=$(echo "$artifacts" | jq -r '.artifacts[0].archive_download_url')

  if [ -n "$artifact_url" ] && [ "$artifact_url" != "null" ]; then
    echo "Downloading artifact from: $artifact_url"
    curl -L -H "Authorization: token ${GITHUB_TOKEN}" "$artifact_url" -o /tmp/deploy/artifact.zip
    unzip -q /tmp/deploy/artifact.zip -d /tmp/deploy
    tar -xzf /tmp/deploy/chess-pipeline-*.tar.gz -C /tmp/deploy
    
    echo "Artifact version: $(cat /tmp/deploy/release.json | jq -r '.version')"
    
    # Copy the pipeline files to the workspaces directory
    cp -r /tmp/deploy/pipelines/* workspaces/pipelines/
    
    # Copy the migrations files to the migrations directory
    cp -r /tmp/deploy/migrations/* migrations/
  else
    echo "No artifacts found, using local files for deployment"
  fi
fi

# Apply Flux kustomizations
kubectl apply -f clusters/my-cluster/kestra-kustomization.yaml
kubectl apply -f clusters/my-cluster/migrations-kustomization.yaml

# Wait for Flux controllers to be ready
echo "Waiting for Flux controllers to be ready..."
kubectl wait --for=condition=ready --timeout=60s -n flux-system deployment -l app=helm-controller 2>/dev/null || true
kubectl wait --for=condition=ready --timeout=60s -n flux-system deployment -l app=kustomize-controller 2>/dev/null || true

# Wait for resources to be reconciled
echo "Waiting for resources to be reconciled..."
sleep 10

# Check status
echo "Flux deployment status:"
flux get all

echo "✅ Flux deployment to test cluster completed"