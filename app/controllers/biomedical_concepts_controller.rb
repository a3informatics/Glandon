require 'controller_helpers.rb'

class BiomedicalConceptsController < ApplicationController

  C_CLASS_NAME = "BiomedicalConceptsController"

  include ControllerHelpers

  before_action :authenticate_user!

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

  def index
    authorize BiomedicalConcept
    @bcs = BiomedicalConceptInstance.unique
    respond_to do |format|
      format.json do
        @bcs = @bcs.map{|x| x.reverse_merge!({history_path: history_biomedical_concepts_path({biomedical_concept:{identifier: x[:identifier], scope_id: x[:scope_id]}})})}
        render json: {data: @bcs}, status: 200
      end
      format.html 
    end
  end

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

  def history
    authorize BiomedicalConcept
    respond_to do |format|
      format.json do
        results = []
        history_results = BiomedicalConceptInstance.history_pagination(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]), count: the_params[:count], offset: the_params[:offset])
        current = BiomedicalConceptInstance.current_uri(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]))
        latest = BiomedicalConceptInstance.latest_uri(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]))
        results = add_history_paths(BiomedicalConcept, history_results, current, latest)
        render json: {data: results, offset: the_params[:offset].to_i, count: results.count}
      end
      format.html do
        @bc = BiomedicalConceptInstance.latest(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]))
        @identifier = the_params[:identifier]
        @scope_id = the_params[:scope_id]
        @close_path = request.referer
      end
    end
  end

  # def new
  #   authorize BiomedicalConcept, :new?
  #   @bcts = BiomedicalConceptTemplate.all
  # end

  # def create
  #   authorize BiomedicalConcept
  #   # New passes URI rather than id, namespace pair. Adjust for the simple create.
  #   # @todo may be adjust this.
  #   uri = UriV2.new({uri: the_params[:uri]})
  #   params[:biomedical_concept][:bct_id] = uri.id
  #   params[:biomedical_concept][:bct_namespace] = uri.namespace
  #   @bc = BiomedicalConcept.create_simple(the_params)
  #   if @bc.errors.empty?
  #     AuditTrail.create_item_event(current_user, @bc, "Biomedical Concept created.")
  #     respond_to do |format|
  #       format.html do
  #         flash[:success] = 'Biomedical Concept was successfully created.'
  #         redirect_to biomedical_concepts_path
  #       end
  #       format.json do
  #         render :json => { data: @bc.to_json }, :status => 200
  #       end
  #     end
  #   else
  #     respond_to do |format|
  #       format.html do
  #         flash[:error] = @bc.errors.full_messages.to_sentence
  #         redirect_to new_biomedical_concept_path
  #       end
  #       format.json do
  #         render :json => { errors: @bc.errors.full_messages }, :status => 422
  #       end
  #     end
  #   end
  # end

  # def edit
  #   authorize BiomedicalConcept
  #   @bc = BiomedicalConcept.find(params[:id], the_params[:namespace])
  #   @bcts = BiomedicalConceptTemplate.all
  #   if @bc.new_version?
  #     json = @bc.to_operation
  #     new_bc = BiomedicalConcept.create(json)
  #     @bc = BiomedicalConcept.find(new_bc.id, new_bc.namespace)
  #   end
  #   @close_path = history_biomedical_concepts_path(:biomedical_concept => { identifier: @bc.identifier, scope_id: @bc.scope.id })
  #   @token = Token.obtain(@bc, current_user)
  #   if @token.nil?
  #     flash[:error] = "The item is locked for editing by another user."
  #     redirect_to request.referer
  #   end
  # end

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


  def show
    authorize BiomedicalConcept
    @bc = BiomedicalConceptInstance.find_minimum(params[:id])
    respond_to do |format|
      format.html do
        @show_path = path_for(:show, @bc)
        @close_path = history_biomedical_concepts_path(:biomedical_concept => { identifier: @bc.has_identifier.identifier, scope_id: @bc.scope })
      end
      format.json do
        items = @bc.get_properties(true)
        render json: {data: items }, status: 200
      end
    end
  end

  # def show_references
  #   authorize BiomedicalConcept
  #   bc = BiomedicalConceptInstance.find_minimum(params[:id])
  #   render json: {data: bc.get_references}, status: 200
  # end

  # def show
  #   authorize BiomedicalConcept
  #   @bc = BiomedicalConcept.find(params[:id], the_params[:namespace])
  #   respond_to do |format|
  #     format.html do
  #       @items = @bc.get_properties(true)
  #       @references = BiomedicalConcept.get_unique_references(@items)
  #       @close_path = history_biomedical_concepts_path(:biomedical_concept => { identifier: @bc.identifier, scope_id: @bc.scope.id })
  #     end
  #     format.json do
  #       @items = @bc.get_properties(true)
  #       render json: @items
  #     end
  #   end
  # end

  # def show_full
  #   authorize BiomedicalConcept, :show?
  #   @bc = BiomedicalConcept.find(params[:id], the_params[:namespace])
  #   render json: @bc.to_json
  # end

  # def export_ttl
  #   authorize BiomedicalConcept
  #   @bc = IsoManaged.find(params[:id], the_params[:namespace])
  #   send_data to_turtle(@bc.triples), filename: "#{@bc.owner_short_name}_#{@bc.identifier}.ttl", type: 'application/x-turtle', disposition: 'inline'
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
    params.require(:biomedical_concept).permit(:namespace, :uri, :identifier, :label, :scope_id, :bc_id, :bc_namespace, :bct_id, :bct_namespace)
  end

  # Path for given action
  def path_for(action, object)
    case action
      when :show
        return biomedical_concept_path(object)
      when :edit
        return ""
      else
        return ""
    end
  end

end
