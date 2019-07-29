# Operational Reference (v3)
#
# @author Dave Iberson-Hurst
# @since 2.21.2
class OperationalReferenceV3 < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/BusinessOperational#Reference"
  data_property :enabled, default: true
  data_property :optional, default: false
  data_property :ordinal, default: 1

  # Reference Klass. Return the reference clas
  #
  # @return [Class] the reference class
  def self.referenced_klass
    # Note :reference is set by class inheriting from this one.
    properties_metadata_class.klass(Fuseki::Persistence::Naming.new(:reference).as_instance)  
  end

  def self.create(params, parent)
    object = new(params)
    object.uri = object.create_uri(parent.uri)
    object.create_or_update(:create) if object.valid?(:create)
    object
  end

end