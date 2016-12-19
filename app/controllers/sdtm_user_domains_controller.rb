class SdtmUserDomainsController < ApplicationController
  
  before_action :authenticate_user!
  
  C_CLASS_NAME = "SdtmUserDomainsController"
  
  def index
    authorize SdtmUserDomain
    @sdtm_user_domains = SdtmUserDomain.unique
    respond_to do |format|
      format.html 
      format.json do
        results = {}
        results[:data] = []
         @sdtm_user_domains.each do |item|
          results[:data] << item
        end
        render json: results
      end
    end
  end

  def history
    authorize SdtmUserDomain
    @identifier = params[:identifier]
    @history = SdtmUserDomain.history(params)
    redirect_to sdtm_user_domains_path if @history.count == 0
  end
  
  def show
    authorize SdtmUserDomain
    id = params[:id]
    namespace = params[:namespace]
    @ig_variables = Array.new
    @bcs = Array.new
    @sdtm_user_domain = SdtmUserDomain.find(id, namespace)
    #ConsoleLogger::log(C_CLASS_NAME,"show","Domain=#{@sdtm_user_domain.to_json}")
    @sdtm_user_domain.children.each do |child|
      if child.variable_ref.nil? 
        ig_variable = SdtmIgDomain::Variable.new
      else
        ig_variable = SdtmIgDomain::Variable.find(child.variable_ref.subject_ref.id, child.variable_ref.subject_ref.namespace)
      end
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
    #ConsoleLogger::log(C_CLASS_NAME,"edit","Domain=#{@sdtm_user_domain.to_json}")
    if @sdtm_user_domain.children.length > 0
      variable = @sdtm_user_domain.children[0]   
      @datatypes = SdtmModelDatatype.all(variable.datatype.namespace)
      @classifications = SdtmModelClassification.all(variable.classification.namespace)
      @compliance = @sdtm_user_domain.compliance
    else
      @datatypes = Array.new
      @classifications = Array.new
      @compliance = Array.new
    end
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
      if @sdtm_user_domain.children.length > 0
        variable = @sdtm_user_domain.children[0]   
        @datatypes = SdtmModelDatatype.all(variable.datatype.namespace)
        @classifications = SdtmModelClassification.all(variable.classification.namespace)
        @compliance = sdtm_ig_domain.compliance
      else
        @datatypes = Array.new
        @classifications = Array.new
        @compliance = Array.new
      end
      #ConsoleLogger::log(C_CLASS_NAME,"clone","Datatypes=#{@datatypes.to_json}")
      #ConsoleLogger::log(C_CLASS_NAME,"clone","Compliance=#{@compliance.to_json}")
      #ConsoleLogger::log(C_CLASS_NAME,"clone","Classifications=#{@classifications.to_json}")    
    else
      # Do nothing at the present time. Can only clone from IG.
    end
  end
  
  def export_ttl
    authorize SdtmUserDomain
    id = params[:id]
    namespace = params[:namespace]
    @sdtm_user_domain = IsoManaged::find(id, namespace)
    send_data to_turtle(@sdtm_user_domain.triples), filename: "#{@sdtm_user_domain.owner}_#{@sdtm_user_domain.identifier}.ttl", type: 'application/x-turtle', disposition: 'inline'
  end
  
  def export_json
    authorize SdtmUserDomain
    id = params[:id]
    namespace = params[:namespace]
    @sdtm_user_domain = SdtmUserDomain.find(id, namespace)
    send_data @sdtm_user_domain.to_json, filename: "#{@sdtm_user_domain.owner}_#{@sdtm_user_domain.identifier}.json", :type => 'application/json; header=present', disposition: "attachment"
  end

  def full_report
    authorize SdtmUserDomain, :view?
    domain = SdtmUserDomain.find(params[:id], params[:namespace])
    pdf = domain.report({:full => true}, current_user)
    send_data pdf, filename: "#{domain.owner}_#{domain.identifier}_Domain.pdf", type: 'application/pdf', disposition: 'inline'
  end

  def the_params
    params.require(:sdtm_user_domain).permit(:namespace, :bcs => [])
  end  

end
