# Edge Server Dockerfile
FROM ossrs/srs:5

LABEL maintainer="SRS Edge Server"
LABEL description="SRS Edge Server for CDN streaming"

# Install envsubst for environment variable substitution
RUN apt-get update && apt-get install -y gettext-base && rm -rf /var/lib/apt/lists/*

# Copy configuration template
COPY conf/edge.conf.template /usr/local/srs/conf/edge.conf.template

# Copy startup script
COPY start-edge.sh /usr/local/srs/start-edge.sh
RUN chmod +x /usr/local/srs/start-edge.sh

# Create logs directory
RUN mkdir -p /usr/local/srs/objs

# Expose ports
EXPOSE 1935 1985 8080 8000/udp

# Health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD curl -f http://localhost:1985/api/v1/versions || exit 1

# Start SRS with edge configuration
CMD ["/usr/local/srs/start-edge.sh"]