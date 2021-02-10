class SdtmSponsorDomain::VariableSSD < SdtmIgDomain::Variable

  configure rdf_type: "http://www.assero.co.uk/Tabulation#SdtmSponsorDomainVariable",
            base_uri: "http://#{EnvironmentVariable.read("url_authority")}/SDV",
            uri_unique: true

  data_property :comment
  data_property :used
  data_property :notes
  data_property :method
  object_property :typed_as, cardinality: :one, model_class: "IsoConceptSystem::Node", delete_exclude: true
  object_property :based_on_ig_variable, cardinality: :one, model_class: "SdtmIgDomain::Variable", delete_exclude: true
  object_property :classified_as, cardinality: :one, model_class: "IsoConceptSystem::Node", delete_exclude: true

  validates_with Validator::Field, attribute: :name, method: :valid_sdtm_variable_name?
  validates_with Validator::Field, attribute: :notes, method: :valid_label?
  validates_with Validator::Field, attribute: :method, method: :valid_label?
  validates_with Validator::Field, attribute: :comment, method: :valid_label?
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
  # @return [SdtmSponsorDomain::VariableSSD] a clone of the object
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
    return true if SdtmVariableName.new(self.name, @parent_for_validation.prefix, is_prefixed?).prefix_match?
    self.errors.add(:name, "prefix does not match '#{@parent_for_validation.prefix}'")
    false
  end

  # unique_name_in_domain ? Check if the variable name is unique in the given domain
  #
  # @return [Boolean] true if valid, false otherwise
  def unique_name_in_domain?
    return true if @parent_for_validation.nil? # Don't validate if we don't know about a domain
    @parent_for_validation.unique_name_in_domain?(self, self.name)
  end

  # Update with clone. Update the object. Clone if there are multiple parents.
  #
  # @param [Hash] params the params
  # @param [Object] managed_ancestor the managed ancestor object
  # @return [Object] the object, either new or the cloned new object with updates
  def update_with_clone(params, managed_ancestor)
    @parent_for_validation = managed_ancestor
    if self.standard?
      if valid_keys?(params)
        super(params.slice(:used, :notes, :comment, :method), managed_ancestor)
      else 
        self.errors.add(:base, "The variable cannot be updated as it is a standard variable.")
        self
      end
    else
      return self unless name_change_valid?(params)
      super(params, managed_ancestor)
    end
  end

  # Update. Update the object with the specified properties if valid. Intercepts to handle the terminology
  #
  # @param [Hash] params a hash of properties to be updated
  # @return [Object] returns the object. Not saved if errors are returned.
  def update(params)
    if params.key?(:ct_reference) 
      self.ct_reference_objects
      set = IsoConceptV2::CodedValueSetTmc.new(self.ct_reference, self)
      set.update(params)
      self.ct_reference = set.items
      params.delete(:ct_reference)
    end
    super
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

    # Check if params contain valid standard keys
    def valid_keys?(params)
      standard_keys = %i[used notes comment method]
      (params.to_h.symbolize_keys.keys & standard_keys).any?
    end
    
    # Check for an invalid name change
    def name_change_valid?(params)
      return true unless params.key?(:name)
      return true if params[:name] == self.name
      @parent_for_validation.unique_name_in_domain?(self, params[:name])
    end

    # Variable is prefixed?
    def is_prefixed?
      query_results = Sparql::Query.new.query("SELECT ?o WHERE {#{self.uri.to_ref} bd:basedOnIgVariable/bd:basedOnClassVariable/bd:prefixed ?o}", "", [:bd])
      return true if query_results.empty?
      query_results.by_object(:o).first.to_bool
    end

end