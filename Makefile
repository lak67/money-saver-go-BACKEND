build:
	@go build -o bin/demo-api cmd/main.go

test:
	@go test -v ./...

run: build
	@./bin/demo-api

migration:
	@migrate create -ext sql -dir cmd/migrate/migrations $(filter-out $@,$(MAKECMDGOALS))

migrate-up:
	@go run cmd/migrate/main.go up

migrate-down:
	@go run cmd/migrate/main.go down

backup:
	@echo "Creating backup..."
	@powershell -Command "$$date = Get-Date -Format 'yyyyMMdd_HHmmss'; if (!(Test-Path 'backups')) { New-Item -ItemType Directory -Force -Path backups | Out-Null }; docker exec $(CONTAINER_NAME) pg_dump -U $(DB_USER) $(DB_NAME) > backups/backup_$$date.sql"
	@echo "Backup created in backups/ directory"

restore:
	@echo "Available backups:"
	@powershell -Command "if (Test-Path 'backups') { Get-ChildItem backups/*.sql | ForEach-Object { Write-Host $$_.Name } } else { Write-Host 'No backups directory found' }"
	@echo ""
	@powershell -Command "$$file = Read-Host 'Enter backup filename to restore'; if (Test-Path \"backups/$$file\") { Get-Content \"backups/$$file\" | docker exec -i $(CONTAINER_NAME) psql -U $(DB_USER) -d $(DB_NAME); Write-Host 'Restore completed successfully' } else { Write-Host 'Backup file not found!' }"

restore-latest:
	@echo "Restoring from latest backup..."
	@powershell -Command "$$latest = Get-ChildItem backups/*.sql | Sort-Object LastWriteTime | Select-Object -Last 1; if ($$latest) { Write-Host \"Restoring from: $$($latest.Name)\"; Get-Content $$latest.FullName | docker exec -i $(CONTAINER_NAME) psql -U $(DB_USER) -d $(DB_NAME); Write-Host 'Restore completed successfully' } else { Write-Host 'No backup files found!' }"

db-shell:
	@docker exec -it $(CONTAINER_NAME) psql -U $(DB_USER) -d $(DB_NAME)

db-reset:
	@echo "WARNING: This will delete all data!"
	@powershell -Command "$$confirm = Read-Host 'Press Enter to continue or Ctrl+C to cancel'; docker exec $(CONTAINER_NAME) psql -U $(DB_USER) -d $(DB_NAME) -c \"DROP SCHEMA public CASCADE; CREATE SCHEMA public;\""
	@make migrate-up
	@echo "Database reset complete"

# Docker container management
docker-up:
	@echo "Starting database container..."
	@docker-compose up -d
	@echo "Waiting for database to be ready..."
	@powershell -Command "Start-Sleep 5"
	@make db-status

docker-down:
	@echo "Stopping database container..."
	@docker-compose down

docker-logs:
	@docker-compose logs -f

db-status:
	@echo "Checking database connection..."
	@docker exec $(CONTAINER_NAME) pg_isready -U $(DB_USER) -d $(DB_NAME) || echo "Database not ready"

# Setup commands for new machines
setup: docker-up
	@echo "Setting up database for the first time..."
	@make migrate-up
	@echo "Setup complete!"

setup-with-data: setup
	@echo "Do you want to restore from a backup? (y/n)"
	@powershell -Command "$$answer = Read-Host; if ($$answer -eq 'y' -or $$answer -eq 'Y') { make restore } else { Write-Host 'Setup complete without data restoration' }"

# List all available targets
help:
	@echo "Available targets:"
	@echo "  build           - Build the application"
	@echo "  test            - Run tests"
	@echo "  run             - Build and run the application"
	@echo "  migration       - Create a new migration"
	@echo "  migrate-up      - Run migrations"
	@echo "  migrate-down    - Rollback migrations"
	@echo "  backup          - Create database backup"
	@echo "  restore         - Restore from backup (interactive)"
	@echo "  restore-latest  - Restore from latest backup"
	@echo "  db-shell        - Open database shell"
	@echo "  db-reset        - Reset database (destructive)"
	@echo "  db-status       - Check database connection"
	@echo "  docker-up       - Start database container"
	@echo "  docker-down     - Stop database container"
	@echo "  docker-logs     - Show container logs"
	@echo "  setup           - Setup database for new machines"
	@echo "  setup-with-data - Setup database and restore from backup"
	@echo "  help            - Show this help message"