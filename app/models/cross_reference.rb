# Cross Reference. Base class for a cross reference
#
# @author Dave Iberson-Hurst
# @since 2.22.1
class CrossReference < IsoConceptV2
  
  configure rdf_type: "http://www.assero.co.uk/CrossReference#CrossReference",
            uri_suffix: "XR",
            uri_property: :ordinal

  data_property :semantic
  data_property :description
  data_property :ordinal, default: 1
  data_property :can_be_deleted, default: false
  data_property :can_be_modified, default: false

end