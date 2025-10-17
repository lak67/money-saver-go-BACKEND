#!/usr/bin/env pwsh
# Validation script to test database setup and restore functionality

Write-Host "Testing Money Saver Go Backend setup..." -ForegroundColor Cyan

# Test 1: Check if required files exist
Write-Host "`n1. Checking required files..." -ForegroundColor Yellow
$requiredFiles = @(".env.example", "docker-compose.yml", "Makefile")
foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "  ✓ $file exists" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $file missing" -ForegroundColor Red
    }
}

# Test 2: Check if Docker is running
Write-Host "`n2. Checking Docker..." -ForegroundColor Yellow
try {
    $dockerInfo = docker info 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ Docker is running" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Docker is not running" -ForegroundColor Red
    }
} catch {
    Write-Host "  ✗ Docker is not installed or not running" -ForegroundColor Red
}

# Test 3: Check if .env file exists
Write-Host "`n3. Checking environment configuration..." -ForegroundColor Yellow
if (Test-Path ".env") {
    Write-Host "  ✓ .env file exists" -ForegroundColor Green
} else {
    Write-Host "  ! .env file missing - run 'cp .env.example .env'" -ForegroundColor Yellow
}

# Test 4: Check if backups directory exists
Write-Host "`n4. Checking backups directory..." -ForegroundColor Yellow
if (Test-Path "backups") {
    $backupCount = (Get-ChildItem "backups\*.sql" -ErrorAction SilentlyContinue).Count
    Write-Host "  ✓ backups directory exists with $backupCount backup files" -ForegroundColor Green
} else {
    Write-Host "  ! backups directory missing - will be created automatically" -ForegroundColor Yellow
}

# Test 5: Check if container is running
Write-Host "`n5. Checking database container..." -ForegroundColor Yellow
try {
    $containerStatus = docker ps --filter "name=savemoney-backend" --format "table {{.Names}}\t{{.Status}}" 2>$null
    if ($containerStatus -and $containerStatus -match "savemoney-backend") {
        Write-Host "  ✓ Database container is running" -ForegroundColor Green
    } else {
        Write-Host "  ! Database container is not running - run 'make docker-up'" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  ! Could not check container status" -ForegroundColor Yellow
}

Write-Host "`nValidation complete!" -ForegroundColor Cyan
Write-Host "`nQuick commands to get started:" -ForegroundColor White
Write-Host "  make help           - Show all available commands" -ForegroundColor Gray
Write-Host "  make setup          - Setup everything for development" -ForegroundColor Gray
Write-Host "  make docker-up      - Start database container" -ForegroundColor Gray
Write-Host "  make backup         - Create database backup" -ForegroundColor Gray
Write-Host "  make restore        - Restore from backup" -ForegroundColor Gray