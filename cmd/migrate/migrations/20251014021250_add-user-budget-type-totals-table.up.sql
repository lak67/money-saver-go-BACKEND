CREATE TABLE IF NOT EXISTS user_budget_type_totals (
    id SERIAL,
    user_id INT NOT NULL,
    budget_type_id INT NOT NULL,
    budget_total_amount INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    
    CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_budget_type FOREIGN KEY (budget_type_id) REFERENCES budget_types(id),
    
    CONSTRAINT user_budget_type_totals_pkey PRIMARY KEY (id)
);

-- Create trigger for auto-updating updated_at
CREATE TRIGGER set_updated_at
BEFORE UPDATE ON user_budget_type_totals
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();