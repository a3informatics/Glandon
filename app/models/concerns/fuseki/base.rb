require "active_model"
require "fuseki/resource"
require "fuseki/persistence"

module Fuseki

  class Base
    
    include ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations
    include ActiveModel::AttributeMethods
    
    attr_reader :uri

    extend Resource
    include Persistence
    include Schema

    def initialize
      @@schema ||= read_schema
      @uri = nil
      klass_ancestors = self.class.ancestors.grep(Fuseki::Resource).reverse
      klass_ancestors.delete(Fuseki::Base) # Remove the base class
      klass_ancestors.each do |klass|
        properties = klass.instance_variable_get(:@properties)
        properties.each do |name, value|
          self.instance_variable_set("@#{name}", value)
        end
      end
    end

  end

end