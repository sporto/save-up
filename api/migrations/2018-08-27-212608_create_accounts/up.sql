CREATE TABLE accounts (
  id SERIAL PRIMARY KEY,
  created_at TIMESTAMP DEFAULT current_timestamp NOT NULL,
  user_id SERIAL REFERENCES users (id),
  name VARCHAR NOT NULL,
  yearly_interest DECIMAL(5,2) NOT NULL
)
