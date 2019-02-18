# Fuseki Resource. Handles the methods to create properties in a class
#
# @author Dave Iberson-Hurst
# @since 2.21.0
module Fuseki
  
  module Utility

    include Fuseki::Naming
  
=begin
  
    module ClassMethods

      def from_hash(params)
        object = self.new
        params.each do |p|
          object.id = json[:id]
    object.name = json[:name]
    object.shortName = json[:shortName]
    object.namespace = json[:namespace]
    return object
      end

    end

    def to_hash
      result = {}
      instance_variables.each do |name|
        object = instance_variable_get(name)
        if objects.is_a?(Array)
          result[from_rails(name)] = []
          objects.each {|x| result[from_rails(name)]<< x.to_hash}
        else
          result[from_rails(name)] = object
        end
      end
    end
=end

  end

end