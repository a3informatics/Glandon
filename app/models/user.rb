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

  # User roles as an array of strings
  #
  # @return [array] Array of roles (strings)
  def role_list
    result = []
    Role.all.each do |role|
      result << Role.role_to_s(role.name) if self.role_ids.include?(role.id)
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

  # Is A Reader
  #
  # @return [Boolean] true if the user has reader access, false otherwise
  def is_a_reader?
    result = self.has_role?(Role::C_READER) || self.has_role?(Role::C_CURATOR) || self.has_role?(Role::C_CONTENT_ADMIN)
    return result
  end

  # Is A Curator
  #
  # @return [Boolean] true if the user has curator access, false otherwise
  def is_a_curator?
    result = self.has_role?(Role::C_CURATOR) || self.has_role?(Role::C_CONTENT_ADMIN)
    return result
  end

  # Is A Content Admin
  #
  # @return [Boolean] true if the user has content admin access, false otherwise
  def is_a_content_admin?
    result = self.has_role? Role::C_CONTENT_ADMIN
    return result
  end

  # Is A System Admin
  #
  # @return [Boolean] true if the user has system admin access, false otherwise
  def is_a_system_admin?
    result = self.has_role? Role::C_SYS_ADMIN
    return result
  end

end