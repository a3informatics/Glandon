class SdtmSponsorDomain::Var < SdtmIgDomain::Variable

  configure rdf_type: "http://www.assero.co.uk/Tabulation#SdtmSponsorDomainVariable",
            base_uri: "http://#{EnvironmentVariable.read("url_authority")}/SDV",
            uri_unique: true

  data_property :comment
  data_property :used
  data_property :notes
  object_property :typed_as, cardinality: :one, model_class: "IsoConceptSystem::Node", delete_exclude: true
  object_property :based_on_ig_variable, cardinality: :one, model_class: "SdtmIgDomain::Variable"
  object_property :classified_as, cardinality: :one, model_class: "IsoConceptSystem::Node", delete_exclude: true

  validates_with Validator::Field, attribute: :name, method: :valid_sdtm_variable_name?
  validate :correct_prefix?
  validate :unique_name_in_domain?, on: :create


  # Managed Ancestors Path. Returns the path from the managed ancestor to this class
  #
  # @return [String] the path as an expanded set of predicates
  def self.managed_ancestors_path
    [
      "<http://www.assero.co.uk/Tabulation#includesColumn>"
    ]
  end

  # Clone. Clone the Sponsor Domain Variable Instance
  #
  # @return [SdtmSponsorDomain::Var] a clone of the object
  def clone
    self.typed_as_links
    self.based_on_ig_variable_links
    self.classified_as_links
    super
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

  # unique_name_in_domain ? Check if the variable name is unique in the given domain
  #
  # @return [Boolean] true if valid, false otherwise
  def unique_name_in_domain?
    return true if @parent_for_validation.nil? # Don't validate if we don't know about a domain
    @parent_for_validation.unique_name_in_domain?(self.name)
  end

  # Toggle with clone. Toggles Used attribute, clone if there are multiple parents
  def toggle_with_clone(managed_ancestor)
    if multiple_managed_ancestors?
      update_with_clone(toggle_used, managed_ancestor)
    else
      self.update(toggle_used)
    end
  end

  # Update with clone. Update the object. Clone if there are multiple parents.
  #
  # @param [Hash] params the params
  # @param [Object] managed_ancestor the managed ancestor object
  # @return [Object] the object, either new or the cloned new object with updates
  def update_with_clone(params, managed_ancestor)
    @parent_for_validation = managed_ancestor
    if self.standard?
      if params.has_key? :used
        super(params.slice(:used), managed_ancestor)
      else 
        self.errors.add(:base, "The variable cannot be updated as it is a standard variable.")
        self
      end
    else
      return self unless name_change_valid?(params)
      super(params, managed_ancestor)
    end
  end

  # Delete. Delete the object. Clone if there are multiple parents.
  #
  # @param [Object] parent_object the parent object
  # @param [Object] managed_ancestor the managed ancestor object
  # @return [Object] the parent object, either new or the cloned new object with updates
  def delete(parent, managed_ancestor)
    if self.standard?
      self.errors.add(:base, "The variable cannot be deleted as it is a standard variable.")
      self
    else 
      if multiple_managed_ancestors?
        parent = delete_with_clone(parent, managed_ancestor)
      else
        self.delete_with_links
      end
      parent.reset_ordinals
      1
    end
  end

  # Standard? Is this an standard variable
  #
  # @result [Boolean] return true if this variable is standard or false if it is a non standard variable
  def standard?
    Sparql::Query.new.query("ASK {#{self.uri.to_ref} bd:basedOnIgVariable|bd:basedOnClassVariable ?o}", "", [:bd]).ask? 
  end

  private
    
    # Check for an invalid name change
    def name_change_valid?(params)
      return true unless params.key?(:name)
      return true if params[:name] == self.name
      @parent_for_validation.unique_name_in_domain?(params[:name])
    end

    # Toggle used
    def toggle_used
      self.used == true ? {used: false} : {used: true}
    end

end