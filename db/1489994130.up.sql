CREATE SEQUENCE posts_id_seq START 1 ;
CREATE TABLE IF NOT EXISTS posts (
  id        BIGINT PRIMARY KEY DEFAULT NEXTVAL('posts_id_seq'),
  author    VARCHAR(50)                                        NOT NULL,
  author_id BIGINT REFERENCES users (id)                       NOT NULL,
  created   TIMESTAMPTZ                                        NOT NULL,
  is_edited BOOLEAN                                                     DEFAULT TRUE,
  forum     VARCHAR(50)                                        NOT NULL,
  forum_id  BIGINT REFERENCES forums (id)                      NOT NULL,
  message   TEXT                                               NOT NULL,
  parent    BIGINT                                             NOT NULL DEFAULT currval('posts_id_seq'),
  path      INT[]                                      NOT NULL,
  thread    VARCHAR(50),
  thread_id BIGINT REFERENCES threads (id)                     NOT NULL
);

CREATE INDEX index_posts_on_path
  ON posts (path);

CREATE INDEX index_posts_on_author_id
  ON posts (author_id);

CREATE INDEX index_posts_on_forum_id
  ON posts (forum_id);

CREATE INDEX index_posts_on_thread_id
  ON posts (thread);

CREATE INDEX index_posts_on_parent
  ON posts (parent);