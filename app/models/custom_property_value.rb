# Custom Property Value. The class holding the data for a custom property.
#
# @author Dave Iberson-Hurst
# @since 3.3.0
class CustomPropertyValue < IsoContextualRelationship
  
  configure rdf_type: "http://www.assero.co.uk/ISO11179Concepts#CustomProperty",
            base_uri: "http://#{EnvironmentVariable.read("url_authority")}/CPV",
            uri_unique: true

  data_property :value
  object_property :custom_property_defined_by, cardinality: :one, model_class: "CustomPropertyDefinition"

  validates :value, presence: true, allow_blank: false
  validates_with Validator::Klass, property: :custom_property_defined_by, level: :uri

  # Coded but not tested as not yet used
  # # Add Context. Add a new context to the value.
  # #
  # # @param [Uri|Object] context the context object or uri
  # # @param [Sparql::Transaction] tx the transaction if one is to be used, defaults to nil if none specified
  # # @return [CustomPropertyValue] the updated object
  # def add_context(context, tx=nil)
  #   context_uri = context.is_a?(Uri) ? context : context.uri
  #   self.transaction_set(tx) unless tx.nil?
  #   self.context_push(context_uri)
  #   self.save
  #   self
  # end

  # Update And Clone
  #
  # @param [Uri|Object] context the context object or uri
  # @param [Sparql::Transaction] tx the transaction if one is to be used, defaults to nil if none specified
  # @return [CustomPropertyValue] the updated object
  def update_and_clone(params, context=self, tx=nil)
    context_uri = context.is_a?(Uri) ? context : context.uri
    self.transaction_set(tx) unless tx.nil?
    if self.context.count > 1
      self.context.delete(context_uri)
      object = self.new(value: params[:value], custom_property_defined_by: self.custom_property_defined_by, context: [context_uri], applies_to: self.applies_to)
    else
      super(params)
    end
    self
  end

end