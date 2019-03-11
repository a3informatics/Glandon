# ISO Concept (V2) 
#
# @author Dave Iberson-Hurst
# @since 2.21.1
class IsoConceptV2 < Fuseki::Base

  configure rdf_type: "http://www.assero.co.uk/ISO11179Concepts#Concept",
            base_uri: "http://www.assero.co.uk/IC" 
  data_property :label

  validates_with Validator::Field, attribute: :label, method: :valid_label?
  
  # Constants
  C_CLASS_NAME = self.name

end