# Change Instruction. A change instruction
#
# @author Dave Iberson-Hurst
# @since 2.22.1
class CrossReference::ChangeInstruction < CrossReference
  
  configure rdf_type: "http://www.assero.co.uk/CrossReference#ChangeInstruction",
            uri_suffix: "CI",
            uri_property: :ordinal

  object_property :previous, cardinality: :many, model_class: "OperationalReferenceV3"
  object_property :current, cardinality: :many, model_class: "OperationalReferenceV3"

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