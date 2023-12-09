import os
from dotenv import load_dotenv
import yaml

# Load the environment variables from .env file
script_dir = os.path.dirname(os.path.abspath(__file__))
load_dotenv(dotenv_path=os.path.join(script_dir, '../../.env'))

# Define the path to the YAML file
RECYCLARR_SECRETS_FILE = os.path.join(script_dir, '../../recyclarr/secrets.yml')

# Load the reccylarr yaml file and set the api keys for RADARR_API_KEY and SONARR_API_KEY
with open(RECYCLARR_SECRETS_FILE, 'r') as file:
	config_data = yaml.safe_load(file)

print('Updating RADARR_API_KEY and SONARR_API_KEY in recyclarr secrets.yml')

config_data['RADARR_API_KEY'] = os.getenv('RADARR_API_KEY')
config_data['SONARR_API_KEY'] = os.getenv('SONARR_API_KEY')

# Write the updated YAML data back to the file
with open(RECYCLARR_SECRETS_FILE, 'w') as file:
	yaml.safe_dump(config_data, file, default_flow_style=False)

print('All API keys updated in recyclarr secrets.yml')
