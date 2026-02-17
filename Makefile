.PHONY: help build up down restart logs clean rebuild status occ

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## Build the Nextcloud images
	docker compose build

up: ## Start all services
	docker compose up -d

down: ## Stop all services
	docker compose down

restart: ## Restart all services
	docker compose restart

logs: ## Show logs (use 'make logs SERVICE=app' for specific service)
	docker compose logs -f $(SERVICE)

clean: ## Stop and remove all containers, networks, and volumes
	@echo "WARNING: This will remove all data!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker compose down -v; \
	fi

rebuild: ## Rebuild and restart services
	docker compose build --no-cache
	docker compose up -d

status: ## Show status of all services
	docker compose ps

occ: ## Run occ command (use 'make occ CMD="user:list"')
	docker compose exec -u www-data app php occ $(CMD)

setup: ## Initial setup - copy .env.example to .env
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo ".env file created. Please edit it with your passwords before running 'make up'"; \
	else \
		echo ".env file already exists"; \
	fi
