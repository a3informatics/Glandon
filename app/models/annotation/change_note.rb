# Annotation CHange Note
#
# @author Dave Iberson-Hurst
# @since 2.23.0
class Annotation::ChangeNote < Annotation
  
  configure rdf_type: "http://www.assero.co.uk/Annotations#ChangeNote",
            base_uri: "http://#{ENV["url_authority"]}/CN",
            uri_unique: true

  data_property :user_reference
  data_property :timestamp

  validates_with Validator::Field, attribute: :user_reference, method: :valid_non_empty_label?
  validates_with Validator::Field, attribute: :timestamp, method: :is_a_date_time?

  # Create. 
  #
  # @param [Hash] params the parameters hash
  # @option params [String] :user_reference the reference to the user, the user's email
  # @option params [String] :description the change note description
  # @option params [String] :reference any references
  # @option params [String] :current the item for which the change note is relevant
  # @return [Annotation::ChangeNote] the change note, may contain errors.
  def self.create(params)
    params[:uri] = create_uri(base_uri)
    params[:label] = "Change Note"
    params[:timestamp] = Time.now
    params[:by_authority] = IsoRegistrationAuthority.owner.uri
    super(params)
  end

  # Update
  #
  # @param [Hash] params the parameters hash
  # @option params [String] :user_reference the reference to the user, the user's email
  # @option params [String] :description the change note description
  # @option params [String] :reference any references
  # @return [Annotation::ChangeNote] the change note, may contain errors.
  def self.update(params)
    params[:timestamp] = Time.now
    super(params)
  end

  # Delete. Delete the change note and the associated reference.
  #
  # @return [Integer] count of items deleted
  def delete
    op_ref = OperationalReferenceV3.find(self.current.first)
    transaction_begin
    op_ref.delete
    super
    transaction_execute
    1
  end

end