#!/bin/bash

set -e  # Exit on error

# Load configuration
CONFIG_FILE="./config/config.cfg"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "Configuration file $CONFIG_FILE not found! Exiting."
    exit 1
fi

# get directory where this script install_all.sh executed
BASE_DIR=$(pwd)

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

# DFIR IRIS installation
echo "Installing DFIR IRIS..."
if [ ! -d "iris-web" ]; then
    git clone https://github.com/dfir-iris/iris-web.git
    cd iris-web
    # switch to stable version v2.4.19
    git checkout v2.4.19

    # Create the socarium-network if it doesn't exist
    echo "Ensuring socarium-network exists..."
    if ! sudo docker network ls | grep "socarium-network"; then
        echo "Creating external network: socarium-network"
        sudo docker network create socarium-network
    else
        echo "Network socarium-network already exists."
    fi
    # Rename env.model to .env
    cp $SOC_DIR/modules/iris-web/.env.model .env
    cp $SOC_DIR/modules/iris-web/docker-compose.yml docker-compose.yml
    cp $SOC_DIR/modules/iris-web/docker-compose.base.yml docker-compose.base.yml
    cp $SOC_DIR/modules/iris-web/docker-compose.dev.yml docker-compose.dev.yml
    sudo docker-compose build
    sudo docker-compose up -d
    cd "$SOC_DIR"
else
    echo "DFIR IRIS already installed. Checking health..."
    #ensure_container_health "dfir-iris" "iris-web/docker-compose.yml"
    sudo docker ps --filter "name=irisweb"
fi