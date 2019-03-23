class SdtmModelDomainsController < ApplicationController
  
  before_action :authenticate_user!
  
  C_CLASS_NAME = "SdtmModelDomainsController"
  
  #def history
  #  authorize SdtmModelDomain
  #  @history = SdtmDomainModel.history()
  #end
  
  def show
    authorize SdtmModelDomain
    @variables = Array.new
    @sdtm_model_domain = SdtmModelDomain.find(params[:id], the_params[:namespace])
    @sdtm_model_domain.children.each do |child|
      @variables << SdtmModel::Variable.find(child.variable_ref.subject_ref.id, child.variable_ref.subject_ref.namespace)
    end
  end

  def export_ttl
    authorize SdtmModelDomain
    @sdtm_model_domain = IsoManaged::find(params[:id], the_params[:namespace])
    send_data to_turtle(@sdtm_model_domain.triples), filename: "#{@sdtm_model_domain.owner_short_name}_#{@sdtm_model_domain.identifier}.ttl", type: 'application/x-turtle', disposition: 'inline'
  end
  
  def export_json
    authorize SdtmModelDomain
    @sdtm_model_domain = SdtmModelDomain.find(params[:id], the_params[:namespace])
    send_data @sdtm_model_domain.to_json.to_json, filename: "#{@sdtm_model_domain.owner_short_name}_#{@sdtm_model_domain.identifier}.json", :type => 'application/json; header=present', disposition: "attachment"
  end

private
  
  def the_params
    params.require(:sdtm_model_domain).permit(:namespace)
  end  
  
end
