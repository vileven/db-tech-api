CREATE TABLE IF NOT EXISTS threads (
  id BIGSERIAL PRIMARY KEY ,
  author VARCHAR(50) REFERENCES users(nickname),
  author_id BIGINT REFERENCES users(id),
  created TIMESTAMPTZ NOT NULL,
  forum VARCHAR(50) REFERENCES forums(slug),
  forum_id BIGINT REFERENCES forums(id),
  message TEXT NOT NULL,
  slug VARCHAR(50) UNIQUE,
  title VARCHAR(100) NOT NULL,
  votes INT NOT NULL DEFAULT 0
);

CREATE INDEX index_threads_on_author_id
  ON threads(author_id);

CREATE INDEX index_threads_on_forum_id
  ON threads(forum_id);

CREATE UNIQUE INDEX
  ON threads(LOWER(slug));