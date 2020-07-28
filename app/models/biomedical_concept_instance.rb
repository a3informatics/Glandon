# Biomedical Concept Instance. 
#
# @author Dave Iberson-Hurst
# @since 3.1.0
class BiomedicalConceptInstance < BiomedicalConcept

  configure rdf_type: "http://www.assero.co.uk/BiomedicalConcept#BiomedicalConceptInstance",
            uri_suffix: "BCI"

  object_property :based_on, cardinality: :one, model_class: "BiomedicalConceptTemplate"

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
    object.create_or_update(:create, true) if object.valid?(:create) && object.create_permitted?
    object
  end

end