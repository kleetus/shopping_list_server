require './web'


use Rack::Session::Cookie, :secret => ENV['rack_session_cookie'] 

use Warden::Manager do |manager|
  manager.default_strategies :password
  manager.failure_app = Web.new
  manager.serialize_into_session {|user| user.id}
  manager.serialize_from_session {|id| User.find_by_id(id) } 
end

run Web 
