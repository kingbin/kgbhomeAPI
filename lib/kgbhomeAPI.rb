require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
require "sinatra/config_file"

require "rack/oauth2/sinatra"
require "rack/oauth2/server/admin"

require 'json'

module KGBHomeAPI
  class App < Sinatra::Base
    use Rack::MethodOverride
#    use Rack::Logger
#    set :sessions, true
    #set :show_exceptions, false

#    set :authorize, "http://kgbhomeapi.chrisblazek.me/oauth/authorize"

    register Sinatra::ConfigFile
    config_file '../config.yml'

#==========================================================#
#=================   OAuth 2 ADMIN    =====================#
#Rack::Builder.new do
#  map("/oauth/admin") { run Rack::OAuth2::Server::Admin }
#  map("/") { run Authorize.new }
#end
#Rack::OAuth2::Server::Admin.set :client_id, "4fbd224c3899dc4e46000001"
#Rack::OAuth2::Server::Admin.set :client_secret, "0c0f9931b9c0ceb5a253c17c5b65ff1a25f8f692966dd42abf564a9ed3b20a49"
##Rack::OAuth2::Server::Admin.set :template_url, "http://localhost:3000/accounts/{id}"
##Rack::OAuth2::Server::Admin.set :authorize_path, "http://kgbhomeapi.chrisblazek.me/oauth/authorize"
##Rack::OAuth2::Server::Admin.set :scope, %w{read write}


#==========================================================#
#=================   OAuth 2 Setups   =====================#
     register Rack::OAuth2::Sinatra


     oauth.database = Mongo::Connection.new["kgbhomeAPI_db"]
     oauth.authenticator = lambda do |username, password|
       #user = User.find(username)
       #user if user && user.authenticated?(password)
       "Batman" if username == "cowbell" && password == "more"
     end

#     before "/oauth/*" do
#       halt oauth.deny! if oauth.scope.include?("time-travel") # Only Superman can do that
#     end

     get "/oauth/authorize" do
        content_type "text/html"
        <<-HTML
        <h1>#{oauth.client.display_name} wants to access your account.</h1>
        <form action="/oauth/grant" method="post"><button>Let It!</button>
        <input type="hidden" name="auth" value="#{oauth.authorization}">
        </form>
    HTML
#      "client: #{oauth.client.display_name}\nscope: #{oauth.scope.join(", ")}\nauthorization: #{oauth.authorization}"
#      if current_user
#        #render "oauth/authorize"
#        "client: #{oauth.client.display_name}\nscope: #{oauth.scope.join(", ")}\nauthorization: #{oauth.authorization}"
#      else
#        "client: #{oauth.client.display_name}\nscope: #{oauth.scope.join(", ")}\nauthorization: #{oauth.authorization}"
#        #redirect "/oauth/login?authorization=#{oauth.authorization}"
#       #"client: #{oauth.client.display_name}\nscope: #{oauth.scope.join(", ")}\nauthorization: #{oauth.authorization}"
#      end
    end

    post "/oauth/authorize" do
      "client: #{oauth.client.display_name}\nscope: #{oauth.scope.join(", ")}\nauthorization: #{oauth.authorization}"
    end

    post "/oauth/grant" do
      oauth.grant! "Batman"
    end

    post "/oauth/deny" do
      oauth.deny!
    end

    before do
      @current_user = oauth.identity if oauth.authenticated?
      ## Only admins allowed to authorize the scope oauth-admin
      #head oauth.deny! if oauth.scope.include?("oauth-admin") && !current_user.admin?
    end

    get "/user" do
      @current_user
    end

    get "/list_tokens" do
      oauth.list_access_tokens("Batman").map(&:token).join(" ")
    end

    oauth_required "/user"
    oauth_required "/list_tokens"
#    oauth_required "/temp"
#    oauth_required "/tempJSON"


#==========================================================#
#=================   OAuth 2 Setups   =====================#

    configure do
      set :root, File.expand_path(File.join(File.dirname(__FILE__), '..'))
      set :app_file, __FILE__
    end

    get '/' do
      "Hello world, it's #{Time.now} at the server! \n Identity: #{oauth.identity if oauth.authenticated?}"
    end

#==========================================================#
#=================  Filtrete Thermostat ===================#
    get '/temp' do
      returnStatus = Array.new
      if oauth.authenticated?
        page = HTTParty.get("http://#{settings.thermostatIP}/tstat").body rescue nil
        status = JSON.parse(page) rescue nil
        returnStatus = Array.new

        if status
          returnStatus[returnStatus.length] = "The temperature is currently #{status["temp"]} degrees."

          if status["tmode"] == 0
            returnStatus[returnStatus.length] = "The heater and air conditioner are turned off."
          else
            device_type = (status["tmode"] == 1 ? "heater" : "air conditioner")
            target_temp = (status["tmode"] == 1 ? status["t_heat"] : status["t_cool"])

            returnStatus[returnStatus.length] =  "The #{device_type} is set to engage at #{target_temp} degrees."

            if status["tstate"] == 0
              returnStatus[returnStatus.length] =  "The #{device_type} is off."
            elsif (status["tmode"] == 1 and status["tstate"] == 1) or (status["tmode"] == 2 and status["tstate"] == 2)
              returnStatus[returnStatus.length] =  "The #{device_type} is running."
            end
          end
        else
          returnStatus[returnStatus.length] =  "Sorry, the thermostat is off."
        end

      else
        returnStatus[returnStatus.length] =  "Why do you want to know the status of my thermostat?"
      end

      @tempStatus = returnStatus
      erb :houseTemp
    end

    get '/temp.json' do
      #content_type :json
      if oauth.authenticated?
        page = HTTParty.get("http://#{settings.thermostatIP}/tstat").body rescue nil
        #page["status"]  = "success" # :comment => you are connected] +  page
        #"#{page.to_json(:status => "success")}"
        
        {:status=>"success",:comment=>"User #{oauth.identity} Authenticated", :data=>"#{page}"}.to_json
        #"#{page}"
      else
        content_type :json
        #{ :key1 => 'value1', :key2 => 'value2' }.to_json
        {:status=>"error",:comment=>"Authenticate first bitches"}.to_json
      end
    end

  end
#==========================================================#
#===================    END OF APIs    ====================#
end
