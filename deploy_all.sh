#!/bin/bash

set -e  # Exit on error

# Load configuration
CONFIG_FILE="config/config.cfg"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "Configuration file $CONFIG_FILE not found! Exiting."
    exit 1
fi

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Ensure Docker network exists
ensure_network() {
    if ! sudo docker network inspect "$NETWORK_NAME" &>/dev/null; then
        log "Creating Docker network: $NETWORK_NAME"
        sudo docker network create "$NETWORK_NAME"
    else
        log "Docker network $NETWORK_NAME already exists."
    fi
}

# Deploy Wazuh
deploy_wazuh() {
    log "Deploying Wazuh..."
    if [ ! -d "$SOC_DIR/modules/wazuh" ]; then
        sudo git clone $WAZUH_REPO "$SOC_DIR/modules/wazuh" -b $WAZUH_VERSION
    fi
    cd "$SOC_DIR/modules/wazuh/single-node"
    sudo sysctl -w vm.max_map_count=262144
    ensure_network
    sudo docker-compose -f generate-indexer-certs.yml run --rm generator
    sudo docker-compose up -d
    log "Wazuh deployed successfully."
}

# Deploy DFIR IRIS
deploy_iris() {
    log "Deploying DFIR IRIS..."
    if [ ! -d "$SOC_DIR/modules/dfir-iris" ]; then
        sudo git clone $IRIS_REPO "$SOC_DIR/modules/dfir-iris"
        cd "$SOC_DIR/modules/dfir-iris"
        sudo git checkout $IRIS_VERSION
    fi
    ensure_network
    sudo docker-compose up -d
    log "DFIR IRIS deployed successfully."
}

# Deploy Shuffle
deploy_shuffle() {
    log "Deploying Shuffle..."
    if [ ! -d "$SOC_DIR/modules/shuffle" ]; then
        sudo git clone $SHUFFLE_REPO "$SOC_DIR/modules/shuffle"
        cd "$SOC_DIR/modules/shuffle"
        sudo git checkout $SHUFFLE_VERSION
    fi
    ensure_network
    sudo docker-compose up -d
    log "Shuffle deployed successfully."
}

# Deploy MISP
deploy_misp() {
    log "Deploying MISP..."
    if [ ! -d "$SOC_DIR/modules/misp" ]; then
        sudo git clone $MISP_REPO "$SOC_DIR/modules/misp"
        cd "$SOC_DIR/modules/misp"
        cp template.env .env
        sudo sed -i "s/^BASE_URL=.*/BASE_URL=https:\\/\\/localhost:$MISP_HTTPS_PORT/" .env
        sudo sed -i "s/- \"80:80\"/- \"$MISP_HTTP_PORT:80\"/g; s/- \"443:443\"/- \"$MISP_HTTPS_PORT:443\"/g" docker-compose.yml
    fi
    ensure_network
    sudo docker-compose up -d
    log "MISP deployed successfully."
}

# Deploy Grafana
deploy_grafana() {
    log "Deploying Grafana..."
    sudo docker run -d -p 3000:3000 --name=grafana grafana/grafana-oss || { log "Failed to deploy Grafana. Exiting."; exit 1; }
    log "Grafana deployed successfully."
}

# Main Deployment
log "Starting full deployment of core services..."
deploy_wazuh
deploy_iris
deploy_shuffle
deploy_misp
deploy_grafana
log "All core services deployed successfully!"
