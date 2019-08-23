# Change Instruction. A change instruction
#
# @author Dave Iberson-Hurst
# @since 2.22.1
class ChangeInstruction < CrossReference
  
  configure rdf_type: "http://www.assero.co.uk/CrossReference#ChanegInstruction",
            uri_suffix: "CI",
            uri_property: :ordinal

  object_property :previous, cardinality: :many, model_class: "OperationalReferenceV3"
  object_property :current, cardinality: :many, model_class: "OperationalReferenceV3"

end