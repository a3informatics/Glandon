class CdiscClPolicy < ApplicationPolicy

	C_CLASS_NAME = self.name
  
	# Initialize. Add in the extra methods
	#
	# @param [User] user the user
	# @param [Object] record the record being accessed
	# @return [void] no return
  def initialize(user, record)
    super
    create_methods(Rails.configuration.policy[C_CLASS_NAME])
  end

end