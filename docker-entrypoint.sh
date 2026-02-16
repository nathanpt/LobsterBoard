#!/bin/sh
set -e

# LobsterBoard Docker Entrypoint
# Ensures config files exist before starting the server

echo "🦞 LobsterBoard starting..."

# Ensure config directory exists
mkdir -p /app/data

# Create default config.json if it doesn't exist
if [ ! -f /app/config.json ]; then
  echo "📝 Creating default config.json..."
  cat > /app/config.json << 'EOF'
{
  "canvas": {
    "width": 1920,
    "height": 1080
  },
  "fontScale": 1.25,
  "widgets": []
}
EOF
fi

# Create default pages.json if it doesn't exist
if [ ! -f /app/pages.json ]; then
  echo "📄 Creating default pages.json..."
  cat > /app/pages.json << 'EOF'
{
  "pages": {}
}
EOF
fi

# Ensure data directory exists with proper permissions
mkdir -p /app/data

echo "✅ Configuration files ready"
echo "🚀 Starting LobsterBoard on ${HOST:-0.0.0.0}:${PORT:-8080}"

# Start the server
exec node server.cjs
