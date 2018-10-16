class CreateImports < ActiveRecord::Migration
  def change
    create_table :imports do |t|
      t.string :type
      t.string :input_file
      t.string :output_file
      t.string :error_file
      t.string :success_path
      t.string :error_path
      t.boolean :success, default: false
      t.integer :background_id
      t.integer :token_id
      t.boolean :auto_load, default: false
      t.string :identifier
      t.string :owner
      t.integer :file_type, default: 0
      t.timestamps null: false
    end
  end
end
