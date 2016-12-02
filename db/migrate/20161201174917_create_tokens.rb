class CreateTokens < ActiveRecord::Migration
  def change
    create_table :tokens do |t|
      t.timestamp :locked_at
      t.integer :refresh_count
      t.string :item_uri
      t.string :item_info
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
