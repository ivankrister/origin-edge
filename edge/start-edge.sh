#!/bin/bash

# Edge server startup script
# This script processes the configuration template and starts SRS

set -e

echo "🔧 Configuring Edge Server..."

# Check required environment variables
if [ -z "$ORIGIN_SERVER" ]; then
    echo "❌ ORIGIN_SERVER environment variable is required"
    echo "   Set it to: YOUR_ORIGIN_SERVER_IP:1935"
    exit 1
fi

if [ -z "$CANDIDATE" ]; then
    echo "❌ CANDIDATE environment variable is required"
    echo "   Set it to: YOUR_EDGE_SERVER_IP"
    exit 1
fi

echo "🔗 Origin Server: $ORIGIN_SERVER"
echo "📍 WebRTC Candidate: $CANDIDATE"

# Replace placeholders in config template
sed -e "s/ORIGIN_SERVER_PLACEHOLDER/$ORIGIN_SERVER/g" \
    -e "s/CANDIDATE_PLACEHOLDER/$CANDIDATE/g" \
    /usr/local/srs/conf/edge.conf.template > /usr/local/srs/conf/edge.conf

echo "✅ Generated edge configuration:"
echo "----------------------------------------"
cat /usr/local/srs/conf/edge.conf
echo "----------------------------------------"

echo "🚀 Starting SRS Edge Server..."

# Start SRS
exec ./objs/srs -c conf/edge.conf