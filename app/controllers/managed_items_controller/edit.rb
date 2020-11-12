# Managed Items Controller Edit
#
# @author Clarisa Romero
# @since 3.2.0
class ManagedItemsController

  class Edit

    # Initialize the object
    #
    # @param [Object] item the managed item object to edit
    # @param [Object] current_user the current user
    # @param [Object] flash the flash object
    # @return [ManagedItemsController::Edit] returns the new edit object
    def initialize(item, current_user, flash)
      @lock = nil
      edit_item(item, current_user, flash)
    end

    # Lock
    #
    # @return [ManagedItemsController::Lock] the lock object
    def lock
      @lock
    end

    # Item
    #
    # @return [Object] the managed item 
    def item
      @lock.item
    end

    # Token
    #
    # @return [Token] the token object
    def token
      @lock.token
    end

    # Error
    #
    # @return [String] any error message
    def error?
      !@lock.error.blank?
    end

  private

    # Edit Item. Edit a managed item
    #
    # @param [Object] item the managed item object to edit
    # @param [Object] current_user the current user
    # @param [Object] flash the flash object
    # @return [Boolean] returns true if success, false otherwise
    def edit_item(item, user, flash)
      @lock = ManagedItemsController::Lock.new(:get, item, user, flash)
      return false if @lock.error?
      new_item = item.create_next_version
      return true if new_item.uri == item.uri
      @lock.release_and_get(new_item)
      return false if @lock.error?
      true
    end

  end
end