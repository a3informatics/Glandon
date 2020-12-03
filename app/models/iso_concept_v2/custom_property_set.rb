# Custom Property Set. A utility class holding the set of custom propeeties for a model.
#
# @author Dave Iberson-Hurst
# @since 3.3.0
class IsoConceptV2

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
    # @return [Array] array of name value pairs
    def name_value_pairs
      @items.map { |item| { name: item.custom_property_defined_by.label, value: item.to_typed } }
    end

    # Return Values. 
    #
    # @return [Boolean] returns true if different, false otherwise
    def return_values
      results = {}
      @items.each do |item| 
        results[item.custom_property_defined_by.label.to_variable_style.to_sym] = { id: item.uri.to_id, value: item.to_typed }
      end
      results
    end

    # Each. Iterate over the proprites
    #
    # @return [Enumerator] returns the enumerator for the collection
    def each
      @items.each do |property| 
        yield(property)
      end
    end

    # Clear. Clear the set
    #
    # @return [CustomPropertySet] the new empty object
    def clear
      @items = []
    end

    # -----------------
    # Test Only Methods
    # -----------------

    if Rails.env.test?

      def items
        @items
      end
      
    end

  end

end