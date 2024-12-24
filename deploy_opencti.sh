#!/bin/bash

# Script to automate the deployment of OpenCTI using the official GitHub repository
# Repository: https://github.com/OpenCTI-Platform/docker.git

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install Docker and try again."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose is not installed. Please install Docker Compose and try again."
    exit 1
fi

# Set the repository directory
TARGET_DIR="/opt/soc"
REPO_DIR="${TARGET_DIR}/opencti"

# Clone the OpenCTI repository and rename the directory
if [ -d "$REPO_DIR" ]; then
    echo "Repository already exists in $REPO_DIR. Pulling latest changes..."
    cd "$REPO_DIR" || exit 1
    sudo git pull
else
    echo "Cloning OpenCTI repository into $TARGET_DIR..."
    cd "$TARGET_DIR" || exit 1
    sudo git clone https://github.com/OpenCTI-Platform/docker.git
    sudo mv docker opencti
fi

cd "$REPO_DIR" || exit 1

# Create environment variables file
echo "Creating environment variables file..."
sudo bash -c 'cat <<EOL > .env
# OpenCTI
OPENCTI_ADMIN_EMAIL=admin@opencti.io
OPENCTI_ADMIN_PASSWORD=socarium
OPENCTI_ADMIN_TOKEN=$(openssl rand -hex 32)
OPENCTI_PORT=8181

# Elasticsearch
ELASTICSEARCH_URL=http://elasticsearch:9203

# MinIO
MINIO_ENDPOINT=minio
MINIO_PORT=9000
MINIO_ACCESS_KEY=opencti
MINIO_SECRET_KEY=socarium

# RabbitMQ
RABBITMQ_HOSTNAME=rabbitmq
RABBITMQ_PORT=5672
RABBITMQ_USERNAME=opencti
RABBITMQ_PASSWORD=socarium

# Redis
REDIS_HOSTNAME=redis
REDIS_PORT=6379

# Neo4j
NEO4J_URI=bolt://neo4j:7687
NEO4J_USERNAME=opencti
NEO4J_PASSWORD=socarium
EOL'

echo "Environment variables file created successfully."

# Start OpenCTI using Docker Compose
echo "Starting OpenCTI..."
sudo docker-compose up -d

if [ $? -ne 0 ]; then
    echo "Failed to start OpenCTI. Please check the logs for more details."
    exit 1
fi

echo "OpenCTI has been successfully deployed!"
echo "Access OpenCTI at: http://localhost:8181"
echo "Admin email: admin@opencti.io"
echo "Admin password: socarium"
