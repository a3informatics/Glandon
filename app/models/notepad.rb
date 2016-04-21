class Notepad < ActiveRecord::Base

	enum note_type: [:term, :bc, :form, :domain]
	
  	belongs_to :user

end
