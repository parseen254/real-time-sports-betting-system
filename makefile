start:
	docker compose up -d
restart:
	docker compose restart
stop:
	docker compose down
build:
	docker compose build
logs:
	docker compose logs
db_migrate:
	cd rails/sport_betting/ && rails db:migrate
rails_test:
	cd rails/sport_betting/ && rails spec
