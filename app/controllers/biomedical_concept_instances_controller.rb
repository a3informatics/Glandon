require 'controller_helpers.rb'

class BiomedicalConceptInstancesController < ManagedItemsController

  C_CLASS_NAME = "BiomedicalConceptInstancesController"

  include ControllerHelpers

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
    items = @bc.get_properties(true)
    items = items.each do |x|
      x[:has_complex_datatype][:has_property][:has_coded_value].each do |cv|
        cv.reverse_merge!({show_path: thesauri_unmanaged_concept_path({id: cv[:reference][:id], unmanaged_concept: {parent_id: cv[:context][:id], context_id: ""}})})
      end
    end
    render json: {data: items}, status: 200
  end

  # def editable
  #   authorize BiomedicalConcept, :index?
  #   results = {:data => []}
  #   bcs = BiomedicalConcept.unique
  #   bcs.each do |bc|
  #     history = BiomedicalConcept.history({identifier: bc[:identifier], scope: IsoNamespace.find(bc[:scope_id])})
  #     if history.length > 0
  #       results[:data] << history[0].to_json if history[0].edit?
  #     end
  #   end
  #   respond_to do |format|
  #     format.json do
  #       render json: results
  #     end
  #   end
  # end


  # def list
  #   authorize BiomedicalConcept
  #   @bcs = BiomedicalConcept.list
  #   respond_to do |format|
  #     format.json do
  #       results = {:data => []}
  #       @bcs.each { |x| results[:data] << x.to_json }
  #       render json: results
  #     end
  #   end
  # end

  # def new
  #   authorize BiomedicalConceptInstance, :new?
  #   @bcts = BiomedicalConceptTemplate.all
  # end

  # def update

  # end

  def create_from_template
    authorize BiomedicalConceptInstance, :create?
    template = BiomedicalConceptTemplate.find_full(protect_from_bad_id(template_id))
    instance = BiomedicalConceptInstance.create_from_template(the_params, template)
    if instance.errors.empty?
      AuditTrail.create_item_event(current_user, instance, "Biomedical Concept created.")
      path = history_biomedical_concept_instances_path({biomedical_concept_instance: {identifier: instance.scoped_identifier, scope_id: instance.scope.id}})
      render :json => {data: path}, :status => 200
    else
      render :json => {errors: instance.errors.full_messages}, :status => 422
    end
  end

  def edit
    authorize BiomedicalConceptInstance
    @bc = BiomedicalConcept.find_minimum(protect_from_bad_id(params))
    # Lock item and get token
    respond_to do |format|
      format.html do
        @data_path = show_data_biomedical_concept_instance_path(@bc)
        @close_path = history_biomedical_concept_instances_path({ biomedical_concept_instance:
            { identifier: @bc.has_identifier.identifier, scope_id: @bc.scope } })
      end
      format.json do
        # Return item data for the table
      end
    end
  end

  # def edit_lock
  #   authorize BiomedicalConcept, :edit?
  #   @bc = BiomedicalConcept.find(params[:id], the_params[:namespace])
  #   if @bc.new_version?
  #     json = @bc.to_operation
  #     new_bc = BiomedicalConcept.create(json)
  #     @bc = BiomedicalConcept.find(new_bc.id, new_bc.namespace)
  #   end
  #   @token = Token.obtain(@bc, current_user)
  #   if @token.nil?
  #     render :json => {}, :status => 422
  #   else
  #     render :json => { bc: @bc.to_json, token: @token.id }, :status => 200
  #   end
  # end

  # def edit_multiple
  #   authorize BiomedicalConcept, :edit?
  #   @bcts = BiomedicalConceptTemplate.all
  #   @close_path = biomedical_concepts_path
  # end

  # def clone
  #   authorize BiomedicalConcept
  #   @bc = BiomedicalConcept.find(params[:id], the_params[:namespace])
  # end

  # def clone_create
  #   authorize BiomedicalConcept, :create?
  #   from_bc = BiomedicalConcept.find(the_params[:bc_id], the_params[:bc_namespace])
  #   @bc = BiomedicalConcept.create_clone(the_params)
  #   if @bc.errors.empty?
  #     AuditTrail.create_item_event(current_user, @bc, "BiomedicalConcept cloned from #{from_bc.identifier}.")
  #     flash[:success] = 'Biomedical Concept was successfully created.'
  #     redirect_to biomedical_concepts_path
  #   else
  #     flash[:error] = @bc.errors.full_messages.to_sentence
  #     redirect_to clone_biomedical_concept_path(:id => the_params[:bc_id], :namespace => the_params[:bc_namespace])
  #   end
  # end

  # def destroy
  #   authorize BiomedicalConcept
  #   bc = BiomedicalConcept.find(params[:id], the_params[:namespace])
  #   token = Token.obtain(bc, current_user)
  #   if !token.nil?
  #     bc.destroy
  #     AuditTrail.delete_item_event(current_user, bc, "Biomedical Concept deleted.")
  #     token.release
  #   else
  #     flash[:error] = "The item is locked for editing by another user."
  #   end
  #   redirect_to request.referer
  # end

  # def show_references
  #   authorize BiomedicalConcept
  #   bc = BiomedicalConceptInstance.find_minimum(params[:id])
  #   render json: {data: bc.get_references}, status: 200
  # end

  # def show_full
  #   authorize BiomedicalConcept, :show?
  #   @bc = BiomedicalConcept.find(params[:id], the_params[:namespace])
  #   render json: @bc.to_json
  # end

  # def export_json
  #   authorize BiomedicalConcept
  #   @bc = BiomedicalConcept.find(params[:id], the_params[:namespace])
  #   send_data @bc.to_json.to_json, filename: "#{@bc.owner_short_name}_#{@bc.identifier}.json", :type => 'application/json; header=present', disposition: "attachment"
  # end

  # def upgrade
  #   authorize BiomedicalConcept
  #   @bc = BiomedicalConcept.find(params[:id], the_params[:namespace])
  #   #@bc.upgrade
  #   flash[:error] = "The operation is currently disabled"
  #   redirect_to history_biomedical_concepts_path(:biomedical_concept => { :identifier => @bc.identifier, :scope_id => @bc.scope.id })
  # end

private

  def the_params
    params.require(:biomedical_concept_instance).permit(:identifier, :label, :offset, :count, :scope_id, :template_id)
  end

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

  def model_klass
    BiomedicalConceptInstance
  end

  def history_path_for(identifier, scope_id)
    return {history_path: history_biomedical_concept_instances_path({biomedical_concept_instance:{identifier: identifier, scope_id: scope_id}})}
  end

  def close_path_for
    biomedical_concept_instances_path
  end

end
