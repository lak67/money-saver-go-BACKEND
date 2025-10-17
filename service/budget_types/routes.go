package budget_types

import (
	"fmt"
	"net/http"

	"github.com/gorilla/mux"
	"github.com/lak67/money-saver-go-BACKEND/types/model"
	"github.com/lak67/money-saver-go-BACKEND/utils"
)

type Handler struct {
	store model.BudgetTypeStore
}

func NewHandler(store model.BudgetTypeStore) *Handler {
	return &Handler{
		store: store,
	}
}

func (h *Handler) RegisterRoutes(router *mux.Router) {
	router.HandleFunc("/budgettypes", h.handleGetBudgetTypes).Methods("POST")
	// router.HandleFunc("/register", h.handleRegister).Methods("POST")
}

func (h *Handler) handleGetBudgetTypes(w http.ResponseWriter, r *http.Request) {
	budget_types, err := h.store.GetAllBudgetTypes()
	if err != nil {
		utils.WriteError(w, http.StatusUnauthorized, fmt.Errorf("failed to get budget types: %v", err))
		return
	}

	utils.WriteJSON(w, http.StatusOK, budget_types)
}