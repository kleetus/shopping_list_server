require 'sinatra'
require 'sinatra/activerecord'
require './environments'
require 'json'
require 'bcrypt'
require 'sinatra/cookies'

class ShoppingList < ActiveRecord::Base
end

class Session < ActiveRecord::Base
  include BCrypt
  SALT_COMPLEXITY = 100 #makes session and user creation faster with lower numbers

  before_create :salted_session, :clean_sessions

  def self.salt
    Engine.generate_salt(Engine.calibrate(SALT_COMPLEXITY))
  end

  def salted_session
    @session = Password.create(Time.now.to_s+Session.salt)
    self.session = @session
  end

  def clean_sessions
    Session.find_all_by_user_id(self.user_id).each {|s| s.destroy }
  end

end

class User < ActiveRecord::Base
  include BCrypt

  has_one :session

  def to_s
    self.user
  end

  def password
    @password ||= Password.new(password_hash)
  end
 
  def password=(new_password)
    salt = Session.salt
    @password = Password.create(new_password+salt)
    self.password_hash = @password
    self.salt = salt
  end

  def authenticate(submitted_password)
    self.password == submitted_password+self.salt
  end

end

class Web < Sinatra::Application

  post '/session' do
    return 422 if not params['email'] or not params['password']
    user = User.find_by_user(params['email'])
    return 422 if not user or not user.authenticate(params['password'])
    set_session(user.create_session)
  end

  get '/logout' do
    check_session
    @session.destroy
    200
  end

  get '/login' do
    200
  end

  post '/users/new' do
    content_type :json
    return 422 if not params['email'] or not params['password']
    user = User.new(:user => params['email'])
    user.password = params[:password]
    user.save!
  end
  
  get '/list.json' do
    check_session
    content_type :json
    ShoppingList.all.to_json
  end
  
  post '/list/item.json' do
    check_session
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
    check_session
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

  private  
  def check_session
    @session ||= Session.find_by_session(cookies['rack.session']) if cookies['rack.session']
    redirect '/login' unless @session
  end

  def set_session(sess)
    cookies['rack.session'] = sess.session.to_s
    200
  end

end
