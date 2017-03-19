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

def sql_exec_prepare(statement, *args)
  $db.exec_prepared statement, args
end


sql_set_prepare 'create user', "
INSERT INTO users (nickname, fullname, email, about) VALUES ($1, $2, $3, $4);
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

sql_set_prepare 'user exists?', "
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
  email    = $2,
  fullname = $3,
  about    = $4
WHERE LOWER(nickname) = LOWER($1)
RETURNING nickname, fullname, email, about;
"
