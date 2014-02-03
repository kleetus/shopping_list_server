class CreateSessions < ActiveRecord::Migration
  def up
 	create_table :sessions do |t|
      t.string :session
      t.timestamps
    end
  end

  def down
  end
end
