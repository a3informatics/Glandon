class AuditTrail < ActiveRecord::Base

	enum event_type: {empty_action: 0, create_action: 1, update_action: 2, delete_action: 3, user_action: 4}

	@@event_string_map = ["", "Create", "Update", "Delete", "User"]

	# Event To String. Human readbale lable for the event
	#
	# @return [string] The label
	def event_to_s
		return @@event_string_map[self.event]
	end

	# Event To String. Human readbale lable for the event
	#
	# @param index [integer] Index of the event
	# @return [string] The label
	def self.event_to_s(index)
		@@event_string_map[index].nil? ? result = "" : result = @@event_string_map[index]
		return result
	end

	# Create Item Event. Log creation of an item
	#
	# @param user [object] The user object
	# @param item [object] The item object
	# @param decscirption [string] The description
	# @return null
	def self.create_item_event(user, item, description)
		add_item(user, item, event_types[:create_action], description)
	end

	# Update Item Event. Log update of an item
	#
	# @param user [object] The user object
	# @param item [object] The item object
	# @param decscirption [string] The description
	# @return null
	def self.update_item_event(user, item, description)
		add_item(user, item, event_types[:update_action], description)
	end

	# Delete Item Event. Log deletion of an item
	#
	# @param user [object] The user object
	# @param item [object] The item object
	# @param decscirption [string] The description
	# @return null
	def self.delete_item_event(user, item, description)
		add_item(user, item, event_types[:delete_action], description)
	end

	# Create Event. Log a creation event (generic)
	#
	# @param user [object] The user object
	# @param decscirption [string] The description
	# @return null
	def self.create_event(user, description)
		add_generic(user, event_types[:create_action], description)
	end

	# Create Event. Log a creation event (generic)
	#
	# @param user [object] The user object
	# @param decscirption [string] The description
	# @return null
	def self.update_event(user, description)
		add_generic(user, event_types[:update_action], description)
	end

	# Create Event. Log a creation event (generic)
	#
	# @param user [object] The user object
	# @param decscirption [string] The description
	# @return null
	def self.delete_event(user, description)
		add_generic(user, event_types[:delete_action], description)
	end

	# User Event. Log a user event
	#
	# @param user [object] The user object
	# @param decscirption [string] The description
	# @return null
	def self.user_event(user, description)
		add_generic(user, event_types[:user_action], description)
	end

	# To CSV
  #
  # @return [Object] the CSV serialization
  def self.to_csv
  	items = AuditTrail.order(:id)
    csv_data = CSV.generate do |csv|
      csv << ["Date Time", "User", "Owner", "Identifier", "Version", "Event", "Details"]
      items.each do |item|
        csv << [Timestamp.new(item.date_time).to_datetime, item.user, item.owner, item.identifier, item.version, item.event_to_s, item.description]
      end
    end
    return csv_data
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
    days = self.group("DATE(date_time)").count
    hash_week.each do |weekday, c|
      days.each do |date, count|
          hash_week[weekday] = count if weekday == date
      end
    end
    hash_week = hash_week.map{ |k, v| [k.strftime("%A"), v] }.to_h
    return hash_week
  end

  # Counts users logins by year and by week
  #
  # @return [hash] Hash with hashes. year as the key and the week year/week as the value. Example: {"2018"=>{"50"=>1}, "2019"=>{"40"=>1, "45"=>1}}
  def self.users_by_year_by_week
    result = {}
    logins = self.have_logged_in
    if !logins.nil? 
      raw_results = logins.group("date_trunc('year', date_time)").group("date_trunc('week',date_time)").count
      raw_results = raw_results.map{ |k, v| [ [k[0].strftime("%Y"), k[1].strftime("%W")] , v] }.to_h
      result = {}
      raw_results.each do |arr, value|
        if result[arr[0]].nil?
          result[arr[0]] = { arr[1]=> value} 
        else 
          result[arr[0]][arr[1]] = value
        end
      end
    end
    return result
  end

  # Counts users logins by year and by month 
  #
  # @return [hash] Hash with an array of year and  month number as the key and the number of users logged that year/week as the value. Example: {"2017"=>{"12"=>1}, "2018"=>{"10"=>1, "11"=>1, "12"=>1}, "2019"=>{"10"=>1, "11"=>1}}
  def self.users_by_year_by_month
    result = {}
    logins = self.have_logged_in
    if !logins.nil? 
      raw_results = logins.group("date_trunc('year', date_time)").group("date_trunc('month',date_time)").count
      raw_results = raw_results.map{ |k, v| [ [k[0].strftime("%Y"), k[1].strftime("%B")] , v] }.to_h
      result = {}
      raw_results.each do |arr, value|
        if result[arr[0]].nil?
          result[arr[0]] = { arr[1]=> value} 
        else 
          result[arr[0]][arr[1]] = value
        end
      end
    end
    return result
  end

  # Counts users logins by year
  #
  # @return [hash] Hash with the year as the key and the number of users logged that year as the value. Example: {"2019"=>4}
  def self.users_by_year
      logins = self.have_logged_in.group("date_trunc('year', date_time)").count
      return {} if logins.empty?
      logins.map{ |k, v| [k.strftime("%Y"), v] }.to_h
  end

  # Counts users logins by domain
  #
  # @return [hash] Hash with the domain as the key and the number of users created with that domain as the value. Example: {"total"=>7, "example.com"=>2, "sanofi.com"=>3, "merck.com"=>1, "s-cubed.com"=>1}
  def self.users_by_domain
    raw = self.have_logged_in.all.select('id', 'user').as_json
    raw = raw.map{ |k, v| k['user'] }.map{ |user| user.sub /^.*@/, '' }
    result = {}
    raw.each do |value|
      result[value].nil? ? result[value] = 1 : result[value] + 1
    end
    result["total"] = raw.count
    return result
  end

private

	def self.add_item(user, item, event, description)
    identifier = item.respond_to?(:scoped_identifier) ? item.scoped_identifier : item.identifier
		self.create(date_time: Time.now, user: user.email, owner: item.owner_short_name, identifier: identifier, version: item.semantic_version, event: event, description: description)
	end

	def self.add_generic(user, event, description)
		self.create(date_time: Time.now, user: user.email, owner: "", identifier: "", version: "", event: event, description: description)
	end

  # Filters all users that have a current_sign_in
  #
  # @return [hash] Hash wit
  def self.have_logged_in
    self.all.where(description: "User logged in.")
  end

end
