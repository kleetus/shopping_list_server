class ChangePasswordFieldNameAndAddSalt < ActiveRecord::Migration
  def up
    rename_column :users, :password, :password_hash
    change_table(:users) do |t|
      t.column :salt, :string
    end
  end

  def down
  end
end
