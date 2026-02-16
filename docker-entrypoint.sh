#!/bin/sh
set -e

# LobsterBoard Docker Entrypoint
# Ensures config files exist before starting the server

echo "🦞 LobsterBoard starting..."

# Ensure data directory exists
mkdir -p /app/data

# Create default config.json in data directory if it doesn't exist
if [ ! -f /app/data/config.json ]; then
  echo "📝 Creating default config.json..."
  cat > /app/data/config.json << 'EOF'
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

# Create default pages.json in data directory if it doesn't exist
if [ ! -f /app/data/pages.json ]; then
  echo "📄 Creating default pages.json..."
  cat > /app/data/pages.json << 'EOF'
{
  "pages": {}
}
EOF
fi

# Symlink config files to app root if they don't exist
if [ ! -L /app/config.json ] && [ ! -f /app/config.json ]; then
  ln -s /app/data/config.json /app/config.json
  echo "🔗 Symlinked config.json"
fi

if [ ! -L /app/pages.json ] && [ ! -f /app/pages.json ]; then
  ln -s /app/data/pages.json /app/pages.json
  echo "🔗 Symlinked pages.json"
fi

echo "✅ Configuration files ready"
echo "🚀 Starting LobsterBoard on ${HOST:-0.0.0.0}:${PORT:-8080}"

# Start the server
exec node server.cjs
