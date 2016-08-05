class SdtmModelDomainsController < ApplicationController
  
  before_action :authenticate_user!
  
  C_CLASS_NAME = "SdtmModelDomainsController"
  
  def history
    authorize SdtmModelDomain
    @history = SdtmDomainModel.history()
  end
  
  def show
    authorize SdtmModelDomain
    id = params[:id]
    namespace = params[:namespace]
    @variables = Array.new
    @sdtm_model_domain = SdtmModelDomain.find(id, namespace)
    @sdtm_model_domain.children.each do |child|
      variable = SdtmModel::Variable.find(child.variable_ref.subject_ref.id, child.variable_ref.subject_ref.namespace)
      @variables << variable
    end
  end

  def export_ttl
    authorize SdtmModelDomain
    id = params[:id]
    namespace = params[:namespace]
    @sdtm_model_domain = IsoManaged::find(id, namespace)
    send_data to_turtle(@sdtm_model_domain.triples), filename: "#{@sdtm_model_domain.owner}_#{@sdtm_model_domain.identifier}.ttl", type: 'application/x-turtle', disposition: 'inline'
  end
  
  def export_json
    authorize SdtmModelDomain
    id = params[:id]
    namespace = params[:namespace]
    @sdtm_model_domain = SdtmModelDomain.find(id, namespace)
    send_data @sdtm_model_domain.to_json, filename: "#{@sdtm_model_domain.owner}_#{@sdtm_model_domain.identifier}.json", :type => 'application/json; header=present', disposition: "attachment"
  end
  
end
