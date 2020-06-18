class AddToBackground < ActiveRecord::Migration[4.2]
  def change
  	add_column :backgrounds, :status, :string
	add_column :backgrounds, :started, :datetime
	add_column :backgrounds, :completed, :datetime
  end
end
