# Fuseki Resource. Handles the methods to create properties in a class
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

      def from_h(params)
        properties = properties_read(:class)
        object = self.new
        params.each do |name, value|
          variable = Fuseki::Persistence::Naming.new(name)
          if value.is_a?(Hash)
            result = properties[variable.as_instance][:model_class].constantize.from_h(value)
            object.instance_variable_set(variable.as_instance, result)
          elsif value.is_a?(Array)
            klass = properties[variable.as_instance][:model_class].constantize
            value.each do |x|
              object.instance_variable_set(variable.as_instance, klass.from_h(value))
            end
          elsif name == :uri
            object.instance_variable_set(:@uri, Uri.new(uri: value))
          else
            object.instance_variable_set(variable.as_instance, value)
          end
        end
        object
      end

    end

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