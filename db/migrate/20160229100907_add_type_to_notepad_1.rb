class AddTypeToNotepad1 < ActiveRecord::Migration[4.2]
  def change
    add_column :notepads, :uri_id, :string
    add_column :notepads, :uri_ns, :string
    remove_column :notepads, :uri
  end
end
