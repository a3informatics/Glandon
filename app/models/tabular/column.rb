class Tabular::Column < IsoConcept
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  
  # Attributes
  attr_accessor :rule, :ordinal
  
  # Constants
  C_CLASS_NAME = "Column"

  # Initialize
  #
  # @params triples [Hash] the triples
  # @params id [String] the id to be initialized
  # @return [Null]
  def initialize(triples=nil, id=nil)
    self.rule = ""
    self.ordinal = 0
    if triples.nil?
      super
    else
      super(triples, id)
    end
  end

  # Find a given column
  #
  # @param id [String] the id of the column
  # @param namespace [String] the namespace of the column
  # @return [Tabular::Coluimn] the column object
  def self.find(id, ns)
    return super(id, ns)
  end

  # To JSON
  #
  # @return [Hash] the object hash 
  def to_json
    json = super
    json[:ordinal] = self.ordinal
    json[:rule] = self.rule
    return json
  end

  # From JSON
  #
  # @param json [Hash] the hash of values for the object 
  # @return [Tabular::Column] the object
  def self.from_json(json)
    object = super(json)
    object.ordinal = json[:ordinal]
    object.rule = json[:rule]
    return object
  end

  # To SPARQL
  #
  # @param parent_uri [UriV2] URI object
  # @param sparql [SparqlUpdateV2] The SPARQL object
  # @return [UriV2] The URI
  def to_sparql_v2(sparql, schema_prefix)
    super(sparql, schema_prefix)
    subject = {:uri => self.uri}
    sparql.triple(subject, {:prefix => schema_prefix, :id => "ordinal"}, {:literal => "#{self.ordinal}", :primitive_type => "positiveInteger"})
    sparql.triple(subject, {:prefix => schema_prefix, :id => "rule"}, {:literal => "#{self.rule}", :primitive_type => "string"})
    return self.uri
  end

  # Check Valid
  #
  # @return [Boolean] returns true if valid, false otherwise.
  def valid?
    result = super
    result = result &&
      FieldValidation::valid_positive_integer?(:ordinal, self.ordinal, self) &&
      FieldValidation::valid_label?(:rule, self.rule, self)
    return result
  end

private

  #def self.find_from_triples(triples, id)
  #  object = new(triples, id)
  #  children_from_triples(object, triples, id)
  #  object.triples = ""
  #  return object
  #end

end
