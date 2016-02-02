class AddToBackground < ActiveRecord::Migration
  def change
  	add_column :backgrounds, :status, :string
	add_column :backgrounds, :started, :datetime
	add_column :backgrounds, :completed, :datetime
  end
end
