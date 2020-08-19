# Canonical Reference. The reference framework
#
# @author Dave Iberson-Hurst
# @since 3.1.0
class CanonicalReference < IsoConceptV2

  configure rdf_type: "http://www.s-cubed.dk/Framework#CanonicalReference",
            base_uri: "http://www.s-cubed.dk/CAR",
            uri_unique: :label,
            cache: true

  data_property :definition
  data_property :bridg
  data_property :sdtm
 
  validates_with Validator::Field, attribute: :definition, method: :valid_label?
  validates_with Validator::Field, attribute: :bridg, method: :valid_label?
  validates_with Validator::Field, attribute: :sdtm, method: :valid_sdtm_variable_name_no_prefix?
  validates :definition, presence: true
  validates :bridg, presence: true
  validates :sdtm, presence: true
  
end