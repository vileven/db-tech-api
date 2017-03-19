CREATE TABLE IF NOT EXISTS forums (
  id      BIGSERIAL PRIMARY KEY,
  posts   INT                                     NOT NULL DEFAULT 0,
  slug    VARCHAR(50)                             NOT NULL UNIQUE,
  threads INT                                     NOT NULL DEFAULT 0,
  title   VARCHAR(100)                            NOT NULL,
  "user"  VARCHAR(50) REFERENCES users (nickname) NOT NULL,
  user_id BIGINT REFERENCES users (id)            NOT NULL
);

CREATE UNIQUE INDEX index_posts_on_slug
  ON forums (LOWER(slug));