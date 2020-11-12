class ChangeVersionFormatInAuditTable < ActiveRecord::Migration[4.2]
  def change
  	change_column :audit_trails, :version, :string
  end
end
