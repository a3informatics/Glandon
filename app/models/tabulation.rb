# Tabulation
#
# @author Dave Iberson-Hurst
# @since 2.21.0
class Tabulation < IsoManagedV2

  configure rdf_type: "http://www.assero.co.uk/Tabulation#Tabulation",
            uri_suffix: "T"

  data_property :rule
  data_property :ordinal, default: 1

  object_property :includes_column, cardinality: :many, model_class: "Tabulation::Column"

  
  # Constants
  # C_CLASS_NAME = self.name

  # Initialize
  #
  # @params [Hash] triples the triples indexed by id (fragment)
  # @params [String] the id of the object to be initialized
  # @return [Void] no return
  # def initialize(triples=nil, id=nil)
  #   self.rule = ""
  #   self.ordinal = 0
  #   super(triples, id)
  #   self.rdf_type = self.class::C_RDF_TYPE_URI.to_s if triples.nil?
  # end

  # Find the given object.
  #
  # @param [String] id the id of the domain. Note this is the true id, not a fragment.
  # @param [Boolean] children find all child objects. Defaults to true.
  # @return [Object] the resulting object.
  # def self.find(id, children=true)
  #   uri = UriV3.new(id: id)
  #   object = super(uri.fragment, uri.namespace)
  #   object.children_from_triples if children
  #   object.triples = {}
  #   return object
  # end

  # Find all the models
  #
  # @return [Array] array of objects found
  # def self.all
  #   return IsoManaged.all_by_type(self::C_RDF_TYPE, self::C_SCHEMA_NS)
  # end

  # Find all the released models
  #
  # @return [Array] array of objects found
  # def self.list
  #   return super(self::C_RDF_TYPE, self::C_SCHEMA_NS)
  # end

  # Find history for a given identifier within a specified scope.
  #
  # @params [Hash] params a hash of parameters
  # @option params [String] :identifier the identifier of the items required.
  # @option params [String] :scope_id the id of the scoping namespace (namespace within which the identifier is unique)
  # @return [Array] An array of objects found.
  # def self.history(params)    
  #   return super(self::C_RDF_TYPE, self::C_SCHEMA_NS, params)
  # end

  # To JSON
  #
  # @return [Hash] the object hash 
  # def to_json
  #   json = super
  #   json[:ordinal] = self.ordinal
  #   json[:rule] = self.rule
  #   return json
  # end

  # From JSON
  #
  # @param json [Hash] the hash of values for the object 
  # @return [Tabular] the object created
  # def self.from_json(json)
  #   object = super(json)
  #   object.ordinal = json[:ordinal]
  #   object.rule = json[:rule]
  #   return object
  # end

  # To SPARQL
  #
  # @param parent_uri [UriV2] URI object
  # @param sparql [SparqlUpdateV2] The SPARQL object
  # @return [UriV2] The URI
  # def to_sparql_v2(sparql, schema_prefix)
  #   super(sparql, schema_prefix)
  #   subject = {:uri => self.uri}
  #   sparql.triple(subject, {:prefix => schema_prefix, :id => "ordinal"}, {:literal => "#{self.ordinal}", :primitive_type => "positiveInteger"})
  #   sparql.triple(subject, {:prefix => schema_prefix, :id => "rule"}, {:literal => "#{self.rule}", :primitive_type => "string"})
  #   return self.uri
  # end

  # Check Valid
  #
  # @return [Boolean] returns true if valid, false otherwise.
  # def valid?
  #   result = super
  #   result = result &&
  #     FieldValidation::valid_positive_integer?(:ordinal, self.ordinal, self) &&
  #     FieldValidation::valid_label?(:rule, self.rule, self)
  #   return result
  # end

  # Build. Build an object from the operational hash
  #
  # @param [Hash] params the operational hash (see IsoManaged)
  # @param [IsoRegistrationAuthority] ra the registration authority object
  # @return [AdamIgDataset] the object created
  # def self.build(params, ra)
  #   super
  # end

end