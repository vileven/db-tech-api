require 'sinatra'
require 'pg'
require './init'
require 'sinatra/json'
# require 'json'
require './models/user'
require './models/forum'
require './models/thread_manager'
require './models/post'

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

  post '/user/:login/create' do
    exists_users = User.get_user_by_login_or_email params[:login], @request_body["email"]

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
    unless User.valid_changing? params[:login], @request_body
      status 409
      halt
    end

    user = User.change_user_by_login params[:login], @request_body
    unless user
      status 404
      halt
    end

    status 200
    response.body = json user
  end

  post '/forum/create' do
    user = User.get_user_by_login_with_id @request_body["user"]
    unless user
      status 404
      halt
    end


    exists_forum = Forum.get_forum_by_slug @request_body["slug"]
    unless exists_forum.nil?
      status 409
      response.body = json exists_forum
      halt response
    end

    forum = Forum.create @request_body, user
    unless forum
      status 409
      halt
    end

    status 201
    response.body = json forum
  end

  get '/forum/:slug/details' do
    forum = Forum.get_forum_by_slug params[:slug]
    unless forum
      status 404
      halt
    end

    status 200
    response.body = json forum
  end


  post '/forum/:slug/create' do
    forum = Forum.get_forum_by_slug_with_id params[:slug]
    user = User.get_user_by_login_with_id @request_body["author"]

    if forum.nil? || user.nil?
      status 404
      halt
    end


    thread = ThreadManager.get_thread_by_id_or_slug (@request_body["id"].nil?) ?
                                                        @request_body["slug"] : @request_body["id"]
    unless thread.nil?
      status 409
      response.body = json ThreadManager.to_read thread
      halt response
    end

    thread = ThreadManager.create forum, user, @request_body
    thread["id"] = Integer(thread["id"])
    # thread["id"] = 42
    # yyyy-MM-dd'T'HH:mm:ss.SSSZ
    # thread["created"] = Time.new(thread["created"]).strftime("%Y-%m-%dT%H:%M:%S%z")
    status 201
    response.body = json thread
  end

  get '/forum/:slug/threads' do
    forum = Forum.get_forum_by_slug_with_id params[:slug]
    unless forum
      status 404
      halt
    end
    threads = Forum.get_threads(forum["slug"], params[:limit], params[:since], params[:desc])
    status 200
    response.body = json threads
  end

  post '/thread/:slug_or_id/create' do
    thread = ThreadManager.get_thread_by_id_or_slug params[:slug_or_id]
    forum = Forum.get_forum_by_slug thread["forum"]
    user = User.get_user_by_login_with_id @request_body[0]["author"]
    if forum.nil? || user.nil?
      status 404
      halt
    end

    post = Post.create forum, user,  thread, @request_body[0]

    status 201
    response.body = json post
  end

  post '/thread/:slug_or_id/vote' do
    thread = ThreadManager.get_thread_by_id_or_slug params[:slug_or_id]
    user = User.get_user_by_login_with_id @request_body["nickname"]
    unless ThreadManager.vote user, thread, @request_body["voice"]
      status 404
      halt
    end
    res = ThreadManager.to_read_with_votes ThreadManager.get_thread_by_id thread["id"]
    p res
    response.body = json res
  end

  get '/thread/:slug_or_id/details' do
    thread = ThreadManager.get_thread_by_id_or_slug params[:slug_or_id]
    unless thread
      status 404
      halt
    end

    status 200
    response.body = json ThreadManager.to_read thread
  end
end

