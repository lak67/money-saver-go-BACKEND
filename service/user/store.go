package user

import (
	"database/sql"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/lak67/money-saver-go-BACKEND/types"
)

type Store struct {
	db *pgxpool.Pool
}

func NewStore(db *pgxpool.Pool) *Store {
	return &Store{
		db: db,
	}
}

func (s *Store) GetUserByEmail(email string) (*types.User, error) {
	rows, err := s.db.Query("SELECT id, first_name, last_name, email, password, created_at FROM users WHERE email = ?", email)
	if err != nil {
		return nil, err
	}

	u := new(types.User)
	for rows.Next() {
		u, err = scanRowIntoUser(rows)
		if err != nil {
			return nil, err
		}
	}

	if u.ID == 0 {
		return nil, sql.ErrNoRows
	}

	return u, nil
}

func scanRowIntoUser(row *sql.Rows) (*types.User, error) {
	user := new(types.User)

	err := row.Scan(&user.ID, &user.FirstName, &user.LastName, &user.Email, &user.Password, &user.CreatedAt)
	if err != nil {
		return nil, err
	}
	return user, nil
}

func (s *Store) CreateUser(u types.User) error {
	_, err := s.db.Exec("INSERT INTO users (first_name, last_name, email, password) VALUES (?, ?, ?, ?)",
		u.FirstName, u.LastName, u.Email, u.Password)
	if err != nil {
		return err
	}

	return nil
}

func (s *Store) GetUserByID(id int) (*types.User, error) {
	rows, err := s.db.Query("SELECT id, first_name, last_name, email, password, created_at FROM users WHERE id = ?", id)
	if err != nil {
		return nil, err
	}

	u := new(types.User)
	for rows.Next() {
		u, err = scanRowIntoUser(rows)
		if err != nil {
			return nil, err
		}
	}

	if u.ID == 0 {
		return nil, sql.ErrNoRows
	}

	return u, nil
}
