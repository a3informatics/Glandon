# User. User class
#
# @author Dave Iberson-Hurst
# @since 0.0.1
class User < ApplicationRecord

  # Include the user settings
  include UserSettings
  include RoleManagement

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, # :validatable
    :timeoutable,
    :password_expirable, :password_archivable , :secure_validatable

  after_create :on_create, :expire_password!
  after_save :on_update
  before_destroy :on_destroy

  validates :name, length: { minimum: 1 }, on: :update

  # This method is called by Devise to check for "active" state of the User
  def active_for_authentication?
    super && self.is_active?
  end

  # If the method 'active_for_authentication?' returns false, 
  # method 'inactive_message' is invoked, user will receive notification for being inactive.
  def inactive_message
    is_active? ? super : :locked
  end

  # Lock. Locks user updating is_active column to false
  #
  # @return [Void] no return
  def lock
    update_attributes(is_active: false) if is_active?
  end

  # Unlock. Unlocks user updating is_active column to false
  #
  # @return [Void] no return
  def unlock
    update_attributes(is_active: true) unless is_active?
  end

  # On Create. Set any extra items we need when a user is created
  #
  # @return [Void] no return
  def on_create
  	# Set the reader default role.
    self.is_active = true
    self.add_role(:reader)
    self.name = "Anonymous" if self.name.blank? # Set default name if not provided
    self.save
    save_roles_and_scopes
  end

  # On Destroy. Actions when record is destroyed
  #
  # @return [Void] no return
  def on_destroy
    # Delete the User::Access associate node
    ua = self.my_access
    ua.delete
  end

  # User Update. Do any processing after user is changed
  #
  # @return [Void] no return
  def on_update
    # Audit if password changed
    AuditTrail.user_event(self, "User changed password.") if saved_change_to_encrypted_password?
  end

  # Is Only System Admin
  #
  # @return [Boolean] returns true if user only has sys admin role
  def is_only_sys_admin
  	return true if self.single_role? && self.has_role?(:sys_admin)
  	return false
  end

  # Is Only Community
  #
  # @return [Boolean] returns true if user only has community reader role
  def is_only_community?
    return true if self.single_role? && self.has_role?(:community_reader)
    return false
  end

  # User logged in
  #
  # @return [Boolean] returns true if user have logged in 
  def logged_in?
    return true if self.current_sign_in_at != nil
    return false
  end

  # Counts users logins by domain
  #
  # @return [hash] Hash with the domain as the key and the number of users created with that domain as the value. Example: {"total"=>7, "example.com"=>2, "sanofi.com"=>3, "merck.com"=>1, "s-cubed.com"=>1}
  def self.users_by_domain
    raw = self.all.select('id', 'email').as_json
    raw = raw.map{ |k, v| k['email'] }.map{ |user| user.sub /^.*@/, '' }
    result = {}
    result = raw.group_by{|e| e}.map{|k, v| [k, v.length]}.to_h
    result["total"] = self.all.count
    return result
  end

  # Removing Last Admin? Validates removal of sys admin role allowed before executing it
  #
  # @return [Boolean] returns true if removing last admin
  def removing_last_admin?(params)
    return false unless params[:role_ids].include?(Role.where_only(name: "sys_admin").id)
    return false unless self.has_role?(:sys_admin)
    return false if User.all.select{ |u| u.role_list.include?("System Admin")}.size > 1
    return true
  end

end
