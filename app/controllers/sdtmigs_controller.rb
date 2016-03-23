class SdtmigsController < ApplicationController
  
  before_action :authenticate_user!
  
  def index
    authorize Sdtmig
    @sdtmigs = Sdtmig.all
  end
  
  def new
    authorize Sdtmig
    @files = Dir.glob(Rails.root.join("public","upload") + "*")
    @sdtmig = Sdtmig.new
  end
  
  def create
    authorize Sdtmig
    @sdtmig = Sdtmig.create(this_params)
    redirect_to sdtmigs_path
  end

  def show
    authorize Sdtmig
    id = params[:id]
    namespace = CGI::unescape(params[:namespace])
    @sdtmig = Sdtmig.find(id, namespace)
  end
  
private
  def this_params
    params.require(:sdtmig).permit({:files => []}, :versionLabel, )
  end

end
