require 'controller_helpers.rb'

class BiomedicalConceptInstancesController < ManagedItemsController

  include ControllerHelpers
  include DatatablesHelpers

  before_action :authenticate_and_authorized

  def index
    super
  end

  def history
    super
  end

  def show
    @bc = BiomedicalConceptInstance.find_minimum(protect_from_bad_id(params))
    @show_path = show_data_biomedical_concept_instance_path(@bc)
    @close_path = history_biomedical_concept_instances_path(biomedical_concept_instance: { identifier: @bc.has_identifier.identifier, scope_id: @bc.scope })
  end

  def show_data
    @bc = BiomedicalConceptInstance.find_minimum(protect_from_bad_id(params))
    render json: {data: bc_properties_with_paths(@bc)}, status: 200
  end

  def create_from_template
    template = BiomedicalConceptTemplate.find_full(protect_from_bad_id(template_id))
    instance = BiomedicalConceptInstance.create_from_template(the_params, template)
    if instance.errors.empty?
      AuditTrail.create_item_event(current_user, instance, instance.audit_message(:created))
      path = history_biomedical_concept_instances_path({biomedical_concept_instance: {identifier: instance.scoped_identifier, scope_id: instance.scope.id}})
      render :json => {data: {history_path: path, id: instance.id}}, :status => 200
    else
      render :json => {errors: instance.errors.full_messages}, :status => 422
    end
  end

  def edit
    @bc = BiomedicalConcept.find_minimum(protect_from_bad_id(params))
    respond_to do |format|
      format.html do
        return true unless edit_lock(@bc)
        @bc = @edit.item
        @close_path = history_biomedical_concept_instances_path({ biomedical_concept_instance:
            { identifier: @bc.scoped_identifier, scope_id: @bc.scope } })
      end
      format.json do
        return true unless edit_lock(@bc)
        @bc = @edit.item
        render :json => {data: @bc.to_h, token_id: @edit.token.id}, :status => 200
      end
    end
  end

  def edit_data
    bc = BiomedicalConcept.find_full(protect_from_bad_id(params))
    return true unless check_lock_for_item(bc)
    render :json => {data: bc_properties_with_paths(bc)}, :status => 200
  end

  def update_property
    bc = BiomedicalConcept.find_full(protect_from_bad_id(params))
    return true unless check_lock_for_item(bc)
    property = bc.update_property(property_params)
    if property.errors.empty?
      AuditTrail.update_item_event(current_user, bc, bc.audit_message(:updated)) if @lock.first_update?
      render :json => {data: bc_properties_with_paths(bc)}, :status => 200
    else
      prefix_property_errors(property, "has_complex_datatype.has_property")
      render :json => {:fieldErrors => format_editor_errors(property.errors)}, :status => 200
    end
  end

  def destroy
    bc = BiomedicalConcept.find_minimum(protect_from_bad_id(params))
    return true unless get_lock_for_item(bc)
    bc.delete
    AuditTrail.delete_item_event(current_user, bc, bc.audit_message(:deleted))
    @lock.release
    redirect_to request.referer
  end

private

  # Prefix Property Errors
  def prefix_property_errors(property, prefix)
    return if property.errors.empty?
    return if property.class unless BiomedicalConceptTemplate::PropertyX
    temp = {}
    property.errors.each {|key, msg| temp["#{prefix}.#{key}".to_sym] = msg}
    property.errors.clear
    temp.each {|key, msg| property.errors.add(key, msg)}
  end

  # Get BC properties with paths
  def bc_properties_with_paths(bc)
    add_tc_paths_to_items(bc.get_properties(true))
  end

  # Add paths to terminology references
  def add_tc_paths_to_items(items)
    items = items.each do |x|
      x[:has_complex_datatype][:has_property][:has_coded_value].each do |cv|
        cv.reverse_merge!({show_path: thesauri_unmanaged_concept_path({id: cv[:reference][:id], unmanaged_concept: {parent_id: cv[:context][:id], context_id: ""}})})
      end
    end
    items
  end

  # Strong parameters, general
  def the_params
    params.require(:biomedical_concept_instance).permit(:identifier, :label, :offset, :count, :scope_id, :template_id)
  end

  # Strong parameters, property update
  def property_params
    params.require(:biomedical_concept_instance).permit(:property_id, :collect, :enabled, :question_text, :prompt_text, :format, :has_coded_value => [])
  end

  # Get the template id from the params
  def template_id
    {id: the_params[:template_id]}
  end

  # Path for given action
  def path_for(action, object)
    case action
      when :show
        return biomedical_concept_instance_path(object)
      when :edit
        return edit_biomedical_concept_instance_path(id: object.id)
      else
        return ""
    end
  end

  # Model class
  def model_klass
    BiomedicalConceptInstance
  end

  # History path
  def history_path_for(identifier, scope_id)
    return {history_path: history_biomedical_concept_instances_path({biomedical_concept_instance:{identifier: identifier, scope_id: scope_id}})}
  end

  # Close path
  def close_path_for
    biomedical_concept_instances_path
  end

end
