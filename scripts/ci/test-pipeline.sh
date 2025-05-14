#!/bin/bash
set -e

echo "Testing Kestra data pipeline..."

# Set up Python environment
echo "Installing required Python packages..."
python -m pip install --upgrade pip
python -m pip install dlt pytest pytest-mock

# Use virtual environment locally, but in CI we can just install directly
if [ -z "$GITHUB_ACTIONS" ]; then
  # Create a virtual environment for testing to avoid dependency conflicts
  if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python -m venv venv
  fi

  # Activate virtual environment
  echo "Activating virtual environment..."
  source venv/bin/activate

  # Install dependencies in the virtual environment
  pip install dlt pytest pytest-mock
else
  # In GitHub Actions, dependencies are installed directly
  echo "Running in GitHub Actions, installing dependencies directly..."
  pip install dlt pytest pytest-mock
fi


# Run the test
echo "Running pipeline tests..."
python -m pytest workspaces/pipelines/tests/test_chess_pipeline.py -v

# Validate the Kestra YAML syntax
echo "Validating Kestra YAML files..."
for file in $(find workspaces/pipelines -name "*.yml" -or -name "*.yaml"); do
  echo "Validating: $file"
  python -c "import yaml; yaml.safe_load(open('$file'))" || exit 1
done

# Deactivate virtual environment if we created one
if [ -z "$GITHUB_ACTIONS" ]; then
  echo "Deactivating virtual environment..."
  deactivate
fi

echo "✅ Pipeline tests completed successfully"