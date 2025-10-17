# Money Saver Go Backend

A Go-based backend API for personal finance management with PostgreSQL database.

## Quick Setup

### Prerequisites

- Docker and Docker Compose
- Go 1.19+
- Make utility

### Setup on a New Machine

#### Option 1: Automated Setup (Recommended)

```powershell
# Copy .env.example to .env and update your settings
cp .env.example .env

# Run the setup script
.\setup.ps1

# For setup with data restoration
.\setup.ps1 -WithData

# For setup with specific backup file
.\setup.ps1 -BackupFile backup_20241016_185533.sql
```

#### Option 2: Manual Setup

```powershell
# 1. Copy environment file
cp .env.example .env

# 2. Start database container
make docker-up

# 3. Run migrations
make migrate-up

# 4. (Optional) Restore from backup
make restore
```

## Database Management

### Backup and Restore

```powershell
# Create backup
make backup

# Restore from backup (interactive)
make restore

# Restore from latest backup
make restore-latest
```

### Container Management

```powershell
# Start database container
make docker-up

# Stop database container
make docker-down

# View container logs
make docker-logs

# Check database status
make db-status
```

### Database Operations

```powershell
# Access database shell
make db-shell

# Reset database (WARNING: Destructive!)
make db-reset

# Run migrations
make migrate-up

# Rollback migrations
make migrate-down
```

## Development

### Building and Running

```powershell
# Build application
make build

# Run tests
make test

# Build and run
make run
```

### Creating Migrations

```powershell
# Create new migration
make migration add-new-table
```

### Available Commands

Run `make help` to see all available commands.

## Project Structure

- `cmd/` - Application entry points
- `config/` - Configuration management
- `db/` - Database connection
- `service/` - Business logic and routes
- `types/` - Type definitions and models
- `utils/` - Utility functions
- `backups/` - Database backup files
