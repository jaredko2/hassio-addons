# /addons/vcan_cannelloni/Dockerfile
# Use a minimal base image
ARG BUILD_FROM=ghcr.io/home-assistant/base:stable
FROM ${BUILD_FROM}

# Install necessary packages:
# iproute2 provides the 'ip' command
# Add bash for easier scripting in run.sh
# We REMOVED 'cannelloni' from here as we'll use the one from /share
RUN apk add --no-cache iproute2 bash

# Copy the run script into the container
COPY run.sh /

# Make the run script executable
RUN chmod a+x /run.sh

# Command that runs when the container starts
CMD [ "/run.sh" ]
