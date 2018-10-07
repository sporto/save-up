CREATE TABLE clients (
  id SERIAL PRIMARY KEY,
  created_at TIMESTAMP DEFAULT current_timestamp NOT NULL,
  name VARCHAR NOT NULL
)
