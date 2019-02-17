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
    include Schema
    include Properties

    def initialize
      @uri = nil
      @@schema ||= read_schema
      properties_inherit
      properties_predicate
    end

  end

end