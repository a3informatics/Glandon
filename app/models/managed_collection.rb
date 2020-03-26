# Managed Collection
#
# @author Dave Iberson-Hurst
# @since Hackathon
class ManagedCollection <  IsoManagedV2

  configure rdf_type: "http://www.assero.co.uk/BusinessOperational#Collection",
            uri_suffix: "MC"

  object_property :has_managed, cardinality: :many, model_class: "OperationalReferenceV3", children: true

  def add_no_save(item, ordinal)
    ref = OperationalReferenceV3.new(ordinal: ordinal, reference: item.uri)
    ref.uri = ref.create_uri(self.uri)
    self.has_managed << ref
  end

  def clone
    self.has_managed_links
    object = super
    object.has_managed = []
    self.has_managed.each do |ref|
      object.has_managed << ref.clone
    end
    object
  end

end
