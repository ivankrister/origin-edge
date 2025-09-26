# SRS Edge Server

This is the Edge Server component of the SRS streaming system. Deploy this on your CDN edge locations to cache streams from the Origin Server.

## What is the Edge Server?

The Edge Server is a CDN cache server that:
- Fetches streams from the Origin Server on demand
- Caches streams locally to serve multiple clients
- Reduces load on the Origin Server
- Provides better performance for geographically distributed users

## Quick Start

1. **Configure server addresses**:
   ```bash
   cp .env.example .env
   # Edit .env and set:
   # - CANDIDATE: This edge server's public IP
   # - ORIGIN_SERVER: Origin server IP:PORT (e.g., 192.168.1.100:1935)
   ```

2. **Start the Edge Server**:
   ```bash
   ./start.sh
   ```

3. **Test connection** (stream should exist on origin first):
   ```bash
   # Play from edge (will fetch from origin automatically)
   ffplay rtmp://YOUR_EDGE_IP:1935/live/stream1
   ```

## How It Works

1. Client requests a stream from Edge Server (e.g., `rtmp://edge:1935/live/stream1`)
2. Edge Server checks if stream is cached locally
3. If not cached, Edge fetches from Origin Server (`origin:1935/live/stream1`)
4. Edge caches and serves the stream to client
5. Subsequent clients get the cached stream (no additional load on origin)

## Ports

- **1935**: RTMP input/output port for clients
- **1985**: HTTP API port
- **8080**: HTTP server for FLV delivery
- **8000/udp**: WebRTC port

## Configuration

The configuration is automatically generated from:
- `conf/edge.conf.template`: Template with placeholder for origin server
- Environment variables: `ORIGIN_SERVER` and `CANDIDATE`

### Multiple Origin Servers

For redundancy, you can specify multiple origin servers in `.env`:
```bash
ORIGIN_SERVER="192.168.1.100:1935 192.168.1.101:1935 192.168.1.102:1935"
```

## Monitoring

- Health check: `curl http://localhost:1985/api/v1/versions`
- Stream stats: `curl http://localhost:1985/api/v1/streams`
- Logs: `docker compose logs -f`

## Deployment Notes

### For CDN Setup:
1. Deploy Origin Server in your main data center
2. Deploy Edge Servers in different geographic locations
3. Point clients to their nearest Edge Server
4. Edge Servers automatically fetch from Origin

### Network Requirements:
- Edge servers need outbound access to Origin Server (port 1935)
- Clients need inbound access to Edge Servers (ports 1935, 8080)
- Configure firewalls accordingly

## Production Notes

- Set `CANDIDATE` to the edge server's public IP
- Configure firewall to allow ports 1935, 1985, 8080, 8000
- Monitor connection to origin server
- Set up multiple origin servers for redundancy
- Consider using load balancer for multiple edge servers

## Building Custom Image

```bash
docker build -t my-srs-edge .
```

## Manual Docker Run

```bash
docker run -d \
  --name srs-edge \
  -p 1935:1935 \
  -p 1985:1985 \
  -p 8080:8080 \
  -p 8000:8000/udp \
  -e CANDIDATE=YOUR_EDGE_IP \
  -e ORIGIN_SERVER=YOUR_ORIGIN_IP:1935 \
  my-srs-edge
```

## Troubleshooting

- **Edge can't connect to origin**: Check network connectivity and firewall
- **Streams not available**: Verify streams exist on origin server first
- **High latency**: Check network path between edge and origin
- **Connection refused**: Verify origin server is running and accessible