class FormsController < ApplicationController
  
  before_action :authenticate_user!
  
  C_CLASS_NAME = "FormsController"

  def index
    @forms = Form.all
  end
  
  def new
  end
  
  def placeholder_new
    @form = Form.new
  end
  
  def bc_normal_new
    ConsoleLogger::log(C_CLASS_NAME,"bc_normal_new", "******Entry*****")
    @bcs = CdiscBc.all
    @form = Form.new
  end
  
  def create
  end

  def placeholder_create
    @form = Form.create_placeholder(the_params)
    redirect_to forms_path
  end
  
  def bc_normal_create
    @cdiscTerm = CdiscTerm.current()
    @form = Form.create_bc_normal(the_params, @cdiscTerm)
    redirect_to forms_path
  end
  
  def update
  end

  def edit
  end

  def destroy
  end

  def show 
    @cdiscTerm = CdiscTerm.current()
    @form = Form.find(params[:id], @cdiscTerm)
  end
  
private
  def the_params
    params.require(:form).permit(:freeText, :name, :shortName, :bcs => [])
  end  
end
