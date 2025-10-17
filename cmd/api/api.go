package api

import (
	"log"
	"net/http"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/lak67/money-saver-go-BACKEND/service/budget_types"
	"github.com/lak67/money-saver-go-BACKEND/service/middleware"
	"github.com/lak67/money-saver-go-BACKEND/service/user"

	"github.com/gorilla/mux"
)

type APIServer struct {
	addr string
	db   *pgxpool.Pool
}

func NewAPIServer(add string, db *pgxpool.Pool) *APIServer {
	return &APIServer{
		addr: add,
		db:   db,
	}
}

func (s *APIServer) Run2() error {
	router := mux.NewRouter()
	subrouter := router.PathPrefix("/api/v1").Subrouter()

	userStore := user.NewStore(s.db)

	userHandler := user.NewHandler(userStore)
	userHandler.RegisterRoutes(subrouter)

	log.Println("Starting server on", s.addr)

	return http.ListenAndServe(s.addr, router)
}

func (s *APIServer) Run() error {
    router := mux.NewRouter()
    subrouter := router.PathPrefix("/api/v1").Subrouter()
    
    userStore := user.NewStore(s.db)
    userHandler := user.NewHandler(userStore)
    userHandler.RegisterRoutes(subrouter)

	budgetTypeStore := budget_types.NewStore(s.db)
	budgetTypeHandler := budget_types.NewHandler(budgetTypeStore)
	budgetTypeHandler.RegisterRoutes(subrouter)
    
    // Apply CORS middleware
    handler := middleware.CorsMiddleware(router)
    
    log.Println("Starting server on", s.addr)
    return http.ListenAndServe(s.addr, handler)
}