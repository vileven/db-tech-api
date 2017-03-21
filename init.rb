require './db/init'

configure do
  set :public_folder, 'public'
  set :bind, '0.0.0.0'
end

def sql(cmd, *args)
  $db ||= DB::connect
  $db.exec cmd, args
end

def sql_without(cmd)
  $db ||= DB::connect
  $db.exec cmd
end

def transaction
  $db ||= DB::connect
  $db.transaction {|con| yield con}
end

def sql_set_prepare(statement, query)
  $db ||= DB::connect
  $db.prepare statement, query
end

def sql_set_prepare_with_type(statement, query, data_types)
  $db ||= DB::connect
  $db.prepare statement, query, data_types
end

def sql_exec_prepare(statement, *args)
  $db.exec_prepared statement, args
end


sql_set_prepare 'create user', "
INSERT INTO users (nickname, fullname, email, about) VALUES ($1, $2, $3, $4);
"

sql_set_prepare 'create forum', "
INSERT INTO forums (posts, slug, threads, title, \"user\", user_id) VALUES ($1, $2, $3, $4, $5, $6)
RETURNING slug, title, \"user\";
"

sql_set_prepare 'create forum without posts and threads', "
INSERT INTO forums (slug, title, \"user\", user_id) VALUES ($1, $2, $3, $4)
RETURNING slug, title, \"user\";
"

sql_set_prepare 'get user by login', "
SELECT
  u.nickname,
  u.fullname,
  u.email,
  u.about
FROM users AS u
WHERE LOWER(u.nickname) = LOWER($1);
"

sql_set_prepare 'get user by login or email', "
SELECT
  u.nickname,
  u.fullname,
  u.email,
  u.about
FROM users AS u
WHERE lower(u.nickname) = lower($1) OR lower(u.email) = lower($2);
"

sql_set_prepare 'change user by login', "
UPDATE users
SET
  email    = CASE WHEN $2::VARCHAR(50) IS NOT NULL THEN $2 ELSE email END,
  fullname = CASE WHEN $3::VARCHAR(50) IS NOT NULL THEN $3 ELSE fullname END,
  about    = CASE WHEN $4::VARCHAR(50) IS NOT NULL THEN $4 ELSE about END
WHERE LOWER(nickname) = LOWER($1)
RETURNING nickname, fullname, email, about;
"

# sql_set_prepare 'change email by login', "
# UPDATE users
# SET
#   email    = $2
# WHERE LOWER(nickname) = LOWER($1)
# RETURNING nickname, fullname, email, about;
# "

sql_set_prepare 'validate changing on unique email', "
SELECT
  *
FROM users AS u
WHERE LOWER(u.nickname) != LOWER($1) AND LOWER(u.email) = LOWER($2);
"

sql_set_prepare 'get user by login with id', "
SELECT
  *
FROM users AS u
WHERE LOWER(u.nickname) = LOWER($1);
"

sql_set_prepare 'get forum by slug', "
SELECT
  *
FROM forums AS f
WHERE LOWER(f.slug) = LOWER($1)
"

sql_set_prepare 'get forum by slug with id', "
SELECT
  f.id,
  f.slug,
  f.title,
  f.\"user\"
FROM forums AS f
WHERE LOWER(f.slug) = LOWER($1)
"

sql_set_prepare 'get thread by id', "
SELECT
  *
FROM threads AS t
WHERE t.id = $1;
"

sql_set_prepare 'get thread by slug', "
SELECT
 *
FROM threads AS t
WHERE LOWER(t.slug) = LOWER($1);
"


sql_set_prepare 'create thread', "
INSERT INTO threads (author, author_id, created, forum, forum_id, message, slug, title) VALUES
  ($1,
   $2,
   CASE WHEN $3::TIMESTAMPTZ IS NOT NULL
     THEN $3
   ELSE now() END,
   $4,
   $5,
   $6,
   CASE WHEN $7::VARCHAR(50) IS NOT NULL
     THEN $7
   ELSE NULL END,
   $8)
RETURNING
  author,
  created,
  forum,
  id,
  message,
  slug,
  title
"

sql_set_prepare 'get forum by thread id', "
SELECT DISTINCT f.id, f.slug
    FROM
      forums AS f
      JOIN threads AS t ON t.id = $1 AND f.id = t.forum_id
"

sql_set_prepare 'create post', "
INSERT INTO posts (author, author_id, created, is_edited, forum, forum_id, message, parent, path, thread, thread_id) VALUES
  ($1,
   $2,
   CASE WHEN $3::TIMESTAMPTZ IS NOT NULL THEN $3 ELSE now() END,
   $4,
   $5,
   $6,
   $7,
   CASE WHEN $8::BIGINT IS NOT NULL THEN $8 ELSE NULL END,
   (SELECT path FROM posts WHERE id = $8) || (select currval('posts_id_seq')::integer),
   $9,
   $10)
RETURNING *
"

sql_set_prepare 'create vote', "
INSERT INTO votes (user_id, thread_id) VALUES
  ($1, $2);
"

sql_set_prepare 'change vote field', "
UPDATE threads
SET
  votes = votes + $2
WHERE id = $1;
"

sql_set_prepare 'vote exists?', "
SELECT * FROM votes WHERE user_id = $1 AND thread_id = $2 ;
"

sql_set_prepare 'insert vote', "
INSERT INTO votes (user_id, thread_id, voice) VALUES ($1, $2, $3)
ON CONFLICT (user_id, thread_id) DO
  UPDATE SET voice = $3;
"

sql_set_prepare 'update vote', "
UPDATE votes
SET voice = $3
WHERE user_id = $1 AND thread_id = $2 ;
"

sql_set_prepare 'update thread',"
UPDATE threads
SET
  message = $2,
  title = $3
WHERE id = $1
RETURNING *
"
sql_set_prepare 'get post by id',"
SELECT
  *
FROM posts AS p
WHERE p.id = $1 ;
"

sql_set_prepare 'update post', "
UPDATE posts
SET
  message = $2,
  is_edited = TRUE
WHERE id = $1
RETURNING *;
"