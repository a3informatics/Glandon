# ISO Registration State (V2) 
#
# @author Dave Iberson-Hurst
# @since 2.21.1
class IsoScopedIdentifierV2 < Fuseki::Base

  configure rdf_type: "http://www.assero.co.uk/ISO11179Registration#RegistrationState",
            base_uri: "http://www.assero.co.uk/RS" 
  data_property :registration_status
  data_property :administrative_note
  data_property :effective_date
  data_property :until_date
  data_property :unresolved_issue
  data_property :administrative_status
  data_property :previous_state
  object_property :regsitration_authority, cardinality: :one, model_class: "IsoRegsistrationAuthority"

  validates_with Validator::Field, attribute: :identifier, method: :valid_identifier?
  validates_with Validator::Field, attribute: :version_label, method: :valid_label?
  validates_with Validator::Field, attribute: :version, method: :valid_version?
  validates_with Validator::Field, attribute: :semantic_version, method: :valid_semantic_version?
  validates_with Validator::ScopedIdentifier, on: :create

  attr_accessor :current, :unresolvedIssue , :administrativeStatus, :previousState
  
  # Constants
  C_CLASS_NAME = self.name
  C_DEFAULT_DATETIME = "2016-01-01T00:00:00+00:00"
  C_UNTIL_DATETIME = "2100-01-01T00:00:00+00:00"

  def initialize
    super
    if date_time >= self.effective_date && date_time <= self.until_date
      self.current = true
    end
  end

  # Test if registered
  # 
  # @return [boolean] True if a registration state present
  def registered?()
  	return false if self.registration_status == "" # Preserve backwards compatibility
    return false if self.registration_status == :Not_Set.to_s
    return true
  end

  # Get the No State status
  # 
  # @return [string] The no state string
  def self.no_state()
    return :Not_Set.to_s
  end

  # Get the next state
  # 
  # @param state [string] The current state
  # @return [string] The next state
  def self.next_state(state)
    info = Rails.configuration.iso_registration_state[state.to_sym]
    nextState = info[:next_state]
    #ConsoleLogger::log(C_CLASS_NAME,"nextState","Old=" + state.to_s + ", New=" + nextState)
    return nextState
  end

  # Get the human readable label for a state
  #
  # @return [string] The label
  def self.state_label(state)
    info = Rails.configuration.iso_registration_state[state.to_sym]
    return info[:label]
  end

  # Get the definition for a state
  #
  # @return [string] The definition
  def self.state_definition(state)
    info = Rails.configuration.iso_registration_state[state.to_sym]
    return info[:definition]
  end

  # Get the released state
  #
  # @return [string] The released state
  def self.released_state
    return :Standard.to_s
  end
  
  # Is the item at the released state
  #
  # @return [boolean] True if in the released state, false otherwise
  def released_state?
    self.registrationStatus == :Standard.to_s
  end
  
  # Has the item been at the released state
  #
  # @return [Boolean] true if it has been in the released state, false otherwise
  def has_been_released_state?
    self.registrationStatus == :Retired.to_s || self.registrationStatus == :Superseded.to_s
  end
  
  # Can the item be edited
  #
  # @return [string] The next state
  def edit?
    info = Rails.configuration.iso_registration_state[self.registrationStatus.to_sym]
    return info[:edit_enabled]
  end

  # Can the item be deleted
  #
  # @return [string] The next state
  def delete?
    info = Rails.configuration.iso_registration_state[self.registrationStatus.to_sym]
    return info[:delete_enabled]
  end

  # Returns the new state after the item has been edited
  #
  # @return [string] The next state
  def state_on_edit
    info = Rails.configuration.iso_registration_state[self.registrationStatus.to_sym]
    return info[:state_on_edit]
  end

  # Returns true if the version needs to be updated after an edit
  #
  # @return [string] The next state
  def new_version?
    info = Rails.configuration.iso_registration_state[self.registrationStatus.to_sym]
    return info[:edit_up_version]
  end

  # Returns true if the item can be the current item
  #
  # @return [string] The next state
  def can_be_current?
    info = Rails.configuration.iso_registration_state[self.registrationStatus.to_sym]
    return info[:can_be_current]
  end

  # Returns true if the state can be changed
  #
  # @return [string] The next state
  def can_be_changed?
    info = Rails.configuration.iso_registration_state[self.registrationStatus.to_sym]
    return info[:next_state] != self.registrationStatus
  end

  # Create the object in the triple store.
  #
  def self.make_current(id)  
    update = UriManagement.buildPrefix(C_NS_PREFIX, ["isoB", "isoR"]) +
      "DELETE \n" +
      "{ \n" +
      " :" + id + " isoR:effectiveDate ?a . \n" +
      " :" + id + " isoR:untilDate ?b . \n" +
      "} \n" +
      "INSERT \n" +
      "{ \n" +
      " :" + id + " isoR:effectiveDate \"#{SparqlUtility.replace_special_chars(Time.now.iso8601)}\"^^xsd:dateTime . \n" +
      " :" + id + " isoR:untilDate \"#{SparqlUtility.replace_special_chars(C_UNTIL_DATETIME)}\"^^xsd:dateTime . \n" +
      "} \n" +
      "WHERE \n" +
      "{ \n" +
      " :" + id + " isoR:effectiveDate ?a . \n" +
      " :" + id + " isoR:untilDate ?b . \n" +
      "}"
    ConsoleLogger.debug(C_CLASS_NAME, "make_current", "Update=#{update}")
    # Send the request, wait the resonse
    response = CRUD.update(update)
    # Response
    if !response.success?
      ConsoleLogger.info(C_CLASS_NAME, "make_current", "Failed to update object.")
      raise Exceptions::UpdateError.new(message: "Failed to update " + C_CLASS_NAME + " object.")
    end
  end

  # Create the object in the triple store.
  #
  def self.make_not_current(id)  
    update = UriManagement.buildPrefix(C_NS_PREFIX, ["isoB", "isoR"]) +
      "DELETE \n" +
      "{ \n" +
      " :" + id + " isoR:untilDate ?a . \n" +
      "} \n" +
      "INSERT \n" +
      "{ \n" +
      " :" + id + " isoR:untilDate \"#{SparqlUtility.replace_special_chars(Time.now.iso8601)}\"^^xsd:dateTime . \n" +
      "} \n" +
      "WHERE \n" +
      "{ \n" +
      " :" + id + " isoR:untilDate ?a . \n" +
      "}"
    # Send the request, wait the resonse
    response = CRUD.update(update)
    # Response
    if !response.success?
      ConsoleLogger.info(C_CLASS_NAME, "make_not_current", "Failed to update object.")
      raise Exceptions::UpdateError.new(message: "Failed to update " + C_CLASS_NAME + " object.")
    end
  end

end