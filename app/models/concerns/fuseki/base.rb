# Fuseki Base. The base class for all objects in the triple store
#
# @author Dave Iberson-Hurst
# @since 2.22.0

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
    validates_with Validator::UniqueUri, attribute: :uri, on: :create

    extend Schema
    extend Resource
    include Persistence
    include Utility
    include Diff

    set_schema
  
    # Initialize
    #
    # @param attributes [Hash] hash of attributes to set on initialization of the class
    # @return [Object] the created object
    def initialize(attributes = {})
      @properties = Fuseki::Resource::Properties.new(self, self.class.resources)
      @transaction = add_to_transaction(attributes)
      @new_record = true
      @destroyed = false
      @uri = attributes.key?(:uri) ? attributes[:uri] : nil
      @properties.each do |property| 
        value = attributes.key?(property.name) ? attributes[property.name] : property.default_value
        property.set_raw(value) # Will cause to_be_saved to be set true (i.e. new record)
      end
    end

    # Properties
    #
    # @return [Fuseki::Resource::Properties] a class containing the propetrties
    def properties
      @properties
    end

    # ---------
    # Test Only
    # ---------
    
    if Rails.env.test?

      def test_inspect
        {uri: @uri, properties: @properties, transaction: @transaction, new_record: @new_record, destroyed: @destroyed}
      end

    end

  private

    def add_to_transaction(attributes)
      @transaction = attributes.key?(:transaction) ? attributes[:transaction] : nil
      @transaction.register(self) if !@transaction.nil?
      @transaction
    end

  end

end