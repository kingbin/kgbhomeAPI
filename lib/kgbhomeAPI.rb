require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
require "sinatra/config_file"

module KGBHomeAPI
  class App < Sinatra::Base
    use Rack::MethodOverride
    register Sinatra::ConfigFile
    config_file '../config.yml'

#    set :port, settings.port

    configure do
      set :root, File.expand_path(File.join(File.dirname(__FILE__), '..'))
      set :app_file, __FILE__

      set :port, settings.port

#      enable :sessions
#      set :session_secret, "N0m d3 D13u d3 put41n d3 60rd31 d3 m3rd3 d3 s4l0pEri3 dE conN4rd d'EnculE d3 t4 m3r3"
#
#      set :auth do |bool|
#        condition do
#          # remenber the previous route
#          session[:route] = request.path_info
#          unless logged_in?
#            flash[:notice] = "You need to be logged in to access this page."
#            redirect '/login'
#          end
#        end
#      end
    end

    get '/' do
      "Hello world, it's #{Time.now} at the server!"
    end

    get '/temp' do
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

      @tempStatus = returnStatus

      erb :houseTemp
    end

    get '/tempJSON' do
      page = HTTParty.get("http://#{settings.thermostatIP}/tstat").body rescue nil
      "#{page}"
    end

  end
end
