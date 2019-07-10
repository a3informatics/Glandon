# Operational Reference (v3)
#
# @author Dave Iberson-Hurst
# @since 2.21.2
class OperationalReferenceV3 < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/BusinessOperational#Reference"
  data_property :enabled, default: true
  data_property :optional, default: false
  data_property :ordinal, default: 1

  def self.referenced_klass
    properties_metadata_class.klass(Fuseki::Persistence::Naming.new(:reference).as_instance)  
  end

end