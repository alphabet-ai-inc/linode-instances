#!/bin/bash
# This StackScript installs git, Docker, Docker Compose, Portainer (in a container),
# clones both backend and frontend repositories, creates a shared network, and runs docker compose.

# <UDF name="app_repository" label="Application Git Repository URL" example="https://github.com/user/repo.git" />
# Define the application repository URLs as variables
APP_REPOSITORY="https://github.com/alphabet-ai-inc/authserver"
FRONTEND_REPOSITORY="https://github.com/alphabet-ai-inc/authserver_front_end"

# Exit on error
set -e

# Set non-interactive frontend for apt
export DEBIAN_FRONTEND=noninteractive

# Update system and install prerequisites
apt-get update -y
apt-get install -y curl ca-certificates gnupg-agent software-properties-common wget

# Install git
apt-get install -y git

# Install Docker
curl -fsSL get.docker.com -o get-docker.sh && chmod +x get-docker.sh && ./get-docker.sh

# Enable and start Docker
systemctl enable docker
systemctl start docker

# Add user to docker group
usermod -aG docker $(whoami)

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Run Portainer in a container
docker run -d \
    --name portainer \
    --restart always \
    -p 9000:9000 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    portainer/portainer-ce:latest

# Create shared Docker network
docker network create authserver-network

# Create /app directory and clone repositories
mkdir -p /app
cd /app

# Clone and deploy backend
git clone "$APP_REPOSITORY"
BACKEND_REPO_NAME=$(basename "$APP_REPOSITORY")
cd "/app/$BACKEND_REPO_NAME"
docker-compose up -d

# Clone and deploy frontend
cd /app
git clone "$FRONTEND_REPOSITORY"
FRONTEND_REPO_NAME=$(basename "$FRONTEND_REPOSITORY")
cd "/app/$FRONTEND_REPO_NAME"
docker-compose up -d

# Open firewall ports (if ufw is enabled)
if command -v ufw >/dev/null; then
    ufw allow 80/tcp
    ufw allow 9000/tcp
    ufw allow 3000/tcp
    ufw allow 8080/tcp
fi

# Clean up
apt-get autoclean
apt-get autoremove --purge -y

# Log completion
echo "StackScript completed: Git, Docker, Portainer, and applications deployed."