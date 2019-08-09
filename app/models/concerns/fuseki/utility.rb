# Fuseki Utility. Utility functions for classes
#
# @author Dave Iberson-Hurst
# @since 2.21.0
module Fuseki
  
  module Utility

    include Fuseki::Resource

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      include Fuseki::Resource

      # From Hash. Create the class from a hash. Will recurse creating child objects
      #
      # @param [Hash] params the hash
      # @return [Object] the object created
      def from_h(params)
        object = self.new
        properties = object.properties
        params.each do |name, value|
          if name == :uri
            object.uri = Uri.from_uri_or_string(value) # Special case, URI is not considered a property
          else
            next if properties.ignore?(name)
            property = properties.property(name)
            if value.is_a?(Hash)
              property.set_from_hash(value)
            elsif value.is_a?(Array)
              value.each do |x| 
                x.is_a?(Hash) ? property.set_from_hash(x) : property.set_uri(x)
              end
            else
              property.set_value(value)
            end
          end
        end
        object
      end

    end

    # To Hash. Output the class as a hash
    #
    # @return [Hash] the hash
    def to_h
      result = {id: self.id, uri: self.uri.to_h, rdf_type: self.rdf_type.to_h} # Core items and handled differently.
      @properties.each do |property| 
        object = property.get
        variable = property.name
        if object.is_a?(Array)
          result[variable] = []
          object.each {|x| result[variable] << x.to_h}
        elsif object.nil?
          result[variable] = nil
        elsif object.respond_to? :to_h 
          result[variable] = object.to_h
        else
          result[variable] = from_typed(object)
        end
      end
      result
    end
    
  private

    # Set a simple typed value
    def from_typed(value)
      if value.is_a?(Time)
        "#{value.iso8601}"
      else
        value
      end
    end

  end

end