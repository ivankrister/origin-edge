#!/bin/bash

# SRS Edge Server Start Script

set -e

echo "🚀 Starting SRS Edge Server..."

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
    echo "⚠️  Please edit .env file and set your IP addresses:"
    echo "   - CANDIDATE: This edge server's public IP"
    echo "   - ORIGIN_SERVER: Origin server IP and port (e.g., 192.168.1.100:1935)"
    exit 1
fi

# Check if origin server is configured
source .env
if [[ "$ORIGIN_SERVER" == "YOUR_ORIGIN_SERVER_IP:1935" ]]; then
    echo "❌ Please configure ORIGIN_SERVER in .env file"
    echo "   Set it to your origin server IP:PORT (e.g., 192.168.1.100:1935)"
    exit 1
fi

# Create logs directory if it doesn't exist
mkdir -p logs

# Pull latest SRS image
echo "🔄 Pulling latest SRS image..."
docker pull ossrs/srs:5

# Build edge server image (needed for config processing)
echo "🔨 Building Edge Server image..."
docker build -t srs-edge .

# Start the service
echo "🏃 Starting Edge Server..."
docker compose up -d

# Wait for service to be ready
echo "⏳ Waiting for service to start..."
sleep 10

# Check if service is running
if docker compose ps | grep -q "Up"; then
    echo "✅ Edge Server started successfully!"
    echo ""
    echo "📊 Service Status:"
    docker compose ps
    echo ""
    echo "🌐 Access URLs:"
    echo "  API Endpoint: http://localhost:1985/api/v1/versions"
    echo "  Web Console:  http://localhost:8080"
    echo ""
    echo "🔗 Origin Server: $ORIGIN_SERVER"
    echo ""
    echo "🎬 Playing from Edge (better performance):"
    echo "  RTMP:     rtmp://YOUR_EDGE_IP:1935/live/YOUR_STREAM_KEY"
    echo "  HTTP-FLV: http://YOUR_EDGE_IP:8080/live/YOUR_STREAM_KEY.flv"
    echo ""
    echo "📝 Note: Streams are cached from origin server automatically"
    echo "📄 View logs with: docker compose logs -f"
else
    echo "❌ Failed to start Edge Server. Check logs with: docker compose logs"
    exit 1
fi