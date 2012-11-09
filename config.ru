require './lib/kgbhomeAPI'
require "logger"
require "rack/oauth2/server"
require "rack/oauth2/server/admin"

logger = Logger.new("log/sinatra.log")
use Rack::CommonLogger, logger


#$logger.level = Logger::DEBUG
#Rack::OAuth2::Server::Admin.configure do |config|
#  config.set :logger, $logger
#  config.set :logging, true
#  config.set :raise_errors, true
#  config.set :dump_errors, true
#  config.oauth.expires_in = 86400 # a day
#  config.oauth.logger = $logger
#end


#==========================================================#
#=================   OAuth 2 ADMIN    =====================#
#Rack::Builder.new do
#  map("/oauth/admin") { run Server::Admin }
#  map("/") { run KGBHomeAPI::App }
#end
#Rack::OAuth2::Server::Admin.set :client_id, "4fbd224c3899dc4e46000001"
#Rack::OAuth2::Server::Admin.set :client_secret, "0c0f9931b9c0ceb5a253c17c5b65ff1a25f8f692966dd42abf564a9ed3b20a49"
##Rack::OAuth2::Server::Admin.set :template_url, "http://localhost:3000/accounts/{id}"
##Rack::OAuth2::Server::Admin.set :authorize_path, "http://kgbhomeapi.chrisblazek.me/oauth/authorize"
#Rack::OAuth2::Server::Admin.set :scope, %w{read write}


run KGBHomeAPI::App

