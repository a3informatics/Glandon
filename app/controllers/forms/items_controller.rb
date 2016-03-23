class Forms::ItemsController < ApplicationController
  
  before_action :authenticate_user!
  
  def index
    authorize Forms::Item
    @formItems = Form::Item.all
  end
  
  def show 
    authorize Forms::Item
    @form = Form.find(params[:formId], params[:namespace], false)
    @formGroup = Form::Group.find(params[:groupId], params[:namespace])
    @formItem = @formGroup.items[params[:id]]
  end
  
private
  def the_params
    params.require(:form_item_group).permit(:formId, :groupId, :namespace)
  end  
end
