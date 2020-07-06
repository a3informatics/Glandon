# ISO Regisration Authority
#
# @author Dave Iberson-Hurst
# @since 2.21.1
class IsoRegistrationAuthority < Fuseki::Base
      
  C_SCHEMES = %w(DUNS)

  configure rdf_type: "http://www.assero.co.uk/ISO11179Registration#RegistrationAuthority",
            base_uri: "http://www.assero.co.uk/RA",
            cache: true 

  data_property :organization_identifier, default: "<Not Set>" 
  data_property :international_code_designator, default: C_SCHEMES.first
  data_property :owner, default: false
  object_property :ra_namespace, cardinality: :one, model_class: "IsoNamespace", delete_exclude: true

  # @todo probably add these to field. Not used anywhere selse at the moment so not worth it.
  validates :organization_identifier, presence: true
  validates_format_of :organization_identifier, with: /\A[0-9]{9}\Z/i
  validates :international_code_designator, presence: true
  validates :international_code_designator, :inclusion => {in: C_SCHEMES, message: "%{value} is not a valid scheme" }
  validates :owner, inclusion: { in: [ true, false ] }
  validates_with Validator::Uniqueness, attribute: :organization_identifier, on: :create
  validates_with Validator::Klass, property: :ra_namespace, level: :uri

  @@repository_scope = nil  # Simple cache for the repository (owner) scope
  @@cdisc_scope = nil       # Simple cache for the CDISC scope
  @@owner = nil             # Simple cache for the owner

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
      "    BIND ('IsoNamespace' as ?e) ." +
      "    ?s1 ?p ?o . " +
      "    BIND (?s1 as ?s) ." +
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
    # Make sure persisted
    parent.ra_namespace.set_persisted
    parent.set_persisted 
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
    @@owner ||= get_owner
    @@owner
  end

  # Find the owner of the repository authority
  #
  # @return [String] the authority
  def self.owner_authority
    @@owner ||= get_owner
    @@owner.ra_namespace.authority
  end

  # Find the scope for the repository owner
  #
  # @return [String] the scope id
  def self.repository_scope
    @@repository_scope ||= owner.ra_namespace
    @@repository_scope
  end

  # Find the scope for CDISC
  #
  # @return [String] the scope id
  def self.cdisc_scope
    @@cdisc_scope ||= find_by_short_name("CDISC").ra_namespace
    @@cdisc_scope
  end
  
  # Create
  #
  # @param attributes [Hash] the set of properties
  # @return [IsoNamespace] the object. Contains errors if it fails
  def self.create(attributes)
    attributes[:uri] = Uri.new(namespace: base_uri.namespace, fragment: attributes[:organization_identifier])
    attributes[:ra_namespace] = IsoNamespace.find(attributes[:namespace_id])
    object = super
    object
  end

  # To JSON. Alias to to_h
  alias :to_json :to_h

  # -----------------
  # Test Only Methods
  # -----------------

  if Rails.env.test?

    # Clear the scopes
    def self.clear_scopes
      @@repository_scope = nil
      @@cdisc_scope = nil
      @@owner = nil
    end

  end

private

  # Find the owner of the repository
  def self.get_owner
    object = where_only({owner: true})
    object.ra_namespace_objects
    object
  end

end