package user

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

func (s *Store) GetUserByEmail(email string) (*model.User, error) {
	user, err := pgxutil.Select(context.Background(), s.db, "select id, name, email from users where email = $1",
		[]interface{}{email}, pgx.RowToStructByPos[model.User])
	if err != nil {
		return nil, err
	}

	if user[0].ID == 0 {
		return nil, sql.ErrNoRows
	}

	return &user[0], nil
}

func (s *Store) CreateUser(u model.User) error {
	pgx.BeginFunc(context.Background(), s.db, func(tx pgx.Tx) error {
		_, err := tx.Exec(context.Background(), `insert into users (first_name, last_name, email, password, income) values
    ($1, $2, $3, $4, $5)`, u.FirstName, u.LastName, u.Email, u.Password, u.Income)
		if err != nil {
			return err
		}
		return nil
	})
	return nil
}

func (s *Store) GetUserByID(id int) (*model.User, error) {
	user, err := pgxutil.Select(context.Background(), s.db, "select id, first_name, last_name, email, password, income, created_at from users where id = $1",
		[]interface{}{id}, pgx.RowToStructByPos[model.User])
	if err != nil {
		return nil, err
	}

	if user[0].ID == 0 {
		return nil, sql.ErrNoRows
	}

	return &user[0], nil
}
