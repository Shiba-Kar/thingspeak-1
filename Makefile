.PHONY: build up down restart logs logs-web console create-admin status clean

# Build the docker containers
build:
	docker-compose build

# Start the docker containers in background
up:
	docker-compose up -d

# Stop the docker containers
down:
	docker-compose down

# Restart the docker containers
restart:
	docker-compose restart

# Tail logs of all containers
logs:
	docker-compose logs -f

# Tail logs of the web application container
logs-web:
	docker-compose logs -f web

# Open a Rails Console inside the running web container
console:
	docker-compose exec web bundle exec rails console

# Create default admin user inside the running web container
# Usage: make create-admin EMAIL=admin@example.com PASSWORD=password123
create-admin:
	@if [ -z "$(EMAIL)" ] || [ -z "$(PASSWORD)" ]; then \
		echo "Usage: make create-admin EMAIL=your_email@example.com PASSWORD=your_password"; \
		exit 1; \
	fi
	docker-compose exec web bundle exec rails runner "AdminUser.create!(email: '$(EMAIL)', password: '$(PASSWORD)', password_confirmation: '$(PASSWORD)')"

# Show docker compose status
status:
	docker-compose ps

# Clean up all containers, images, and volumes
clean:
	docker-compose down -v --rmi all --remove-orphans
