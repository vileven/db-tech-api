CREATE TABLE IF NOT EXISTS posts (
  id        BIGSERIAL PRIMARY KEY,
  author    VARCHAR(50) NOT NULL,
  author_id BIGINT REFERENCES users (id),
  created   TIMESTAMPTZ NOT NULL,
  is_edited BOOLEAN DEFAULT TRUE,
  forum     VARCHAR(50) NOT NULL,
  forum_id  BIGINT REFERENCES forums (id),
  message   TEXT        NOT NULL,
  parent    BIGINT NOT NULL DEFAULT 0,
  thread    VARCHAR(50),
  thread_id BIGINT REFERENCES threads(id)
);

CREATE INDEX index_posts_on_author_id
  ON posts (author_id);

CREATE INDEX index_posts_on_forum_id
  ON posts (forum_id);

CREATE INDEX index_posts_on_thread_id
  ON posts (thread);

CREATE INDEX index_posts_on_parent
  ON posts (parent);