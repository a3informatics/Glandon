class FormsController < ApplicationController
  
  before_action :authenticate_user!
  
  C_CLASS_NAME = "FormsController"

  def index
    @forms = Form.all
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
    @form = Form.create(params[:form])
    if @form.errors.empty?
      render :nothing => true, :status => 200, :content_type => 'text/html'
    else
      render :json => { :errors => @form.errors.full_messages}, :status => 422
    end
  end

  def placeholder_create
    @form = Form.createPlaceholder(the_params)
    if @form.errors.empty?
      redirect_to forms_path
    else
      flash[:error] = @form.errors.full_messages.to_sentence
      redirect_to placeholder_new_forms_path
    end
  end
  
  def bc_normal_create
    @form = Form.createBcNormal(the_params)
    if @form.errors.empty?
      redirect_to forms_path
    else
      flash[:error] = @form.errors.full_messages.to_sentence
      redirect_to bc_normal_new_forms_path
    end
  end
  
  def update
  end

  def edit
  end

  def destroy
  end

  def show 
    @form = Form.find(params[:id], params[:namespace])
  end
  
  def view 
    @form = Form.find(params[:id], params[:namespace])
  end
  
  def acrf
    @form = Form.find(params[:id], params[:namespace])
  end

  def crf
    @form = Form.find(params[:id], params[:namespace])
  end

private
  def the_params
    params.require(:form).permit(:formId, :namespace, :freeText, :identifier, :label, :children => {}, :bcs => [])
  end  
end
