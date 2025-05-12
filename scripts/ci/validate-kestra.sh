#!/bin/bash
set -e

echo "Validating Kestra pipelines..."

# Simple validation for all YAML files in the pipelines directory
for file in $(find ./workspaces/pipelines -name "*.yml" -or -name "*.yaml"); do
  echo "Validating Kestra pipeline: $file"
  # Basic YAML validation
  python -c "import yaml; yaml.safe_load(open('$file'))" || exit 1
done

echo "✅ All Kestra pipelines are valid"