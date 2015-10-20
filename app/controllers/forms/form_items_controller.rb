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
    @cdiscTerm = CdiscTerm.current
    @form = Form.find(params[:form_id], @cdiscTerm)
    @formGroup = @form.groups[params[:group_id]]
    @formItem = @formGroup.items[params[:id]]
  end
  
private
  def the_params
    params.require(:form_item_group).permit(:form_id, :group_id)
  end  
end
