# ISO Registration State (V2) 
#
# @author Dave Iberson-Hurst
# @since 2.21.1
class IsoRegistrationStateV2 < Fuseki::Base

  configure rdf_type: "http://www.assero.co.uk/ISO11179Registration#RegistrationState",
            base_uri: "http://www.assero.co.uk/RS" 
  data_property :registration_status
  data_property :administrative_note
  data_property :effective_date
  data_property :until_date
  data_property :unresolved_issue
  data_property :administrative_status
  data_property :previous_state
  object_property :by_authority, cardinality: :one, model_class: "IsoRegistrationAuthority"

  #validates_with Validator::Field, attribute: :registration_status, method: :valid_registration_state?
  #validates_with Validator::Field, attribute: :previous_state, method: :valid_registration_state?
  validates_with Validator::Field, attribute: :administrative_note, method: :valid_label?
  validates_with Validator::Field, attribute: :unresolved_issue, method: :valid_label?
  validates_with Validator::Field, attribute: :administrative_status, method: :valid_label?
  
  # Constants
  C_CLASS_NAME = self.name
  C_DEFAULT_DATETIME = "2016-01-01T00:00:00+00:00"
  C_UNTIL_DATETIME = "2100-01-01T00:00:00+00:00"
  C_NOT_SET = "Not_Set"

  def initialize(attributes = {})
    self.registration_status = C_NOT_SET
    self.previous_state = C_NOT_SET
    super
  end

  # Current?
  # 
  # @return [Boolean] returns true if the item is current
  def current?
    Time.now.between?(self.effective_date, self.until_date)
  end

  # Test if registered
  # 
  # @return [Boolean] True if a registration state present
  def registered?()
  	return false if ["", C_NOT_SET].include?(self.registration_status) # Keep empty string to preserve backwards compatibility
    return true
  end

  # Get the No State status
  # 
  # @return [String] The no state string
  def self.no_state()
    return C_NOT_SET
  end

  # Get the next state
  # 
  # @param state [String] The current state
  # @return [String] The next state
  def self.next_state(state)
    info = Rails.configuration.iso_registration_state[state.to_sym]
    nextState = info[:next_state]
    #ConsoleLogger::log(C_CLASS_NAME,"nextState","Old=" + state.to_s + ", New=" + nextState)
    return nextState
  end

  # Get the human readable label for a state
  #
  # @return [String] The label
  def self.state_label(state)
    info = Rails.configuration.iso_registration_state[state.to_sym]
    return info[:label]
  end

  # Get the definition for a state
  #
  # @return [String] The definition
  def self.state_definition(state)
    info = Rails.configuration.iso_registration_state[state.to_sym]
    return info[:definition]
  end

  # Get the released state
  #
  # @return [String] The released state
  def self.released_state
    return :Standard.to_s
  end
  
  # Is the item at the released state
  #
  # @return [Boolean] True if in the released state, false otherwise
  def released_state?
    self.registration_status == :Standard.to_s
  end
  
  # Has the item been at the released state
  #
  # @return [Boolean] true if it has been in the released state, false otherwise
  def has_been_released_state?
    self.registration_status == :Retired.to_s || self.registration_status == :Superseded.to_s
  end
  
  # Can the item be edited
  #
  # @return [String] The next state
  def edit?
    info = Rails.configuration.iso_registration_state[self.registration_status.to_sym]
    return info[:edit_enabled]
  end

  # Can the item be deleted
  #
  # @return [String] The next state
  def delete?
    info = Rails.configuration.iso_registration_state[self.registration_status.to_sym]
    return info[:delete_enabled]
  end

  # Returns the new state after the item has been edited
  #
  # @return [String] The next state
  def state_on_edit
    info = Rails.configuration.iso_registration_state[self.registration_status.to_sym]
    return info[:state_on_edit]
  end

  # Returns true if the version needs to be updated after an edit
  #
  # @return [String] The next state
  def new_version?
    info = Rails.configuration.iso_registration_state[self.registration_status.to_sym]
    return info[:edit_up_version]
  end

  # Returns true if the item can be the current item
  #
  # @return [String] The next state
  def can_be_current?
    info = Rails.configuration.iso_registration_state[self.registration_status.to_sym]
    return info[:can_be_current]
  end

  # Returns true if the state can be changed
  #
  # @return [String] The next state
  def can_be_changed?
    info = Rails.configuration.iso_registration_state[self.registration_status.to_sym]
    return info[:next_state] != self.registration_status
  end

  # Create
  #
  # @param attributes [Hash] the set of properties
  # @return [IsoNamespace] the object. Contains errors if it fails
  def self.create(attributes)
    identifier = attributes[:identifier].gsub(/[^0-9A-Za-z]/, '-')
    uri = Uri.new(namespace: base_uri.namespace, fragment: "")
    uri.extend_path("#{attributes[:by_authority].ra_namespace.short_name}/#{identifier}")
    attributes[:uri] = uri
    super
  end 

  # Make current
  #
  # @return [Void] no return
  def make_current
    Sparql::Update.new.sparql_update(make_current_query, self.rdf_type.namespace, [:isoR])
  end

  # Make not current
  #
  # @return [Void] no return
  def make_not_current  
    Sparql::Update.new.sparql_update(make_not_current_query, self.rdf_type.namespace, [:isoR])
  end

private

  def make_current_query
    "DELETE \n" +
    "{ \n" +
    " #{self.uri.to_ref} isoR:effectiveDate ?a . \n" +
    " #{self.uri.to_ref} isoR:untilDate ?b . \n" +
    "} \n" +
    "INSERT \n" +
    "{ \n" +
    " #{self.uri.to_ref} isoR:effectiveDate \"#{SparqlUtility.replace_special_chars(Time.now.iso8601)}\"^^xsd:dateTime . \n" +
    " #{self.uri.to_ref} isoR:untilDate \"#{SparqlUtility.replace_special_chars(C_UNTIL_DATETIME)}\"^^xsd:dateTime . \n" +
    "} \n" +
    "WHERE \n" +
    "{ \n" +
    " #{self.uri.to_ref} isoR:effectiveDate ?a . \n" +
    " #{self.uri.to_ref} isoR:untilDate ?b . \n" +
    "}"
  end

  def make_not_current_query
    "DELETE \n" +
    "{ \n" +
    " #{self.uri.to_ref} isoR:untilDate ?a . \n" +
    "} \n" +
    "INSERT \n" +
    "{ \n" +
    " #{self.uri.to_ref} isoR:untilDate \"#{SparqlUtility.replace_special_chars(Time.now.iso8601)}\"^^xsd:dateTime . \n" +
    "} \n" +
    "WHERE \n" +
    "{ \n" +
    " #{self.uri.to_ref} isoR:untilDate ?a . \n" +
    "}"
  end

end