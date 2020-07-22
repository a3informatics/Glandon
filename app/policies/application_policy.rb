class ApplicationPolicy
  
  attr_reader :user, :record

	# Initialize. This is required by pundit.
	#
	# @param [User] user the user
	# @param [Object] record the record being accessed
	# @return [void] no return
  def initialize(user, record)
    @user = user
    @record = record
    create_methods("#{ApplicationPolicy}") # Force the class name as the default policy class.
  end
  
  # Create Methods. Create the methods, full policy and alias versions.
  #
  # @return [void] no return	
  def create_methods(klass)
    create_policies(read_policy_definitions(klass))
    create_alias(read_alias_definitions(klass))
  end

  # Create Policies. Create the <action>? methods based on the configuration file
	#
	# @param [Hash] policy_list the policy settings
  # @return [void] no return
	def create_policies(policy_list)
		policy_list.each do |action, role_permission| 
			# <action>?. Determines if the <action> is permitted.
			#
			# @return [Boolean] returns True if permitted, false otherwise
			define_singleton_method :"#{action}?" do 
				Rails.configuration.roles[:roles].each do |key, value| 
	    		return true if role_permission[key].to_bool && @user.has_role?(key)
	    	end
	    	return false
	  	end
  	end
  end

  # Create Alias. Create the <action>? methods based on the configuration file
  #
  # @param [Hash] policy_list the policy settings
  # @return [void] no return
  def create_alias(policy_list)
    policy_list.each do |action, method| 
      # <action>?. Determines if the <action> is permitted. Uses existing method to determine access.
      #
      # @return [Boolean] returns True if permitted, false otherwise
      define_singleton_method :"#{action}?" do 
        self.class.send("#{method}?")
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

private

  # Read the policy definitions
  def read_policy_definitions(klass)
    config = Rails.configuration.policy[:policies][klass.to_sym]
    config.nil? ? {} : config
  end

  # Read the alias definitions
  def read_alias_definitions(klass)
    config = Rails.configuration.policy[:alias][klass.to_sym]
    config.nil? ? {} : config
  end

end
