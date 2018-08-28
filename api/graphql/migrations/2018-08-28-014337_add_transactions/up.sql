CREATE TABLE transactions (
  id SERIAL PRIMARY KEY,
  created_at TIMESTAMP DEFAULT current_timestamp NOT NULL,
  account_id SERIAL REFERENCES accounts (id),
  kind VARCHAR NOT NULL,
  amount MONEY NOT NULL
)
