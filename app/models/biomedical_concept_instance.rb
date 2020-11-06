# Biomedical Concept Instance. 
#
# @author Dave Iberson-Hurst
# @since 3.1.0
class BiomedicalConceptInstance < BiomedicalConcept

  configure rdf_type: "http://www.assero.co.uk/BiomedicalConcept#BiomedicalConceptInstance",
            uri_suffix: "BCI"

  object_property :based_on, cardinality: :one, model_class: BiomedicalConceptTemplate, delete_exclude: true, read_exclude: true

  # Create From Template. Creates a new instance from the specified template
  #
  # @params [Hash] params a set of initial vaues for any attributes
  # @option params [String] :identifier the identifier
  # @option params [String] :label the label
  # @return [BiomedicalConceptInstance] the created object. May contain errors if unsuccesful.
  def self.create_from_template(params, template)
  	new_params = template.to_h
  	new_params[:label] = params[:label] 
  	new_params[:identifier] = params[:identifier] 
  	object = self.from_h(new_params)
    object.based_on = template.uri
    object.set_initial(params[:identifier])
    object.creation_date = object.last_change_date # Will have been set by set_initial, ensures the same one used.
    object.set_question_text_and_format
    object.create_or_update(:create, true) if object.valid?(:create) && object.create_permitted?
    object
  end

  # Update Property. Updates a property handling the split between the item and properties
  #
  # @params [Hash] params a set of updated values for any attribute within the property or item
  # @return [BiomedicalConceptInstance] the updated object
  def update_property(params)
    new_params = split_params(params)
    property = BiomedicalConceptInstance::PropertyX.find(params[:property_id])
    if new_params[:property].any?
      property.update_with_clone(new_params[:property], self)
    elsif new_params[:item].any?
      uris = property.managed_ancestor_path_uris(self)
      item = BiomedicalConceptInstance::Item.find(uris.first)
      item.update_with_clone(new_params[:item].dup, self) if new_params[:item].keys.any?
    else
      # Nothing to be done, empty parameters submitted
      ConsoleLogger.info(self.class.name, "update_property", "Attempt to update property with empty parameters.")
      self
    end
  end

  # Identifier required and not multiple. 
  # @result [Boolean] return true if it required and it has zero or one coded value.
  def identifier_required_and_not_multiple?
    property_x = self.identified_by.has_complex_datatype.first.has_property.first
    property_x.has_coded_value.count <= 1 
  rescue => e
    return false
  end

  # Clone. Clone the BC Instance
  #
  # @return [BiomedicalConcept] a clone of the object
  def clone
    self.based_on_links
    super
  end

  # Set question text to Not set as default
  def set_question_text_and_format
    self.has_item.each do |item|
      if item.collect || item.enabled
        item.has_complex_datatype.each do |cdt|
          cdt.has_property.each do |property|
            property.question_text = "Not set" if item.collect
            property.format = XSDDatatype.new(property.is_complex_datatype_property.simple_datatype).default_format if item.enabled
          end
        end
      end
    end
  end

private

  # Split the params into the two parts, property and item
  def split_params(params)
    new_params = {item: {}, property: {}}
    params.each do |k,v|
      next if k.to_sym == :property_id
      child = property_to_child(k.to_sym)
      new_params[child][k.to_sym] = v
    end
    Errors::application_error(self.class.name, "split_params", "Attempting to update multiple children '#{new_params}'.") if new_params[:item].any? && new_params[:property].any?
    new_params
  end

  # Map the property to the correct child.
  def property_to_child(property)
    map = {
      collect: :item, 
      enabled: :item, 
      question_text: :property, 
      prompt_text: :property, 
      format: :property,
      has_coded_value: :property
    }
    Errors::application_error(self.class.name, "property_to_child", "No matching property for '#{property}' found.") unless map.key?(property)
    map[property]
  end

end