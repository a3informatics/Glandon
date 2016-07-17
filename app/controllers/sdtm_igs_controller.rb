class SdtmIgsController < ApplicationController
  
  before_action :authenticate_user!
  
  def history
    authorize SdtmIg
    @history = SdtmIg.history()
  end
  
  def import_file
    authorize SdtmIg
    @files = Dir.glob(Rails.root.join("public","upload") + "*")
    @sdtm_ig = SdtmIg.new
    @sdtm_models = SdtmModel.all
  end
  
  def import
    authorize SdtmIg
    hash = SdtmIg.import(this_params)
    @sdtm_model = hash[:object]
    @job = hash[:job]
    if @sdtm_model.errors.empty?
      redirect_to backgrounds_path
    else
      flash[:error] = @sdtm_model.errors.full_messages.to_sentence
      redirect_to history_sdtm_igs_path
    end
  end
  
  def show
    authorize SdtmIg
    @sdtm_ig_domains = Array.new
    id = params[:id]
    namespace = params[:namespace]
    @sdtm_ig = SdtmIg.find(id, namespace)
    @sdtm_ig.domain_refs.each do |op_ref|
      @sdtm_ig_domains << IsoManaged.find(op_ref.subject_ref.id, op_ref.subject_ref.namespace, false)
    end
  end
  
private
  
  def this_params
    params.require(:sdtm_ig).permit(:version, :version_label, :date, :model_uri, :files => [] )
  end  

end
