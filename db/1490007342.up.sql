CREATE TABLE IF NOT EXISTS votes(
  user_id BIGINT REFERENCES users(id) NOT NULL,
  thread_id BIGINT REFERENCES threads(id) NOT NULL,
  voice INT NOT NULL
);

CREATE UNIQUE INDEX index_votes_on_user_id_and_thread_id
  ON votes(user_id, thread_id);

CREATE INDEX index_votes_on_user_id
  ON votes(user_id);

CREATE INDEX index_votes_on_thread_id
  ON votes(thread_id);