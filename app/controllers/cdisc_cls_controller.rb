class CdiscClsController < ApplicationController
  
  before_action :authenticate_user!
  
  def index
    @cdiscCls = CdiscCl.all
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
    id = params[:id]
    termId = params[:termId]
    @cdiscTerm = CdiscTerm.find(params[:termId])
    @cdiscCl = CdiscCl.find(id, @cdiscTerm)
    @cdiscClis = CdiscCli.allForCl(id, @cdiscTerm)
  end
  
  private
    def this_params
      params.require(:cdisc_term).permit(:id, :termId)
    end

end
