# Origin Server Dockerfile
FROM ossrs/srs:5

LABEL maintainer="SRS Origin Server"
LABEL description="SRS Origin Server for live streaming"

# Copy configuration
COPY conf/origin.conf /usr/local/srs/conf/origin.conf

# Create logs directory
RUN mkdir -p /usr/local/srs/objs

# Expose ports
EXPOSE 1935 1985 8080 8000/udp

# Health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD curl -f http://localhost:1985/api/v1/versions || exit 1

# Start SRS with origin configuration
CMD ["./objs/srs", "-c", "conf/origin.conf"]