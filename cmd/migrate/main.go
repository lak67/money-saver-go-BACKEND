package main

import (
	"fmt"
	"log"
	"os"

	"github.com/lak67/money-saver-go-BACKEND/config"
	"github.com/lak67/money-saver-go-BACKEND/db"

	"github.com/golang-migrate/migrate/v4"
	"github.com/golang-migrate/migrate/v4/database/postgres"
	_ "github.com/golang-migrate/migrate/v4/source/file"
	"github.com/jackc/pgx/v5/stdlib"
)

func main() {
	// Build connection string
	connStr := fmt.Sprintf("postgres://%s:%s@%s/%s?sslmode=disable",
		config.Envs.DBUser,
		config.Envs.DBPassword,
		config.Envs.DBAddress,
		config.Envs.DBName,
	)

	// Create pgxpool for your app
	pool, err := db.NewPGXPoolStorage(connStr)
	if err != nil {
		log.Fatal(err)
	}
	defer pool.Close()

	// For migrations, we need *pgxpool.Pool, so we get it from the pool
	sqlDB := stdlib.OpenDBFromPool(pool)

	// Run migrations
	driver, err := postgres.WithInstance(sqlDB, &postgres.Config{})
	if err != nil {
		log.Fatal(err)
	}

	m, err := migrate.NewWithDatabaseInstance(
		"file://cmd/migrate/migrations",
		"postgres",
		driver,
	)
	if err != nil {
		log.Fatal(err)
	}

	cmd := os.Args[len(os.Args)-1]
	if cmd == "up" {
		if err := m.Up(); err != nil && err != migrate.ErrNoChange {
			log.Fatal(err)
		}
		log.Println("Migrations applied successfully")
	}
	if cmd == "down" {
		if err := m.Down(); err != nil && err != migrate.ErrNoChange {
			log.Fatal(err)
		}
		log.Println("Migrations rolled back successfully")
	}

	// Now you can use 'pool' for your app queries
	// Example:
	// rows, err := pool.Query(ctx, "SELECT * FROM users")
}
