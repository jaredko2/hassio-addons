# /addons/vcan_cannelloni/Dockerfile

# IMPORTANT: Replace 'amd64' with your actual HA system architecture
ARG BUILD_ARCH=amd64
ARG BUILD_FROM=ghcr.io/home-assistant/${BUILD_ARCH}-base:latest
FROM ${BUILD_FROM}

# Install necessary packages:
# iproute2: for 'ip' command
# bash: for scripting
# gcompat: Provides glibc compatibility layer for binaries compiled against glibc
RUN apk add --no-cache iproute2 bash gcompat

# Create a directory for the application binary and libraries
WORKDIR /app
RUN mkdir -p /app/bin

# Copy the run script into the container root
COPY run.sh /

# Copy the cannelloni binary and its libraries from the local 'local_bin' folder
# into the '/app/bin' directory inside the container.
COPY local_bin/ /app/bin/

# Make the run script and the copied binaries/libraries executable
# Ensure the binary itself has execute permissions after copy
RUN chmod a+x /run.sh && \
    chmod +x /app/bin/cannelloni && \
    find /app/bin/ -name '*.so*' -exec chmod +x {} \; # Ensure libs also have execute if needed (usually not, but safe)


# Set the working directory
WORKDIR /

# Command that runs when the container starts
CMD [ "/run.sh" ]
