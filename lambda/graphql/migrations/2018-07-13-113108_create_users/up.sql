CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  client_id SERIAL REFERENCES clients (id),
  role VARCHAR NOT NULL,
  name VARCHAR NOT NULL,
  email VARCHAR NOT NULL,
  password_hash VARCHAR NOT NULL,
  timezone VARCHAR NOT NULL
)
