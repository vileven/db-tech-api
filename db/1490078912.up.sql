CREATE OR REPLACE FUNCTION threads_insert()
  RETURNS TRIGGER AS $$
BEGIN
  UPDATE forums
  SET
    threads = threads + 1
  WHERE id = NEW.forum_id;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS on_threads_insert
ON threads;

CREATE TRIGGER on_threads_insert
AFTER INSERT ON threads
FOR EACH ROW EXECUTE PROCEDURE threads_insert();

CREATE OR REPLACE FUNCTION posts_insert()
  RETURNS TRIGGER AS $$
BEGIN
  UPDATE forums
  SET
    posts = posts + 1
  WHERE id = NEW.forum_id;

  IF NEW.parent IS NOT NULL THEN
    PERFORM 1 FROM posts p
    WHERE p.id = NEW.parent AND NEW.thread_id = p.thread_id AND p.forum_id = NEW.forum_id ;
    IF NOT FOUND THEN
      RAISE EXCEPTION '% on % is not allowed. % - %',
      TG_OP, TG_TABLE_NAME, NEW.id, NEW.parent;
    END IF;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS on_posts_insert
ON posts;

CREATE TRIGGER on_posts_insert
AFTER INSERT ON posts
FOR EACH ROW EXECUTE PROCEDURE posts_insert();


CREATE OR REPLACE FUNCTION threads_delete()
  RETURNS TRIGGER AS $$
BEGIN
  UPDATE forums
  SET
    threads = threads - 1
  WHERE id = OLD.forum_id;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS on_threads_delete
ON threads;

CREATE TRIGGER on_threads_delete
AFTER DELETE ON threads
FOR EACH ROW EXECUTE PROCEDURE threads_delete();



CREATE OR REPLACE FUNCTION posts_delete()
  RETURNS TRIGGER AS $$
BEGIN
  UPDATE forums
  SET
    posts = posts - 1
  WHERE id = OLD.forum_id;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS on_posts_delete
ON posts;

CREATE TRIGGER on_posts_delete
AFTER DELETE ON posts
FOR EACH ROW EXECUTE PROCEDURE posts_delete();
