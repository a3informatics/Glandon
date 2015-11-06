class SdtmigsController < ApplicationController
  
  before_action :authenticate_user!
  
  def index
    @sdtmigs = Sdtmig.all
  end
  
  def new
    @files = Dir.glob(Rails.root.join("public","upload") + "*")
    @sdtmig = Sdtmig.new
  end
  
  def create
    @sdtmig = Sdtmig.create(this_params)
    redirect_to sdtmigs_path
  end

  def update
  end

  def edit
  end
  
  def destroy
  end

  def show
    id = params[:id]
    namespace = CGI::unescape(params[:namespace])
    @sdtmig = Sdtmig.find(id, namespace)
  end
  
private
  def this_params
    params.require(:sdtmig).permit({:files => []}, :version, )
  end

end
