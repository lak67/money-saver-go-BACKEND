package db

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"
)

// func NewMySQLStorage(cfg mysql.Config) (*pgxpool.Pool, error) {
// 	db, err := sql.Open("mysql", cfg.FormatDSN())
// 	if err != nil {
// 		log.Fatal(err)
// 	}
// 	return db, nil
// }

// func NewPostgresStorage(cfg *pgx.ConnConfig) (*pgxpool.Pool, error) {
// 	connStr := stdlib.RegisterConnConfig(cfg)
// 	db, err := sql.Open("pgx", connStr)
// 	if err != nil {
// 		return nil, fmt.Errorf("failed to open database: %w", err)
// 	}
// 	return db, nil
// }

func NewPGXPoolStorage(cfg string) (*pgxpool.Pool, error) {
	ctx := context.Background()

	poolConfig, err := pgxpool.ParseConfig(cfg)
	if err != nil {
		return nil, fmt.Errorf("failed to parse config: %w", err)
	}

	// Configure pool settings (optional, for learning)
	poolConfig.MaxConns = 10
	poolConfig.MinConns = 2

	pool, err := pgxpool.NewWithConfig(ctx, poolConfig)
	if err != nil {
		return nil, fmt.Errorf("failed to create connection pool: %w", err)
	}

	return pool, nil
}
