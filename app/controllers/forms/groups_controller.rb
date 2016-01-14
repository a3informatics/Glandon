class Forms::GroupsController < ApplicationController
  
  before_action :authenticate_user!
  
  def index
    @formGroups = Form::Group.all
  end
  
  def show 
    @form = Form.find(params[:formId], params[:namespace], false)
    #@formGroup = @form.groups[params[:id]]
    @formGroup = Form::Group.find(params[:id], params[:namespace])
  end
  
private
  def the_params
    params.require(:form_form_group).permit(:formId, :namespace)
  end  
end
