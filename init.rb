require './db/init'

configure do
  set :public_folder, 'public'
  set :bind, '0.0.0.0'
end

def sql(cmd, *args)
  $db ||= DB::connect
  $db.exec cmd, args
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
  email    = CASE WHEN LOWER($2) IS NOT NULL THEN $2 ELSE email END,
  fullname = CASE WHEN LOWER($3) IS NOT NULL THEN $3 ELSE fullname END,
  about    = CASE WHEN LOWER($4) IS NOT NULL THEN $4 ELSE about END
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
  f.slug,
  f.title,
  f.\"user\"
FROM forums AS f
WHERE LOWER(f.slug) = LOWER($1)
"