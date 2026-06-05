#!/bin/bash

# Stride Project - Server Setup Script
# This script creates a dedicated user and prepares the server for Docker deployment.

# Configuration
PROJECT_USER="stride_admin"
APP_DIR="/home/$PROJECT_USER/app"

echo "🚀 Starting server setup for Stride Backend..."

# 1. Create the dedicated project user if it doesn't exist
if id "$PROJECT_USER" &>/dev/null; then
    echo "✅ User $PROJECT_USER already exists."
else
    echo "👤 Creating dedicated user: $PROJECT_USER..."
    sudo useradd -m -s /bin/bash "$PROJECT_USER"
    echo "✅ User $PROJECT_USER created."
fi

# 2. Install Docker & Docker Compose if not present
if ! command -v docker &> /dev/null; then
    echo "📦 Installing Docker..."
    sudo apt-get update
    sudo apt-get install -y docker.io docker-compose-v2
    sudo systemctl enable --now docker
fi

# 3. Add the user to the docker group
echo "🛡️ Adding $PROJECT_USER to the docker group..."
sudo usermod -aG docker "$PROJECT_USER"

# 4. Prepare the application directory
echo "📂 Preparing application directory at $APP_DIR..."
sudo mkdir -p "$APP_DIR"
sudo chown -R "$PROJECT_USER:$PROJECT_USER" "$APP_DIR"

# 5. Instructions for the user
echo ""
echo "🎉 Server setup complete!"
echo "--------------------------------------------------------"
echo "NEXT STEPS:"
echo "1. Log in as the project user: sudo su - $PROJECT_USER"
echo "2. Clone your repository: git clone <your-repo-url> $APP_DIR"
echo "3. Go to the backend folder: cd $APP_DIR/backend"
echo "4. Create your .env file: cp .env.production.example .env"
echo "5. Edit the .env with your secrets: nano .env"
echo "6. Build and start the container: docker compose up -d --build"
echo "--------------------------------------------------------"
