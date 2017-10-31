class User < ActiveRecord::Base

  # Include the user settings
  include UserSettings
 
	# Constants
  C_CLASS_NAME = "User"

  # Rolify gem extension for roles
  rolify

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  after_create :set_extra
  after_save :user_update

  # Set any extra items we need when a user is created
  def set_extra
  	# Set the reader default role.
    self.add_role :reader
  end

  # Do any processing after user is changed
  def user_update
    # Audit if password changed  
    if encrypted_password_changed?
      AuditTrail.user_event(self, "User changed password.")
    end
  end

  # Is Only System Admin
  #
  # @return [Boolean] returns true if user only has sys admin role
  def is_only_sys_admin
  	return true if self.role_ids.count == 1 && self.has_role?(:sys_admin)
  	return false
  end

  # User roles as an array of strings
  #
  # @return [array] Array of roles (strings)
  def role_list
    result = []
    ids = self.role_ids
    roles Role.order('name ASC').all
    roles.each do |role|
      result << Role.to_display(role.name.to_sym) if ids.include?(role.id)
    end
    return result 
  end

  # User roles stripped
  #
  # @return [array] Array of roles (strings)
  def role_list_stripped
    result = "#{self.role_list}"
    return result.gsub(/[^A-Za-z, ]/, '') 
  end

end