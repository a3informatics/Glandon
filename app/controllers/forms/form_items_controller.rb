class Forms::FormItemsController < ApplicationController
  
  before_action :authenticate_user!
  
  def index
    @formItems = Form::FormItem.all
  end
  
  def new
  end
  
  def create
  end

  def update
  end

  def edit
  end

  def destroy
  end

  def show 
    @form = Form.find(params[:formId], params[:namespace])
    @formGroup = @form.groups[params[:groupId]]
    @formItem = @formGroup.items[params[:id]]
  end
  
private
  def the_params
    params.require(:form_item_group).permit(:formId, :groupId, :namespace)
  end  
end
