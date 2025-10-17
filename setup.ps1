#!/usr/bin/env pwsh
# Setup script for Money Saver Go Backend
# This script helps set up the development environment on a new machine

param(
    [switch]$WithData,
    [string]$BackupFile,
    [switch]$Help
)

function Show-Help {
    Write-Host @"
Money Saver Go Backend Setup Script

Usage:
    .\setup.ps1 [options]

Options:
    -WithData           Setup database and restore from backup
    -BackupFile <file>  Specify backup file to restore from
    -Help              Show this help message

Examples:
    .\setup.ps1                                    # Basic setup
    .\setup.ps1 -WithData                         # Setup with backup restoration
    .\setup.ps1 -BackupFile backup_20241016.sql  # Setup with specific backup

Prerequisites:
    - Docker and Docker Compose installed
    - Go 1.19+ installed
    - Make utility installed
"@
}

function Test-Prerequisites {
    Write-Host "Checking prerequisites..." -ForegroundColor Yellow
    
    $missing = @()
    
    if (!(Get-Command docker -ErrorAction SilentlyContinue)) {
        $missing += "Docker"
    }
    
    if (!(Get-Command docker-compose -ErrorAction SilentlyContinue)) {
        $missing += "Docker Compose"
    }
    
    if (!(Get-Command go -ErrorAction SilentlyContinue)) {
        $missing += "Go"
    }
    
    if (!(Get-Command make -ErrorAction SilentlyContinue)) {
        $missing += "Make"
    }
    
    if ($missing.Count -gt 0) {
        Write-Host "Missing prerequisites: $($missing -join ', ')" -ForegroundColor Red
        Write-Host "Please install the missing tools and try again." -ForegroundColor Red
        exit 1
    }
    
    Write-Host "All prerequisites found!" -ForegroundColor Green
}

function Copy-EnvFile {
    if (!(Test-Path ".env")) {
        if (Test-Path ".env.example") {
            Copy-Item ".env.example" ".env"
            Write-Host "Created .env file from .env.example" -ForegroundColor Green
            Write-Host "Please review and update .env file with your settings" -ForegroundColor Yellow
        } else {
            Write-Host "Warning: No .env.example file found" -ForegroundColor Yellow
        }
    } else {
        Write-Host ".env file already exists" -ForegroundColor Green
    }
}

function Start-Setup {
    Write-Host "Starting Money Saver Go Backend setup..." -ForegroundColor Cyan
    
    Test-Prerequisites
    Copy-EnvFile
    
    Write-Host "Starting database container..." -ForegroundColor Yellow
    & make docker-up
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to start database container" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "Running database migrations..." -ForegroundColor Yellow
    & make migrate-up
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to run migrations" -ForegroundColor Red
        exit 1
    }
    
    if ($WithData -or $BackupFile) {
        Restore-Data
    }
    
    Write-Host @"

Setup completed successfully! 🎉

Next steps:
1. Review your .env file settings
2. Run 'make build' to build the application
3. Run 'make run' to start the application
4. Run 'make help' to see all available commands

Database is running at: localhost:5432
"@ -ForegroundColor Green
}

function Restore-Data {
    if ($BackupFile) {
        if (Test-Path "backups\$BackupFile") {
            Write-Host "Restoring from backup: $BackupFile" -ForegroundColor Yellow
            Get-Content "backups\$BackupFile" | docker exec -i savemoney-backend psql -U lakeman -d go_savemoney_dev
            Write-Host "Data restored successfully!" -ForegroundColor Green
        } else {
            Write-Host "Backup file not found: backups\$BackupFile" -ForegroundColor Red
        }
    } elseif ($WithData) {
        if (Test-Path "backups") {
            $backups = Get-ChildItem "backups\*.sql" | Sort-Object LastWriteTime -Descending
            if ($backups.Count -gt 0) {
                Write-Host "Available backups:" -ForegroundColor Yellow
                for ($i = 0; $i -lt $backups.Count; $i++) {
                    Write-Host "$($i + 1). $($backups[$i].Name)"
                }
                
                $selection = Read-Host "Enter backup number to restore (or press Enter to skip)"
                if ($selection -and $selection -match '^\d+$' -and [int]$selection -le $backups.Count) {
                    $selectedBackup = $backups[[int]$selection - 1]
                    Write-Host "Restoring from: $($selectedBackup.Name)" -ForegroundColor Yellow
                    Get-Content $selectedBackup.FullName | docker exec -i savemoney-backend psql -U lakeman -d go_savemoney_dev
                    Write-Host "Data restored successfully!" -ForegroundColor Green
                }
            } else {
                Write-Host "No backup files found in backups directory" -ForegroundColor Yellow
            }
        } else {
            Write-Host "No backups directory found" -ForegroundColor Yellow
        }
    }
}

# Main execution
if ($Help) {
    Show-Help
    exit 0
}

Start-Setup