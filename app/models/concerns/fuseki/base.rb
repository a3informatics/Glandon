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

    extend Resource
    include Persistence
    extend Schema
    extend Properties

    def initialize
      @uri = nil
      @@schema ||= self.class.read_schema
      self.class.properties_inherit
      self.class.properties_predicate
      # Set the instance variables
      self.class.instance_variable_get(:@properties).each {|name, value| instance_variable_set(name, value[:default])}
    end

  end

end