class AddTypeToNotepad1 < ActiveRecord::Migration
  def change
    add_column :notepads, :uri_id, :string
    add_column :notepads, :uri_ns, :string
    remove_column :notepads, :uri
  end
end
