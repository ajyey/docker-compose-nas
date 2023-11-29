#!/bin/bash

# See https://stackoverflow.com/a/44864004 for the sed GNU/BSD compatible hack

#!/bin/bash

# Function to extract the API key from tautulli config file
extract_api_key_from_ini() {
    local config_file="$1"
    grep "^api_key = " "$config_file" | cut -d ' ' -f 3
}


TAUTULLI_CONFIG_FILE="./tautulli/config/config.ini"

echo "Updating Radarr configuration..."
until [ -f ./radarr/config.xml ]
do
  sleep 5
done
sed -i.bak "s/<UrlBase><\/UrlBase>/<UrlBase>\/radarr<\/UrlBase>/" ./radarr/config.xml && rm ./radarr/config.xml.bak
sed -i.bak 's/^RADARR_API_KEY=.*/RADARR_API_KEY='"$(sed -n 's/.*<ApiKey>\(.*\)<\/ApiKey>.*/\1/p' ./radarr/config.xml)"'/' .env && rm .env.bak

echo "Updating Sonarr configuration..."
until [ -f ./sonarr/config.xml ]
do
  sleep 5
done
sed -i.bak "s/<UrlBase><\/UrlBase>/<UrlBase>\/sonarr<\/UrlBase>/" ./sonarr/config.xml && rm ./sonarr/config.xml.bak
sed -i.bak 's/^SONARR_API_KEY=.*/SONARR_API_KEY='"$(sed -n 's/.*<ApiKey>\(.*\)<\/ApiKey>.*/\1/p' ./sonarr/config.xml)"'/' .env && rm .env.bak

echo "Updating Lidarr configuration..."
until [ -f ./lidarr/config.xml ]
do
  sleep 5
done
sed -i.bak "s/<UrlBase><\/UrlBase>/<UrlBase>\/lidarr<\/UrlBase>/" ./lidarr/config.xml && rm ./lidarr/config.xml.bak
sed -i.bak 's/^LIDARR_API_KEY=.*/LIDARR_API_KEY='"$(sed -n 's/.*<ApiKey>\(.*\)<\/ApiKey>.*/\1/p' ./lidarr/config.xml)"'/' .env && rm .env.bak

echo "Updating Readarr configuration..."
until [ -f ./readarr/config.xml ]
do
  sleep 5
done
sed -i.bak "s/<UrlBase><\/UrlBase>/<UrlBase>\/readarr<\/UrlBase>/" ./readarr/config.xml && rm ./readarr/config.xml.bak
sed -i.bak 's/^READARR_API_KEY=.*/READARR_API_KEY='"$(sed -n 's/.*<ApiKey>\(.*\)<\/ApiKey>.*/\1/p' ./readarr/config.xml)"'/' .env && rm .env.bak

echo "Updating Prowlarr configuration..."
until [ -f ./prowlarr/config.xml ]
do
  sleep 5
done
sed -i.bak "s/<UrlBase><\/UrlBase>/<UrlBase>\/prowlarr<\/UrlBase>/" ./prowlarr/config.xml && rm ./prowlarr/config.xml.bak
sed -i.bak 's/^PROWLARR_API_KEY=.*/PROWLARR_API_KEY='"$(sed -n 's/.*<ApiKey>\(.*\)<\/ApiKey>.*/\1/p' ./prowlarr/config.xml)"'/' .env && rm .env.bak

echo "Updating Tautulli configuration..."
until [ -f "$TAUTULLI_CONFIG_FILE" ]
do
  sleep 5
done
TAUTULLI_API_KEY=$(extract_api_key_from_ini "$TAUTULLI_CONFIG_FILE")
echo ${NEW_SERVICE_API_KEY}
sed -i.bak 's/^TAUTULLI_API_KEY=.*/TAUTULLI_API_KEY='"$TAUTULLI_API_KEY"'/' .env && rm .env.bak

echo "Restarting containers..."
sudo docker compose restart radarr sonarr lidarr readarr prowlarr tautulli


