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

    extend Schema
    extend Resource
    include Persistence
    include Utility
    include Diff

    set_schema
  
    def initialize(attributes = {})
      @properties = Fuseki::Resource::Properties.new(self, self.class.resources)
      @transaction = nil
      @new_record = true
      @destroyed = false
      @uri = attributes.key?(:uri) ? attributes[:uri] : nil
      @properties.each do |property| 
        value = attributes.key?(property.name) ? attributes[property.name] : property.default_value
        property.set_value(value)
      end
    end

    def properties
      @properties
    end

  end

end