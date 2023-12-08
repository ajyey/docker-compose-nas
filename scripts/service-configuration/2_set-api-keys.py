import os
import json
import xml.etree.ElementTree as ET
import logging
from configparser import ConfigParser, MissingSectionHeaderError

logging.basicConfig(level=logging.WARNING, format='%(levelname)s: %(message)s')

# Get the absolute path of this script
script_dir = os.path.dirname(os.path.abspath(__file__))

# Update relative paths to be absolute
ENV_FILE_PATH = os.path.join(script_dir, '../../.env')
ENV_EXAMPLE_FILE_PATH = os.path.join(script_dir, '../../.env.example')
DOCKER_COMPOSE_FILE_PATH = os.path.join(script_dir, '../../docker-compose.yml')


def extract_api_key_from_xml(config_file):
	"""Extracts the API key from the specified XML config file."""
	tree = ET.parse(config_file)
	root = tree.getroot()
	for api_key in root.iter('ApiKey'):
		return api_key.text


def extract_api_key_from_json(config_file):
	"""Extracts the API key from the specified JSON config file."""
	with open(config_file, 'r') as f:
		data = json.load(f)
		return data['main']['apiKey']


def extract_api_key_from_ini(config_file):
	"""Extracts the API key from the specified INI config file."""
	config = ConfigParser()
	try:
		# Try to read the file directly
		with open(config_file, 'r') as f:
			config.read_file(f)
		# All services use the general section except for sabnzbd
		api_key_section = 'General'
	except MissingSectionHeaderError:
		# If there's a MissingSectionHeaderError, prepend a dummy section and try again
		# This is necessary because the sabnzbd.ini config file doesnt start with a section header
		with open(config_file, 'r') as f:
			config_string = '[dummy_section]\n' + f.read()
		config.read_string(config_string)
		api_key_section = 'misc'  # sabnzbd uses the misc section
	return config.get(api_key_section, 'api_key')


def update_env_file(key, value, quote=False):
	"""
    Updates the.env file with the specified key and value.
    If quote is True, wraps the value in double quotes.
    """
	# If quote is True, wrap the value in double quotes
	value_str = f'"{value}"' if quote else value

	with open(ENV_FILE_PATH, 'r') as file:
		lines = file.readlines()
	with open(ENV_FILE_PATH, 'w') as file:
		found = False
		for line in lines:
			if line.startswith(f'{key}='):
				file.write(f'{key}={value_str}\n')
				found = True
			else:
				file.write(line)
		# If the key was not found, append it to the file
		if not found:
			file.write(f'{key}={value_str}\n')


def file_exists(file_path):
	if not os.path.exists(file_path):
		logging.warning(f"File {file_path} does not exist.")
		return False
	return True


# Define the list of services to update
services = [
	{'name': 'RADARR', 'config_path': os.path.join('../../radarr/config.xml'), 'extract_func': extract_api_key_from_xml},
	{'name': 'SONARR', 'config_path': os.path.join('../../sonarr/config.xml'), 'extract_func': extract_api_key_from_xml},
	{'name': 'LIDARR', 'config_path': os.path.join('../../lidarr/config.xml'), 'extract_func': extract_api_key_from_xml},
	{'name': 'READARR', 'config_path': os.path.join('../../readarr/config.xml'), 'extract_func': extract_api_key_from_xml},
	{'name': 'PROWLARR', 'config_path': os.path.join('../../prowlarr/config.xml'), 'extract_func': extract_api_key_from_xml},
	{'name': 'OVERSEERR', 'config_path': os.path.join('../../overseerr/config/settings.json'),
	 'extract_func': extract_api_key_from_json, 'quote': True},
	{'name': 'TAUTULLI', 'config_path': os.path.join('../../tautulli/config/config.ini'), 'extract_func': extract_api_key_from_ini},
	{'name': 'SABNZBD', 'config_path': os.path.join('../../sabnzbd/config/sabnzbd.ini'), 'extract_func': extract_api_key_from_ini},
	# Add other services here
]

# Update the config path for each service to be absolute
for service in services:
	service['config_path'] = os.path.join(script_dir, service['config_path'])

# Update .env file for each service
for service in services:
	print(f"Updating {service['name']} configuration...")
	if file_exists(service['config_path']):
		api_key = service['extract_func'](service['config_path'])
		update_env_file(f"{service['name']}_API_KEY", api_key, quote=service.get('quote', False))

# Restart containers
print("Restarting containers...")
os.system(
	f"sudo docker compose --file {DOCKER_COMPOSE_FILE_PATH} restart radarr sonarr lidarr readarr prowlarr overseerr "
	f"tautulli sabnzbd homepage")

# todo
# set the api keys for the buildarr config file
# set the api keys for the recyclarr secrets file
