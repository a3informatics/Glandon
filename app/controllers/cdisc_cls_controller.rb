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
    ns = params[:namespace]
    id = params[:id]
    @cdiscCl = CdiscCl.find(id, ns)
    @cdiscClis = CdiscCli.allForCl(id, ns)
  end
  
  private
    def this_params
      params.require(:cdisc_term).permit(:id, :namespace)
    end

end
