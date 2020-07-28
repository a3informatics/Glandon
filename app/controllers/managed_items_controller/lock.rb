# Managed Items Controller Lock
#
# @author Clarisa Romero
# @since 3.2.0
class ManagedItemsController

  class Lock

    # Initialize the object
    #
    # @param operation [Symbol] the operation, either :get or :keep
    # @param object [Object] The managed item object
    # @param current_user [Object] The current user
    # @param flash [Object] The flash object
    # @return [object] The lock object
    def initialize(operation, object, current_user, flash)
      @item = object
      @user = current_user
      @error = ""
      @token = nil
      @flash = flash
      operation == :get ? token_get : token_keep 
    end

    # Token
    #
    # @return [Token] the token object
    def token
      @token
    end

    # Item
    #
    # @return [Object] the managed item 
    def item
      @item
    end

    # Error?
    #
    # @return [Boolean] true if error, otherwise false
    def error?
      !@error.blank?
    end

    # Error
    #
    # @return [String] any error message
    def error
      @error
    end

    # User
    #
    # @return [User] the user that locked
    def user
      @user
    end

    # Release And Lock. Release the lock and lock the new item
    #
    # @param object [Object] The managed item object
    #
    def release_and_get(new_item)
      @item = new_item
      @token.release
      token_get
    end

  private
    
    # Token Get. Get the token for a Managed Item.
    #
    # @return [Boolean] true if successful, false otherwise
    def token_get
      @token = Token.obtain(@item, @user)
      return true unless @token.nil?
      token_error
    rescue => e
      error_not_found(e)
    end

    # Token Keep. Keep the token, if exists, for a Managed Item.
    #
    # @return [Boolean] true if successful, false otherwise
    def token_keep
      @token = Token.find_token(@item, @user)
      return true unless @token.nil?
      token_error
    rescue => e
      error_not_found(e)
    end

    # Token Error
    #
    # @return [Boolean] always false
    def token_error
      token = Token.find_token_for_item(@item)
      token.nil? ? error_lock_timeout : error_already_locked(token)
      @flash[:error] = @error
      return false
    end

    # Already locked error message
    def error_already_locked(token)
      user = User.find(token.user_id).email
      @error = "The item is locked for editing by user: #{user}."
    end

    # Lock timeout error message
    def error_lock_timeout
      @error = "The edit lock has timed out."
    end

    # Not found error message
    def error_not_found(e)
      @error = "Something has gone wrong reading the lock status."
      @flash[:error] = @error
      ConsoleLogger.info(self.class.name, "error_not_found", "#{@error}\n#{e.message}\n\n#{e.backtrace.join("\n")}")
      false
    end

  end

end