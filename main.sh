#!/bin/bash

set -e  # Exit on any error

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

# Functions for deploying services
deploy_all() {
    log "Calling deploy_all.sh to deploy all core services..."
    sudo bash deploy_all.sh || { log "Failed to execute deploy_all.sh. Exiting."; exit 1; }
    log "All core services deployed successfully via deploy_all.sh."
}

deploy_wazuh() {
    log "Deploying Wazuh..."
    cd "$SOC_DIR/modules/wazuh"
    sudo docker-compose up -d || { log "Failed to deploy Wazuh."; }
    log "Wazuh deployed successfully."
}

deploy_iris() {
    log "Deploying DFIR IRIS..."
    cd "$SOC_DIR/modules/dfir-iris"
    
    sudo docker-compose up -d || { log "Failed to deploy DFIR IRIS."; }
    log "DFIR IRIS deployed successfully."
}

deploy_shuffle() {
    log "Deploying Shuffle..."
    cd "$SOC_DIR/modules/shuffle"
    sudo docker-compose up -d || { log "Failed to deploy Shuffle."; }
    log "Shuffle deployed successfully."
}

deploy_misp() {
    log "Deploying MISP..."
    cd "$SOC_DIR/modules/misp"
    sudo docker-compose up -d || { log "Failed to deploy MISP."; }
    log "MISP deployed successfully."
}

deploy_grafana() {
    log "Deploying Grafana and Prometheus..."
    cd "$SOC_DIR/modules/grafana"
    sudo docker-compose up -d || { log "Failed to deploy Grafana and Prometheus."; }
    log "Grafana and Prometheus deployed successfully."
}

deploy_yara() {
    log "Deploying Yara..."
    cd "$SOC_DIR/modules/yara"
    # Add Yara-specific deployment steps here
    log "Yara deployed successfully."
}

deploy_opencti() {
    log "Deploying OpenCTI..."
    cd "$SOC_DIR/modules/opencti"
    # Add OpenCTI-specific deployment steps here
    log "OpenCTI deployed successfully."
}

# Dropdown Menu
while true; do
    CHOICE=$(whiptail --title "Socarium Deployment Menu" --menu "Choose an option:" 20 78 12 \
        "0" "Install Prerequisites" \
        "1" "Deploy All Core Services" \
        "2" "Deploy Wazuh" \
        "3" "Deploy DFIR IRIS" \
        "4" "Deploy Shuffle" \
        "5" "Deploy MISP" \
        "6" "Deploy Grafana" \
        "7" "Deploy Yara" \
        "8" "Deploy OpenCTI" \
        "9" "Exit" 3>&1 1>&2 2>&3)

    case $CHOICE in
        0) log "Installing prerequisites..."; bash install_prerequisites.sh ;;
        1) deploy_all ;;
        2) deploy_wazuh ;;
        3) deploy_iris ;;
        4) deploy_shuffle ;;
        5) deploy_misp ;;
        6) deploy_grafana ;;
        7) deploy_yara ;;
        8) deploy_opencti ;;
        9) log "Exiting menu."; exit 0 ;;
        *) log "Invalid option. Please try again." ;;
    esac
done
