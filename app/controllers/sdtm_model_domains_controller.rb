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
  
end
