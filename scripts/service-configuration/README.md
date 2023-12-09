# What is this directory for?

This configuration directory stores scripts to take some of the pain out of configuring many of the services within the stack

```bash
.
├── 1_create-file-structure.sh
├── 2_set-env-api-keys.py
├── README.md
├── configure.py
├── configure.sh
├── requirements.txt
└── sabnzbd
    ├── config.example.yml
    └── configure-sabnzbd.py


```

These scripts assume you have your Ubuntu server already setup and are now ready to start your services for the first time.

To get started, perform the following steps:
- Make sure you've filled out your `.env` file
  - In particular, make sure you've set your `DATA_ROOT` and the various usenet indexer API keys
- Run `1_create-file-structure.sh`
  - This creates the file structure necessary for the various media services to work correctly
  - E.g. Sonarr, Radarr, etc
- Bring the stack up for the first time
  - `docker compose up -d`
- Install python dependencies
  - `pip install -r requirements.txt`
- Run `2_set-api-keys.py`
  - This will pull the API keys from the configuration files of the following services and set them correctly in your .env file. It will then restart the services
    - Sonarr
    - Radarr
    - Readarr
    - Lidarr
    - Sabnzbd
    - Tautulli
- Run `3_set-buildarr-api-keys.py`
  - This will pull the now set API keys from your .env file and set them in the buildarr configuration
- Run `4_set-recyclarr-api-keys.py`
  - This will pull the now set API keys from your .env file and set them in the recyclarr secrets configuration file
- Run `docker compose -f docker-compose-buildarr.yml run --rm buildarr run /config/buildarr.yml`
  - This will perform a run of buildarr, which will do some initial configuration of prowlarr, radarr, and sonarr
    - This configuration includes:
      - Setting up indexers and apps in prowlarr (including app sync)
      - Setting up download clients in sonarr and radarr
- Run `configure-sabnzbd.py`
  - This will use the `config.yml` at `service-configuration/sabnzbd/config.yml` to configure Sabnzbd for you.
    - Make sure you use the example provided. At this time setting up your servers is supported.
