class Forms::GroupsController < ApplicationController
  
  before_action :authenticate_user!
  
  def index
    authorize Forms::Group
    @formGroups = Form::Group.all
  end
  
  def show 
    authorize Forms::Group
    @form = Form.find(params[:formId], params[:namespace], false)
    @formGroup = Form::Group.find(params[:id], params[:namespace])
  end
  
private
  def the_params
    params.require(:form_form_group).permit(:formId, :namespace)
  end  
end
