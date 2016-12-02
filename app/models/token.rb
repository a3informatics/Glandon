class Token < ActiveRecord::Base

	C_CLASS_NAME = "Token"

	@@token_timeout ||= APP_CONFIG['token_timeout']
	
	# Obtain a token for the item. Will timeout the lock if necessary.
	#
	# @param managed_item [Object] The managed item being locked
	# @param user [Object] the user locking the managed item
	# @return [Object] The token if locked, nil if not locked.
	def self.obtain(managed_item, user)
		token = nil
		tokens = self.where(item_uri: managed_item.uri.to_s)
		item_info = "[#{managed_item.owner}, #{managed_item.identifier}, #{managed_item.version}]"
		if tokens.length == 0
			token = create(locked_at: Time.now, refresh_count: 0, item_uri: managed_item.uri, item_info: item_info, user_id: user.id)
		elsif tokens.length == 1
			if timed_out?(tokens[0])
				tokens[0].destroy
				token = create(locked_at: Time.now, refresh_count: 0, item_uri: managed_item.uri, item_info: item_info, user_id: user.id)
			end
		end
		return token
	end

	# Release a token for an item
	#
	# @return null
	def release
		self.destroy
	end

	# Refresh the lock for an item
	#
	# @return [Integer] The refresh count
	def refresh
		self.locked_at = Time.now
		self.refresh_count += 1
		self.save
		return self.refresh_count
	end

	# Determine if item is locked by a user. Will timeout the lock if necessary.
	#
	# @param managed_item [Object] The managed item being locked
	# @param user [Object] the user locking the managed item
	# @return [Boolean] True if lockedby the user, false otherwise
	def self.locked_by_user?(managed_item, user)
		tokens = self.where(item_uri: managed_item.uri.to_s)
		if tokens.length == 1
			return false if timed_out?(tokens[0])
			return tokens[0].user_id == user.id
		end
		return false
	end

	# Expire all tokens that have passed the time limit
	#
	# @return null
	def self.expire
		tokens = self.all
		tokens.each do |token|
			token.destroy if timed_out?(token)
		end
	end

	# Update timeout
	#
	# @param timeout [Integer] Update timeout in seconds
	# @return Null
	def self.set_timeout(timeout)
		@@token_timeout = timeout
	end

	# Get timeout
	#
	# @return [Integer] The current timeout value
	def self.get_timeout
		return @@token_timeout
	end

private

	def self.timed_out?(token)
		#ConsoleLogger.debug(C_CLASS_NAME, "timed_out", "Token=#{token.to_json}")
		#ConsoleLogger.debug(C_CLASS_NAME, "timed_out", "Timeout set=#{@@token_timeout}, Time=#{Time.now}")
		return Time.now > token.locked_at + @@token_timeout
	end

end
