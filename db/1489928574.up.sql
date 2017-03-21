-- ALTER USER postgres SET timezone='Europe/Moscow';
-- set timezone='Europe/Moscow';
CREATE TABLE IF NOT EXISTS users (
  id       BIGSERIAL PRIMARY KEY,
  nickname VARCHAR(50)  NOT NULL UNIQUE,
  fullname VARCHAR(100) NOT NULL,
  email    VARCHAR(50)  NOT NULL UNIQUE,
  about    TEXT
);

CREATE INDEX index_users_on_nickname
  ON users (LOWER(nickname));

CREATE INDEX index_users_on_email
  ON users (LOWER(email));