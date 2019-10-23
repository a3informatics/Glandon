class IsoManagedV2Controller < ApplicationController

  before_action :authenticate_and_authorized

  C_CLASS_NAME = self.class.to_s

  # def update
  #   authorize IsoManaged
  #   managed_item = IsoManaged.find(params[:id], this_params[:namespace], false)
  #   managed_item.update(this_params)
  #   redirect_to this_params[:referer]
  # end

  def status
    @managed_item = IsoManagedV2.find_minimum(params[:id])
    @current_id = this_params[:current_id]
    @referer = request.referer
    @close_path = TypePathManagement.history_url_v2(@managed_item)
  end

private

  def this_params
    # Strong parameter using iso_managed not V2 version.
    params.require(:iso_managed).permit(:identifier, :scope_id, :change_description, :explanatory_comment, :origin, :referer, :current_id)
  end

  def authenticate_and_authorized
    authenticate_user!
    authorize IsoManaged # Note using old class, not V2, saves creating new defs
  end

end
