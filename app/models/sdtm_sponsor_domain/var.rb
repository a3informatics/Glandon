class SdtmSponsorDomain::Var < SdtmIgDomain::Variable

  configure rdf_type: "http://www.assero.co.uk/Tabulation#SdtmSponsorDomainVariable",
            uri_property: :name

  data_property :comment
  data_property :used
  data_property :notes
  object_property :typed_as, cardinality: :one, model_class: "IsoConceptSystem::Node", delete_exclude: true
  object_property :based_on_ig_variable, cardinality: :one, model_class: "SdtmIgDomain::Variable"
  object_property :classified_as, cardinality: :one, model_class: "IsoConceptSystem::Node", delete_exclude: true

  validates_with Validator::Field, attribute: :name, method: :valid_sdtm_variable_name?
  validate :correct_prefix?
  validate :duplicate_name_in_domain?

  # Managed Ancestors Path. Returns the path from the managed ancestor to this class
  #
  # @return [String] the path as an expanded set of predicates
  def self.managed_ancestors_path
    [
      "<http://www.assero.co.uk/Tabulation#SdtmSponsorDomain>",
      "<http://www.assero.co.uk/Tabulation#includesColumn>"
    ]
  end

  def set_name(var_name, domain)
    @parent_for_validation= domain
    self.name = var_name
  end

  # correct_prefix ? Check if the variable name prefix matches the domain prefix
  #
  # @return [Boolean] true if valid, false otherwise
  def correct_prefix?
    return true if @parent_for_validation.nil? # Don't validate if we don't know about a domain
    return true if SdtmVariableName.new(self.name, @parent_for_validation.prefix, true).prefix_match?
    self.errors.add(:name, "prefix does not match '#{@parent_for_validation.prefix}'")
    false
  end

  # duplicate_name_in_domain ? Check if the variable name is unique in the given domain
  #
  # @return [Boolean] true if valid, false otherwise
  def duplicate_name_in_domain?
    return true if @parent_for_validation.nil? # Don't validate if we don't know about a domain
    @parent_for_validation.duplicate_name_in_domain?(self)
  end

  # Delete. Delete the object. Clone if there are multiple parents.
  #
  # @param [Object] parent_object the parent object
  # @param [Object] managed_ancestor the managed ancestor object
  # @return [Object] the parent object, either new or the cloned new object with updates
  def delete_or_unlink(parent)
    if multiple_managed_ancestors?
      parent_object.delete_link(:includes_column, self.uri)
    else
      self.delete_with_links
    end
    parent.reset_ordinals
    1
  end

end