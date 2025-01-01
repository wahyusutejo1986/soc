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
    log "Calling install_all.sh to deploy all core services..."
    sudo ./install_all.sh || { log "Failed to execute install_all.sh. Exiting."; exit 1; }
    log "All core services deployed successfully via install_all.sh."
    cd $BASE_DIR
}

deploy_wazuh() {
    log "Deploying Wazuh..."
    cd "$BASE_DIR/modules/wazuh"
    sudo chmod +x wazuh.sh
    sudo ./wazuh.sh
    log "Wazuh deployed successfully."
    cd $BASE_DIR
}

deploy_iris() {
    log "Deploying DFIR IRIS..."
    cd "$BASE_DIR/modules/iris-web"
    sudo chmod +x dfir-iris.sh
    sudo ./dfir-iris.sh
    log "DFIR IRIS deployed successfully."
    cd $BASE_DIR
}

deploy_shuffle() {
    log "Deploying Shuffle..."
    cd "$BASE_DIR/modules/shuffle"
    sudo chmod +x shuffle.sh
    sudo ./shuffle.sh
    log "Shuffle deployed successfully."
    cd $BASE_DIR
}

deploy_misp() {
    log "Deploying MISP..."
    cd "$BASE_DIR/modules/misp"
    sudo chmod +x misp.sh
    sudo ./misp.sh
    log "MISP deployed successfully."
    cd $BASE_DIR
}

deploy_grafana() {
    log "Deploying Grafana and Prometheus..."
    cd "$BASE_DIR/modules/grafana"
    sudo docker-compose up -d || { log "Failed to deploy Grafana and Prometheus."; }
    log "Grafana and Prometheus deployed successfully."
    cd $BASE_DIR
}

deploy_yara() {
    log "Deploying Yara..."
    cd "$BASE_DIR/modules/yara"
    # Add Yara-specific deployment steps here
    sudo apt install yara -y
    log "Yara deployed successfully."
    cd $BASE_DIR
}

deploy_opencti() {
    log "Deploying OpenCTI..."
    cd "$BASE_DIR/modules/opencti"
    # Add OpenCTI-specific deployment steps here
    sudo chmod +x deploy_opencti.sh
    sudo ./deploy_opencti.sh
    log "OpenCTI deployed successfully."
    cd $BASE_DIR
}

deploy_velociraptor() {
    log "Deploying Velociraptor..."
    cd "$BASE_DIR/modules/velociraptor"
    # Add Velociraptor-specific deployment steps here
    sudo docker-compose up -d
    log "Velociraptor deployed successfully."
    cd $BASE_DIR
}

# Dropdown Menu
while true; do
    CHOICE=$(whiptail --title "Socarium SOC Packages Deployment Menu" --menu "Choose an option:" 20 78 12 \
        "0" "Install Prerequisites" \
        "1" "Deploy All Core Services" \
        "2" "Deploy Wazuh" \
        "3" "Deploy DFIR IRIS" \
        "4" "Deploy Shuffle" \
        "5" "Deploy MISP" \
        "6" "Deploy Grafana" \
        "7" "Deploy Yara" \
        "8" "Deploy OpenCTI" \
        "9" "Velociraptor" \
        "10" "Exit" 3>&1 1>&2 2>&3)

    case $CHOICE in
        0) log "Installing prerequisites..."; sudo ./install_prerequisites.sh ;;
        1) deploy_all ;;
        2) deploy_wazuh ;;
        3) deploy_iris ;;
        4) deploy_shuffle ;;
        5) deploy_misp ;;
        6) deploy_grafana ;;
        7) deploy_yara ;;
        8) deploy_opencti ;;
        9) deploy_velociraptor ;;
        10) log "Exiting menu."; exit 0 ;;
        *) log "Invalid option. Please try again." ;;
    esac
done
