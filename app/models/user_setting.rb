class UserSetting < ActiveRecord::Base

	belongs_to :user

	validates_uniqueness_of :name, :scope => :user_id
	
	# TODO: This needs to be commented out, not sure why, may be investigate
	#attr_accessor  :name, :value
	
end
