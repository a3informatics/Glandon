# Change Instruction. A change instruction
#
# @author Dave Iberson-Hurst
# @since 2.23.0
class Annotation::ChangeInstruction < Annotation
  
  configure rdf_type: "http://www.assero.co.uk/Annotations#ChangeInstruction",
            uri_suffix: "CI",
            uri_property: :ordinal

  data_property :ordinal, default: 1
  data_property :semantic 
  object_property :previous, cardinality: :many, model_class: "OperationalReferenceV3"

  # Create. 
  #
  # @param [Hash] params the parameters hash
  # @option params [String] :semantic The semantic of the change instruction
  # @option params [String] :description The description, the actual annotation.
  # @option params [String] :reference any references
  # @option params [Array] :current the current item for which the change instruction is relevant
  # @option params [Array] :previous the previous item for which the change instruction is relevant
  # @return [Annotation::ChangeInstruction] the change instruction, may contain errors.
  def self.create(params)
    ci = Annotation::ChangeInstruction.new
    ci.by_authority = IsoRegistrationAuthority.owner.uri
    params[:previous].each do |p|
      uri = Uri.new(id: p)
      self.previous_push(ci.add_op_reference(uri)) # <<<< need something like this to add to the collection. Same below
      # What about ordinal?????. Needs setting
    end
    params[:current].each do |c|
      uri = Uri.new(id: c)
      ci.add_op_reference(uri)
    end
    ci.save
    ci
  end

#   # Update
#   #
#   # @param [Hash] params the parameters hash
#   # @option params [String] :semantic the ...
#   # @option params [String] :description the change instruction description
#   # @option params [String] :reference any references
#   # @option params [String] :current the current item for which the change instruction is relevant
#   # @option params [String] :previous the previous item for which the change instruction is relevant
#   # @return [Annotation::ChangeInstruction] the change instruction, may contain errors.
#   def update(params)
#     params[:timestamp] = Time.now
#     super(params)
#   end

#   # Delete. Delete the change instruction and the associated references.
#   #
#   # @return [Integer] count of items deleted
#   def delete
#     self.current_objects
#     op_ref = OperationalReferenceV3.find(self.current.first.uri) #will we have more than one OP?
#     transaction_begin
#     op_ref.delete
#     super
#     transaction_execute
#     1
#   end

  def add_previous(ct, reference)
    add_reference(self.previous, ct, reference)
  end

  def add_current(ct, reference)
    add_reference(self.current, ct, reference)
  end

    def add_op_reference(uri)
    object = OperationalReferenceV3.new
    #object.ordinal = self.previous.count + self.current.count + 1
    object.uri = object.create_uri(self.uri)
    object.reference = uri
    object.enabled = true
    object.optional = false
    object
  end

private
  
  def add_reference(collection, ct, reference)
    set = ct.find_by_identifiers(reference)
    if set.key?(reference.last)
      object = reference.count == 1 ? OperationalReferenceV3::TmcReference.new : OperationalReferenceV3::TucReference.new
      object.ordinal = self.previous.count + self.current.count + 1
      object.uri = object.create_uri(self.uri)
      object.reference = set[reference.last]
      object.context = ct.uri
      object.enabled = true
      object.optional = false
      collection << object
    else
      errors.add(:base, "Failed to find code list references #{reference} within CT.")
    end
  end

end