class SdtmUserDomainsController < ApplicationController
  
  before_action :authenticate_user!
  
  C_CLASS_NAME = "SdtmUserDomainsController"
  
  def index
    authorize SdtmUserDomain
    @sdtm_user_domains = SdtmUserDomain.unique
    respond_to do |format|
      format.html 
      format.json do
        results = {:data => @sdtm_user_domains}
        render json: results
      end
    end
  end

  def history
    authorize SdtmUserDomain
    @identifier = the_params[:identifier]
    @history = SdtmUserDomain.history(the_params)
    redirect_to sdtm_user_domains_path if @history.count == 0
  end
  
  def show
    authorize SdtmUserDomain
    @ig_variables = Array.new
    @bcs = Array.new
    @sdtm_user_domain = SdtmUserDomain.find(params[:id], the_params[:namespace])
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

  def clone_ig
    authorize SdtmUserDomain, :clone?
    @sdtm_ig_domain = SdtmIgDomain.find(the_params[:sdtm_ig_domain_id], the_params[:sdtm_ig_domain_namespace])
  end

  def clone_ig_create
    authorize SdtmUserDomain, :clone?
    @sdtm_ig_domain = SdtmIgDomain.find(the_params[:sdtm_ig_domain_id], the_params[:sdtm_ig_domain_namespace])
    @sdtm_user_domain = SdtmUserDomain.create_clone_ig(the_params, @sdtm_ig_domain)
    if @sdtm_user_domain.errors.empty?
      AuditTrail.create_item_event(current_user, @sdtm_user_domain, "SDTM Sponsor Domain cloned from #{@sdtm_ig_domain.identifier}.")
      flash[:success] = 'SDTM Sponsor Domain was successfully created.'
      redirect_to sdtm_user_domains_path
    else
      flash[:error] = @sdtm_user_domain.errors.full_messages.to_sentence
      redirect_to clone_ig_sdtm_user_domains_path(:id => the_params[:sdtm_ig_domain_id], :namespace => the_params[:sdtm_ig_domain_namespace])
    end
  end
  
  #def create
  #  authorize SdtmUserDomain
  #  @sdtm_user_domain = SdtmUserDomain.create(params)
  #  if @sdtm_user_domain.errors.empty?
  #    render :json => { :data => @sdtm_user_domain.to_edit}, :status => 200
  #  else
  #    render :json => { :errors => @sdtm_user_domain.errors.full_messages}, :status => 422
  #  end
  #end

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
    @sdtm_user_domain = SdtmUserDomain.find(params[:id], the_params[:namespace])
    if @sdtm_user_domain.new_version?
      json = @sdtm_user_domain.to_operation
      new_domain = SdtmUserDomain.create(json)
      @sdtm_user_domain = SdtmUserDomain.find(new_domain.id, new_domain.namespace)
    end
    @close_path = history_biomedical_concepts_path(identifier: @bc.identifier, scope_id: @bc.owner_id)
    @token = Token.obtain(@sdtm_user_domain, current_user)
    if @token.nil?
      flash[:error] = "The item is locked for editing by another user."
      redirect_to request.referer
    end
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

  def add
    authorize SdtmUserDomain, :edit?
    @sdtm_user_domain = SdtmUserDomain.find(params[:id], the_params[:namespace], false)
    @token = Token.obtain(@sdtm_user_domain, current_user)
    if @token.nil?
      flash[:error] = "The item is locked for editing by another user."
      redirect_to request.referer
    end
    @bcs = BiomedicalConcept.all
  end

  def update_add
    authorize SdtmUserDomain, :edit?
    @sdtm_user_domain = SdtmUserDomain.find(params[:id], the_params[:namespace])
    token = Token.find_token(@sdtm_user_domain, current_user)
    if !token.nil?
      @sdtm_user_domain.add(the_params)
      AuditTrail.update_item_event(current_user, @sdtm_user_domain, "SDTM Sponsor Domain updated.")
      token.release
    else
      flash[:error] = "The item is locked for editing by another user."
    end
    redirect_to sdtm_user_domain_path(:id => params[:id], :sdtm_user_domain => { :namespace => the_params[:namespace] })
  end

  def remove 
    authorize SdtmUserDomain, :edit?
    @sdtm_user_domain = SdtmUserDomain.find(params[:id], the_params[:namespace])
    @token = Token.obtain(@sdtm_user_domain, current_user)
    if @token.nil?
      flash[:error] = "The item is locked for editing by another user."
      redirect_to request.referer
    end
    @bcs = []
    @sdtm_user_domain.bc_refs.each do |child|
      @bcs << IsoManaged.find(child.subject_ref.id, child.subject_ref.namespace, false)
    end
  end

  def update_remove
    authorize SdtmUserDomain, :edit?
    @sdtm_user_domain = SdtmUserDomain.find(params[:id], the_params[:namespace])
    token = Token.find_token(@sdtm_user_domain, current_user)
    if !token.nil?
      @sdtm_user_domain.remove(the_params)
      AuditTrail.update_item_event(current_user, @sdtm_user_domain, "SDTM Sponsor Domain updated.")
      token.release
    else
      flash[:error] = "The item is locked for editing by another user."
    end
    redirect_to sdtm_user_domain_path(:id => params[:id], :sdtm_user_domain => { :namespace => the_params[:namespace] })
  end

  def destroy
    authorize SdtmUserDomain
    sdtm_user_domain = SdtmUserDomain.find(params[:id], the_params[:namespace], false)
    token = Token.obtain(sdtm_user_domain, current_user)
    if !token.nil?
      sdtm_user_domain.destroy
      AuditTrail.delete_item_event(current_user, sdtm_user_domain, "SDTM Sponsor Domain deleted.")
      token.release
    else
      flash[:error] = "The item is locked for editing by another user."
    end
    redirect_to request.referer
  end

  def export_ttl
    authorize SdtmUserDomain
    @sdtm_user_domain = IsoManaged::find(params[:id], the_params[:namespace])
    send_data to_turtle(@sdtm_user_domain.triples), 
      filename: "#{@sdtm_user_domain.owner}_#{@sdtm_user_domain.identifier}.ttl", type: 'application/x-turtle', disposition: 'inline'
  end
  
  def export_json
    authorize SdtmUserDomain
    @sdtm_user_domain = SdtmUserDomain.find(params[:id], the_params[:namespace])
    send_data @sdtm_user_domain.to_json, 
      filename: "#{@sdtm_user_domain.owner}_#{@sdtm_user_domain.identifier}.json", :type => 'application/json; header=present', disposition: "attachment"
  end

  def full_report
    authorize SdtmUserDomain, :view?
    domain = SdtmUserDomain.find(params[:id], the_params[:namespace])
    respond_to do |format|
      format.pdf do
        @html = Reports::DomainReport.new.create(domain, {}, current_user)
        render pdf: "#{domain.owner}_#{domain.identifier}.pdf", page_size: current_user.paper_size
      end
    end
  end

private

  def the_params
    params.require(:sdtm_user_domain).permit(:namespace, :identifier, :scope_id, :sdtm_ig_domain_id, :sdtm_ig_domain_namespace, :label, :prefix, :bcs => [])
  end  

end
