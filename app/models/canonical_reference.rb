# Canonical Reference. The reference framework
#
# @author Dave Iberson-Hurst
# @since 3.1.0
class CanonicalReference < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/Framework#CanonicalReference",
            base_uri: "http://www.a3informatics.com/CAR",
            uri_unique: :label,
            cache: true

  data_property :definition
  data_property :bridg
 
  validates_with Validator::Field, attribute: :definition, method: :valid_label?
  validates_with Validator::Field, attribute: :bridg, method: :valid_label?
  validates :definition, presence: true
  validates :bridg, presence: true
  
end