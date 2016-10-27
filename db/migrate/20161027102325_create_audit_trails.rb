class CreateAuditTrails < ActiveRecord::Migration
  def change
    create_table :audit_trails do |t|
      t.datetime :date_time
      t.string :user
      t.string :owner
      t.string :identifier
      t.float :version
      t.integer :event
      t.string :description

      t.timestamps null: false
    end
  end
end
