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

    def initialize
      @@schema ||= read_schema
      @uri = nil
      #@@properties.each do |name, value|
      #  self.instance_variable_set("@#{name}", value)
      #end
    end

  end

end