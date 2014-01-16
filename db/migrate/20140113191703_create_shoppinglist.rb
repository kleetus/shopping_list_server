class CreateShoppinglist < ActiveRecord::Migration
  def up
    create_table :shopping_lists do |t|
      t.string :item
      t.integer :quantity
      t.timestamps
    end
  end

  def down
    drop_table :shopping_lists
  end
end
