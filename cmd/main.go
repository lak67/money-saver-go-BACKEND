package main

import (
	"context"
	"fmt"
	"log"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/lak67/money-saver-go-BACKEND/cmd/api"
	"github.com/lak67/money-saver-go-BACKEND/config"
	"github.com/lak67/money-saver-go-BACKEND/db"
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

	initStorage(pool)

	server := api.NewAPIServer(":8080", pool)
	if err := server.Run(); err != nil {
		log.Fatal(err)
	}
}

func initStorage(pool *pgxpool.Pool) {
	err := pool.Ping(context.Background())
	if err != nil {
		log.Fatal(err)
	}

	log.Println("Database connected")
}
