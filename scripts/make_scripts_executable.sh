#!/bin/bash
set -e

# Make scripts executable
chmod +x scripts/commit_changes.sh
chmod +x rails/sport_betting/bin/docker-entrypoint

echo "Scripts are now executable"

# Run the commit script
./scripts/commit_changes.sh
