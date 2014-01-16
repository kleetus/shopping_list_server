require 'sinatra'
require 'sinatra/activerecord'
require './environments'
require 'json'


class ShoppingList < ActiveRecord::Base
end

use Rack::Auth::Basic, "Restricted Area" do |username, password|
  username == 'admin' and password == 'admin'
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
  ids.each { |i| ShoppingList.destroy(i.to_i) } 
  ShoppingList.all.to_json
end

