#!/bin/bash

set -e  # Exit on error

# get directory where this script install_all.sh executed
# BASE_DIR=$(pwd)

# Load configuration
script_dir=$(cd "$(dirname "$0")" && pwd)
parent_dir=$(dirname "$script_dir")
grandparent_dir=$(dirname "$parent_dir")
CONFIG_FILE="${grandparent_dir}/config/config.cfg"
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
else
    echo "Configuration file $CONFIG_FILE not found! Exiting."
    exit 1
fi

# Create /tmp/socarium directory if it doesn't exist
SOC_DIR="/tmp/socarium"
if [ ! -d "$SOC_DIR" ]; then
    echo "Creating directory $SOC_DIR..."
    mkdir -p "$SOC_DIR"
else
    echo "Directory $SOC_DIR already exists."
fi

# Copy modules directory to /tmp/socarium if it doesn't already exist
MODULES_SRC="modules"
MODULES_DEST="$SOC_DIR/modules"
if [ ! -d "$MODULES_DEST" ]; then
    echo "Copying modules to $SOC_DIR..."
    cp -r "$MODULES_SRC" "$MODULES_DEST"
else
    echo "Modules directory already exists in $SOC_DIR. Skipping copy."
fi

cd "$SOC_DIR"

# MISP installation
echo "Installing MISP..."
if [ ! -d "misp-docker" ]; then
    # clone official misp repository latest version
    git clone https://github.com/MISP/misp-docker.git
    #change directory to misp-docker after clone success
    cd $SOC_DIR/misp-docker
    #copy template.env to .env
    cp template.env .env
    #add value for variable BASE_URL=https://localhost:10443/    
    sed -i 's|^BASE_URL=.*|BASE_URL=https://'"$MISP_REDIRECT_URL:$MISP_HTTPS_PORT"'|' .env
    #prevent port conflict with other platform to 8181 for http and 10443 for https
    sed -i 's|- "80:80"|- "8181:80"|g; s|- "443:443"|- "10443:443"|g' docker-compose.yml
    #pull image for faster deployment instead of build
    sudo docker-compose pull
    #running the containers
    sudo docker compose up -d
    cd "$SOC_DIR"
else
    echo "MISP already installed. Checking health..."
    #ensure_container_health "misp" "misp/docker-compose.yml"
    sudo docker ps --filter "name=misp"
fi
