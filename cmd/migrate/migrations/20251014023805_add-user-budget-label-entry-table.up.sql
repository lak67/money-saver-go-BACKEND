CREATE TABLE IF NOT EXISTS user_budget_label_entry (
    id SERIAL,
    user_id INT NOT NULL,
    budget_type_label_id INT NOT NULL,
    amount INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    
    CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_budget_type_label FOREIGN KEY (budget_type_label_id) REFERENCES budget_type_labels(id),
    CONSTRAINT user_budget_label_entry_pkey PRIMARY KEY (id)
);

-- Add trigger for auto-updating updated_at
CREATE TRIGGER set_updated_at
BEFORE UPDATE ON user_budget_label_entry
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();