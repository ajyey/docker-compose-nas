import os
from dotenv import load_dotenv
import yaml

# Load the environment variables from .env file
script_dir = os.path.dirname(os.path.abspath(__file__))
load_dotenv(dotenv_path=os.path.join(script_dir, '../../.env'))

# Define the path to the YAML file
BUILDARR_CONFIG_FILE = os.path.join(script_dir, '../../buildarr/buildarr.yml')

# Read the existing YAML file
with open(BUILDARR_CONFIG_FILE, 'r') as file:
	config_data = yaml.safe_load(file)

# Update indexer api keys
config_data['prowlarr']['api_key'] = os.getenv('PROWLARR_API_KEY')
for indexer_name, indexer_config in config_data['prowlarr']['settings']['indexers']['indexers']['definitions'].items():
	env_var_name = f"{indexer_name.upper()}_API_KEY"
	api_key = os.getenv(env_var_name)
	if api_key:
		indexer_config['secret_fields']['apiKey'] = api_key
# Update app api keys
for app_name, app_config in config_data['prowlarr']['settings']['apps']['applications']['definitions'].items():
	env_var_name = f"{app_name.upper()}_API_KEY"
	api_key = os.getenv(env_var_name)
	if api_key:
		app_config['api_key'] = api_key
# Update downloader api keys
for downloader_name, downloader_config in config_data['prowlarr']['settings']['download_clients']['definitions'].items():
	env_var_name = f"{downloader_name.upper()}_API_KEY"
	api_key = os.getenv(env_var_name)
	if api_key:
		downloader_config['api_key'] = api_key

# Write the updated YAML data back to the file
with open(BUILDARR_CONFIG_FILE, 'w') as file:
	yaml.safe_dump(config_data, file, default_flow_style=False)

print('All API keys updated in buildarr.yml')
