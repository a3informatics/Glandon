class SdtmModelsController < ApplicationController
  
  before_action :authenticate_user!
  
  C_CLASS_NAME = "SdtmModelsController"
  
  def history
    authorize SdtmModel
    @history = SdtmModel.history()
  end
  
  def import
    authorize SdtmModel
    @files = Dir.glob(Rails.root.join("public","upload") + "*")
    @sdtm_class_model = SdtmModel.new
  end
  
  def create
    authorize SdtmModel, :import?
    hash = SdtmModel.import(the_params)
    @sdtm_model = hash[:object]
    @job = hash[:job]
    if @sdtm_model.errors.empty?
      redirect_to backgrounds_path
    else
      flash[:error] = @sdtm_model.errors.full_messages.to_sentence
      redirect_to history_sdtm_models_path
    end
  end
  
  def show
    authorize SdtmModel
    @sdtm_model_classes = Array.new
    @sdtm_model = SdtmModel.find(params[:id], the_params[:namespace])
    @sdtm_model.class_refs.each do |class_ref|
      @sdtm_model_classes << IsoManaged.find(class_ref.subject_ref.id, class_ref.subject_ref.namespace, false)
    end
  end

  def export_ttl
    authorize SdtmModel
    @sdtm_model = IsoManaged::find(params[:id], the_params[:namespace])
    send_data to_turtle(@sdtm_model.triples), filename: "#{@sdtm_model.owner}_#{@sdtm_model.identifier}.ttl", type: 'application/x-turtle', disposition: 'inline'
  end
  
  def export_json
    authorize SdtmModel
    @sdtm_model = IsoManaged::find(params[:id], the_params[:namespace])
    send_data @sdtm_model.to_json, filename: "#{@sdtm_model.owner}_#{@sdtm_model.identifier}.json", :type => 'application/json; header=present', disposition: "attachment"
  end

private
  
  def the_params
    params.require(:sdtm_model).permit(:namespace, :version, :version_label, :date, :files => [] )
  end  

end
