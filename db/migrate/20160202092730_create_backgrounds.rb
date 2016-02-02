class CreateBackgrounds < ActiveRecord::Migration
  def change
    create_table :backgrounds do |t|
      t.string :description
      t.boolean :complete, default: false
      t.integer :percentage, default: 0

      t.timestamps null: false
    end
  end
end
