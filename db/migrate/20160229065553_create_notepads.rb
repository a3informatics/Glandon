class CreateNotepads < ActiveRecord::Migration
  def change
    create_table :notepads do |t|
      t.string :uri
      t.string :identifier
      t.string :useful_1
      t.string :useful_2
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
