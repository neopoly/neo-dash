require 'dashing'

AUTH_TOKEN = ENV['AUTH_TOKEN']

abort "Need AUTH_TOKEN env" unless AUTH_TOKEN

configure do
  set :auth_token, AUTH_TOKEN

  helpers do
    def protected!
     # Put any authentication code you want in here.
     # This method is run before accessing any resource.
    end
  end
end

map Sinatra::Application.assets_prefix do
  run Sinatra::Application.sprockets
end

run Sinatra::Application
