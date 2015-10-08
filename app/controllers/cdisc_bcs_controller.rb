class CdiscBcsController < ApplicationController
  
  before_action :authenticate_user!
  
  def index
    @cdiscBcs = CdiscBc.all
  end
  
  def new
  end
  
  def create
  end

  def update
  end

  def edit
  end

  def destroy
  end

  def show 
    @cdiscTerm = CdiscTerm.current
    @cdiscBc = CdiscBc.find(params[:id], @cdiscTerm)
  end
  
private
  def the_params
    params.require(:cdisc_bc).permit(:scopedIdentifierId)
  end  
end
