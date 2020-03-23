class CanonicalReference < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/Framework#CanonicalReference",
            uri_unique: :bridg

  data_property :definition
  data_property :bridg
 
  validates_with Validator::Field, attribute: :definition, method: :valid_label?
  validates_with Validator::Field, attribute: :bridg, method: :valid_label?
  validates :definition, presence: true
  validates :bridg, presence: true
  
end