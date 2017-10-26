class ApplicationPolicy
  
  C_CLASS_NAME = self.name
  
  attr_reader :user, :record

  # Required by pundit
  def initialize(user, record)
    @user = user
    @record = record
    create_methods(Rails.configuration.policy[C_CLASS_NAME])
  end
  
	def create_methods(list)
		list.each do |action, role_permission| 
			# <action>?. Determines if the <action> is permitted.
			#
			# @return [Boolean] returns True if permitted, false otherwise
			define_singleton_method :"#{action}?" do 
				Rails.configuration.roles["roles"].each do |key, value| 
	    		return true if role_permission["#{key}"].to_bool && @user.has_role?(key.to_sym)
	    	end
	    	return false
	  	end
  	end
  end

  # Require by pundit
  def scope
    Pundit.policy_scope!(user, record.class)
  end

  # Required by pundit
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end
  end

end
