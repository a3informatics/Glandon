class NameValues < ActiveRecord::Migration
  
  create_table :name_values do |t|
    t.string :name
    t.string :value
    
    t.timestamps null: false
  end

end
