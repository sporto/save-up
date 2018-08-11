CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  created_at TIMESTAMP  DEFAULT current_timestamp NOT NULL,
  client_id SERIAL REFERENCES clients (id),
  email VARCHAR NOT NULL,
  password_hash VARCHAR NOT NULL,
  name VARCHAR NOT NULL,
  role VARCHAR NOT NULL,
  email_confirmation_token VARCHAR,
  email_confirmed_at TIMESTAMP
)
