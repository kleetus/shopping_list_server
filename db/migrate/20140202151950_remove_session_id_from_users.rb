class RemoveSessionIdFromUsers < ActiveRecord::Migration
  def up
  	remove_column :users, :session_id
  end

  def down
  end
end
