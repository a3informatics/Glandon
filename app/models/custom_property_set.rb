# Custom Property Set. A utility class holding the set of custom propeeties for a model.
#
# @author Dave Iberson-Hurst
# @since 3.3.0
class CustomPropertySet
  
  # Initialize
  #
  # @return [CustomPropertySet] the new object
  def initialize
    @items = []
  end

  # <<
  #
  # @param [Object] item the object to be added
  # @return [Void] no return
  def <<(item)
    @items << item
  end

  # To H
  #
  # @return [Hash] the object as a hash
  def to_h
    @items.map {|x| x.to_h}
  end

end