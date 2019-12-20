class IsoManagedV2Controller < ApplicationController

  before_action :authenticate_user!

  C_CLASS_NAME = self.class.to_s

  # def update
  #   authorize IsoManaged
  #   managed_item = IsoManaged.find(params[:id], this_params[:namespace], false)
  #   managed_item.update(this_params)
  #   redirect_to this_params[:referer]
  # end

  def status
    authorize IsoManaged, :status?
    @managed_item = get_item(params)
    @current_id = the_params[:current_id]
    @next_versions = SemanticVersion.from_s(@managed_item.previous_release).next_versions
    @referer = request.referer
    @close_path = TypePathManagement.history_url_v2(@managed_item, true)
  end

  def make_current
    authorize IsoManaged, :update?
    managed_item = IsoManagedV2.find_minimum(params[:id])
    clear_current(the_params[:current_id])
    managed_item.has_state.make_current
    redirect_to request.referer
  end

  def update_status
    authorize IsoManaged, :update?
    referer = request.referer
    @managed_item = IsoManagedV2.find_minimum(params[:id])
    @managed_item.update_status(the_params)
    flash[:error] = @managed_item.errors.full_messages.to_sentence if !@managed_item.errors.empty?
    redirect_to referer
  end

  def update_semantic_version
    authorize IsoManaged, :update?
    @managed_item = get_item(params)
    @managed_item.release(the_params[:sv_type].downcase.to_sym)
    status = @managed_item.errors.empty? ? 200 : 422
    render :json => { :data => @managed_item.semantic_version, :errors => @managed_item.errors.full_messages}, :status => status
  end

  def find_by_tag
    authorize IsoManaged, :show?
    render json: {data: IsoManagedV2.find_by_tag(the_params[:tag_id])}, status: 200
  end
    
private

  def get_item(params)
    uri = Uri.new(id: params[:id])
    rdf_type = IsoManagedV2.the_type(uri)
    klass = IsoManagedV2.rdf_type_to_klass(rdf_type.to_s)
    klass.find_minimum(params[:id])
  end

  def clear_current(current_id)
    return false if current_id.blank?
    current_item = IsoManagedV2.find_minimum(current_id)
    current_item.has_state.make_not_current
    true
  rescue Errors::NotFoundError => e
    false
  end

  def the_params
    # Strong parameter using iso_managed not V2 version.
    params.require(:iso_managed).permit(:current_id, :tag_id, :registration_status, :previous_state, :administrative_note, :unresolved_issue, :sv_type)
  end

end
