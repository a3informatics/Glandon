class AddTypeToNotepad < ActiveRecord::Migration[4.2]
  def change
    add_column :notepads, :note_type, :integer
  end
end
