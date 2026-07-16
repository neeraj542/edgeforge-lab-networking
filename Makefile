.PHONY: help certs up down restart reload test logs status clean ps

COMPOSE ?= docker compose

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

certs: ## Generate self-signed TLS certs for edgeforge.local
	@chmod +x nginx/generate-certs.sh
	./nginx/generate-certs.sh

up: certs ## Build and start EdgeForge (edge + origin)
	$(COMPOSE) up --build -d --remove-orphans
	@echo ""
	@echo "EdgeForge is starting. Run: make test"

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
