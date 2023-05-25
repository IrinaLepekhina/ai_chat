# Migration to create the products table
class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.string :title, null: false
      t.integer :price_type
      t.text :description
      t.decimal :price_init, precision: 10, scale: 3

      t.timestamps
    end

    # Add unique index to title column
    add_index :products, :title, unique: true
  end
end
