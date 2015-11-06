class StandardsController < ApplicationController
  
  before_action :authenticate_user!
  
  def index
    @standards = Standard.all
  end
  
  def new
    @standard = Standard.new
  end
  
  def create
    @standard = Standard.create(this_params)
    redirect_to cdisc_sdtm_igs_path
  end

  def update
  end

  def edit
  end
  
  def destroy
  end

  def show
    id = params[:id]
    @standard = Standard.find(id)
  end
  
private
  def this_params
    params.require(:standard).permit()
  end

end
