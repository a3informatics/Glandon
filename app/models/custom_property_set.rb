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

  # Diff? Two sets different
  #
  # @return [Boolean] returns true if different, false otherwise
  def diff?(other)
    self.name_value_pairs != other.name_value_pairs
  end

  # Name Value Pairs. Returns the property set as an array of hashes containing the name value pairs
  #
  # @return [Boolean] returns true if different, false otherwise
  def name_value_pairs
    @items.map{|x| {name: x.custom_property_defined_by.label, value: x.value}}
  end

  # Each. Iterate over the items
  #
  # @return [Enumerator] returns the enumerator for the collection
  def each
    @items.each do |item| 
      yield(item)
    end
  end

end