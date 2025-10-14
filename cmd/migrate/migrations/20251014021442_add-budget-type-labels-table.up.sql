CREATE TABLE IF NOT EXISTS budget_type_labels (
    id SERIAL,
    label_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    budget_type_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,

    CONSTRAINT fk_budget_type FOREIGN KEY (budget_type_id) REFERENCES budget_types(id),
    CONSTRAINT budget_type_labels_unique UNIQUE (label_name),
    CONSTRAINT budget_type_labels_pkey PRIMARY KEY (id)
);

-- Add trigger for updated_at
CREATE TRIGGER set_updated_at
BEFORE UPDATE ON budget_type_labels
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();