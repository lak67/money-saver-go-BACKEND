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
	@powershell -Command "$$date = Get-Date -Format 'yyyyMMdd_HHmmss'; New-Item -ItemType Directory -Force -Path backups | Out-Null; docker exec savemoney-backend pg_dump -U lakeman go_savemoney_dev > backups/backup_$$date.sql"
	@echo "Backup created in backups/ directory"

restore:
	@echo "Available backups:"
	@ls backups/
	@echo ""
	@echo "Enter backup filename to restore:"
	@read -p "Filename: " file && docker exec -i savemoney-backend psql -U ($DB_USER) -d ($DB_NAME) < backups/$$file

db-shell:
	@docker exec -it savemoney-backend psql -U ($DB_USER) -d ($DB_NAME)

db-reset:
	@echo "WARNING: This will delete all data!"
	@echo "Press Ctrl+C to cancel, or Enter to continue..."
	@read
	@docker exec savemoney-backend psql -U ($DB_USER) -d ($DB_NAME) -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
	@make migrate-up
	@echo "Database reset complete"