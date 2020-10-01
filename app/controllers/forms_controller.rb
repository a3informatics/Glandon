require 'controller_helpers.rb'

class FormsController < ManagedItemsController

  include DatatablesHelpers

  before_action :authenticate_and_authorized

  C_CLASS_NAME = "FormsController"

  include ControllerHelpers

  def index
    super
  end

  def history
    super
  end

  def show
    @form = Form.find_minimum(protect_from_bad_id(params))
    @show_path = show_data_form_path(@form)
    @close_path = history_forms_path(:form => { identifier: @form.has_identifier.identifier, scope_id: @form.scope })
  end

  def show_data
    @form = Form.find_minimum(protect_from_bad_id(params))
    items = @form.get_items
    items = items.each_with_index do |item, index|
      item[:order_index] = index + 1
      item[:has_coded_value].each do |cv|
        cv.reverse_merge!({show_path: thesauri_unmanaged_concept_path({id: cv[:reference][:id], unmanaged_concept: {parent_id: cv[:context][:id], context_id: ""}})})
      end
    end
    render json: { data: items }, status: 200
  end

  def crf
    @form = Form.find_minimum(protect_from_bad_id(params))
    @close_path = history_forms_path(:form => { identifier: @form.has_identifier.identifier, scope_id: @form.scope })
    @html = @form.to_crf
  end

  def referenced_items
    form = Form.find_minimum(protect_from_bad_id(params))
    items = form.get_referenced_items
    render json: { data: items }, status: 200
  end

  def destroy
    form = Form.find_minimum(protect_from_bad_id(params))
    return true unless get_lock_for_item(form)
    form.delete
    AuditTrail.delete_item_event(current_user, form, form.audit_message(:deleted))
    @lock.release
    redirect_to request.referer
  end

  def create
    instance = Form.create(the_params)
    return true if item_errors(instance)
    AuditTrail.create_item_event(current_user, instance, instance.audit_message(:created))
    result = instance.to_h
    result[:history_path] = history_forms_path({form: {identifier: instance.scoped_identifier, scope_id: instance.scope}})
    render :json => {data: result}, :status => 200
    rescue => e
      render :json => {errors: instance.errors.full_messages}, :status => 422
  end

  def edit
    authorize Form
    @form = Form.find_minimum(protect_from_bad_id(params))
    respond_to do |format|
      format.html do
        return true unless edit_lock(@form)
        @form = @edit.item
        @close_path = history_forms_path({ form:
            { identifier: @form.scoped_identifier, scope_id: @form.scope } })
      end
      format.json do
        @form = Form.find_full(@form.id)
        render :json => { data: @form.to_h }, :status => 200
      end
    end
  end

  def update
    form = Form.find_full(protect_from_bad_id(params))
    return true unless check_lock_for_item(form)
    form = form.update(update_params)
    if form.errors.empty?
      AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.first_update?
      render :json => {data: form.to_h}, :status => 200
    else
      render :json => {:fieldErrors => format_editor_errors(form.errors)}, :status => 200
    end
  end

  def add_child
    form = Form.find_minimum(protect_from_bad_id(params))
    return true unless check_lock_for_item(form)
    new_child = form.add_child(add_child_params)
    return true if item_errors(new_child)
    return true if lock_item_errors
    AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.token.refresh == 1
    render :json => {data: new_child.to_h}, :status => 200
  end

  # def clone
  #   authorize Form
  #   @form = Form.find(params[:id], params[:namespace])
  # end

  # def clone_create
  #   authorize Form, :create?
  #   base_form = Form.find(params[:form_id], params[:form_namespace])
  #   identifier = base_form.identifier # Preserve for audit log
  #   operation = base_form.to_clone
  #   managed_item = operation[:managed_item]
  #   managed_item[:scoped_identifier][:identifier] = the_params[:identifier]
  #   managed_item[:label] = the_params[:label]
  #   @form = Form.create(operation)
  #   if @form.errors.empty?
  #     AuditTrail.create_item_event(current_user, @form, "Form cloned from #{identifier}.")
  #     flash[:success] = 'Form was successfully created.'
  #     redirect_to forms_path
  #   else
  #     flash[:error] = @form.errors.full_messages.to_sentence
  #     redirect_to clone_forms_path(:id => params[:form_id], :namespace => params[:form_namespace])
  #   end
  # end

  # def branch
  #   authorize Form
  #   @form = Form.find(params[:id], params[:namespace])
  # end

  # def branch_create
  #   authorize Form, :create?
  #   base_form = Form.find(params[:form_id], params[:form_namespace])
  #   identifier = base_form.identifier # Preserve for audit log
  #   operation = base_form.to_clone
  #   managed_item = operation[:managed_item]
  #   managed_item[:scoped_identifier][:identifier] = the_params[:identifier]
  #   managed_item[:label] = the_params[:label]
  #   @form = Form.create(operation)
  #   if @form.errors.empty?
  #     @form.add_branch_parent(params[:form_id], params[:form_namespace])
  #     AuditTrail.create_item_event(current_user, @form, "Form branched from #{identifier}.")
  #     flash[:success] = 'Form was successfully created.'
  #     redirect_to forms_path
  #   else
  #     flash[:error] = @form.errors.full_messages.to_sentence
  #     redirect_to branch_forms_path(:id => params[:form_id], :namespace => params[:form_namespace])
  #   end
  # end

  # def create
  #   authorize Form
  #   @form = Form.create_simple(the_params)
  #   if @form.errors.empty?
  #     AuditTrail.create_item_event(current_user, @form, "Form created.")
  #     flash[:success] = 'Form was successfully created.'
  #     redirect_to forms_path
  #   else
  #     flash[:error] = @form.errors.full_messages.to_sentence
  #     redirect_to new_form_path
  #   end
  # end

  # def update
  #   authorize Form
  #   form = Form.find(params[:id], params[:namespace], false)
  #   token = Token.find_token(form, current_user)
  #   if !token.nil?
  #     @form = Form.update(params[:form])
  #     if @form.errors.empty?
  #       AuditTrail.update_item_event(current_user, @form, "Form updated.") if token.refresh == 1
  #       render :json => { :data => @form.to_operation}, :status => 200
  #     else
  #       render :json => { :errors => @form.errors.full_messages}, :status => 422
  #     end
  #   else
  #     render :json => {:errors => ["The changes were not saved as the edit lock has timed out."]}, :status => 422
  #   end
  # end

  # def destroy
  #   authorize Form
  #   form = Form.find(params[:id], params[:namespace], false)
  #   token = Token.obtain(form, current_user)
  #   if !token.nil?
  #     form.destroy
  #     AuditTrail.delete_item_event(current_user, form, "Form deleted.")
  #     token.release
  #   else
  #     flash[:error] = "The item is locked for editing by another user."
  #   end
  #   redirect_to request.referer
  # end

  # def view
  #   authorize Form
  #   @form = Form.find(params[:id], params[:namespace])
  #   @close_path = history_forms_path(identifier: @form.identifier, scope_id: @form.scope.id)
  # end

  # def export_ttl
  #   authorize Form
  #   @form = IsoManaged::find(params[:id], params[:namespace])
  #   send_data to_turtle(@form.triples), filename: "#{@form.owner_short_name}_#{@form.identifier}.ttl", type: 'application/x-turtle', disposition: 'inline'
  # end

  # def export_json
  #   authorize Form
  #   @form = Form.find(params[:id], params[:namespace])
  #   send_data @form.to_json.to_json, filename: "#{@form.owner_short_name}_#{@form.identifier}.json", :type => 'application/json; header=present', disposition: "attachment"
  # end

  # def export_odm
  #   authorize Form, :export_json?
  #   @form = Form.find(params[:id], params[:namespace])
  #   send_data @form.to_xml, filename: "#{@form.owner_short_name}_#{@form.identifier}_ODM.xml", :type => 'application/xhtml+xml; header=present', disposition: "attachment"
  # end

  # def acrf
  #   authorize Form, :view?
  #   @form = Form.find(params[:id], params[:namespace])
  #   @close_path = request.referer
  #   respond_to do |format|
  #     format.html do
  #       @html = Reports::CrfReport.new.create(@form, {:annotate => true, :full => false}, current_user)
  #     end
  #     format.pdf do
  #       @html = Reports::CrfReport.new.create(@form, {:annotate => true, :full => true}, current_user)
  #       @render_args = {pdf: "#{@form.owner_short_name}_#{@form.identifier}_CRF", page_size: current_user.paper_size, lowquality: true}
  #       render @render_args
  #     end
  #   end
  # end

private

  def the_params
    params.require(:form).permit(:offset, :count, :identifier, :label, :scope_id)
  end

  def add_child_params
    params.require(:form).permit(:type)
  end

  def update_params
    params.require(:form).permit(:label, :completion, :note)
  end

  # Path for given action
  def path_for(action, object)
    case action
      when :show
        return form_path(object)
      when :edit
        return edit_form_path(object)
      when :view
        return crf_form_path(object)
      # when :destroy
      #   return form_path(object)
      else
        return ""
    end
  end

  def model_klass
    Form
  end

  def history_path_for(identifier, scope_id)
    return {history_path: history_forms_path({form:{identifier: identifier, scope_id: scope_id}})}
  end

  def close_path_for
    forms_path
  end

end
