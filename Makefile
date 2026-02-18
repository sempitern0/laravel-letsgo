# ==========================================
# Docker Compose Shortcuts
# ==========================================

.PHONY: up down ps restart stop build build-nc destroy destroy-volumes

up:
	docker compose up -d

down:
	docker compose down --remove-orphans

ps:
	docker compose ps

restart: down up

stop:
	docker compose stop

build:
	docker compose build

build-nc:
	docker compose build --no-cache

destroy:
	docker compose down --rmi all --volumes --remove-orphans

destroy-volumes:
	docker compose down --volumes --remove-orphans

# ==========================================
# (Shell access)
# ==========================================

.PHONY: shell-app shell-web shell-db shell-redis

shell-app:
	docker compose exec laravel_app bash

shell-web:
	docker compose exec webserver sh

shell-mysql_db:
	docker compose exec mysql_db bash 

shell-postgres_db:
	docker compose exec postgres_db bash

shell-redis:
	docker compose exec redis sh

exec:
	docker compose exec laravel_app $(c)