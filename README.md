# Real-Time Sports Betting System

A scalable, real-time sports betting platform built with Ruby on Rails, Node.js, and React.

<details>
<summary>Table of Contents</summary>

- [Overview](#overview)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Architecture](#architecture)
- [Development](#development)
- [Testing](#testing)
- [Data Simulation](#data-simulation)
- [API Documentation](#api-documentation)
- [Monitoring](#monitoring)
- [Troubleshooting](#troubleshooting)
</details>

## Overview

<details>
<summary>Click to expand</summary>

A microservices-based sports betting system featuring:
- Real-time odds updates via WebSocket
- User balance management
- Fraud detection system
- Live leaderboard
- Health monitoring

### Health Checks
All services implement health checks for reliable orchestration:
```bash
# Rails API health check
curl http://localhost:3000/health

# WebSocket Server health check
curl http://localhost:3001/health

# Services status check
make health
```

### Key Components
- Rails API (port 3000)
- Node.js WebSocket (port 3001)
- React Frontend (port 3002)
- Redis for pub/sub
- PostgreSQL for data
</details>

## Quick Start

<details>
<summary>Click to expand</summary>

1. Clone and setup:
```bash
git clone <repository-url>
cd real-time-sports-betting-system
make setup
```

2. Run tests:
```bash
make test
```

3. Start services:
```bash
make start
```

4. Generate sample data:
```bash
make generate-data
```

Access the services:
- Frontend: http://localhost:3002
- API Docs: http://localhost:3000/api-docs
- WS Server: ws://localhost:3001
</details>

## Development

<details>
<summary>Click to expand</summary>

### Available Commands

```bash
# Build and start services
make setup
make start

# Database operations
make db-migrate
make db-reset

# Testing
make test
make test-rails
make test-frontend

# Development tools
make logs
make shell-rails
make shell-node

# Data operations
make generate-data
make simulate-changes
```

### Container Structure
All services run in Docker containers:
- `rails`: Core API service
- `node`: WebSocket server
- `frontend`: React application
- `db`: PostgreSQL database
- `redis`: Caching and pub/sub
</details>

## Testing

<details>
<summary>Click to expand</summary>

### Running Tests
```bash
# Full test suite
make test

# Individual components
make test-rails
make test-frontend
```

### Test Structure
- Rails: RSpec for unit and integration tests
- Node.js: Jest for WebSocket and API tests
- Frontend: Jest + React Testing Library
</details>

## Data Simulation

<details>
<summary>Click to expand</summary>

### Mock Data Generation
```bash
# Generate initial data
make generate-data

# Simulate live updates
make simulate-changes
```

### Available Data
The system generates:
- Sample users with balances
- Active and upcoming games
- Historical bets and results
- Leaderboard data
</details>

## API Documentation

<details>
<summary>Click to expand</summary>

### Authentication
```ruby
# Headers
Authorization: Bearer <token>
Content-Type: application/json
```

### Core Endpoints
- POST /api/v1/users
- POST /api/v1/bets
- GET /api/v1/users/:id/bets
- GET /api/v1/leaderboard

### Health Checks
- GET /health
- GET /api/v1/status
</details>

## Monitoring

<details>
<summary>Click to expand</summary>

### Health Checks
All services implement health endpoints:
```bash
# Check all services
make health

# Individual services
curl http://localhost:3000/health
curl http://localhost:3001/health
```

### Log Access
```bash
# All logs
make logs

# Service specific
docker compose logs rails
docker compose logs node
```

### Metrics
- User activity
- Betting patterns
- System health
</details>

## Troubleshooting

<details>
<summary>Click to expand</summary>

### Common Issues

1. Database Connection:
```bash
make db-reset
```

2. Redis Connection:
```bash
make restart
```

3. Container Issues:
```bash
make clean
make setup
```

### Debugging
```bash
# Enable debug mode
DEBUG=true make start

# Access logs
make logs

# Rails console
make shell-rails
```
</details>
