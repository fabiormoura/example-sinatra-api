require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'byebug'
require 'jwt'

SECRET = "96e8r4u3ltsdogveuciwuaric7wu5cp"

before do
   content_type :json
   headers 'Access-Control-Allow-Origin' => '*',
               'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST'],
               'Access-Control-Allow-Headers' => ['Content-Type', 'Authorization']
end

set :protection, false

options '/welcome.json' do
  200
end

def protect!
  halt 401, 'Not Authorized' unless verify_token!(request.env['HTTP_AUTHORIZATION'])
end

get '/welcome.json' do
  protect!
  {:text => "This is a private a content" }.to_json
end

options '/authenticate.json' do
  200
end

post '/authenticate.json' do
  params.merge! JSON.parse(request.env["rack.input"].read)
  user_id = authenticate!(params[:username], params[:password])

  result = {}

  result[:authenticated] = authenticated = !user_id.nil?

  errors = validate(params[:username], params[:password])
  result[:errors] = errors if errors

  result[:token]  = generate_auth_token(user_id) if authenticated

  result.to_json
end

private

def verify_token!(token)
  result = JWT.decode(token, SECRET)
  result[0]["user_id"].to_s == 1.to_s
rescue JWT::DecodeError
  false
end

def authenticate!(username, password)
  return 1 if username == "admin" && password == "admin"
end

def generate_auth_token(user_id)
  JWT.encode({"user_id" => user_id.to_s}, SECRET)
end

def validate(username, password)
  errors = {}
  if username.nil? || username.size == 0
    errors[:username] = "please enter your username"
  elsif username.size <= 4
    errors[:username] = "username is too short"
  end

  if password.nil? || password.size == 0
    errors[:password] = "please enter your password"
  elsif password.size <= 4
    errors[:password] = "password is too short"
  end

  errors.empty? ? nil : errors
end