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
  	items = AuditTrail.all
    csv_data = CSV.generate do |csv|
      csv << ["Date Time", "User", "Owner", "Identifier", "Version", "Event", "Details"]
      items.each do |item|
        csv << [Timestamp.new(item.date_time).to_datetime, item.user, item.owner, item.identifier, item.version, item.event_to_s, item.description]
      end
    end
    return csv_data
  end

private

	def self.add_item(user, item, event, description)
		self.create(date_time: Time.now, user: user.email, owner: item.owner, identifier: item.identifier, version: item.semantic_version, event: event, description: description)
	end

	def self.add_generic(user, event, description)
		self.create(date_time: Time.now, user: user.email, owner: "", identifier: "", version: "", event: event, description: description)
	end

end
