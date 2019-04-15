# Fuseki Utility. Utility functions for classes
#
# @author Dave Iberson-Hurst
# @since 2.21.0
module Fuseki
  
  module Utility

    include Fuseki::Properties

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      include Fuseki::Properties
      include Fuseki::Persistence::Property

      # From Hash. Create the class from a hash. Will recurse creating child objects
      #
      # @param [Hash] params the hash
      # @return [Object] the object created
      def from_h(params)
        object = self.new
        params.each do |name, value|
          inst_var = Fuseki::Persistence::Naming.new(name).as_instance
          if name == :uri
            object.from_uri(inst_var, value)
          elsif value.is_a?(Hash)
            object.from_hash(inst_var, value)
          elsif value.is_a?(Array)
            value.each do |x| 
              x.is_a?(Hash) ? object.from_hash(inst_var, value) : object.from_uri(inst_var, value)
            end
          else
            object.from_value(inst_var, value)
          end
        end
        object
      end

    end

    # To Hash. Output the class as a hash
    #
    # @return [Hash] the hash
    def to_h
      result = {uri: instance_variable_get(:@uri).to_h, rdf_type: self.rdf_type.to_h}
      properties = properties_read(:instance)
      properties.each do |name, property|
        variable = Fuseki::Persistence::Naming.new(name).as_symbol
        object = instance_variable_get(name)
        if object.is_a?(Array)
          result[variable] = []
          object.each {|x| result[variable] << x.to_h}
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