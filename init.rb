require './db/init'

configure do
  set :public_folder, 'public'
  set :bind, '0.0.0.0'
end

# configure :development do
#   set :conn, PG::connect('postgres://localhost/testdb')
# end

# configure :development do
#   set :database, {adapter: 'postgresql',  encoding: 'unicode', database: 'testdb',
#                   pool: 2, username: 'Vileven', password: 'Chelsea11'}
# end

def sql(cmd, *args)
  $db ||= DB::connect
  $db.exec cmd, args
end
