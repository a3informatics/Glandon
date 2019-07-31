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
    include Properties
    include Utility
    include Diff

    set_schema

    def initialize(attributes = {})
      @transaction = nil
      @new_record = true
      @destroyed = false
      self.class.properties_inherit
      @uri = attributes.key?(:uri) ? attributes[:uri] : nil
      self.class.instance_variable_get(:@properties).each do |name, definition| 
        variable = Fuseki::Persistence::Naming.new(name)
        value = attributes.key?(variable.as_symbol) ? attributes[variable.as_symbol] : definition[:default].dup
        from_value(variable.as_instance, value)
      end
    end

  end

end