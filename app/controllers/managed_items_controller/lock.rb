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

    def token
      @token
    end

    def item
      @item
    end

    def error
      @error
    end

    def user
      @user
    end

    def release_and_get(item)
      @item = item
      @token.release
      @token = token_get
    end


  private
    
    # Token get. Get the token for a Managed Item.
    #
    # @return [Token] the token or nil if not found. Flash error set to standard error in not found.
    def token_get
      @token = Token.obtain(@item, @user)
      return unless @token.nil?
      token_error
      rescue ActiveRecord::RecordNotFound => e
      @flash[:error] = "The item is locked for editing by user: <unknown>."
      @error = "The item is locked for editing by user: <unknown>."
      return nil
    end

    # Token keep. Keep the token, if exists, for a Managed Item.
    #
    # @return [Token] the token or nil if not found. Flash error set to standard error in not found.
    def token_keep
      @token = Token.find_token(@item, @user)
      return unless @token.nil?
      token_error
      rescue ActiveRecord::RecordNotFound => e
      @flash[:error] = "The item is locked for editing by user: <unknown>."
      @error = "The item is locked for editing by user: <unknown>."
      return nil
    end

    def token_error
      token = Token.find_token_for_item(@item)
      user = token.nil? ? "<unknown>" : User.find(token.user_id).email
      @flash[:error] = "The item is locked for editing by user: #{user}."
      @error = "The item is locked for editing by user: #{user}."
      return nil
    end

  end
end