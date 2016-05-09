class FormsController < ApplicationController
  
  before_action :authenticate_user!
  
  C_CLASS_NAME = "FormsController"

  #def test
  #  authorize Form, :view?
  #  ns = params[:namespace]
  #  id = params[:id]
  #  @form = Form.find(id,ns)
  #end

  def new
    authorize Form
    @form = Form.new
  end

  def index
    authorize Form
    @forms = Form.unique
    respond_to do |format|
      format.html 
      format.json do
        results = {}
        results[:data] = []
        @forms.each do |item|
          results[:data] << item
        end
        render json: results
      end
    end
  end
  
  def history
    authorize Form
    @identifier = params[:identifier]
    @form = Form.history(params)
  end

  def placeholder_new
    authorize Form, :new?
    @form = Form.new
  end
  
  def bc_normal_new
    authorize Form, :new?
    @bcs = BiomedicalConcept.all
    @form = Form.new
  end
  
  def placeholder_create
    authorize Form, :create?
    @form = Form.createPlaceholder(the_params)
    if @form.errors.empty?
      redirect_to forms_path
    else
      flash[:error] = @form.errors.full_messages.to_sentence
      redirect_to placeholder_new_forms_path
    end
  end
  
  def bc_normal_create
    authorize Form, :create?
    @form = Form.createBcNormal(the_params)
    if @form.errors.empty?
      redirect_to forms_path
    else
      flash[:error] = @form.errors.full_messages.to_sentence
      redirect_to bc_normal_new_forms_path
    end
  end
  
  def edit
    authorize Form
    ns = params[:namespace]
    id = params[:id]
    @form = Form.find(id, ns)
  end

  def clone
    authorize Form
    ns = params[:namespace]
    id = params[:id]
    @form = Form.find(id, ns)
  end

  def create
    authorize Form
    @form = Form.create(params)
    if @form.errors.empty?
      render :json => { :data => @form.to_edit}, :status => 200
    else
      render :json => { :errors => @form.errors.full_messages}, :status => 422
    end
  end

  def update
    authorize Form
    @form = Form.update(params)
    if @form.errors.empty?
      render :json => { :data => @form.to_edit}, :status => 200
    else
      render :json => { :errors => @form.errors.full_messages}, :status => 422
    end
  end

  def destroy
    authorize Form
    id = params[:id]
    namespace = params[:namespace]
    form = Form.find(id, namespace)
    form.destroy
    redirect_to forms_path
  end

  def show 
    authorize Form
    @form = Form.find(params[:id], params[:namespace])
  end
  
  def view 
    authorize Form
    @form = Form.find(params[:id], params[:namespace])
  end
  
  def acrf
    authorize Form, :view?
    @form = Form.find(params[:id], params[:namespace])
  end

  def crf
    authorize Form, :view?
    @form = Form.find(params[:id], params[:namespace])
  end

private
  def the_params
    params.require(:form).permit(:formId, :namespace, :freeText, :identifier, :label, :children => {}, :bcs => [])
  end  
end
