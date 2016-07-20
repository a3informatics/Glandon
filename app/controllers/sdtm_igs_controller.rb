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
    @sdtm_igs = SdtmIg.all
  end
  
  def import
    authorize SdtmIg
    hash = SdtmIg.import(this_params)
    @sdtm_ig = hash[:object]
    @job = hash[:job]
    if @sdtm_ig.errors.empty?
      redirect_to backgrounds_path
    else
      flash[:error] = @sdtm_ig.errors.full_messages.to_sentence
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
  
def export_ttl
    authorize SdtmIg
    id = params[:id]
    namespace = params[:namespace]
    @sdtm_ig = IsoManaged::find(id, namespace)
    send_data to_turtle(@sdtm_ig.triples), filename: "#{@sdtm_ig.owner}_#{@sdtm_ig.identifier}.ttl", type: 'application/x-turtle', disposition: 'inline'
  end
  
  def export_json
    authorize SdtmIg
    id = params[:id]
    namespace = params[:namespace]
    @sdtm_ig = SdtmIg.find(id, namespace)
    send_data @sdtm_ig.to_json, filename: "#{@sdtm_ig.owner}_#{@sdtm_ig.identifier}.json", :type => 'application/json; header=present', disposition: "attachment"
  end

private
  
  def this_params
    params.require(:sdtm_ig).permit(:version, :version_label, :date, :model_uri, :files => [] )
  end  

end
