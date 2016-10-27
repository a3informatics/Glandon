class AuditTrail < ActiveRecord::Base

	enum event_type: {empty_action: 0, create_action: 1, update_action: 2, delete_action: 3}

	@@event_string_map = ["", "Create", "Update", "Delete"]

	def event_to_s
		return @@event_string_map[self.event]
	end

	def self.event_to_s(index)
		return @@event_string_map[index]
	end

	def self.add(user, item, event, description)
		self.create(date_time: Time.now, user: user.email, owner: item.owner, identifier: item.identifier, version: item.version, event: event, description: description)
	end

end
