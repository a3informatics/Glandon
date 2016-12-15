class Forms::GroupsController < ApplicationController
  
  before_action :authenticate_user!
  
  #def index
  #  authorize Form::Group
  #  @formGroups = Form::Group.all
  #end
  
  def show 
    authorize Form::Group
    @form = Form.find(params[:formId], params[:namespace], false)
    type = IsoConcept.get_type(params[:id], params[:namespace])
    if type.to_s == Form::Group::Normal::C_RDF_TYPE_URI.to_s
      @formGroup = Form::Group::Normal.find(params[:id], params[:namespace])
    else
      @formGroup = Form::Group::Common.find(params[:id], params[:namespace])
    end
  end
  
private
  def the_params
    params.require(:form_form_group).permit(:formId, :namespace)
  end  
end
