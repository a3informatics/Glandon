require "nokogiri"
require "uri"

class IsoRegistrationAuthority

  include Fuseki::Base
      
  configure rdf_type: "http://www.assero.co.uk/ISO11179Registration#RegistrationAuthority",
            base_uri: "http://www.assero.co.uk/RA" 

  data_property :organization_identifier
  data_property :international_code_designator
  data_property :owner
  object_property :ra_namespace, cardinality: :one, model_class: "IsoNamespace"

  SCHEMES = %w(DUNS S-CUBED)

  validates :organization_identifier, presence: true
  validates_format_of :name, with: /\A[0-9]{9}\Z/i
  validates :international_code_designator, presence: true
  validates_format_of :international_code_designator, :inclusion => {:in => SCHEMES}
  validates :authority, presence: true
  validates_with SubjectUniquenessValidator, attribute: :organization_identifier

  # Find by the short name.
  #
  # @param name [String] The short name of the authority to be found
  # @return [IsoRegistrationAuthority] the object
  def self.find_by_short_name(name)
    where_only({short_name: name})
  end

  # Exists?
  #
  # @param name [String] The short name of the authority to be found
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

  # To JSON
  #
  # @return [hash] The object hash 
  def to_json
    json = 
    { 
      :id => self.id, 
      :number => self.number,
      :scheme => self.scheme,
      :owner => self.owner,
      :namespace => self.namespace.to_json
    }
    return json
  end

  # From JSON
  #
  # @param json [hash] The hash of values for the object 
  # @return [object] The object
  def self.from_json(json)
    object = self.new
    #ConsoleLogger::log(C_CLASS_NAME,"from_json", "Json=#{json}")
    object.id = json[:id]
    object.number = json[:number]
    object.scheme = json[:scheme]
    object.owner = json[:owner]
    object.namespace = IsoNamespace.from_json(json[:namespace])
    return object
  end

end