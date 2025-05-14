import pytest
from unittest.mock import patch, MagicMock
import sys
import os

# Add the directory to path to import the module
script_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.append(os.path.join(os.path.dirname(script_dir), 'dlt'))

# Try to import the module
try:
    import dlt_chess_snowflake as chess_module
except ImportError:
    # If it fails, try to create a properly named module
    dlt_dir = os.path.join(os.path.dirname(script_dir), 'dlt')
    src_path = os.path.join(dlt_dir, 'dlt-chess-snowflake.py')
    dst_path = os.path.join(dlt_dir, 'dlt_chess_snowflake.py')
    
    if os.path.exists(src_path) and not os.path.exists(dst_path):
        with open(src_path, 'r') as src:
            with open(dst_path, 'w') as dst:
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
