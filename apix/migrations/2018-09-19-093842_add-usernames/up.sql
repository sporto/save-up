ALTER TABLE users
ADD COLUMN username VARCHAR NOT NULL;

CREATE INDEX index_users_on_username ON users (username);
