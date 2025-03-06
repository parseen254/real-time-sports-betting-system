#!/bin/bash
set -e

echo "Making docker-entrypoint executable..."
chmod +x rails/sport_betting/bin/docker-entrypoint

echo "Running tests..."
echo "1. Rails tests..."
make test-rails || { echo "Rails tests failed!"; exit 1; }

echo "2. Node.js tests..."
cd node && npm install && npm test
cd ..

echo "Tests passed successfully!"

echo "Staging changes..."
git add .

commit_message="Implement health checks and testing infrastructure

Infrastructure Updates:
- Added health check endpoints for Rails (/health) and Node.js (/health)
- Added Redis initializer with connection pool and pub/sub
- Updated docker-compose with health checks and startup dependencies
- Added executable docker-entrypoint script
- Added startup sequence validation

Testing Infrastructure:
- Added health check tests for Rails and Node.js
- Added WebSocket connection tests
- Added Redis connection tests
- Added concurrent request handling tests

Implementation Details:
- Rails health controller with database and Redis checks
- Node.js Express health endpoint with WebSocket status
- Redis connection pool configuration
- PostgreSQL health check using pg_isready
- Proper error handling and status reporting

This ensures reliable service orchestration and monitoring capability
with comprehensive test coverage."

echo "Committing changes..."
git commit -m "$commit_message"

echo "All changes committed successfully!"
