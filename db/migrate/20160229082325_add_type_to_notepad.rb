class AddTypeToNotepad < ActiveRecord::Migration
  def change
    add_column :notepads, :note_type, :integer
  end
end
