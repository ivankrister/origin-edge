#!/bin/bash

echo "🔍 SRS Edge Server Debug Information"
echo "===================================="

# Check environment variables
echo "📋 Environment Variables:"
echo "CANDIDATE: ${CANDIDATE:-NOT SET}"
echo "ORIGIN_SERVER: ${ORIGIN_SERVER:-NOT SET}"
echo ""

# Check if edge container is running
echo "🐳 Container Status:"
docker ps | grep srs-edge || echo "Edge container not running"
echo ""

# Check edge server logs (last 20 lines)
echo "📄 Edge Server Logs (last 20 lines):"
echo "------------------------------------"
docker logs --tail 20 srs-edge 2>/dev/null || echo "Cannot get logs - container may not be running"
echo ""

# Check if origin server is reachable
if [ ! -z "$ORIGIN_SERVER" ]; then
    echo "🔗 Testing connection to origin server:"
    IFS=':' read -r ORIGIN_IP ORIGIN_PORT <<< "$ORIGIN_SERVER"
    echo "Testing connection to $ORIGIN_IP:$ORIGIN_PORT..."
    
    # Use nc (netcat) to test connection
    if command -v nc >/dev/null 2>&1; then
        if nc -z -w3 "$ORIGIN_IP" "$ORIGIN_PORT" 2>/dev/null; then
            echo "✅ Origin server is reachable"
        else
            echo "❌ Cannot connect to origin server"
        fi
    else
        echo "⚠️  netcat not available, cannot test connection"
    fi
else
    echo "⚠️  ORIGIN_SERVER not set, cannot test connection"
fi

echo ""
echo "🧪 API Endpoints:"
echo "Edge API: http://localhost:1985/api/v1/versions"
echo "Edge Streams: http://localhost:1985/api/v1/streams"
echo ""

# Test edge API if running
echo "🔍 Testing Edge API:"
if curl -s -f http://localhost:1985/api/v1/versions > /dev/null 2>&1; then
    echo "✅ Edge API is responding"
    echo "📊 Current streams:"
    curl -s http://localhost:1985/api/v1/streams | head -10
else
    echo "❌ Edge API is not responding"
fi