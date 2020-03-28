class Timepoint::Offset < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/Protocol#TimepointOffset",
            uri_suffix: "TPO"

  data_property :window_offset
  data_property :window_minus
  data_property :window_plus

  validates_with Validator::Field, attribute: :window_offset, method: :valid_positive_integer?
  validates_with Validator::Field, attribute: :window_minus, method: :valid_positive_integer?
  validates_with Validator::Field, attribute: :window_plus, method: :valid_positive_integer?

  validates :window_offset, presence: true

end
