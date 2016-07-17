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
  
end
