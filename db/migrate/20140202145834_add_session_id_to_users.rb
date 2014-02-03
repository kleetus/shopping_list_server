class AddSessionIdToUsers < ActiveRecord::Migration
  def up
  	remove_column :sessions, :user_id
  	add_column :users, :session_id, :integer
  end

  def down
  end
end
