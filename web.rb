require 'sinatra'
require 'sinatra/activerecord'
require './environments'
require 'json'
require 'warden'
require 'bcrypt'

class ShoppingList < ActiveRecord::Base
end

class User < ActiveRecord::Base
  include BCrypt
  
  def password
    @password ||= Password.new(password_hash)
  end
 
  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end
end

class Web < Sinatra::Application

  use Rack::Session::Cookie, :secret => "sjdkdjfksjlksjhlkfhdjlkghfsdjklbg,fsdmbgm, s,iorutputoperhtipwskjasfjasdljfdlksahflkeuyrejvsndjncdiso947230hcnw ey0wyrwe0"

  use Warden::Manager do |manager|
    manager.default_strategies :password
    manager.failure_app = self
    manager.serialize_into_session {|user| user.id}
    manager.serialize_from_session {|id| User.find_by_id(id) } 
  end
  
  Warden::Manager.before_failure do |env,opts|
    env['REQUEST_METHOD'] = 'POST'
  end
  
  Warden::Strategies.add(:password) do
    def valid?
      params['email'] || params['password']
    end
  
    def authenticate!
      user = User.find_by_user(params['email'])
      if user && user.authenticate(params['password'])
        success!(user)
      else
        fail!("Could not log in")
      end
    end
  end 
  
  post '/session' do
    warden_handler.authenticate!  
    if warden_handler.authenticated?
      redirect "/list.json"
    end
  end

  get '/logout' do
    warden_handler.logout
    200    
  end

  post '/unauthenticated' do
    403
  end

  post '/users/new' do
    content_type :json
    return 422 if not params['email'] or not params['password']
    @user = User.new(:user => params['email'])
    @user.password = params[:password]
    @user.save!
  end
  
  get '/list.json' do
    
    content_type :json
    ShoppingList.all.to_json
  end
  
  
  post '/list/item.json' do
    content_type :json
    return 422 if (not params['item'] or params['item'].length < 1)
    if params['quantity'] and (params['quantity'] =~ /[^\d+]/).nil?
      q = params['quantity'].to_i
    else
      q = 1
    end
    ShoppingList.create(:item => params['item'], :quantity => q)
    ShoppingList.all.to_json
  end
  
  post '/list/clear.json' do
    content_type :json
    ids = params['items'].gsub(/\[|\]/, "").split(',')
    ids.each do |i| 
      begin
        ShoppingList.destroy(i.to_i) 
      rescue ActiveRecord::RecordNotFound => e
      end
    end
    ShoppingList.all.to_json
  end
  
  def warden_handler
    env['warden']
  end
  
  def current_user
    warden_handler.user
  end
  
  def check_authentication
    return 422 unless warden_handler.authenticated?
  end
end
