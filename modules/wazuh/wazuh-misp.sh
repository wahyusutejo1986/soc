#!/bin/bash

SOC_DIR="/home/$(logname)/soc"

# File path to wazuh_manager.conf
CONFIG_FILE="$SOC_DIR/wazuh-docker/single-node/config/wazuh_cluster/wazuh_manager.conf"

# MISP configuration to add
MISP_CONFIG=$(cat <<'EOF'
<!--integration-misp-->
<integration>
  <name>custom-misp</name>
  <group>sysmon_event1,sysmon_event3,sysmon_event6,sysmon_event7,sysmon_event_15,sysmon_event_22,syscheck</group>
  <alert_format>json</alert_format>
</integration>
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

# Check if the MISP configuration already exists in the file
if grep -q "<!--integration-misp-->" "$CONFIG_FILE"; then
  echo "MISP configuration already exists in $CONFIG_FILE."
else
  # Create a temporary file for the modified configuration
  TEMP_FILE=$(mktemp)

  # Insert the MISP configuration above </ossec_config>
  sudo awk -v misp_config="$MISP_CONFIG" '
    /<\/ossec_config>/ {
      print "\n" misp_config "\n"
    }
    { print }
  ' "$CONFIG_FILE" > "$TEMP_FILE"

  # Replace the original file with the modified file
  sudo mv "$TEMP_FILE" "$CONFIG_FILE"
  echo "MISP configuration has been successfully."
fi
