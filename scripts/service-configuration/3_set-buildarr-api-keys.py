import os
from dotenv import load_dotenv
import yaml

# Load the environment variables from .env file
script_dir = os.path.dirname(os.path.abspath(__file__))
load_dotenv(dotenv_path=os.path.join(script_dir, '../../.env'))

# Define the path to the YAML file
BUILDARR_SECRETS_FILE = os.path.join(script_dir, '../../buildarr/buildarr-secret.yml')

# Read the existing YAML file
with open(BUILDARR_SECRETS_FILE, 'r') as file:
	config_data = yaml.safe_load(file)


config_data['prowlarr']['api_key'] = os.getenv('PROWLARR_API_KEY')
config_data['radarr']['api_key'] = os.getenv('RADARR_API_KEY')
config_data['sonarr']['api_key'] = os.getenv('SONARR_API_KEY')

#################################
# Update indexer api keys
#################################

for indexer_name, indexer_config in config_data['prowlarr']['settings']['indexers']['indexers']['definitions'].items():
	env_var_name = f"{indexer_name.upper()}_API_KEY"
	api_key = os.getenv(env_var_name)
	if api_key:
		indexer_config['secret_fields']['apiKey'] = api_key

#################################
# Update app api keys
#################################

for app_name, app_config in config_data['prowlarr']['settings']['apps']['applications']['definitions'].items():
	env_var_name = f"{app_name.upper()}_API_KEY"
	api_key = os.getenv(env_var_name)
	if api_key:
		app_config['api_key'] = api_key

#################################
# Update download client api keys
#################################
services_to_update = ['prowlarr', 'sonarr', 'radarr']
for service_name in services_to_update:
	for downloader_name, downloader_config in config_data[service_name]['settings']['download_clients']['definitions'].items():
		env_var_name = f"{downloader_name.upper()}_API_KEY"
		api_key = os.getenv(env_var_name)
		if api_key:
			downloader_config['api_key'] = api_key


# Write the updated YAML data back to the file
with open(BUILDARR_SECRETS_FILE, 'w') as file:
	yaml.safe_dump(config_data, file, default_flow_style=False)

print('All API keys updated in buildarr-secret.yml')
