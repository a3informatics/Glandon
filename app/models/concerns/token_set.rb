# Token Set. A set of tokens
#
# @author Dave Iberson-Hurst
# @since 3.8.0
class TokenSet

  # Initialize
  #
  # @return [CustomPropertySet] the new object
  def initialize(items, user)
    @items = []
    @user = user
    items.each { |item| @items << { item: item, lock: Token.obtain(item, user) } }
  end

  # <<
  #
  # @param [Object] item the object to be added
  # @return [Void] no return
  def <<(item)
    @items << { item: item, lock: Token.obtain(item, @user) }
  end

  # Locked? All items locked?
  #
  #
  # @return [Boolean] true if all items locked
  def locked?
    !@items.any?{ |item| item[:lock].nil? }
  end

  # Each. Iterate over the items
  #
  # @return [Enumerator] returns the enumerator for the collection
  def each
    @items.each do |property| 
      yield(property)
    end
  end

  # Release the locks
  #
  # @return [Boolean] always true
  def release
    @items.each { |item| item[:lock].release }
    @items = []
    true
  end

  # Items
  #
  # @return [Array] the set of items as an array
  def items
    @items
  end

  # Ids. 
  #
  # @return [Array] the ids for the items
  def ids
    @items.map { |x| x[:item].id}
  end

end