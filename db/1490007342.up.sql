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

CREATE OR REPLACE FUNCTION vote_insert()
  RETURNS TRIGGER AS $$
BEGIN
  UPDATE threads
  SET
    votes = votes + NEW.voice
  WHERE id = NEW.thread_id;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS on_vote_insert
ON votes;

CREATE TRIGGER on_vote_insert
AFTER INSERT ON votes
FOR EACH ROW EXECUTE PROCEDURE vote_insert();

CREATE OR REPLACE FUNCTION vote_update()
  RETURNS TRIGGER AS $$
BEGIN

  IF OLD.voice = NEW.voice
  THEN
    RETURN NULL;
  END IF;

  UPDATE threads
  SET
    votes = votes + CASE WHEN NEW.voice = -1 THEN -2 ELSE 2 END
  WHERE id = NEW.thread_id;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS on_vote_update
ON votes;

CREATE TRIGGER on_vote_update
AFTER UPDATE ON votes
FOR EACH ROW EXECUTE PROCEDURE vote_update();