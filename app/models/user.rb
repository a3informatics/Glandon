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

end