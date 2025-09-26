# SRS Origin Server

This is the Origin Server component of the SRS streaming system. Deploy this on your main streaming server.

## What is the Origin Server?

The Origin Server is the main streaming server that:
- Receives live streams from publishers (streamers)
- Generates HLS segments
- Handles transcoding (if enabled)
- Records streams (DVR)
- Serves as the source for Edge servers

## Quick Start

1. **Configure your server IP**:
   ```bash
   cp .env.example .env
   # Edit .env and set CANDIDATE to your server's public IP
   ```

2. **Start the Origin Server**:
   ```bash
   ./start.sh
   ```

3. **Publish a stream**:
   ```bash
   ffmpeg -re -i input.mp4 -c copy -f flv rtmp://YOUR_SERVER_IP:1935/live/stream1
   ```

4. **Test playback**:
   - RTMP: `rtmp://YOUR_SERVER_IP:1935/live/stream1`
   - HTTP-FLV: `http://YOUR_SERVER_IP:8080/live/stream1.flv`
   - HLS: `http://YOUR_SERVER_IP:8080/live/stream1.m3u8`

## Ports

- **1935**: RTMP input/output port
- **1985**: HTTP API port
- **8080**: HTTP server for HLS/FLV delivery
- **8000/udp**: WebRTC port

## Configuration

Edit `conf/origin.conf` to customize:
- HLS settings (fragment duration, window size)
- DVR recording
- Transcoding profiles
- WebRTC settings

## Monitoring

- Health check: `curl http://localhost:1985/api/v1/versions`
- Stream stats: `curl http://localhost:1985/api/v1/streams`
- Logs: `docker compose logs -f`

## Production Notes

- Set `CANDIDATE` to your public IP address
- Configure firewall to allow ports 1935, 1985, 8080, 8000
- Consider using HTTPS proxy for web delivery
- Set up monitoring and alerting
- Configure backup and redundancy

## Building Custom Image

```bash
docker build -t my-srs-origin .
```

## Manual Docker Run

```bash
docker run -d \
  --name srs-origin \
  -p 1935:1935 \
  -p 1985:1985 \
  -p 8080:8080 \
  -p 8000:8000/udp \
  -e CANDIDATE=YOUR_IP \
  -v $(pwd)/conf/origin.conf:/usr/local/srs/conf/origin.conf \
  -v $(pwd)/logs:/usr/local/srs/objs \
  ossrs/srs:5
```