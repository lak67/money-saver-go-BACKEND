package budget_types

import (
	"context"
	"database/sql"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/jackc/pgxutil"
	"github.com/lak67/money-saver-go-BACKEND/types/model"
)
type Store struct {
	db *pgxpool.Pool
}

func NewStore(db *pgxpool.Pool) *Store {
	return &Store{
		db: db,
	}
}

func (s *Store) GetAllBudgetTypes() (*[]model.BudgetType, error) {
	ctx := context.Background()
	budgetTypes, err := pgxutil.Select(ctx, s.db, "SELECT id, type_name, description, created_at, updated_at, deleted_at FROM budget_types", []any{}, pgx.RowToStructByPos[model.BudgetType])
	if err != nil {
		return nil, err
	}

	if len(budgetTypes) == 0 {
		return nil, sql.ErrNoRows
	}

	return &budgetTypes, nil
}
