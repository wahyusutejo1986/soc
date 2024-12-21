#!/bin/bash

LOG_FILE="/opt/socarium/install_logs/install_all.log"
INSTALL_PATH="/opt/socarium"
mkdir -p $INSTALL_PATH
mkdir -p /opt/socarium/install_logs

# Color definitions
GREEN="\033[0;32m"
RESET="\033[0m"

# Function to display progress bar
progress_bar() {
    local PROGRESS=$1
    echo -ne "\r================== ${PROGRESS}% Completed ================="
}

# Function to execute commands with real installations and checklist
run_step() {
    local STEP_NAME=$1
    local STEP_COMMANDS=("${@:2}") # All commands passed as arguments

    echo -e "\n==================="
    echo "Current Process: $STEP_NAME"
    echo "==================="

    local LINE_COUNT=0
    local COMMAND_COUNT=0
    local TOTAL_COMMANDS=${#STEP_COMMANDS[@]}
    local STATUS=()

    # Initialize status array with empty strings
    for ((i = 0; i < TOTAL_COMMANDS; i++)); do
        STATUS[i]=""
    done

    for COMMAND in "${STEP_COMMANDS[@]}"; do
        if [ $LINE_COUNT -eq 10 ]; then
            tput cuu 10 # Move cursor up 10 lines
            LINE_COUNT=0
        fi

        # Display current status for all commands
        for ((i = 0; i < TOTAL_COMMANDS; i++)); do
            if [ $i -eq $COMMAND_COUNT ]; then
                echo -ne "${STEP_COMMANDS[i]} ${STATUS[i]}\n"
            else
                echo -ne "${STEP_COMMANDS[i]} ${STATUS[i]}\n"
            fi
        done

        # Execute the command
        eval "$COMMAND" >> $LOG_FILE 2>&1
        if [ $? -eq 0 ]; then
            STATUS[COMMAND_COUNT]="${GREEN}(complete)${RESET}"
        else
            echo -e "\n❌ Error during: $COMMAND"
            echo "Check logs: $LOG_FILE"
            exit 1
        fi

        COMMAND_COUNT=$((COMMAND_COUNT + 1))
        LINE_COUNT=$((LINE_COUNT + 1))

        # Update terminal display
        tput cuu $TOTAL_COMMANDS
    done

    # Complete section
    echo "==================="
    echo "Process Completed for: $STEP_NAME"
    echo "==================="
    sleep 1
}

# Installation processes
install_prerequisites() {
    progress_bar 10
    run_step "Install Prerequisites" \
        "sudo apt update" \
        "sudo apt install -y git curl wget" \
        "sudo apt install -y python3-pip" \
        "sudo apt install -y docker docker-compose" \
        "sudo systemctl start docker && sudo systemctl enable docker"
}

install_wazuh() {
    progress_bar 30
    run_step "Install Wazuh" \
        "git clone https://github.com/wazuh/wazuh-docker.git $INSTALL_PATH/wazuh-docker" \
        "cd $INSTALL_PATH/wazuh-docker/single-node" \
        "docker-compose build" \
        "docker-compose up -d" \
        "docker ps"
}

install_opencti() {
    progress_bar 50
    run_step "Install OpenCTI" \
        "git clone https://github.com/OpenCTI-Platform/docker.git $INSTALL_PATH/opencti" \
        "cd $INSTALL_PATH/opencti" \
        "cp .env.sample .env" \
        "docker-compose build" \
        "docker-compose up -d" \
        "docker ps"
}

install_shuffle() {
    progress_bar 70
    run_step "Install Shuffle SOAR" \
        "git clone https://github.com/shuffle/Shuffle.git $INSTALL_PATH/Shuffle" \
        "cd $INSTALL_PATH/Shuffle" \
        "docker-compose build" \
        "docker-compose up -d" \
        "docker ps"
}

install_dfir_iris() {
    progress_bar 90
    run_step "Install DFIR IRIS" \
        "git clone https://github.com/dfir-iris/iris-web.git $INSTALL_PATH/iris_web" \
        "cd $INSTALL_PATH/iris_web" \
        "cp .env.template .env" \
        "docker-compose build" \
        "docker-compose up -d" \
        "docker ps"
}

install_misp() {
    progress_bar 100
    run_step "Install MISP" \
        "git clone https://github.com/MISP/misp-docker.git $INSTALL_PATH/MISP" \
        "cd $INSTALL_PATH/MISP" \
        "cp template.env .env" \
        "docker-compose build" \
        "docker-compose up -d" \
        "docker ps"
}

# Full Installation Workflow
install_all() {
    echo "Installation progress, please wait....."
    install_prerequisites
    install_wazuh
    install_opencti
    install_shuffle
    install_dfir_iris
    install_misp
    echo -e "\n✅ All SOC platforms installed successfully!"
}

# Start the installation
install_all
