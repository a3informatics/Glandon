class FormsController < ApplicationController
  
  before_action :authenticate_user!
  
  def index
    @forms = Form.all
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
    @form = Form.find(params[:id], @cdiscTerm)
  end
  
private
  def the_params
    params.require(:form).permit(:scopedIdentifierId)
  end  
end
