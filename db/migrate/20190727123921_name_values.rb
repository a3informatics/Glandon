class NameValues < ActiveRecord::Migration[4.2]
  
  create_table :name_values do |t|
    t.string :name
    t.string :value
    
    t.timestamps null: false
  end

end
