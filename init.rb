require './db/init'

configure do
  set :public_folder, 'public'
  set :bind, '0.0.0.0'
end

def sql(cmd, *args)
  $db ||= DB::connect
  $db.exec cmd, args
end
