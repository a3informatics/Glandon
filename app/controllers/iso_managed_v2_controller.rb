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
    @managed_item = IsoManagedV2.find_minimum(params[:id])
    @current_id = the_params[:current_id]
    @next_versions = SemanticVersion.from_s(@managed_item.semantic_version.to_s).next_versions
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
    # referer = request.referer
    @managed_item = IsoManagedV2.find_minimum(params[:id])
    # @next_versions = SemanticVersion.from_s(@managed_item.semantic_version.to_s).next_versions
    @managed_item.release(the_params[:sv_type].downcase.to_s)
    # flash[:error] = @managed_item.errors.full_messages.to_sentence if !@managed_item.errors.empty?
    # redirect_to referer
    render json: {data: " ", error: "Error: "}, status: 200
  end

  def find_by_tag
    authorize IsoManaged, :show?
    render json: {data: IsoManagedV2.find_by_tag(the_params[:tag_id])}, status: 200
  end
    
private

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
