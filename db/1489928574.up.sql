CREATE TABLE IF NOT EXISTS users (
  id       BIGSERIAL PRIMARY KEY,
  nickname VARCHAR(50)  NOT NULL,
  fullname VARCHAR(100) NOT NULL,
  email    VARCHAR(50)  NOT NULL,
  about    TEXT
);

CREATE UNIQUE INDEX index_users_on_nickname ON users (LOWER(nickname));

CREATE UNIQUE INDEX index_users_on_email ON users (LOWER(email));
