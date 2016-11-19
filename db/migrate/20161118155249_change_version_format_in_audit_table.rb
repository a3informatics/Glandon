class ChangeVersionFormatInAuditTable < ActiveRecord::Migration
  def change
  	change_column :audit_trails, :version, :string
  end
end
