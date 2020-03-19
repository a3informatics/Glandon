# Complex Datatype Property
#
# @author Dave Iberson-Hurst
# @since Hackathon
class ComplexDatatype::Property < Fuseki::Base

  configure rdf_type: "http://www.s-cubed.dk/ComplexDatatypes#Property",
            base_uri: "http://#{ENV["url_authority"]}/CDTP",
            uri_property: :label,
            cache: true,
            key_property: :label

  data_property :label
  data_property :simple_datatype
  
  validates :label, presence: true
  validates :simple_datatype, presence: true

end