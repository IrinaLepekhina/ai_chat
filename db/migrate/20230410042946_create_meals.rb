# Migration to create the meals table
class CreateMeals < ActiveRecord::Migration[7.0]
  def change
    create_table :meals do |t|
      t.string :title, null: false
      t.integer :price_type
      t.text :description
      t.decimal :price_init, precision: 10, scale: 3

      t.timestamps
    end

    # Add unique index to title column
    add_index :meals, :title, unique: true
  end
end
