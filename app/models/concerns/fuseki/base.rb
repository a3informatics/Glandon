require "active_model"
require "fuseki/resource"
require "fuseki/persistence"

module Fuseki

  class Base
    
    include ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations
    include ActiveModel::AttributeMethods
    
    attr_accessor :uri

    validates :uri, presence: true

    extend Resource
    include Persistence
    extend Schema
    extend Properties
    include Utility

    def initialize(attributes = {})
      @@schema ||= self.class.read_schema
      self.class.properties_inherit
      self.class.properties_predicate
      # Set the instance variables
      @uri = attributes.key?(:uri) ? attributes[:uri] : nil
      self.class.instance_variable_get(:@properties).each do |name, definition| 
        variable = Fuseki::Persistence::Naming.new(name)
        value = attributes.key?(variable.as_symbol) ? attributes[variable.as_symbol] : definition[:default]
        from_value(variable.as_instance, value)
      end
    end

  end

end