class IsoNamespace < Fuseki::Base

  configure rdf_type: "http://www.assero.co.uk/ISO11179Identification#Namespace"
  data_property :short_name
  data_property :name
  data_property :authority
  
  C_CLASS_NAME = self.name
  
  # Find namespace by the short name.
  #
  # @param name [String] The short name of the namespace to be found
  # @return [IsoNamespace] Iso Namespace object
  def self.find_by_short_name(name)
    results = IsoNamespace.where({short_name: name})
    return nil if results.empty?
    Errors.application_error(C_CLASS_NAME, __method__.to_s, "Multiple short names found.") if results.count > 1
    return results.first
  end

  # Find namespace by the short name.
  #
  # @param name [String] The short name of the namespace to be found
  # @return [object] Iso Namespace object
  def self.exists?(name)
    !find_by_short_name(name).nil?
  end

  # Create
  #
  # @return [IsoNamespace] the object or errors
  # @raise [Errors::CreateError] if object not created
  def create
    super if self.valid? && !self.class.exists?(self.short_name)
  end

  # To Hash
  #
  # @return [Hash] the object hash 
  def to_hash
    {uri: self.uri.to_s, name: self.name, short_name: self.short_name, authority: self.authority}
  end
  
  alias :to_json :to_hash

  # From hash
  #
  # @param params [Hash] the hash of values for the object 
  # @return [IsoNamespace] the object
  def self.from_hash(params)
    object = self.new
    object.uri = Uri.new(uri: params[:uri])
    object.name = params[:name]
    object.short_name = params[:short_name]
    object.authority = params[:authority]
    object
  end

  class << self  
     alias :from_json :from_hash
   end  

  # Object Valid
  #
  # @return [Boolean] true if valid, false otherwise.
  def valid?
    return FieldValidation.valid_short_name?(:short_name, self.short_name, self) && FieldValidation.valid_long_name?(:name, self.name, self)
  end

end