# SRS Origin and Edge Server Setup

This project sets up SRS (Simple Realtime Server) with separate deployable Origin and Edge servers for CDN-style live streaming distribution.

## Architecture

- **Origin Server**: The main streaming server that receives and processes live streams
- **Edge Server**: CDN cache server that fetches streams from origin and serves multiple clients

## Project Structure

```
ossrs/
├── origin/                 # Origin Server (deploy on main server)
│   ├── docker-compose.yml
│   ├── Dockerfile
│   ├── conf/origin.conf
│   ├── start.sh
│   └── README.md
├── edge/                   # Edge Server (deploy on CDN locations)
│   ├── docker-compose.yml
│   ├── Dockerfile
│   ├── conf/edge.conf.template
│   ├── start.sh
│   └── README.md
└── README.md              # This file
```

## Quick Start

### 1. Deploy Origin Server (Main Server)

```bash
cd origin/
cp .env.example .env
# Edit .env and set CANDIDATE to your origin server's public IP
./start.sh
```

### 2. Deploy Edge Server (CDN Locations)

```bash
cd edge/
cp .env.example .env
# Edit .env and set:
# - CANDIDATE: Edge server's public IP
# - ORIGIN_SERVER: Origin server IP:PORT (e.g., 192.168.1.100:1935)
./start.sh
```

## Port Configuration

### Origin Server
- `1935`: RTMP input/output port
- `1985`: HTTP API
- `8080`: HTTP server for HLS/FLV
- `8000/udp`: WebRTC

### Edge Server  
- `1935`: RTMP port for clients
- `1985`: HTTP API
- `8080`: HTTP server for FLV
- `8000/udp`: WebRTC

*Note: Each server runs independently on different machines, so port conflicts are not an issue.*

## Usage

## Usage Flow

### 1. Publishing Streams

Publish to the **Origin Server**:
```bash
# Using FFmpeg
ffmpeg -re -i input.mp4 -c copy -f flv rtmp://ORIGIN_SERVER_IP:1935/live/stream1

# Using OBS
# RTMP URL: rtmp://ORIGIN_SERVER_IP:1935/live
# Stream Key: stream1
```

### 2. Playing Streams

Connect clients to the **Edge Server** for better performance:

**RTMP:**
```
rtmp://EDGE_SERVER_IP:1935/live/stream1
```

**HTTP-FLV:**
```
http://EDGE_SERVER_IP:8080/live/stream1.flv
```

**HLS (from origin only):**
```
http://ORIGIN_SERVER_IP:8080/live/stream1.m3u8
```

**WebRTC:**
- Publish: `http://ORIGIN_SERVER_IP:8080/players/rtc_publisher.html`
- Play: `http://EDGE_SERVER_IP:8080/players/rtc_player.html`

## Deployment Strategy

### Single Origin, Multiple Edges

```
Publisher → Origin Server (Main Datacenter)
               ↓
         ┌─────┼─────┐
         ↓     ↓     ↓
    Edge-1  Edge-2  Edge-3  (Different locations)
         ↓     ↓     ↓
    Clients  Clients  Clients
```

### Steps:
1. Deploy Origin Server in your primary datacenter
2. Deploy Edge Servers in different geographic locations
3. Configure each Edge Server to point to the Origin Server
4. Direct clients to their nearest Edge Server

## Scaling

### Multiple Edge Servers

Deploy additional edge servers by copying the `edge/` folder:

```bash
# For each new location
cp -r edge/ edge-location2/
cd edge-location2/
# Edit .env with location-specific IPs
./start.sh
```

### Multiple Origin Servers (Redundancy)

Configure multiple origins in edge `.env`:
```bash
ORIGIN_SERVER="192.168.1.100:1935 192.168.1.101:1935"
```

## Monitoring

### Health Checks
```bash
# Origin server status
curl http://ORIGIN_SERVER_IP:1985/api/v1/versions

# Edge server status  
curl http://EDGE_SERVER_IP:1985/api/v1/versions

# Stream statistics
curl http://ORIGIN_SERVER_IP:1985/api/v1/streams
curl http://EDGE_SERVER_IP:1985/api/v1/streams
```

### Logs
```bash
# On origin server
cd origin/
docker-compose logs -f

# On edge server
cd edge/
docker-compose logs -f
```

## Troubleshooting

1. **Edge can't connect to origin**: Check network connectivity and firewall rules
2. **Streams not playing on edge**: Verify origin is receiving streams first
3. **WebRTC issues**: Ensure CANDIDATE environment variable is set to your public IP
4. **Permission errors**: Check that `logs/` directory is writable

## Production Considerations

1. **Security**: Configure authentication and HTTPS
2. **SSL/TLS**: Use reverse proxy (Nginx) for HTTPS termination  
3. **Monitoring**: Set up proper logging and monitoring
4. **Backup**: Configure multiple origin servers for redundancy
5. **Network**: Use proper CDN network topology

## Environment Variables

- `CANDIDATE`: Your server's public IP address for WebRTC (required for WebRTC)

## References

- [SRS Documentation](https://ossrs.io/lts/en-us/docs/v6/doc/edge)
- [Docker Hub - SRS Images](https://hub.docker.com/r/ossrs/srs/tags)