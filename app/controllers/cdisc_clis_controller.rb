class CdiscClisController < ApplicationController
  
  before_action :authenticate_user!
  
  def index
    @cdiscClis = CdiscCli.all
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
    @cdiscCli = CdiscCli.find(id, ns)
  end
  
  private
    def this_params
      params.require(:cdisc_term).permit({:files => []}, :version, :date, :thesaurus_id)
    end

end
