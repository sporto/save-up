DROP INDEX index_users_on_username;

ALTER TABLE users
DROP COLUMN username;
