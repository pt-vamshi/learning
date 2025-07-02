# Python Hello World with Docker

A simple Python Flask application containerized with Docker.

## Features
- **Hot Reload**: Code changes are automatically detected and the server restarts
- **Volume Mounting**: Local code is mounted into the container for real-time development
- **Nginx Reverse Proxy**: Professional web server frontend
- **Health Checks**: Built-in health monitoring

## Quick Start

### Using Docker Compose (Recommended)
```bash
# Build and run
docker-compose up --build

# Run in background
docker-compose up -d

# Stop
docker-compose down
```

### Using Docker directly
```bash
# Build image
docker build -t python-hello-world .

# Run container
docker run -p 80:80 -p 8000:8000 python-hello-world

# Run in background
docker run -d -p 80:80 -p 8000:8000 --name hello-world python-hello-world
```

## Access the Application

- **Main endpoint**: http://localhost (via Nginx)
- **Direct Python app**: http://localhost:8000
- **Health check**: http://localhost/health

## API Endpoints

- `GET /` - Returns Hello World message with container info
- `GET /health` - Health check endpoint

## Files

- `app.py` - Flask application
- `requirements.txt` - Python dependencies
- `Dockerfile` - Combined Python + Nginx Docker image
- `nginx.conf` - Nginx configuration
- `docker-compose.yml` - Single container setup
- `.dockerignore` - Files to exclude from Docker build

## Developer Notes

- **No need to rebuild after initial setup!**
  - Once you run `docker-compose up --build` the first time, you can use just `docker-compose up` for subsequent runs.
  - Thanks to Docker volumes, changes to `app.py`, `nginx.conf`, or `start.sh` are reflected live in the running container.

## Volumes

The following files are mounted as volumes for live reload:
- `app.py` → `/app/app.py`
- `nginx.conf` → `/etc/nginx/nginx.conf`
- `start.sh` → `/app/start.sh`

## Screenshot

Below is a sample screenshot of the running app in the browser:

![App Screenshot](Screenshot%202025-07-02%20at%208.44.13%E2%80%AFPM%20(2).png)

> To update the screenshot: Replace this file in the folder with your own. 