class SdtmUserDomainsController < ApplicationController
  
  before_action :authenticate_user!
  
  C_CLASS_NAME = "SdtmUserDomainsController"
  
  def index
    authorize SdtmUserDomain
    @sdtm_user_domains = SdtmUserDomain.unique
  end

  def history
    authorize SdtmUserDomain
    @identifier = params[:identifier]
    @history = SdtmUserDomain.history(params)
  end
  
  def show
    authorize SdtmUserDomain
    id = params[:id]
    namespace = params[:namespace]
    #@model_variables = Array.new
    @ig_variables = Array.new
    @bcs = Array.new
    @sdtm_user_domain = SdtmUserDomain.find(id, namespace)
    ConsoleLogger::log(C_CLASS_NAME,"show","Domain=#{@sdtm_user_domain.to_json}")
    @sdtm_user_domain.children.each do |child|
      ig_variable = SdtmIgDomain::Variable.find(child.variable_ref.subject_ref.id, child.variable_ref.subject_ref.namespace)
      #class_variable = SdtmModelDomain::Variable.find(ig_variable.variable_ref.subject_ref.id, ig_variable.variable_ref.subject_ref.namespace)
      #model_variable = SdtmModel::Variable.find(class_variable.variable_ref.subject_ref.id, class_variable.variable_ref.subject_ref.namespace)
      #@model_variables << model_variable
      @ig_variables << ig_variable
    end
    @sdtm_user_domain.bc_refs.each do |child|
      bc = IsoManaged.find(child.subject_ref.id, child.subject_ref.namespace, false)
      @bcs << bc
    end
  end

  def create
    authorize SdtmUserDomain
    @sdtm_user_domain = SdtmUserDomain.create(params)
    if @sdtm_user_domain.errors.empty?
      render :json => { :data => @sdtm_user_domain.to_edit}, :status => 200
    else
      render :json => { :errors => @sdtm_user_domain.errors.full_messages}, :status => 422
    end
  end

  def update
    authorize SdtmUserDomain
    @sdtm_user_domain = SdtmUserDomain.update(params)
    if @sdtm_user_domain.errors.empty?
      render :json => { :data => @sdtm_user_domain.to_edit}, :status => 200
    else
      render :json => { :errors => @sdtm_user_domain.errors.full_messages}, :status => 422
    end
  end

  def edit
    authorize SdtmUserDomain
    id = params[:id]
    namespace = params[:namespace]
    @sdtm_user_domain = SdtmUserDomain.find(id, namespace)
    ConsoleLogger::log(C_CLASS_NAME,"edit","Domain=#{@sdtm_user_domain.to_json}")
    @datatypes = SdtmModelDatatype.all(@sdtm_user_domain.model_ref.subject_ref.namespace)
    ConsoleLogger::log(C_CLASS_NAME,"edit","Domain=#{@datatypes.to_json}")
    ig_domain = IsoManaged.find(@sdtm_user_domain.ig_ref.subject_ref.id, @sdtm_user_domain.ig_ref.subject_ref.namespace, false)
  end

  def update_add
    authorize SdtmUserDomain, :edit?
    id = params[:id]
    namespace = params[:namespace]
    @SdtmUserDomain = SdtmUserDomain.find(id, namespace)
    @SdtmUserDomain.add(the_params)
    redirect_to sdtm_user_domain_path(:id => id, :namespace => namespace)
  end

  def update_remove
    authorize SdtmUserDomain, :edit?
    id = params[:id]
    namespace = params[:namespace]
    @SdtmUserDomain = SdtmUserDomain.find(id, namespace)
    @SdtmUserDomain.remove(the_params)
    redirect_to sdtm_user_domain_path(:id => id, :namespace => namespace)
  end

  def add
    authorize SdtmUserDomain, :edit?
    id = params[:id]
    namespace = params[:namespace]
    @sdtm_user_domain = SdtmUserDomain.find(id, namespace, false)
    @bcs = BiomedicalConcept.all
  end

  def remove 
    authorize SdtmUserDomain, :destroy?
    id = params[:id]
    namespace = params[:namespace]
    @bcs = Array.new
    @sdtm_user_domain = SdtmUserDomain.find(id, namespace)
    @sdtm_user_domain.bc_refs.each do |child|
      bc = IsoManaged.find(child.subject_ref.id, child.subject_ref.namespace, false)
      @bcs << bc
    end
  end

  def destroy
    authorize SdtmUserDomain
    id = params[:id]
    namespace = params[:namespace]
    sdtm_user_domain = SdtmUserDomain.find(id, namespace, false)
    sdtm_user_domain.destroy
    redirect_to sdtm_user_domains_path
  end

  def clone
    authorize SdtmUserDomain
    namespace = params[:namespace]
    id = params[:id]
    clone_type = params[:clone_type]
    if clone_type == "IG"
      sdtm_ig_domain = SdtmIgDomain.find(id, namespace)
      @sdtm_user_domain = SdtmUserDomain.upgrade(sdtm_ig_domain)
      @datatypes = SdtmModelDatatype.all(sdtm_ig_domain.model_ref.subject_ref.namespace)
    else
      #@sdtm_user_domain = SdtmUserDomain.find(id, namespace)
      #@datatypes = SdtmModelDatatype.all(sdtm_ig_domain.namespace)
    end
  end
  
  def export_ttl
    authorize Form
    id = params[:id]
    namespace = params[:namespace]
    @sdtm_user_domain = IsoManaged::find(id, namespace)
    send_data to_turtle(@sdtm_user_domain.triples), filename: "#{@sdtm_user_domain.owner}_#{@sdtm_user_domain.identifier}.ttl", type: 'application/x-turtle', disposition: 'inline'
  end
  
  def export_json
    authorize Form
    id = params[:id]
    namespace = params[:namespace]
    @sdtm_user_domain = SdtmUserDomain.find(id, namespace)
    send_data @sdtm_user_domain.to_json, filename: "#{@sdtm_user_domain.owner}_#{@sdtm_user_domain.identifier}.json", :type => 'application/json; header=present', disposition: "attachment"
  end

  def the_params
    params.require(:sdtm_user_domain).permit(:namespace, :bcs => [])
  end  

end
