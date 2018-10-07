CREATE TABLE invitations (
  id SERIAL PRIMARY KEY,
  created_at TIMESTAMP  DEFAULT current_timestamp NOT NULL,
  user_id SERIAL REFERENCES users (id),
  email VARCHAR NOT NULL,
  role VARCHAR NOT NULL,
  token VARCHAR NOT NULL,
  used_at TIMESTAMP
)
