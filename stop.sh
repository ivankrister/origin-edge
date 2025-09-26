#!/bin/bash

# SRS Origin and Edge Server Stop Script

set -e

echo "🛑 Stopping SRS Origin and Edge Servers..."

# Stop and remove containers
docker compose down

echo "✅ Services stopped successfully!"

# Optional: Remove logs (uncomment if needed)
# echo "🧹 Cleaning up logs..."
# rm -rf logs/*

echo "🔍 To view remaining containers: docker ps -a"
echo "🗑️  To remove images: docker rmi srs-origin srs-edge"