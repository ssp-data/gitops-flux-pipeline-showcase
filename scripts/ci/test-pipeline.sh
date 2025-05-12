#!/bin/bash
set -e

echo "Testing Kestra data pipeline..."

# Set up Python environment
python -m pip install --upgrade pip
pip install dlt pytest pytest-mock

# Testing approach for CI/CD:
# 1. We can't run the full Kestra server in CI/CD
# 2. Instead, we test the core pipeline logic directly

cd workspaces/pipelines

# Create a simple test for the chess pipeline
cat > test_chess_pipeline.py << EOF
import pytest
from unittest.mock import patch, MagicMock
import json
import sys
import os

# Add the directory to path to import the module
sys.path.append(os.path.abspath('./dlt'))

# Rename dlt-chess-snowflake.py to dlt_chess_snowflake.py for import
if not os.path.exists('./dlt/dlt_chess_snowflake.py'):
    with open('./dlt/dlt-chess-snowflake.py', 'r') as src:
        with open('./dlt/dlt_chess_snowflake.py', 'w') as dst:
            dst.write(src.read())

import dlt_chess_snowflake as chess_module

@pytest.fixture
def mock_requests_get():
    with patch('dlt.sources.helpers.requests.get') as mock_get:
        yield mock_get

def test_chess_players_online_status(mock_requests_get):
    # Mock API responses
    first_response = MagicMock()
    first_response.json.return_value = {
        'live_blitz': [{'username': 'player1'}, {'username': 'player2'}]
    }
    
    second_response = MagicMock()
    second_response.json.return_value = {'online': True}
    
    # Set up the mock responses
    mock_requests_get.side_effect = [first_response, second_response, second_response]
    
    # Call the function
    results = list(chess_module.chess_players_online_status())
    
    # Assert results
    assert len(results) == 2
    assert all('is_online' in player for player in results)
EOF

# Run the test
python -m pytest test_chess_pipeline.py -v

# Additionally, validate the Kestra YAML syntax
for file in $(find . -name "*.yml" -or -name "*.yaml"); do
  echo "Validating Kestra pipeline: $file"
  python -c "import yaml; yaml.safe_load(open('$file'))" || exit 1
done

echo "✅ Pipeline tests completed successfully"