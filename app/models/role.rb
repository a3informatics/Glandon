class Role < ActiveRecord::Base

  has_and_belongs_to_many :users, :join_table => :users_roles

  belongs_to :resource,
             :polymorphic => true

  validates :resource_type,
            :inclusion => { :in => Rolify.resource_types },
            :allow_nil => true

  C_CLASS_NAME = "Role"

  class << self

  	# Build enabled/disabled helper methods
  	Rails.configuration.roles[:roles].each do |k, v|

			# <role>_enabled?. Determines if the <role> is enabled.
  		#
  		# @return [Boolean] returns True if enabled, false otherwise
  		define_method :"#{k}_enabled?" do
      	return v[:enabled]
    	end

			# <role>_disbled?. Determines if the <role> is disabled.
  		#
  		# @return [Boolean] returns True if disabled, false otherwise
			define_method :"#{k}_disabled?" do
      	return !v[:enabled]
    	end

    end
  end

  # With System Admin
  #
  # @return [Boolean] return true if role can be combined with the system admin role.
  def self.with_sys_admin(role)
  	return Rails.configuration.roles[:roles][role][:with_sys_admin] if Rails.configuration.roles[:roles].has_key?(role)
  	return ""
  end

  # Description
  #
  # @return [String] returns the role description if role valid else blank.
  def self.description(role)
  	return Rails.configuration.roles[:roles][role][:description] if Rails.configuration.roles[:roles].has_key?(role)
  	return ""
  end

  # To Display. Return role as a human readable string
  #
  # @param [Symbol] role the role
  # @return [String] The role string if found, otherwise empty
  def self.to_display(role)
  	return Rails.configuration.roles[:roles][role][:display_text] if Rails.configuration.roles[:roles].has_key?(role)
  	return ""
  end

  # List. Get a list of roles
  #
  # @return [Hash] hash of ids for the role names
  def self.list
    results = {}
    Role.all.each do |x|
     results[x.name.to_sym] = { id: x.id, display_text: Rails.configuration.roles[:roles][x.name.to_sym][:display_text] }
    end
    return results
  end

  # Converts role name (symbol) to a role id (int)
  #
  # @return [Integer] role id
  def self.to_id(role_name)
    r = Role.where(name: "#{role_name}")
    Errors.application_error(self.name, __method__.to_s, "No role found. Searching for #{role_name}.") if r.empty?
    r.first.id
  end

	scopify

end
