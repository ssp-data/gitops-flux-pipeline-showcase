# Flux Infrastructure Example

This repository contains a GitOps infrastructure setup using Flux CD to manage Kubernetes applications and resources.

## Overview

This infrastructure repository demonstrates how to use Flux CD for GitOps-driven deployments, including:

- Flux system components
- Kestra workflow orchestration platform via Helm chart
- Database migrations with Liquibase
- CI/CD pipelines with GitHub Actions

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

## Directory Structure

```
clusters/             # Kubernetes manifests managed by Flux
  └── my-cluster/     # Cluster-specific configuration
      ├── flux-system/ # Flux components
      ├── kestra/     # Kestra deployment 
      └── migrations/ # Database migrations

workspaces/           # Application code and pipelines
  └── pipelines/      # Kestra pipeline definitions
      ├── dlt/        # Python data pipeline code
      └── tests/      # Test pipelines

scripts/              # CI/CD and utility scripts
  └── ci/             # CI pipeline scripts

migrations/           # Local migration files
  └── changelog/      # Liquibase changelog definitions
```

## CI/CD Pipeline

This repository includes a GitHub Actions CI/CD workflow that automatically tests and deploys changes:

### CI Pipeline Features

- **Linting**: Validates Kustomize resources and Kestra pipeline syntax
- **Data Pipeline Testing**: Tests the data pipelines with sample data
- **Database Schema Testing**: Tests Liquibase migrations
- **Deployment Testing**: Deploys to a test cluster using Flux

### Workflow Diagram

```
[Code Push] → [Lint] → [Test Pipelines] → [Test Migrations] → [Deploy]
                                                                  ↑
                               (Only runs on main branch pushes) ─┘
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

# Access Kestra UI
make port-forward-kestra
```

## Database Migrations

Database migrations are managed with Liquibase:

1. Simple schema with players table
2. Migrations applied automatically via Kubernetes job
3. Changes tracked in version control

## Kestra Data Pipelines

The example includes a simple data pipeline that:

1. Fetches chess player data from a public API
2. Processes the data with DLT
3. Outputs the results to a database