class IsoManagedV2Controller < ApplicationController

  before_action :authenticate_user!

  def edit
    authorize IsoManaged
    @managed_item = find_item(params)
    @referer = request.referer
    @close_path = TypePathManagement.history_url_v2(@managed_item, true)
  end

  def update
    authorize IsoManaged
    managed_item = IsoManagedV2.find_minimum(protect_from_bad_id(params))
    managed_item.update_comments(the_params)
    redirect_to the_params[:referer]
  end

  def status
    authorize IsoManaged, :status?
    @referer = request.referer
    @managed_item = find_item(params)
    @token = get_token(@managed_item)
    if !@token.nil?
      @current_id = the_params[:current_id]
      @next_versions = SemanticVersion.from_s(@managed_item.previous_release).next_versions
      @close_path = TypePathManagement.history_url_v2(@managed_item, true)
    else
      redirect_to @referer
    end
  end

  def comments
    authorize IsoManaged, :edit?
    comments = IsoManagedV2.comments(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]))
    comments.each do |x|
      x[:edit_path] = edit_iso_managed_v2_path({id: x[:uri].to_id})
      x[:uri] = x[:uri].to_s
    end
    render json: {data: comments}
  end

  def impact
    authorize IsoManaged, :show?
    @managed_item = find_item(params)
    @new_cdisc_th = Thesaurus.find_minimum(the_params[:new_th_id])
    @ref_cdisc_th = Thesaurus.find_minimum(protect_from_bad_id(params)).get_referenced_thesaurus
    if Date.parse(@new_cdisc_th.version_label) <= Date.parse(@ref_cdisc_th.version_label)
      flash[:error] = "You must choose a CDISC release newer than #{@ref_cdisc_th.version_label} to view Impact Analysis."
      redirect_to request.referer
    end
    @close_path = request.referer
  end

  def make_current
    authorize IsoManaged, :status?
    managed_item = find_item(params)
    managed_item.make_current
    redirect_to request.referer
  end

  def update_status
    authorize IsoManaged, :status?
    referer = request.referer
    @managed_item = IsoManagedV2.find_minimum(protect_from_bad_id(params))
    token = Token.find_token(@managed_item, current_user)
    if !token.nil?
      @managed_item.update_status(the_params)
      if !@managed_item.errors.empty?
        flash[:error] = @managed_item.errors.full_messages.to_sentence
      else
        AuditTrail.update_item_event(current_user, @managed_item, @managed_item.audit_message_status_update)
      end
      redirect_to referer
    else
      flash[:error] = "The edit lock has timed out."
      redirect_to TypePathManagement.history_url_v2(@managed_item)
    end
  end

  def update_semantic_version
    authorize IsoManaged, :status?
    @managed_item = find_item(params)
    token = Token.find_token(@managed_item, current_user)
    if !token.nil?
      @managed_item.release(the_params[:sv_type].downcase.to_sym)
      status = @managed_item.errors.empty? ? 200 : 422
      render :json => { :data => @managed_item.semantic_version, :errors => @managed_item.errors.full_messages}, :status => status
    else
      render :json => {:errors => ["The edit lock has timed out."] }, :status => 422
    end
  end

  def find_by_tag
    authorize IsoManaged, :show?
    render json: {data: IsoManagedV2.find_by_tag(the_params[:tag_id])}, status: 200
  end

  def list_change_notes
    authorize IsoManaged, :show?
    @managed_item = find_item(params)
    @close_path = request.referer
  end

  def list_change_notes_data
    authorize IsoManaged, :show?
    tc = Thesaurus::ManagedConcept.find_with_properties(protect_from_bad_id(params))
    result = tc.change_notes_paginated({offset: the_params[:offset], count: the_params[:count]})
    render :json => {data: result, offset: the_params[:offset], count: result.count}, :status => 200
  end

  def export_change_notes_csv
    authorize IsoManaged, :show?
    item = Thesaurus::ManagedConcept.find_with_properties(protect_from_bad_id(params))
    send_data item.change_notes_csv, filename: "CL_CHANGE_NOTES_#{item.identifier}.csv", :type => 'text/csv; charset=utf-8; header=present', disposition: "attachment"
  end

  def export_ttl
    authorize IsoManaged
    uri = Uri.new(id: protect_from_bad_id(params))
    item = IsoManagedV2.klass_for(uri).find_full(uri, :export_paths)
    filename = "#{item.owner_short_name}_#{item.scoped_identifier}_#{item.version}.ttl"
    send_data PublicFile.read(item.to_ttl), filename: filename, type: 'application/x-turtle', disposition: 'inline'
  end

  def export_json
    authorize IsoManaged
    uri = Uri.new(id: protect_from_bad_id(params))
    item = IsoManagedV2.klass_for(uri).find_full(uri, :export_paths)
    filename = "#{item.owner_short_name}_#{item.scoped_identifier}_#{item.version}.json"
    send_data item.to_h, filename: filename, type: 'application/json', disposition: 'inline'
  end

private

  # Find item.
  def find_item(params, method=:find_minimum)
    uri = Uri.new(id: protect_from_bad_id(params))
    IsoManagedV2.klass_for(uri).send(method, uri)
  end

  # Strong parameters.
  def the_params
    # Strong parameter using iso_managed not V2 version.
    params.require(:iso_managed).permit(:identifier, :scope_id, :current_id, :tag_id, :registration_status, :previous_state, 
      :administrative_note, :unresolved_issue, :sv_type, :offset, :count, :new_th_id, 
      :change_description, :explanatory_comment, :origin, :referer)
  end

end
