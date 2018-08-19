
class Token < ActiveRecord::Base

	C_CLASS_NAME = "Token"

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
			if tokens[0].user_id == user.id
				tokens[0].destroy
				token = create(locked_at: Time.now, refresh_count: 0, item_uri: managed_item.uri, item_info: item_info, user_id: user.id)				
			elsif tokens[0].timed_out?
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

	# Extend the lock for an item. Does not update the refresh count.
	#
	# @return [Null] no return
	def extend_token
		self.locked_at = Time.now
		self.save
	end

	# Determine if item is locked by a user. Will timeout the lock if necessary.
	#
	# @param managed_item [Object] The managed item being locked
	# @param user [Object] the user locking the managed item
	# @return [Object] The token if found, nil otherwise
	def self.find_token(managed_item, user)
		tokens = self.where(item_uri: managed_item.uri.to_s)
		if tokens.length == 1
			return nil if tokens[0].timed_out?
			return tokens[0] if tokens[0].user_id == user.id
		end
		return nil
	end

	# Expire all tokens that have passed the time limit
	#
	# @return null
	def self.expire
		tokens = self.all
		tokens.each do |token|
			token.destroy if token.timed_out?
		end
	end

	# Get timeout
	#
	# @return [Integer] The current timeout value
	def self.get_timeout
		initialize_timeout
		return @@token_timeout
	end

	# Timed out?
	#
	# @return [Boolean] true if timed out, false otherwise
	def timed_out?
		self.class.initialize_timeout
		return Time.now > self.locked_at + @@token_timeout
	end

	# Remaining
	#
	# @return [Integer] the timeout value in seconds remaining or zero if timed out
	def remaining 
		value = self.class.get_timeout - (Time.now - self.locked_at).to_i
		result = value > 0 ? value : 0
		return result
	end

  if Rails.env.test?
  
    # Update timeout. Only to be used for testing
    #
    # @param timeout [Integer] Update timeout in seconds
    # @return [Void] No return value
    def self.set_timeout(timeout)
      initialize_timeout
      @@token_timeout = timeout
    end

    # Restore timeout. Only to be used for testing
    #
    # @return [Void] No return value
    def self.restore_timeout
      @@token_timeout = ENV['token_timeout'].to_i
    rescue => e
      @@token_timeout ||= 600   
    end

  end

private

	def self.initialize_timeout
		@@token_timeout ||= ENV['token_timeout'].to_i
	rescue => e
		@@token_timeout ||= 600		
	end

end
