CREATE TABLE IF NOT EXISTS "User" (
  id        INT          NOT NULL PRIMARY KEY,
  name      VARCHAR(50)  NOT NULL UNIQUE,
  full_name VARCHAR(100) NOT NULL,
  email     VARCHAR(50)  NOT NULL UNIQUE,
  about     TEXT
);
