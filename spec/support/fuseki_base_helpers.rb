module FusekiBaseHelpers

  class TestScopedIdentifier < Fuseki::Base
    
    configure rdf_type: "http://www.assero.co.uk/Test#ScopedIdentifier"
    
    data_property :identifier
    object_property :by_authority, cardinality: :one, model_class: "IsoRegistrationAuthority"
    
    validates_with Validator::Uniqueness, attribute: :identifier
    validates_with Validator::Klass, property: :by_authority
    validates_with Validator::Field, attribute: :identifier, method: :valid_identifier?
    
  end

  class TestRegistrationAuthorities < Fuseki::Base

    configure rdf_type: "http://www.assero.co.uk/Test#RegistrationAuthority",
              base_uri: "http://www.assero.co.uk/RA" 

    data_property :organization_identifier, default: "<Not Set>" 
    data_property :international_code_designator, default: "XXX"
    data_property :owner, default: false
    object_property :ra_namespace, cardinality: :one, model_class: "IsoNamespace", delete_exclude: true
    object_property :by_authority, cardinality: :one, model_class: "IsoRegistrationAuthority", read_exclude: true

  end 

  def self.clear
    Fuseki::Base.instance_variable_set(:@schema, nil)
    Fuseki::Base.class_variable_set(:@@subjects, nil)
  end

  def self.read_schema
    Fuseki::Base.set_schema
  end

end
