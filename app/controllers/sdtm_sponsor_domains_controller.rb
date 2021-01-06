require 'controller_helpers.rb'

class SdtmSponsorDomainsController < ManagedItemsController

  before_action :authenticate_and_authorized
  
  C_CLASS_NAME = "SdtmSponsorDomainsController"

  include ControllerHelpers
  include DatatablesHelpers

  def index
    super
  end

  def history
    super
  end

  def show
    @sdtm_sponsor_domain = SdtmSponsorDomain.find_minimum(protect_from_bad_id(params))
    @show_path = show_data_sdtm_sponsor_domain_path(@sdtm_sponsor_domain)
    @close_path = history_sdtm_sponsor_domains_path(:sdtm_sponsor_domain => {identifier: @sdtm_sponsor_domain.has_identifier.identifier, scope_id: @sdtm_sponsor_domain.scope})
  end

  def show_data
    sdtm_sponsor_domain = SdtmSponsorDomain.find_minimum(protect_from_bad_id(params))
    render json: {data: sdtm_sponsor_domain.get_children}, status: 200
  end

  def edit
    authorize SdtmSponsorDomain
    @sdtm_sponsor_domain = SdtmSponsorDomain.find_minimum(protect_from_bad_id(params))
    respond_to do |format|
      format.html do
        return true unless edit_lock(@sdtm_sponsor_domain)
        @sdtm_sponsor_domain = @edit.item
        @close_path = history_sdtm_sponsor_domains_path({ sdtm_sponsor_domain:
            { identifier: @sdtm_sponsor_domain.scoped_identifier, scope_id: @sdtm_sponsor_domain.scope } })
      end
      format.json do
        @sdtm_sponsor_domain = SdtmSponsorDomain.find_full(@sdtm_sponsor_domain.id)
        return true unless check_lock_for_item(@sdtm_sponsor_domain)
        render :json => { data: @sdtm_sponsor_domain.get_children }, :status => 200
      end
    end
  end

  def create_from_ig
    sdtm_ig_domain = SdtmIgDomain.find_full(protect_from_bad_id(sdtm_ig_domain_id))
    sdtm_sponsor_domain = SdtmSponsorDomain.create_from_ig(the_params, sdtm_ig_domain)
    if sdtm_sponsor_domain.errors.empty?
      AuditTrail.create_item_event(current_user, sdtm_sponsor_domain, "SDTM Sponsor Domain created from #{sdtm_ig_domain.scoped_identifier}.")
      path = history_sdtm_sponsor_domains_path({sdtm_sponsor_domain: {identifier: sdtm_sponsor_domain.scoped_identifier, scope_id: sdtm_sponsor_domain.scope.id}})
      render :json => {data: {history_path: path, id: sdtm_sponsor_domain.id}}, :status => 200
    else
      render :json => {errors: sdtm_sponsor_domain.errors.full_messages}, :status => 422
    end
  end

  def create_from_class
    sdtm_class = SdtmClass.find_full(protect_from_bad_id(sdtm_class_id))
    sdtm_sponsor_domain = SdtmSponsorDomain.create_from_class(the_params, sdtm_class)
    if sdtm_sponsor_domain.errors.empty?
      AuditTrail.create_item_event(current_user, sdtm_sponsor_domain, "SDTM Sponsor Domain created from #{sdtm_class.scoped_identifier}.")
      path = history_sdtm_sponsor_domains_path({sdtm_sponsor_domain: {identifier: sdtm_sponsor_domain.scoped_identifier, scope_id: sdtm_sponsor_domain.scope.id}})
      render :json => {data: {history_path: path, id: sdtm_sponsor_domain.id}}, :status => 200
    else
      render :json => {errors: sdtm_sponsor_domain.errors.full_messages}, :status => 422
    end
  end

  def add_non_standard_variable
    sdtm_sponsor_domain = SdtmSponsorDomain.find_full(protect_from_bad_id(params))
    non_standard_variable = sdtm_sponsor_domain.add_non_standard_variable
    if non_standard_variable.errors.empty?
      AuditTrail.create_item_event(current_user, sdtm_sponsor_domain, "Non standard variable #{non_standard_variable.name} added to SDTM Sponsor Domain.")
      render :json => {data: sdtm_sponsor_domain.get_children.find {|var| var[:id] == non_standard_variable.id} }, :status => 200
    else
      render :json => {errors: non_standard_variable.errors.full_messages}, :status => 422
    end
  end

  def delete_non_standard_variable
    sdtm_sponsor_domain = SdtmSponsorDomain.find_full(protect_from_bad_id(params))
    non_standard_variable = SdtmSponsorDomain::Var.find_full(the_params[:non_standard_var_id])
    return true unless check_lock_for_item(sdtm_sponsor_domain)
    result = non_standard_variable.delete(sdtm_sponsor_domain, sdtm_sponsor_domain)
    return true if lock_item_errors
    AuditTrail.update_item_event(current_user, sdtm_sponsor_domain, "SDTM Sponsor Domain updated, variable #{non_standard_variable.label} deleted.") if @lock.token.refresh == 1
    render json: {data: sdtm_sponsor_domain.get_children}, status: 200
  end

  # @todo Not currently used
  def toggle_used
    sdtm_sponsor_domain = SdtmSponsorDomain.find_full(protect_from_bad_id(params))
    non_standard_variable = SdtmSponsorDomain::Var.find_full(the_params[:non_standard_var_id])
    return true unless check_lock_for_item(sdtm_sponsor_domain)
    result = non_standard_variable.toggle_with_clone(sdtm_sponsor_domain)
    return true if lock_item_errors
    AuditTrail.update_item_event(current_user, sdtm_sponsor_domain, "SDTM Sponsor Domain updated, variable #{non_standard_variable.label} updated.") if @lock.token.refresh == 1
    render json: {data: ""}, status: 200
  end

  def editor_metadata
    render json: {data: {compliance: SdtmIgDomain::Variable.compliance, typed_as: SdtmClass::Variable.datatypes, classified_as: SdtmClass::Variable.classification} }, status: 200
  end

  def update
    sdtm_sponsor_domain = SdtmSponsorDomain.find_full(protect_from_bad_id(params))
    return true unless check_lock_for_item(sdtm_sponsor_domain)
    sdtm_sponsor_domain = sdtm_sponsor_domain.update(update_params)
    if sdtm_sponsor_domain.errors.empty?
      AuditTrail.update_item_event(current_user, sdtm_sponsor_domain, sdtm_sponsor_domain.audit_message(:updated)) if @lock.first_update?
      render :json => {data: sdtm_sponsor_domain.to_h}, :status => 200
    else
      render :json => {:fieldErrors => format_editor_errors(sdtm_sponsor_domain.errors)}, :status => 422
    end
  end

  def update_variable
    sdtm_sponsor_domain = SdtmSponsorDomain.find_full(protect_from_bad_id(params))
    return true unless check_lock_for_item(sdtm_sponsor_domain)
    non_standard_variable = SdtmSponsorDomain::Var.find_full(update_var_params[:non_standard_var_id])
    non_standard_variable = non_standard_variable.update_with_clone(update_var_params, sdtm_sponsor_domain)
    if non_standard_variable.errors.empty?
      AuditTrail.update_item_event(current_user, sdtm_sponsor_domain, sdtm_sponsor_domain.audit_message(:updated)) if @lock.first_update?
      result = sdtm_sponsor_domain.get_children.find {|var| var[:id] == non_standard_variable.id}
      render :json => {data: [result]}, :status => 200
    else
      if non_standard_variable.errors.has_key? :base
        render :json => {:errors => non_standard_variable.errors.full_messages}, :status => 422 
      else 
        render :json => {:fieldErrors => format_editor_errors(non_standard_variable.errors)}, :status => 422
      end
    end
  end
  
private
  
  def the_params
    params.require(:sdtm_sponsor_domain).permit(:identifier, :scope_id, :count, :offset, :sdtm_ig_domain_id, :sdtm_class_id, :non_standard_var_id, :label, :prefix)
  end

  # def non_standard_var_params
  #   params.require(:sdtm_sponsor_domain).permit(:name, :compliance, :typed_as, :classified_as)
  # end

  def update_params
    params.require(:sdtm_sponsor_domain).permit(:label)
  end

  def update_var_params
    params.require(:sdtm_sponsor_domain).permit(:non_standard_var_id, :used, :name, :label, :typed_as, :format, :classified_as, :description, :compliance)
  end

  # Get the ig domain id from the params
  def sdtm_ig_domain_id
    {id: the_params[:sdtm_ig_domain_id]}
  end

  # Get the class id from the params
  def sdtm_class_id
    {id: the_params[:sdtm_class_id]}
  end

  # Path for given action
  def path_for(action, object)
    case action
      when :show
        return sdtm_sponsor_domain_path(object)
      when :edit
        return edit_sdtm_sponsor_domain_path(object)
      else
        return ""
    end
  end

  def model_klass
    SdtmSponsorDomain
  end

  def history_path_for(identifier, scope_id)
    return {history_path: history_sdtm_sponsor_domains_path({sdtm_sponsor_domain:{identifier: identifier, scope_id: scope_id}})} 
  end

  def close_path_for
    sdtm_sponsor_domains_path
  end        

end
