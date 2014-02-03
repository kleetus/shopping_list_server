require './web'


use Rack::Session::Cookie, :secret => ENV['RACK_SESSION_COOKIE'] 

run Web 
