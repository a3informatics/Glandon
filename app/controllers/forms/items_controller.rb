class Forms::ItemsController < ApplicationController
  
  before_action :authenticate_user!
  
  def index
    @formItems = Form::Item.all
  end
  
  def show 
    @form = Form.find(params[:formId], params[:namespace])
    #@formGroup = @form.groups[params[:groupId]]
    #@formItem = @formGroup.items[params[:id]]
    @form = Form.find(params[:formId], params[:namespace], false)
    @formGroup = Form::Group.find(params[:groupId], params[:namespace])
    @formItem = @formGroup.items[params[:id]]
  end
  
private
  def the_params
    params.require(:form_item_group).permit(:formId, :groupId, :namespace)
  end  
end
