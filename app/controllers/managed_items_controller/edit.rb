class ManagedItemsController

  class Edit

    # Initialize the object
    #
    # @param object [Object] The managed item object to edit
    # @param current_user [Object] The current user
    # @param flash [Object] The flash object
    # @return [object] The lock object
    def initialize(object, current_user, flash)
      @item = object
      @user = current_user
      @error = ""
      @lock = nil
      @flash = flash
      edit_item 
    end

    def lock
      @lock
    end

    def item
      @item
    end

  private

    # Edit Item. Edit a managed item
    #
    # @return [Object] the new item. It may be the same item. Will be nil if cannot be locked. Token set in controller
    def edit_item
      @lock = ManagedItemsController::Lock.new(:get, @item, @user, @flash)
      return nil if @lock.token.nil?
      new_item = @item.create_next_version
      return @item if new_item.uri == @item.uri
      @lock.release_and_get(new_item)
      return nil if @lock.token.nil?
      return @item = new_item
    end

  end
end