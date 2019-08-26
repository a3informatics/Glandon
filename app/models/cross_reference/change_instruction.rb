# Change Instruction. A change instruction
#
# @author Dave Iberson-Hurst
# @since 2.22.1
class CrossReference::ChangeInstruction < CrossReference
  
  configure rdf_type: "http://www.assero.co.uk/CrossReference#ChanegInstruction",
            uri_suffix: "CI",
            uri_property: :ordinal

  object_property :previous, cardinality: :many, model_class: "OperationalReferenceV3"
  object_property :current, cardinality: :many, model_class: "OperationalReferenceV3"

  def add_previous(ct, reference)
    add_reference(self.previous, reference)
  end

  def add_current(ct, reference)
    add_reference(self.current, reference)
  end

private
  
  def add_reference(collection, ct, reference)
    set = ct.find_by_identifier(reference)
    if set.key?(reference.last)
      reference.count == 1
        object = OperationalReferenceV3::TmcReference.new
      else
        object = OperationalReferenceV3::TucReference.new
      end
      object.ordinal = collection.count + 1
      object.reference set[reference.last]
      object.context = ct.uri
      object.enabled = true
      object.optional = false
      collection << object
    else
      errors.add(:base, "")
    end
  end

end