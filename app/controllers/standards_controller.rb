class StandardsController < ApplicationController
  
  before_action :authenticate_user!
  
  def index
    authorize Standard
    @standards = Standard.all
  end
  
  def new
    authorize Standard
    @standard = Standard.new
  end
  
  def create
    authorize Standard
    @standard = Standard.create(this_params)
    redirect_to cdisc_sdtm_igs_path
  end

  def show
    authorize Standard
    id = params[:id]
    @standard = Standard.find(id)
  end
  
private
  def this_params
    params.require(:standard).permit()
  end

end
