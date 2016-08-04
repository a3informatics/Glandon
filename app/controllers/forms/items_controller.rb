class Forms::ItemsController < ApplicationController
  
  before_action :authenticate_user!
  
  def index
    authorize Form::Item
    @formItems = Form::Item.all
  end
  
  def show 
    authorize Form::Item
    @form = Form.find(params[:formId], params[:namespace], false)
    @formItem = Form::Item.find(params[:id], params[:namespace])
    @property = @formItem.bc_property
    @tcs = @formItem.thesaurus_concepts
  end
  
private

  def the_params
    params.require(:form_item_group).permit(:formId, :groupId, :namespace)
  end  

end
