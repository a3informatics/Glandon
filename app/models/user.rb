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

  ############################
  # Overall Login Statistics #
  ############################

  # Counts users logged by current week, by day
  # 
  # @return [hash] Hash with the days as the key and the number of users logged that day as the value. Example: {"Friday"=>0, "Monday"=>3, "Saturday"=>0, "Sunday"=>0, "Thursday"=>0, "Tuesday"=>4, "Wednesday"=>2}
  def self.users_by_current_week
    week = (Date.today.at_beginning_of_week..Date.today.at_end_of_week).map
    hash_week = (week).each_with_object({}) { |date, hash| hash[date] = 0 }
    days = self.group("DATE(current_sign_in_at)").count
    hash_week.each do |weekday, c|
      days.each do |date, count|
        if weekday == date
          hash_week[weekday] = count
        end
      end
    end
    hash_week = hash_week.map{ |k, v| [k.strftime("%A"), v] }.to_h
    return hash_week
  end

  # Counts users logins by week and by day 
  #
  # @return [hash] Hash with an array of year and  month number as the key and the number of users logged that year/week as the value. Example: {["37", "Wednesday"]=>1, ["35", "Monday"]=>1, ["45", "Tuesday"]=>1, ["41", "Monday"]=>1}
  # def self.users_by_week_by_day
  #   result = User.group("date_trunc('week', current_sign_in_at)").group("date_trunc('day',current_sign_in_at)").count
  #   result = result.map{ |k, v| [ [k[0].strftime("%W"), k[1].strftime("%A")] , v] }.to_h
  #   return result
  # end

  # Counts users logins by year, by week, by day 
  #
  # @return [hash] Hash with an array of year and  month number as the key and the number of users logged that year/week as the value. Example: {["2018", "41", "Monday"]=>1, ["2019", "37", "Wednesday"]=>1, ["2019", "35", "Monday"]=>1, ["2019", "45", "Tuesday"]=>1}
  # def self.users_by_year_by_week_by_day
  #   result = User.group("date_trunc('year', current_sign_in_at)").group("date_trunc('week',current_sign_in_at)").group("date_trunc('day', current_sign_in_at)").count
  #   result = result.map{ |k, v| [ [k[0].strftime("%Y"), k[1].strftime("%W"), k[2].strftime("%A") ] , v] }.to_h
  #   return result
  # end

  # Counts users logins by year and by week
  #
  # @return [hash] Hash with hashes. year as the key and the week year/week as the value. Example: {"2018"=>{"50"=>1}, "2019"=>{"40"=>1, "45"=>1}}
  def self.users_by_year_by_week
    raw_results = User.group("date_trunc('year', current_sign_in_at)").group("date_trunc('week',current_sign_in_at)").count
    raw_results = raw_results.map{ |k, v| [ [k[0].strftime("%Y"), k[1].strftime("%W")] , v] }.to_h
    result = {}
    raw_results.each do |arr, value|
      if result[arr[0]].nil?
          result[arr[0]] = { arr[1]=> value} 
      else 
          result[arr[0]][arr[1]] = value
      end
    end
    return result
  end

  # Counts users logins by year and by month 
  #
  # @return [hash] Hash with an array of year and  month number as the key and the number of users logged that year/week as the value. Example: {"2017"=>{"12"=>1}, "2018"=>{"10"=>1, "11"=>1, "12"=>1}, "2019"=>{"10"=>1, "11"=>1}}
  def self.users_by_year_by_month
    raw_results = self.group("date_trunc('year', current_sign_in_at)").group("date_trunc('month',current_sign_in_at)").count
    raw_results = raw_results.map{ |k, v| [ [k[0].strftime("%Y"), k[1].strftime("%B")] , v] }.to_h
    result = {}
    raw_results.each do |arr, value|
      if result[arr[0]].nil?
          result[arr[0]] = { arr[1]=> value} 
      else 
          result[arr[0]][arr[1]] = value
      end
    end
    return result
  end

  # Counts users logins by month
  #
  # @return [hash] Hash with the dates as the key and the number of users logged that day as the value. Example: {"November"=>2, "September"=>2}
  # def self.users_by_month
  #   result = self.group("date_trunc('month', current_sign_in_at)").count
  #   result = result.map{ |k, v| [k.strftime("%B"), v] }.to_h
  #   return result
  # end

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
  # @return [hash] Hash with the domain as the key and the number of users created with that domain as the value. Example: {"total"=>7, "example.com"=>2, "sanofi.com"=>3, "merck.com"=>1, "s-cubed.com"=>1}
  def self.users_by_domain 
    raw = self.all.select('id, email').as_json
    raw = raw.map{ |k, v| k['email'] }
    raw = raw.map{ |email| email.sub /^.*@/, '' }
    result = {}
    raw.each do |value|
      if result[value].nil?
          result[value] = 1
      else 
          result[value] = result[value] + 1
      end
    end
    result["total"] = self.all.count
    return result
  end

end
