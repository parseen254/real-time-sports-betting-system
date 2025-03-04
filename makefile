start:
	docker compose up -d
stop:
	docker compose down
build:
	docker compose build
logs:
	docker compose logs
db_migrate:
	cd rails/sport_betting/ && rails db:migrate
