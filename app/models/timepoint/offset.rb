class Timepoint::Offset < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/Protocol#TimepointOffset",
            uri_suffix: "TPO",
            uri_unique: true

  data_property :window_offset
  data_property :window_minus
  data_property :window_plus
  data_property :unit

  validates_with Validator::Field, attribute: :window_offset, method: :valid_integer?
  validates_with Validator::Field, attribute: :window_minus, method: :valid_integer?
  validates_with Validator::Field, attribute: :window_plus, method: :valid_integer?

  validates :window_offset, presence: true

  def as_days
    (self.window_offset / 86400).to_i
  end

end
