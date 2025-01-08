#!/bin/bash

SOC_DIR="/home/$(logname)/soc"

# File path to wazuh_manager.conf
CONFIG_FILE="$SOC_DIR/wazuh-docker/single-node/config/wazuh_cluster/wazuh_manager.conf"

# IRIS configuration to add
IRIS_CONFIG=$(cat <<'EOF'
<!--integration-iris-->
  <integration>
    <name>integration-iris.py</name>
    <hook_url>https://<IRIS_IP_ADDRESS>/alerts/add</hook_url>
    <level>7</level>
    <api_key><IRIS_API_KEY></api_key> <!-- Replace with your IRIS API key -->
    <alert_format>json</alert_format>
  </integration
EOF
)

# Debugging: Check if the file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Error: File $CONFIG_FILE does not exist."
  exit 1
else
  echo "File $CONFIG_FILE exists."
fi

# Debugging: Check file permissions
if [[ ! -w "$CONFIG_FILE" ]]; then
  echo "File $CONFIG_FILE is not writable. Attempting to write with sudo."
fi

# Check if the IRIS configuration already exists in the file
if grep -q "<!--interation-iris-->" "$CONFIG_FILE"; then
  echo "MISP configuration already exists in $CONFIG_FILE."
else
  # Create a temporary file for the modified configuration
  TEMP_FILE=$(mktemp)

  # Insert the IRIS configuration above </ossec_config>
  sudo awk -v iris_config="$IRIS_CONFIG" '
    /<\/ossec_config>/ {
      print "\n" iris_config "\n"
    }
    { print }
  ' "$CONFIG_FILE" > "$TEMP_FILE"

  # Replace the original file with the modified file
  sudo mv "$TEMP_FILE" "$CONFIG_FILE"
  echo "IRIS configuration has been successfully."
fi
