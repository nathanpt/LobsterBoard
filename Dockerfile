# LobsterBoard Dockerfile
FROM node:18-alpine

# Install system dependencies needed for systeminformation
# These are required for CPU, memory, disk, and network stats
RUN apk add --no-cache \
    coreutils \
    dmidecode \
    ethtool \
    iproute2 \
    net-tools \
    smartmontools \
    util-linux \
    procps \
    tzdata

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy application files
COPY server.cjs ./
COPY app.html ./
COPY js ./js
COPY css ./css
COPY templates ./templates
COPY pages ./pages
COPY docker-entrypoint.sh ./

# Make entrypoint executable
RUN chmod +x docker-entrypoint.sh

# Create necessary directories
RUN mkdir -p data

# Expose port
EXPOSE 8080

# Set environment variables
ENV HOST=0.0.0.0
ENV PORT=8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:8080', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Use entrypoint script to ensure config files exist
ENTRYPOINT ["/app/docker-entrypoint.sh"]
