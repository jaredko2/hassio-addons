#!/usr/bin/env bashio
# ^^^ Using bashio shebang

set -e # Exit immediately if a command exits with a non-zero status.

bashio::log.info "VCAN Cannelloni Add-on starting..."

# Directory where the binary and its libraries were copied inside the container
BIN_DIR="/app/bin"
CANNELLONI_BIN="${BIN_DIR}/cannelloni"

bashio::log.info "Expecting cannelloni binary at: ${CANNELLONI_BIN}"
bashio::log.info "Setting library path to: ${BIN_DIR}"

# --- Set Library Path ---
# Prepend the internal binary directory to the library search path
export LD_LIBRARY_PATH="${BIN_DIR}:${LD_LIBRARY_PATH:-}"

# --- Setup vcan0 ---
bashio::log.info "Attempting to create vcan0 interface..."
if ip link show vcan0 > /dev/null 2>&1; then
    bashio::log.warning "vcan0 already exists. Skipping creation."
else
    if ip link add name vcan0 type vcan; then
        bashio::log.info "Successfully added vcan0 interface."
    else
        bashio::log.error "Failed to add vcan0 interface."
        # exit 1 # Optional: exit on failure
    fi
fi

bashio::log.info "Bringing up vcan0 interface..."
if ip link set dev vcan0 up; then
    bashio::log.info "Successfully brought up vcan0 interface."
else
    bashio::log.error "Failed to bring up vcan0 interface."
    # exit 1 # Optional: exit on failure
fi

# --- Start Cannelloni ---
bashio::log.info "Starting cannelloni..."
# Execute cannelloni from its internal path. LD_LIBRARY_PATH is inherited.
exec "${CANNELLONI_BIN}" -I vcan0 -C c -R 192.168.13.220

# This part is only reached if exec fails or cannelloni exits
bashio::log.warning "Cannelloni process exited unexpectedly."
exit 1
