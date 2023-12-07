import requests
import yaml
import os
from dotenv import load_dotenv

# Load the .env file
dotenv_path = '../../../.env'  # Replace with your custom .env file path
load_dotenv(dotenv_path=dotenv_path)

# Load YAML configuration
def load_yaml_config(file_path):
    with open(file_path, 'r') as f:
        return yaml.safe_load(f)

SABNZBD_API_KEY = os.getenv('SABNZBD_API_KEY')
SABNZBD_HOST = os.getenv('SABNZBD_HOST')  # Change the port if needed
CONFIG_FILE_PATH = './config.yml'  # Path to your YAML config file

def set_usenet_server(server_info):
    """Sets a Usenet server configuration in SABnzbd."""
    url = f"{SABNZBD_HOST}/sabnzbd/api"
    # Prepare the parameters for the API request
    params = {
        'mode': 'set_config',
        'section': 'servers',
        'name': server_info['name'],
        'displayname': server_info['displayname'],
        'host': server_info['host'],
        'port': server_info['port'],
        'username': server_info['username'],
        'password': server_info['password'],
        'connections': server_info['connections'],
        'ssl': int(server_info['ssl']),  # Convert boolean to int
        'priority': server_info['priority'],
        'retention': server_info['retention'],
        'timeout': server_info['timeout'],
        'ssl_verify': int(server_info['ssl_verify']),  # Convert boolean to int
        'ssl_ciphers': server_info['ssl_ciphers'],
        'required': int(server_info['required']),  # Convert boolean to int
        'optional': int(server_info['optional']),  # Convert boolean to int
        'send_group': int(server_info['send_group']),
        'expire_date': server_info['expire_date'],
        'quota': server_info['quota'],
        'enable': int(server_info['enable']),  # Convert boolean to int
        'notes': server_info['notes'],
        'apikey': SABNZBD_API_KEY, # used to talk to sabnzbd
    }

    response = requests.get(url, params=params)
    if response.status_code == 200:
        print(f"Server {server_info['name']} configuration set successfully.")
        return True
    else:
        print(f"Failed to set server {server_info['name']} configuration.")
        return False

# Load the server configurations from the YAML file
server_configurations = load_yaml_config(CONFIG_FILE_PATH)

# Set each server configuration
for server in server_configurations['servers']:
    set_usenet_server(server)
