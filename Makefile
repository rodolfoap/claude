
# Claude Code Container
# Makefile for building and managing the Claude Code Docker container

# Variables
IMAGE_NAME := claude-code
CONTAINER_NAME := claude-code-instance
NPM_CACHE_VOLUME := claude-code-npm-cache

# Default target
.PHONY: all
all: build ## Build the Docker image (default target)

# Build the Docker image
.PHONY: build
build: ## Build the Docker image without using cache (ensures fresh npm packages)
	@echo "Building Docker image $(IMAGE_NAME) without cache..."
	docker build --no-cache --pull -t $(IMAGE_NAME) .
	@echo "Build complete."

# Quick build (with cache for faster rebuilds)
.PHONY: quick-build
quick-build: ## Build the Docker image using cache for faster rebuilds
	@echo "Building Docker image $(IMAGE_NAME) with cache..."
	docker build --pull -t $(IMAGE_NAME) .
	@echo "Quick build complete."

# Run the container
.PHONY: run
run: ## Run the Docker container with current directory mapped to /app
	@echo "Starting container $(CONTAINER_NAME)..."
	docker run --name $(CONTAINER_NAME) -it --rm \
		-v "$$(pwd):/app" \
		-v $(NPM_CACHE_VOLUME):/npm-cache \
		-e CONTAINER_USER_ID=$$(id -u) \
		-e CONTAINER_GROUP_ID=$$(id -g) \
		$(IMAGE_NAME)

# Run with a specified directory
.PHONY: run-dir
run-dir: ## Run with a specified directory mapped to /app (usage: make run-dir DIR=/path/to/directory)
	@if [ -z "$(DIR)" ]; then \
		echo "Error: DIR parameter is required. Usage: make run-dir DIR=/path/to/directory"; \
		exit 1; \
	fi
	@echo "Starting container $(CONTAINER_NAME) with $(DIR) mapped to /app..."
	docker run --name $(CONTAINER_NAME) -it --rm \
		-v "$(DIR):/app" \
		-v $(NPM_CACHE_VOLUME):/npm-cache \
		-e CONTAINER_USER_ID=$$(id -u) \
		-e CONTAINER_GROUP_ID=$$(id -g) \
		$(IMAGE_NAME)

# Run with API key
.PHONY: run-auth
run-auth: ## Run with Anthropic API key (usage: make run-auth KEY=your_api_key)
	@if [ -z "$(KEY)" ]; then \
		echo "Error: KEY parameter is required. Usage: make run-auth KEY=your_api_key"; \
		exit 1; \
	fi
	@echo "Starting container $(CONTAINER_NAME) with API authentication..."
	docker run --name $(CONTAINER_NAME) -it --rm \
		-v "$$(pwd):/app" \
		-v $(NPM_CACHE_VOLUME):/npm-cache \
		-e ANTHROPIC_API_KEY="$(KEY)" \
		-e CONTAINER_USER_ID=$$(id -u) \
		-e CONTAINER_GROUP_ID=$$(id -g) \
		$(IMAGE_NAME)

# Clean up resources
.PHONY: clean
clean: ## Remove the Docker image
	@echo "Cleaning up resources..."
	docker rmi $(IMAGE_NAME) || true

# Clean up everything including volumes
.PHONY: clean-all
clean-all: clean ## Remove the Docker image and all volumes
	@echo "Removing npm cache volume..."
	docker volume rm $(NPM_CACHE_VOLUME) || true

# Help command
.PHONY: help
help: ## Display this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
