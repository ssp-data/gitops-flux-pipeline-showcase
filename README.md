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
- **Data Pipeline Testing**: Tests the data pipeline logic directly using pytest
- **Database Schema Testing**: Validates Liquibase migrations
- **Artifact Building**: Creates versioned release artifacts
- **Deployment Testing**: Deploys infrastructure to a test cluster using Flux

### Workflow Diagram

```
[Code Push] → [Lint] → [Test Code] → [Test Migrations] → [Build Artifact] → [Validate Artifact] → [Deploy]
                                                                                                       ↑
                                                      (Only runs on main branch pushes) ───────────────┘
```

### Testing Approach

For CI/CD testing without a full Kubernetes environment:

1. **Data Pipeline Tests**: Tests the pipeline logic directly with pytest and mocks, not through Kestra
2. **Liquibase Tests**: Runs against a PostgreSQL service container that's spun up for the tests
3. **Artifact Building**: Creates a versioned artifact with code, migrations and metadata
4. **Infrastructure Testing**: Uses Kind to create a temporary Kubernetes cluster for infrastructure validation

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

## Release Process

The CI/CD workflow:

1. Tests all components separately
2. Builds a versioned artifact (e.g., chess-pipeline-20250512123045.tar.gz)
3. Validates the artifact's contents 
4. Deploys the infrastructure using Flux in a test environment
5. For production, you would manually promote tested releases