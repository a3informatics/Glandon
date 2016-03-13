class FormsController < ApplicationController
  
  before_action :authenticate_user!
  
  C_CLASS_NAME = "FormsController"

  #def new
  #  @form = Form.new
  #  @termList = []
  #  terms = Thesaurus.unique
  #  terms.each do |identifier|
  #    history = Thesaurus.history(identifier)
  #    history.each do |term|
  #      if term.latest?
  #        @termList << [term.label, term.id + "|" + term.namespace]
  #      end
  #    end
  #  end
  #end

  def new
    @form = Form.new
  end

  def index
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
    @identifier = params[:identifier]
    @form = Form.history(params)
  end

  def placeholder_new
    @form = Form.new
  end
  
  def bc_normal_new
    ConsoleLogger::log(C_CLASS_NAME,"bc_normal_new", "******Entry*****")
    @bcs = BiomedicalConcept.all
    @form = Form.new
  end
  
  #def create
  #  @form = Form.createFull(params[:form])
  #  if @form.errors.empty?
  #    render :nothing => true, :status => 200, :content_type => 'text/html'
  #  else
  #    render :json => { :errors => @form.errors.full_messages}, :status => 422
  #  end
  #end

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
  
  def edit
    ns = params[:namespace]
    id = params[:id]
    @form = Form.find(id, ns)
  end

  def create
    @form = Form.create(params)
    if @form.errors.empty?
      render :json => { :data => @form.to_edit}, :status => 200
    else
      render :json => { :errors => @form.errors.full_messages}, :status => 422
    end
  end

  def update
    @form = Form.update(params)
    if @form.errors.empty?
      render :json => { :data => @form.to_edit}, :status => 200
    else
      render :json => { :errors => @form.errors.full_messages}, :status => 422
    end
  end

  def destroy
    id = params[:id]
    namespace = params[:namespace]
    form = Form.find(id, namespace)
    form.destroy
    redirect_to forms_path
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
