class SdtmModelsController < ApplicationController
  
  before_action :authenticate_user!
  
  C_CLASS_NAME = "SdtmModelsController"
  
  def history
    authorize SdtmModel
    @history = SdtmModel.history()
  end
  
  def import_file
    authorize SdtmModel
    @files = Dir.glob(Rails.root.join("public","upload") + "*")
    @sdtm_class_model = SdtmModel.new
  end
  
  def import
    authorize SdtmModel
    hash = SdtmModel.import(this_params)
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
    id = params[:id]
    namespace = params[:namespace]
    @sdtm_model_classes = Array.new
    @sdtm_model = SdtmModel.find(id, namespace)
    @sdtm_model.class_refs.each do |class_ref|
      @sdtm_model_classes << IsoManaged.find(class_ref.subject_ref.id, class_ref.subject_ref.namespace, false)
    end
  end

  def export_ttl
    authorize SdtmModel
    id = params[:id]
    namespace = params[:namespace]
    @sdtm_model = IsoManaged::find(id, namespace)
    send_data to_turtle(@sdtm_model.triples), filename: "#{@sdtm_model.owner}_#{@sdtm_model.identifier}.ttl", type: 'application/x-turtle', disposition: 'inline'
  end
  
  def export_json
    authorize SdtmModel
    id = params[:id]
    namespace = params[:namespace]
    @sdtm_model = SdtmModel.find(id, namespace)
    send_data @sdtm_model.to_json, filename: "#{@sdtm_model.owner}_#{@sdtm_model.identifier}.json", :type => 'application/json; header=present', disposition: "attachment"
  end

private
  
  def this_params
    params.require(:sdtm_model).permit(:version, :version_label, :date, :files => [] )
  end  

end
