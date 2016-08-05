class SdtmIgDomainsController < ApplicationController
  
  before_action :authenticate_user!
  
  C_CLASS_NAME = "SdtmIgDomainsController"
  
  def history
    authorize SdtmIgDomain
    @history = SdtmIgDomain.history()
  end
  
  def show
    authorize SdtmIgDomain
    id = params[:id]
    namespace = params[:namespace]
    @variables = Array.new
    @sdtm_ig_domain = SdtmIgDomain.find(id, namespace)
    @sdtm_ig_domain.children.each do |child|
      class_variable = SdtmModelDomain::Variable.find(child.variable_ref.subject_ref.id, child.variable_ref.subject_ref.namespace)
      model_variable = SdtmModel::Variable.find(class_variable.variable_ref.subject_ref.id, class_variable.variable_ref.subject_ref.namespace)
      @variables << model_variable
    end
  end

  def export_ttl
    authorize SdtmIgDomain
    id = params[:id]
    namespace = params[:namespace]
    @sdtm_ig_domain = IsoManaged::find(id, namespace)
    send_data to_turtle(@sdtm_ig_domain.triples), filename: "#{@sdtm_ig_domain.owner}_#{@sdtm_ig_domain.identifier}.ttl", type: 'application/x-turtle', disposition: 'inline'
  end
  
  def export_json
    authorize SdtmIgDomain
    id = params[:id]
    namespace = params[:namespace]
    @sdtm_ig_domain = SdtmIgDomain.find(id, namespace)
    send_data @sdtm_ig_domain.to_json, filename: "#{@sdtm_ig_domain.owner}_#{@sdtm_ig_domain.identifier}.json", :type => 'application/json; header=present', disposition: "attachment"
  end
  
end
