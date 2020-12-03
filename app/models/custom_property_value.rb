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

  validates_with Validator::Field, attribute: :value, method: :valid_label?
  validates :value, presence: true, allow_blank: true
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
  # @param [Hash] params the params, may include a transaction
  # @param [Uri|Object] context the context object or uri
  # @return [CustomPropertyValue] the updated object
  def update_and_clone(params, context)
    params[:value] = to_literal(params[:value]) # Make sure a literal string and is not typed
    return update(params) if self.context.count == 1
    tx_exists = transaction_present?(params)
    tx = self.transaction_begin(params)
    context_uri = context.is_a?(Uri) ? context : context.uri
    self.context_delete(context_uri)
    object = self.class.new(value: params[:value], custom_property_defined_by: self.custom_property_defined_by, 
      context: [context_uri], applies_to: self.applies_to, transaction: tx)
    object.uri = object.create_uri(self.class.base_uri)
    object.save
    object.transaction_execute unless tx_exists
    object
  end

  # Where Unique. Find the custom property for the specified main node, context and name
  #
  # @param [Uri|Object] applies_to the variable the property applies to
  # @param [Uri|Object] context the context object or uri
  # @param [String] name the name of the property being searched for
  # @return [CustomPropertyValue] the updated object
  def self.where_unique(applies_to, context, name)
    applies_to_uri = applies_to.is_a?(Uri) ? applies_to : applies_to.uri
    context_uri = context.is_a?(Uri) ? context : context.uri
    upper_case_version = "#{name}".from_variable_style
    query_string = %Q{
      SELECT ?s WHERE 
      {            
        ?s rdf:type isoC:CustomProperty .
        ?s isoC:appliesTo #{applies_to_uri.to_ref} .          
        ?s isoC:context #{context_uri.to_ref} . 
        ?s isoC:customPropertyDefinedBy/isoC:label ?l .
        FILTER (ucase(?l) = '#{upper_case_version}')
      }   
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoC])
    results = query_results.by_object(:s)
    return results.first if results.count == 1
    msg_root = results.empty? ? "Cannot find property" : "Found multiple properties for"
    Errors.application_error(self.class.name, __method__.to_s, "#{msg_root} #{name} for #{applies_to_uri} in context #{context_uri}.")
  end

  # To Typed
  #
  # @return [Object] the value as a typed variable
  def to_typed
    dt = XSDDatatype.new(self.custom_property_defined_by.datatype)
    dt.to_typed(self.value)
  end

private

  # To literal
  def to_literal(value)
    dt = XSDDatatype.new(self.custom_property_defined_by.datatype)
    dt.to_literal(value)
  end

end