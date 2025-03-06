.PHONY: start stop restart build logs test setup clean generate-data simulate-changes

# Docker operations
start:
	docker compose up -d

stop:
	docker compose down

restart:
	docker compose restart

build:
	docker compose build

logs:
	docker compose logs -f

# Database operations
setup: build
	@echo "Setting up the application..."
	docker compose down -v
	docker compose up -d db redis
	@echo "Waiting for databases to be ready..."
	sleep 5
	docker compose run --rm rails bin/rails db:drop db:create db:migrate
	docker compose run --rm rails bin/rails db:drop db:create db:migrate RAILS_ENV=test
	docker compose run --rm rails bin/rails db:seed
	@echo "Starting all services..."
	docker compose up -d
	@echo "Setup completed successfully!"

db-migrate:
	docker compose run --rm rails rails db:migrate
	docker compose run --rm rails rails db:migrate RAILS_ENV=test

db-reset:
	docker compose run --rm rails rails db:drop db:create db:migrate
	docker compose run --rm rails rails db:seed

# Testing
test: test-rails test-frontend

test-rails:
	docker compose run --rm -e RAILS_ENV=test rails rspec

test-frontend:
	docker compose run --rm frontend npm test

# Code quality
lint:
	docker compose run --rm frontend npm run lint
	docker compose run --rm node npm run lint

# Data generation and simulation
generate-data:
	docker compose run --rm rails rails runner 'require "rake"; Rake::Task["mock_data:generate"].invoke'

simulate-changes:
docker compose run --rm rails rails runner 'require "rake"; Rake::Task["mock_data:simulate_changes"].invoke'

# Health checks
health:
@echo "Checking service health..."
@echo "\nChecking PostgreSQL..."
@docker compose exec db pg_isready -U postgres || exit 1
@echo "\nChecking Redis..."
@docker compose exec redis redis-cli ping || exit 1
@echo "\nChecking Rails API..."
@curl -f http://localhost:3000/health || exit 1
@echo "\nChecking WebSocket server..."
@curl -f http://localhost:3001/health || exit 1
@echo "\nAll services are healthy!"

# Development helpers
shell-rails:
	docker compose run --rm rails bash

shell-node:
	docker compose run --rm node sh

clean:
	docker compose down -v
	rm -rf tmp/postgres_data tmp/redis_data
	rm -rf frontend/node_modules node/node_modules rails/node_modules

# Help
help:
	@echo "Available commands:"
	@echo "  make start              - Start all containers"
	@echo "  make stop               - Stop all containers"
	@echo "  make restart            - Restart all containers"
	@echo "  make build              - Build all containers"
	@echo "  make setup              - Initial setup of the application"
	@echo "  make db-migrate         - Run database migrations"
	@echo "  make db-reset           - Reset and seed the database"
	@echo "  make test               - Run all tests"
	@echo "  make test-rails         - Run Rails tests"
	@echo "  make test-frontend      - Run frontend tests"
	@echo "  make lint               - Run linters"
	@echo "  make generate-data      - Generate mock data"
	@echo "  make simulate-changes   - Simulate real-time data changes"
	@echo "  make shell-rails        - Open Rails console"
	@echo "  make shell-node         - Open Node console"
	@echo "  make clean              - Remove all generated files"
	@echo "  make logs               - Show container logs"
