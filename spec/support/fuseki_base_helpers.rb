module FusekiBaseHelpers

  class TestScopedIdentifier < Fuseki::Base
    
    configure rdf_type: "http://www.assero.co.uk/Test#ScopedIdentifier"
    
    data_property :identifier
    object_property :by_authority, cardinality: :one, model_class: "IsoRegistrationAuthority"
    
    validates_with Validator::Uniqueness, attribute: :identifier
    validates_with Validator::Klass, property: :by_authority
    validates_with Validator::Field, attribute: :identifier, method: :valid_identifier?
    
  end

  def self.clear
    Fuseki::Base.instance_variable_set(:@schema, nil)
    Fuseki::Base.class_variable_set(:@@subjects, nil)
  end

  def self.read_schema
    Fuseki::Base.set_schema
  end

end
