require 'sinatra'
require 'pg'
require './init'
require 'json'


class Application < Sinatra::Base
  configure do
    set :bind, '0.0.0.0'

    set :method do |method|
      condition { request.request_method == method.to_s.upcase }
    end
  end


  before :method => :post do
    request.body.rewind
    @request_body = JSON.parse request.body.read.to_s
    p @request_body
  end

  get '/' do

    sql('select version from schema_info').first['version']
    # ENV['DATABASE_URL']
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

  post '/user/create' do

  end

end

