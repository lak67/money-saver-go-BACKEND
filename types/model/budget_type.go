package model

import "time"

type BudgetTypeStore interface {
	// GetUserByEmail(email string) (*User, error)
	// GetUserByID(id int) (*User, error)
	// CreateUser(User) error
	GetAllBudgetTypes() (*[]BudgetType, error)
}

type RegisterBudgetTypePayload struct {
	Name        string `json:"name" validate:"required"`
	Description string `json:"description" validate:"required"`
}

type BudgetType struct {
	ID          int       `json:"id"`
	Name        string    `json:"name"`
	Description string    `json:"description"`
	CreatedAt  time.Time `json:"created_at"`
	UpdatedAt  *time.Time `json:"updated_at,omitempty"`
	DeletedAt  *time.Time `json:"deleted_at,omitempty"`
}

// type LoginUserPayload struct {
// 	Email    string `json:"email" validate:"required,email"`
// 	Password string `json:"password" validate:"required"`
// }
