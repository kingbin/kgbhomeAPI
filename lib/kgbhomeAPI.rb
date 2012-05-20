require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
require "sinatra/config_file"

require "rack/oauth2/sinatra"

module KGBHomeAPI
  class App < Sinatra::Base
    use Rack::MethodOverride
    register Sinatra::ConfigFile
    config_file '../config.yml'

#==========================================================#
#=================   OAuth 2 Setups   =====================#
     register Rack::OAuth2::Sinatra

     oauth.database = Mongo::Connection.new["kgbhomeAPI_db"]
     oauth.authenticator = lambda do |username, password|
       #user = User.find(username)
       #user if user && user.authenticated?(password)
       "Batman" if username == "cowbell" && password == "more"
     end

     before "/oauth/*" do
       halt oauth.deny! if oauth.scope.include?("time-travel") # Only Superman can do that
     end

     get "/oauth/authorize" do
       "client: #{oauth.client.display_name}\nscope: #{oauth.scope.join(", ")}\nauthorization: #{oauth.authorization}"
      if current_user
        render "oauth/authorize"
      else
        redirect "/oauth/login?authorization=#{oauth.authorization}"
       #"client: #{oauth.client.display_name}\nscope: #{oauth.scope.join(", ")}\nauthorization: #{oauth.authorization}"
      end
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

    get '/tempJSON' do
      if oauth.authenticated?
        page = HTTParty.get("http://#{settings.thermostatIP}/tstat").body rescue nil
        "#{page}"
      else
        "{Why do you want to know the status of my thermostat?}"
      end
    end

  end
#==========================================================#
#===================    END OF APIs    ====================#
end
