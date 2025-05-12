# Flux Infrastructure Example

This repository contains a GitOps infrastructure setup using Flux CD to manage Kubernetes applications and resources.

## Overview

This infrastructure repository demonstrates how to use Flux CD for GitOps-driven deployments, including:

- Flux system components
- Kestra workflow orchestration platform via Helm chart
- Makefile with helpful commands

## Getting Started

### Prerequisites

- Kubernetes cluster
- Flux CLI installed
- `kubectl` configured

### Bootstrapping Flux

To bootstrap Flux on your cluster:

```bash
export GITHUB_USER=<your-github-username>
make flux-bootstrap
```

### Available Resources

- **Kestra**: Workflow orchestration platform deployed via Helm chart
- **Flux System**: Core Flux components

## Directory Structure

```
clusters/
└── my-cluster/
    ├── flux-system/         # Flux core components
    ├── kestra/              # Kestra Helm chart installation
    └── kestra-kustomization.yaml # Flux kustomization for Kestra
```

## Usage

The repository includes a Makefile with common commands:

```bash
# Display help for available commands
make help

# Reconcile all resources
make reconcile-all

# View resource status
make status

# Access Kestra UI (after deployment)
make port-forward-kestra
```

## Kestra Configuration

The Kestra workflow platform is configured with:

- Standalone deployment mode
- PostgreSQL database
- MinIO for internal storage
- Docker-in-Docker for task execution

## Troubleshooting

If you encounter issues with Docker-in-Docker root access, I added priviledged execution to `kestra-helm-release.yaml` see `securityContext`.

