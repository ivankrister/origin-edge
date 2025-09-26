#!/bin/bash

# Edge server startup script
# This script processes the configuration template and starts SRS

set -e

echo "🔧 Configuring Edge Server..."

# Set default origin server if not provided
if [ -z "$ORIGIN_SERVER" ]; then
    echo "❌ ORIGIN_SERVER environment variable is required"
    echo "   Set it to: YOUR_ORIGIN_SERVER_IP:1935"
    exit 1
fi

# Replace placeholder in config template
sed "s/ORIGIN_SERVER_PLACEHOLDER/$ORIGIN_SERVER/g" /usr/local/srs/conf/edge.conf.template > /usr/local/srs/conf/edge.conf

echo "✅ Configuration ready. Starting SRS Edge Server..."
echo "🔗 Connecting to origin: $ORIGIN_SERVER"

# Start SRS
exec ./objs/srs -c conf/edge.conf