#!/usr/bin/env bash
set -e # Exit immediately if a command exits with a non-zero status.

# Bashio is a helper library for Home Assistant add-ons
if [ -f /usr/bin/bashio ]; then
    # shellcheck source=/dev/null
    source /usr/bin/bashio
else
    echo "Error: bashio not found. Make sure the base image includes it."
    exit 1
fi

echo "VCAN Cannelloni Add-on starting..."

# Read configuration options using bashio
REMOTE_IP=$(bashio::config 'remote_ip')
LOCAL_CAN_IF=$(bashio::config 'local_can_interface')
# Define the path to the binary inside the container (mapped from host:/share)
CANNELLONI_BIN="/share/cannelloni_bin/cannelloni" # Adjust 'cannelloni_bin' if you used a different subfolder name

bashio::log.info "Using Remote IP: ${REMOTE_IP}"
bashio::log.info "Using Local CAN Interface: ${LOCAL_CAN_IF}"
bashio::log.info "Expecting cannelloni binary at: ${CANNELLONI_BIN}"

# Check if the binary exists and is executable
if [ ! -x "${CANNELLONI_BIN}" ]; then
    bashio::log.fatal "Cannelloni binary not found or not executable at ${CANNELLONI_BIN}. Please ensure it's placed in the host's /share/cannelloni_bin/ directory and has execute permissions (chmod +x)."
    exit 1
fi

# --- Setup vcan0 ---
bashio::log.info "Attempting to create vcan0 interface..."
if ip link show vcan0 > /dev/null 2>&1; then
    bashio::log.warning "vcan0 already exists. Skipping creation."
else
    ip link add name vcan0 type vcan || bashio::log.error "Failed to add vcan0"
fi

bashio::log.info "Bringing up vcan0 interface..."
ip link set dev vcan0 up || bashio::log.error "Failed to bring up vcan0"

# --- Start Cannelloni ---
bashio::log.info "Starting cannelloni from mapped directory..."
# Execute cannelloni using its path inside the container's /share mount
exec "${CANNELLONI_BIN}" -I "${LOCAL_CAN_IF}" -C c -R "${REMOTE_IP}"

# This part of the script will only be reached if cannelloni exits
bashio::log.warning "Cannelloni process exited."

exit 0
