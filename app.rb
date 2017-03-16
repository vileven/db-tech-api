require 'sinatra'
require 'pg'
require './init'

configure do
  set :bind, '0.0.0.0'
end

get '/' do

  # sql('select version from schema_info').first['version']
  ENV['DATABASE_URL']
end

get '/create/test/db' do
  sql('CREATE TABLE test (test_field INTEGER NOT NULL)')
end

get '/add/test/value' do
  sql "insert into test (test_field) values (15)"
end

get '/show/test/values' do
  sql( "select test_field from test" ).first['test_field']
end
