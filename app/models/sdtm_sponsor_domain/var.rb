class SdtmSponsorDomain::Var < SdtmIgDomain::Variable

  configure rdf_type: "http://www.assero.co.uk/Tabulation#SdtmSponsorDomainVariable",
            uri_property: :name

  data_property :comment
  data_property :used
  data_property :notes
  object_property :typed_as, cardinality: :one, model_class: "IsoConceptSystem::Node", delete_exclude: true
  object_property :based_on_ig_variable, cardinality: :one, model_class: "SdtmIgDomain::Variable"

  validates_with Validator::Field, attribute: :name, method: :valid_sdtm_variable_name?

  validate :correct_prefix?
  validate :unique_in_domain?

  # correct_prefix ? Check if the variable name prefix matches the domain prefix
  #
  # @return [Boolean] true if valid, false otherwise
  def correct_prefix?
    return true if @domain.nil? # Don't validate if we don't know about a domain
    return true if SdtmVariableName.new(@var_name, @domain.prefix).prefix_match?
    false
  end

  # unique_in_domain ? Check if the variable name is unique in the given domain
  #
  # @return [Boolean] true if valid, false otherwise
  def unique_in_domain?
    return true if @domain.nil? # Don't validate if we don't know about a domain
    @domain.unique_in_domain?(@var_name)
  end

  def set_name(var_name, domain)
    @domain= domain
    @var_name = var_name
    self.name = var_name
    #self.save
  end


end