CREATE TABLE IF NOT EXISTS user_table (
  id       BIGSERIAL PRIMARY KEY,
  nickname VARCHAR(50)  NOT NULL UNIQUE,
  fullname VARCHAR(100) NOT NULL,
  email    VARCHAR(50)  NOT NULL UNIQUE,
  about    TEXT
);