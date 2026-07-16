.PHONY: help certs certs-force up down restart reload test logs status clean ps example-static example-api example-byo

COMPOSE ?= docker compose

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

certs: ## Generate TLS certs only if missing (safe for running edge)
	@chmod +x nginx/generate-certs.sh
	./nginx/generate-certs.sh

certs-force: ## Force regenerate TLS certs (recreate edge afterward)
	@chmod +x nginx/generate-certs.sh
	FORCE=1 ./nginx/generate-certs.sh
	@echo "Certs regenerated. Recreate the edge with: make up"

up: certs ## Build and start ns-cdn-lab (edge + origin)
	$(COMPOSE) up --build -d --force-recreate --remove-orphans
	@echo ""
	@echo "ns-cdn-lab is starting. Run: make test"

down: ## Stop and remove containers (keeps cache volume)
	$(COMPOSE) down --remove-orphans

restart: ## Restart all services
	$(COMPOSE) restart

reload: ## Reload Nginx config inside edge-proxy
	$(COMPOSE) exec edge-proxy nginx -t
	$(COMPOSE) exec edge-proxy nginx -s reload

test: ## Run the verification test suite
	@chmod +x test-suite.sh
	./test-suite.sh

logs: ## Tail logs from edge-proxy and origin-server
	$(COMPOSE) logs -f --tail=100 edge-proxy origin-server

status: ## Show compose service status
	$(COMPOSE) ps

ps: status ## Alias for status

clean: ## Stop stack and remove volumes (wipes edge cache)
	$(COMPOSE) down -v --remove-orphans

example-static: certs ## Run the static-site caching example
	$(COMPOSE) -f docker-compose.yml -f examples/static-site/docker-compose.override.yml up --build -d --force-recreate --remove-orphans
	@echo "Static-site example started. See examples/static-site/README.md"

example-api: certs ## Run the cache-aware API example
	$(COMPOSE) -f docker-compose.yml -f examples/api/docker-compose.override.yml up --build -d --force-recreate --remove-orphans
	@echo "API example started. See examples/api/README.md"

example-byo: certs ## Run ns-cdn-lab against a host app (set NS_CDN_LAB_UPSTREAM_PORT)
	$(COMPOSE) -f docker-compose.yml -f examples/byo-origin/docker-compose.override.yml up --build -d --force-recreate --remove-orphans
	@echo "BYO-origin example started. See examples/byo-origin/README.md"
