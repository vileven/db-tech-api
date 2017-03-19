require 'sinatra'
require 'pg'
require './init'
require 'sinatra/json'
require './models/user'


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
    # p @request_body
  end

  before do
    content_type :json
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

  post '/user/:login/create' do
    exists_users = User.exists? params[:login], @request_body["email"]

    if exists_users
      status 409
      response.body = json exists_users
    else
      user = User.create @request_body, params[:login]
      status 201
      response.body = json user
    end
  end

  get '/user/:login/profile' do
    user = User.get_user_by_login params[:login]
    unless user
      status 404
      halt
    end

    status 200
    response.body = json user
  end

  post '/user/:login/profile' do
    user = User.change_user_by_login params[:login], @request_body
    unless user
      status 404
      halt
    end

    status 200
    response.body = json user
  end

end

