#!/bin/bash

# MISP installation
echo "Installing MISP..."
if [ ! -d "misp" ]; then
    git clone https://github.com/MISP/misp-docker.git
    cd misp-docker

    # Create the socarium-network if it doesn't exist
    echo "Ensuring socarium-network exists..."
    if ! sudo docker network ls | grep "socarium-network"; then
        echo "Creating external network: socarium-network"
        sudo docker network create socarium-network
    else
        echo "Network socarium-network already exists."
    fi

    sudo cp /opt/soc/modules/misp/template.env .env
    sudo cp /opt/soc/modules/misp/docker-compose.yml docker-compose.yml
    sudo docker compose up -d
    cd "$SOC_DIR"
else
    echo "MISP already installed. Checking health..."
    #ensure_container_health "misp" "misp/docker-compose.yml"
fi
