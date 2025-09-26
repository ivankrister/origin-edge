#!/bin/bash

# SRS Origin and Edge Server Start Script

set -e

echo "🚀 Starting SRS Origin and Edge Servers..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Check if docker compose is available
if ! command -v docker compose &> /dev/null; then
    echo "❌ docker compose is not installed. Please install docker compose first."
    exit 1
fi

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file from example..."
    cp .env.example .env
    echo "⚠️  Please edit .env file and set your CANDIDATE IP address"
fi

# Create logs directory if it doesn't exist
mkdir -p logs

# Pull latest SRS image
echo "🔄 Pulling latest SRS image..."
docker pull ossrs/srs:5

# Start the services
echo "🏃 Starting services..."
docker compose up -d

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 10

# Check if services are running
if docker compose ps | grep -q "Up"; then
    echo "✅ Services started successfully!"
    echo ""
    echo "📊 Service Status:"
    docker compose ps
    echo ""
    echo "🌐 Access URLs:"
    echo "  Origin Server API: http://localhost:1985/api/v1/versions"
    echo "  Edge Server API:   http://localhost:1986/api/v1/versions"
    echo "  Origin Web Player: http://localhost:8080"
    echo "  Edge Web Player:   http://localhost:8081"
    echo ""
    echo "📺 Publishing:"
    echo "  RTMP to Origin: rtmp://localhost:19350/live/your_stream"
    echo ""
    echo "🎬 Playing from Edge:"
    echo "  RTMP: rtmp://localhost:1935/live/your_stream"
    echo "  HTTP-FLV: http://localhost:8081/live/your_stream.flv"
    echo ""
    echo "📄 View logs with: docker compose logs -f"
else
    echo "❌ Failed to start services. Check logs with: docker compose logs"
    exit 1
fi