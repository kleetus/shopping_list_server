class AddUserIdToSessions < ActiveRecord::Migration
  def up
  	add_column :sessions, :user_id, :integer
  end

  def down
  end
end
