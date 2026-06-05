# Deployment Guide

This directory contains scripts and configuration for deploying the Stride Backend on a Linux server.

## Security Features
- **Dedicated Host User**: The `setup-server.sh` script creates a special `stride_admin` user on the host to isolate the application files and Docker permissions.
- **Non-Root Container User**: The `Dockerfile` creates a `stride_user` inside the container. The application process never runs as root.
- **Multi-Stage Build**: Keeps the production image small (Alpine-based) and free of build tools/source code.

## Quick Start

1. **On your server**, run the setup script:
   ```bash
   curl -sSL https://raw.githubusercontent.com/your-username/your-repo/main/deploy/setup-server.sh | bash
   ```
2. **Switch to the new user**:
   ```bash
   sudo su - stride_admin
   ```
3. **Deploy the app**:
   ```bash
   cd app/backend
   cp .env.production.example .env
   # Edit .env with your real API keys and DB URL
   docker compose up -d --build
   ```

## Backend Port
The backend is exposed on port **4000** by default.
