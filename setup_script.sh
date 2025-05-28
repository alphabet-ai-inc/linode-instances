#!/bin/bash
# This StackScript installs git, Docker, Docker Compose, Nginx (in a container), 
# Portainer (in a container), clones an application repository, and runs docker compose.

# <UDF name="app_repository" label="Application Git Repository URL" example="https://github.com/user/repo.git" />
# Define the application repository URL as a UDF variable
APP_REPOSITORY="https://github.com/alphabet-ai-inc/authserver"

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

# Create Nginx configuration for proxying to Portainer and application
mkdir -p /root/nginx
cat << 'EOF' > /root/nginx/nginx.conf
events {}
http {
    server {
        listen 80;
        server_name _;

        location / {
            proxy_pass http://localhost:8080; # Adjust port if your app uses a different one
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        location /portainer/ {
            proxy_pass http://localhost:9000/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
EOF

# Run Nginx in a container
docker run -d \
    --name nginx \
    --restart always \
    -p 80:80 \
    -v /root/nginx/nginx.conf:/etc/nginx/nginx.conf:ro \
    nginx:latest

# Run Portainer in a container
docker run -d \
    --name portainer \
    --restart always \
    -p 9000:9000 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    portainer/portainer-ce:latest

# Create /app directory
mkdir -p /app

# Clone the application repository
cd /app
git clone "$APP_REPOSITORY"

# Navigate to the cloned repository (assuming it clones to a directory named after the repo)
REPO_NAME=$(basename "$APP_REPOSITORY")
cd "/app/$REPO_NAME"

# Run docker compose up -d
docker-compose up -d

# Open firewall ports (if ufw is enabled)
if command -v ufw >/dev/null; then
    ufw allow 80/tcp
    ufw allow 9000/tcp
fi

# Clean up
apt-get autoclean
apt-get autoremove --purge -y

# Log completion
echo "StackScript completed: Git, Docker, Nginx, Portainer, and application deployed."
