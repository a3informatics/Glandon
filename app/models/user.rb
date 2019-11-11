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
    :recoverable, :rememberable, :trackable, # :validatable
    :timeoutable,
    :password_expirable, :password_archivable , :secure_validatable

  after_create :set_extra, :expire_password!
  after_save :user_update

  validates :name, length: { minimum: 1 }, on: :update

  # Set any extra items we need when a user is created
  def set_extra
  	# Set the reader default role.
    self.add_role :reader
    # Set default name if not provided
    if self.name.blank?
      self.name = "Anonymous"
    end
    self.save
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

  # Is Only Community
  #
  # @return [Boolean] returns true if user only has community reader role
  def is_only_community?
    return true if self.role_ids.count == 1 && self.has_role?(:community_reader)
    return false
  end

  # User roles as an array of strings
  #
  # @return [array] Array of roles (strings)
  def role_list
    result = []
    ids = self.role_ids
    roles = Role.order('name ASC').all
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

  # Validates removal of sys admin role allowed before executing it
  #
  # @return [Boolean] returns true if removing last admin
  def removing_last_admin?(params)
    return false if !self.has_role?(:sys_admin)
    return false if User.all.select{ |u| u.role_list.include?("System Admin")}.size > 1
    return false if params[:role_ids].include?(Role.to_id(:sys_admin))
    return true
    #if params[:role_ids]
  end

  ######################
  # Overall Login Status
  ######################

  # Counts users logged by date
  #
  # @return [hash] Hash with the dates as the key and the number of users logged that day as the value.
  def self.users_by_date
    return result = self.group("DATE(current_sign_in_at)").count
  end

  # Counts users logged by day
  #
  # @return [hash] Hash with the dates as the key and the number of users logged that day as the value. Example: {"Wednesday"=>1, "Friday"=>1, "Monday"=>1}
  def self.users_by_day
    result = self.group("date_trunc('day', current_sign_in_at)").count
    result = result.map{ |k, v| [k.strftime("%A"), v] }.to_h
    return result
  end

  # Counts users logins by week
  #
  # @return [hash] Hash with the dates as the key and the number of users logged that day as the value. Example: {"45"=>1, "35"=>1, "44"=>1, "37"=>1}
  def self.users_by_week
    result = self.group("date_trunc('week', current_sign_in_at)").count
    result = result.map{ |k, v| [k.strftime("%W"), v] }.to_h
    return result
  end

  # Counts users logins by week by month
  #
  # @return [hash] Hash with the dates as the key and the number of users logged that day as the value. Example: {"45"=>1, "35"=>1, "44"=>1, "37"=>1}
  def self.users_by_month_by_year
    result = self.group("date_trunc('week', current_sign_in_at)").count
    result = result.map{ |k, v| [k.strftime("%W"), v] }.to_h
    return result
  end

    # Counts users logins by month
  #
  # @return [hash] Hash with the dates as the key and the number of users logged that day as the value. Example: {"November"=>2, "September"=>2}
  def self.users_by_month
    result = self.group("date_trunc('month', current_sign_in_at)").count
    result = result.map{ |k, v| [k.strftime("%B"), v] }.to_h
    return result
  end

  # Counts users logins by year
  #
  # @return [hash] Hash with the year as the key and the number of users logged that year as the value. Example: {"2019"=>4}
  def self.users_by_year
    result = self.group("date_trunc('year', current_sign_in_at)").count
    result = result.map{ |k, v| [k.strftime("%Y"), v] }.to_h
    return result
  end

  # Counts users logins by domain
  #
  # @return [hash] Hash with the domain as the key and the number of users logged with that domain as the value. Example: {"ci.ruby-lang.org"=>4}
  def self.users_by_domain
  byebug
    result = self.group("current_sign_in_ip").count
    result = result.map{ |k, v| [result[k] = (Resolv.getname k), v] }.to_h
    result["total"] = self.all.count
    return result
  end

end
