#!/bin/bash

# Make docker-entrypoint executable
chmod +x rails/sport_betting/bin/docker-entrypoint

# Stage changes
git add .

# Create commit message
commit_message="Implement health checks and improve system reliability

- Added health check endpoints for Rails and Node.js
- Added Redis initializer with connection pool
- Updated docker-compose with health checks
- Added executable docker-entrypoint script
- Improved service dependencies and startup sequence

Health Check Endpoints:
- Rails: /health
- Node: /health
- Redis: Using PING
- PostgreSQL: Using pg_isready

This ensures proper service orchestration and monitoring capability."

# Commit changes
git commit -m "$commit_message"

echo "Changes committed successfully"
