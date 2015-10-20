class Forms::FormGroupsController < ApplicationController
  
  before_action :authenticate_user!
  
  def index
    @formGroups = Form::FormGroup.all
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
    @formGroup = @form.groups[params[:id]]
  end
  
private
  def the_params
    params.require(:form_form_group).permit(:form_id)
  end  
end
