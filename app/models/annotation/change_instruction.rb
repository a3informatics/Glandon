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
  def self.create
    ci = Annotation::ChangeInstruction.new
    ci.uri = ci.create_uri(ci.class.base_uri)
    ci.by_authority = IsoRegistrationAuthority.owner.uri
    ci.reference = "Not set"
    ci.description = "Not set"
    ci.semantic = "Not set"
    ci.save
    ci
  end

  # # Delete. Delete the change instruction and the associated references.
  # #
  # # @return [Integer] count of items deleted
  # def delete_change_instruction
  #   self.current_objects
  #   op_ref = OperationalReferenceV3.find(self.current.first.uri) #will we have more than one OP?
  #   transaction_begin
  #   op_ref.delete
  #   super
  #   transaction_execute
  #   1
  #       query_string = %Q{
  #       DELETE 
  #       {
  #         ?s ?p ?o
  #       } 
  #       WHERE 
  #       {
  #         {
  #           #{self.uri.to_ref} (th:members/th:memberNext*) ?s .
  #           ?s ?p ?o .
  #         }     
  #         UNION
  #         { 
  #           #{self.uri.to_ref} (^th:isOrdered) ?s .
  #           ?s th:narrower ?o
  #           BIND ( th:narrower as ?p ) .
  #         } 
  #       }
  #     }
  #     partial_update(query_string, [:th])
  # end

  def remove_reference(params)
    if params[:type] == "previous"
      set = self.previous_objects
    else
      set = self.current_objects
    end
    object = set.find{|x| x.reference == Uri.new(id: params[:id])}   
    transaction_begin
    object.delete
    self.save
    transaction_execute
    1
  end

  def add_references(params)
    transaction_begin
    if !params[:previous].empty?
      params[:previous].each_with_index do |p, index| 
        self.previous_push(add_op_reference(Uri.new(id: p), index))
      end
    end
    if !params[:current].empty?
      params[:current].each_with_index do |c, index|
        self.current_push(add_op_reference(Uri.new(id: c), index+10000))
      end
    end
    self.save
    transaction_execute
    self
  end

  def add_op_reference(uri, index)
    OperationalReferenceV3.create({reference: uri, context: nil, ordinal: index + 1}, self)
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