# ISO Regisration Authority
#
# @author Dave Iberson-Hurst
# @since 2.21.1
class IsoRegistrationAuthority < Fuseki::Base
      
  configure rdf_type: "http://www.assero.co.uk/ISO11179Registration#RegistrationAuthority",
            base_uri: "http://www.assero.co.uk/RA" 

  data_property :organization_identifier
  data_property :international_code_designator
  data_property :owner
  object_property :ra_namespace, cardinality: :one, model_class: "IsoNamespace"

  SCHEMES = %w(DUNS)

  validates :organization_identifier, presence: true
  validates_format_of :organization_identifier, with: /\A[0-9]{9}\Z/i
  validates :international_code_designator, presence: true
  validates :international_code_designator, :inclusion => {in: SCHEMES, message: "%{value} is not a valid scheme" }
  validates :owner, inclusion: { in: [ true, false ] }
  validates_with SubjectUniquenessValidator, attribute: :organization_identifier

  # Find by the short name.
  #
  # @param name [String] The short name of the namespace of the authority to be found
  # @return [IsoRegistrationAuthority] the object
  def self.find_by_short_name(name)
    parent = nil
    ra_namespace = nil
    query_string = 
      "SELECT ?s ?p ?o ?e WHERE {" +
      "  ?s1 rdf:type #{IsoNamespace.rdf_type.to_ref} ." +
      "  ?s1 isoI:shortName \"#{name}\"^^xsd:string ." +
      "  {"+
      "    BIND (?s1 as ?s) ." +
      "    BIND ('IsoNamespace' as ?e) ." +
      "    ?s ?p ?o . " +
      "  } UNION {" +
      "    ?s :raNamespace ?s1 ." +
      "    BIND ('IsoRegistrationAuthority' as ?e) ." +
      "    ?s ?p ?o ." +
      "  }" +
      "}"
    results = Sparql::Query.new.query(query_string, self.rdf_type.namespace, [:isoI])
    raise Exceptions::NotFoundError.new("Failed to find short name #{name} in #{self.name} object.") if results.empty?
    results.subject_map.each do |subject, klass|
      uri = Uri.new(uri: subject)
      object = klass.constantize.new.class.from_results(uri, results.by_subject[subject])
      klass == self.name ? parent = object : ra_namespace = object
    end
    parent.ra_namespace = ra_namespace
    parent
  end

  # Exists?
  #
  # @param name [String] The short name of the namespace of the authority to be found
  # @return [IsoRegistrationAuthority] the object
  def self.exists?(name)
    !find_by_short_name(name).nil?
  end

  # Find the owner of the repository
  #
  # @return [IsoRegistrationAuthority] the object
  def self.owner
    where_only({owner: true})
  end

    # Create
  #
  # @param attributes [Hash] the set of properties
  # @return [IsoNamespace] the object. Contains errors if it fails
  def self.create(attributes)
    attributes[:uri] = Uri.new(namespace: base_uri.namespace, fragment: attributes[:organization_identifier])
    super
  end 

end