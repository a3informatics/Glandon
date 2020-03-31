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
    ci.uri = ci.create_uri(ci.class.base_uri)
    ci.by_authority = IsoRegistrationAuthority.owner.uri
    ci.reference = params[:reference]
    ci.description = params[:description]
    ci.semantic = params[:semantic]
    params[:previous].each_with_index do |p, index| 
      uri = Uri.new(id: p)
      ci.previous_push(ci.add_op_reference(uri, index))
    end
    params[:current].each_with_index do |c, index|
      uri = Uri.new(id: c)
      ci.current_push(ci.add_op_reference(uri, index+10000))
    end
    ci.save
    ci
  end

  # Update
  #
  # @param [Hash] params the parameters hash
  # @option params [String] :semantic the ...
  # @option params [String] :description the change instruction description
  # @option params [String] :reference any references
  # @return [Annotation::ChangeInstruction] the change instruction, may contain errors.
  # def update(params)
  #   #self.reference = params[:reference]
  #   #self.description = params[:description]
  #   #self.semantic = params[:semantic]
  #   #self.save
  #   #self
  #   super(params)
  # end

#   # Delete. Delete the change instruction and the associated references.
#   #
#   # @return [Integer] count of items deleted
#   def delete_change_instruction
#     self.current_objects
#     op_ref = OperationalReferenceV3.find(self.current.first.uri) #will we have more than one OP?
#     transaction_begin
#     op_ref.delete
#     super
#     transaction_execute
#     1
#   end

  def remove_reference(id)
    uri = Uri.new(id: id)
  byebug
    self.current_objects
    op_ref = OperationalReferenceV3.find(self.current.first.uri)
    transaction_begin
    op_ref.delete
    transaction_execute
    1
  end

  def add_references(params)
    params[:previous].each do |p| 
      self.previous_push(self.add_op_reference(Uri.new(id: p), self.previous.count))
    end
    params[:current].each do |c|
      self.current_push(self.add_op_reference(Uri.new(id: c), self.current.count+10000))
    end
     self.save
     self
  end

  def add_op_reference(uri, index)
    object = OperationalReferenceV3.new
    object.ordinal = index + 1
    object.uri = object.create_uri(self.uri)
    object.reference = uri
    object.enabled = true
    object.optional = false
    object
  end

  def add_previous(ct, reference)
    add_reference(self.previous, ct, reference)
  end

  def add_current(ct, reference)
    add_reference(self.current, ct, reference)
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