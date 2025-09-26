#!/bin/bash

# SRS Origin Server Start Script

set -e

echo "🚀 Starting SRS Origin Server..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    echo "❌ docker-compose is not installed. Please install docker-compose first."
    exit 1
fi

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file from example..."
    cp .env.example .env
    echo "⚠️  Please edit .env file and set your CANDIDATE IP address"
    echo "⚠️  Set CANDIDATE to this server's public IP address"
fi

# Create logs directory if it doesn't exist
mkdir -p logs

# Pull latest SRS image
echo "🔄 Pulling latest SRS image..."
docker pull ossrs/srs:5

# Start the service
echo "🏃 Starting Origin Server..."
docker-compose up -d

# Wait for service to be ready
echo "⏳ Waiting for service to start..."
sleep 10

# Check if service is running
if docker-compose ps | grep -q "Up"; then
    echo "✅ Origin Server started successfully!"
    echo ""
    echo "📊 Service Status:"
    docker-compose ps
    echo ""
    echo "🌐 Access URLs:"
    echo "  API Endpoint: http://localhost:1985/api/v1/versions"
    echo "  Web Console:  http://localhost:8080"
    echo ""
    echo "📺 Publishing (RTMP):"
    echo "  URL: rtmp://YOUR_SERVER_IP:1935/live/YOUR_STREAM_KEY"
    echo ""
    echo "🎬 Playing:"
    echo "  RTMP:     rtmp://YOUR_SERVER_IP:1935/live/YOUR_STREAM_KEY"
    echo "  HTTP-FLV: http://YOUR_SERVER_IP:8080/live/YOUR_STREAM_KEY.flv"
    echo "  HLS:      http://YOUR_SERVER_IP:8080/live/YOUR_STREAM_KEY.m3u8"
    echo ""
    echo "📄 View logs with: docker-compose logs -f"
else
    echo "❌ Failed to start Origin Server. Check logs with: docker-compose logs"
    exit 1
fi