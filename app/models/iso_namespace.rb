class IsoNamespace < Fuseki::Base

  configure rdf_type: "http://www.assero.co.uk/ISO11179Identification#Namespace",
            base_uri: "http://www.assero.co.uk/NS" 
  data_property :short_name
  data_property :name
  data_property :authority

  validates :name, presence: true
  validates_format_of :name, with: /\A[a-zA-Z0-9 ]+\Z/i
  validates :short_name, presence: true
  validates_format_of :short_name, with: /\A[a-zA-Z0-9 ]+\Z/i
  validates :authority, presence: true
  validates_with SubjectUniquenessValidator, attribute: :short_name

  C_CLASS_NAME = self.name
  
  # Find namespace by the short name.
  #
  # @param name [String] The short name of the namespace to be found
  # @return [IsoNamespace] Iso Namespace object
  def self.find_by_short_name(name)
    where_only({short_name: name})
  end

  # Exists?
  #
  # @param name [String] The short name of the namespace to be found
  # @return [Boolean] true if found, false otherwise
  def self.exists?(name)
    !find_by_short_name(name).nil?
  end

  # Create
  #
  # @param attributes [Hash] the set of properties
  # @return [IsoNamespace] the object. Contains errors if it fails
  def self.create(attributes)
    attributes[:uri] = Uri.new(namespace: base_uri.namespace, fragment: attributes[:short_name])
    super
  end 

end