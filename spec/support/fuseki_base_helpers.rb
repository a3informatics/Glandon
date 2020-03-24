module FusekiBaseHelpers

  def property_metadata(property)
    result = {}
    property.each {|key, value| result[key] = value.respond_to?(:to_h) ? value.to_h : value}
    result
  end

  def all_metadata(metadata)
    result = {}
    metadata.each {|key, property| result[key] = property_metadata(property)}
    result
  end

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

  class TestAdministeredItem < Fuseki::Base

    configure rdf_type: "http://www.assero.co.uk/Test#AdministeredItem",
              base_uri: "http://www.assero.co.uk/RA" 

    object_property :has_state, cardinality: :one, model_class: "IsoRegistrationStateV2"
    object_property :has_identifier, cardinality: :many, model_class: "IsoScopedIdentifierV2"
    data_property :change_description

  end

  class TestUnmanagedConcept < IsoConceptV2

    configure rdf_type: "http://www.assero.co.uk/Test#UnmanagedConcept",
              uri_property: :identifier,
              key_property: :identifier

    object_property :synonym, cardinality: :many, model_class: "Thesaurus::Synonym"
  
    include Thesaurus::Synonyms

  end

  def self.clear
    Fuseki::Base.instance_variable_set(:@schema, nil)
    Fuseki::Base.class_variable_set(:@@subjects, nil)
  end

  def self.read_schema
    Fuseki::Base.set_schema
  end

end
