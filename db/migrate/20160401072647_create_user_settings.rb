class CreateUserSettings < ActiveRecord::Migration[4.2]
  def change
    create_table :user_settings do |t|
      t.string :name
      t.string :value
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
