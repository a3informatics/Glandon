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
    rescue ActiveRecord::RecordNotFound => e
      @flash[:error] = "The item is locked for editing by user: <unknown>."
      @error = "The item is locked for editing by user: <unknown>."
      return false
    end

    # Token Keep. Keep the token, if exists, for a Managed Item.
    #
    # @return [Boolean] true if successful, false otherwise
    def token_keep
      @token = Token.find_token(@item, @user)
      return true unless @token.nil?
      token_error
    rescue ActiveRecord::RecordNotFound => e
      @flash[:error] = "The item is locked for editing by user: <unknown>."
      @error = "The item is locked for editing by user: <unknown>."
      return false
    end

    # Token Error
    #
    # @return [Boolean] always false
    def token_error
      token = Token.find_token_for_item(@item)
      user = token.nil? ? "<unknown>" : User.find(token.user_id).email
      @flash[:error] = "The item is locked for editing by user: #{user}."
      @error = "The item is locked for editing by user: #{user}."
      return false
    end

  end

end