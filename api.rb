require 'sinatra'
require 'sinatra/reloader'
require 'json'

before do
   content_type :json
   headers 'Access-Control-Allow-Origin' => '*',
               'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST'],
               'Access-Control-Allow-Headers' => 'Content-Type'
end

set :protection, false

options '/authenticate.json' do
  200
end

post '/authenticate.json' do
  params.merge! JSON.parse(request.env["rack.input"].read)

  result = {authenticated: authenticated?(params[:username], params[:password])}
  errors = validate(params[:username], params[:password])

  result[:errors] = errors if errors
  result.to_json
end

private

def authenticated?(username, password)
  username == "admin" && password == "admin"
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