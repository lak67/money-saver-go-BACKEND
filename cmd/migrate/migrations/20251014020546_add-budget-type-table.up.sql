CREATE TABLE IF NOT EXISTS budget_types (
    id SERIAL,
    type_name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,

    CONSTRAINT budget_types_pkey PRIMARY KEY (id),
    CONSTRAINT budget_types_type_name_key UNIQUE (type_name)
);

-- Create the trigger
CREATE TRIGGER set_updated_at
BEFORE UPDATE ON budget_types
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();