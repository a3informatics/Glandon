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
    @managed_item = find_item(params)
    respond_to do |format|
      format.html do
        @token = get_token(@managed_item)
        if !@token.nil?
          @close_path = TypePathManagement.history_url_v2(@managed_item, true)
          @item_klass = @managed_item.class.name
        else
          flash[:error] = "The item is locked for editing."
          redirect_to request.referer
        end
      end
      format.json do
        token = Token.find_token(@managed_item, current_user)
        if token.nil?
          render :json => {:errors => ["The edit lock has timed out."] }, :status => 422
        else
          render :json => { data: @managed_item.status_summary }, :status => 200
        end
      end
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
    item = find_item(params)
    respond_to do |format|
      format.html do
        @managed_item = item 
        @managed_item_ref = "#{item.label} #{item.scoped_identifier} v#{item.semantic_version}"
        @close_path = request.referrer 
        @data_path = impact_iso_managed_v2_path(item)
      end
      format.json do
        results = item.dependency_required_by
        render json: impact_d3(item, results)
      end
    end 
  end

  def custom_properties
    authorize IsoManaged, :show?
    item = find_item(params)
    owned = item.owned?
    render json: {data: owned ? item.find_custom_property_values : {}, definitions: owned ? item.find_custom_property_definitions_to_h : {}}
  end

  def make_current 
    authorize IsoManaged, :status?
    managed_item = find_item(params)
    managed_item.make_current
    respond_to do |format|
      format.html { redirect_to request.referer }
      format.json { render json: { data: {} } }
    end
  end

  def next_state
    authorize IsoManaged, :status?
    item = find_item(params)
    token = Token.find_token(item, current_user)
    if !token.nil?
      update_to_next_state(item, the_params)
      if item.errors.empty?
        AuditTrail.update_item_event(current_user, item, item.audit_message_status_update)
        render :json => { :data => item.status_summary}, :status => 200
      else
        render :json => { :errors => item.errors.full_messages}, :status => 422
      end
    else
      render :json => {:errors => ["The edit lock has timed out."] }, :status => 422
    end
  end

  def state_change
    authorize IsoManaged, :status?
    return false unless valid_action?(the_params[:action].to_sym)
    item = find_item(params)
    token = Token.find_token(item, current_user)
    if !token.nil?
      if item.update_status_permitted?
        items = item.update_status_dependent_items(the_params[:action])
        lock_set = TokenSet.new(items, current_user)
        ffor(item, lock_set.ids, the_params[:action])
        lock_set.each { |x| AuditTrail.update_item_event(current_user, x[:item], x[:item].audit_message_status_update) }
        lock_set.release

        render :json => { :data => IsoManagedV2.find_minimum(item.uri).status_summary}, :status => 200
      else
        render :json => { :errors => item.errors.full_messages}, :status => 422
      end
    else
      render :json => {:errors => ["The edit lock has timed out."] }, :status => 422
    end
  end

  def state_change_impacted_items
    authorize IsoManaged, :status?
    return false unless valid_action?(the_params[:action].to_sym)
    item = find_item(params)
    token = Token.find_token(item, current_user)
    if !token.nil?
      items = item.update_status_dependent_items(the_params[:action].to_sym)      
      render :json => { :data => ffor_impacted_items(item, items.map{|x| x.id}, the_params[:action].to_sym)}, :status => 200
    else
      render :json => {:errors => ["The edit lock has timed out."] }, :status => 422
    end
  end

  def update_semantic_version
    authorize IsoManaged, :status?
    @managed_item = find_item(params)
    token = Token.find_token(@managed_item, current_user)
    if !token.nil?
      @managed_item.release(the_params[:sv_type].downcase.to_sym)
      status = @managed_item.errors.empty? ? 200 : 422
      render :json => { :data => @managed_item.status_summary[:semantic_version], :errors => @managed_item.errors.full_messages}, :status => status
    else
      render :json => {:errors => ["The edit lock has timed out."] }, :status => 422
    end
  end

  def update_version_label
    authorize IsoManaged, :status?
    @managed_item = find_item(params)
    token = Token.find_token(@managed_item, current_user)
    if !token.nil?
      si = @managed_item.has_identifier
      si.update(the_params)
      status = si.errors.empty? ? 200 : 422
      render :json => { :data => si.version_label, :errors => si.errors.full_messages}, :status => status
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
      :administrative_note, :unresolved_issue, :sv_type, :version_label, :offset, :count, 
      :change_description, :explanatory_comment, :origin, :referer, :with_dependecies, :action)
  end

  # Formatting impact for D3
  def impact_d3(item, nodes)
    result = {nodes: [], links: []}
    nodes.each {|x| result[:links] << { source: item.id, target: x.id } } 
    nodes.insert(0, item) 
    result[:nodes] = nodes.map {|x| { uri: x.uri.to_s, id: x.uri.to_id, identifier: x.scoped_identifier, semantic_version: x.semantic_version, 
        version_label: x.version_label, label: x.label, rdf_type: x.rdf_type.to_s, history_path: TypePathManagement.history_url_v2(x, true),
        impact_path: impact_iso_managed_v2_path(x)}}
    result
  end

  # Update to next state
  def update_to_next_state(item, params)
    return unless item.update_status_permitted?
    item.next_state(params)
  end

  def valid_action?(action)
    return true if [:fast_forward, :rewind].include? action
    render :json => {:errors => ["Invalid action detected."] }, :status => 422
    false
  end

  # Fast Forward or Rewind
  def ffor(item, ids, action)
    return IsoManagedV2.fast_forward_state([item.id] + ids) if action.to_sym == :fast_forward
    return IsoManagedV2.rewind_state([item.id] + ids) if action.to_sym == :rewind
  end

  # Fast Forward or Rewind to find impacted items
  def ffor_impacted_items(item, ids, action)
    return IsoManagedV2.fast_forward_permitted([item.id] + ids) if action == :fast_forward
    return IsoManagedV2.rewind_permitted([item.id] + ids) if action == :rewind
  end

end
