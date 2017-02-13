class SdtmIgDomainsController < ApplicationController
  
  before_action :authenticate_user!
  
  C_CLASS_NAME = "SdtmIgDomainsController"
  
  #def history
  #  authorize SdtmIgDomain
  #  @history = SdtmIgDomain.history()
  #end
  
  def show
    authorize SdtmIgDomain
    @variables = Array.new
    @sdtm_ig_domain = SdtmIgDomain.find(params[:id], the_params[:namespace])
    @sdtm_ig_domain.children.each do |child|
      # TODO Not every IG domain is linked yet. Check if references present
      if !child.variable_ref.nil?
        class_variable = SdtmModelDomain::Variable.find(child.variable_ref.subject_ref.id, child.variable_ref.subject_ref.namespace)
        model_variable = SdtmModel::Variable.find(class_variable.variable_ref.subject_ref.id, class_variable.variable_ref.subject_ref.namespace)
      else
        model_variable = SdtmModel::Variable.new
      end
      @variables << model_variable
    end
  end

  def export_ttl
    authorize SdtmIgDomain
    @sdtm_ig_domain = IsoManaged::find(params[:id], the_params[:namespace])
    send_data to_turtle(@sdtm_ig_domain.triples), filename: "#{@sdtm_ig_domain.owner}_#{@sdtm_ig_domain.identifier}.ttl", type: 'application/x-turtle', disposition: 'inline'
  end
  
  def export_json
    authorize SdtmIgDomain
    @sdtm_ig_domain = SdtmIgDomain.find(params[:id], the_params[:namespace])
    send_data @sdtm_ig_domain.to_json.to_json, filename: "#{@sdtm_ig_domain.owner}_#{@sdtm_ig_domain.identifier}.json", :type => 'application/json; header=present', disposition: "attachment"
  end
  
private
  
  def the_params
    params.require(:sdtm_ig_domain).permit(:namespace)
  end  

end
