require 'controller_helpers.rb'

class Forms::Groups::NormalGroupsController < ManagedItemsController

  include DatatablesHelpers

  before_action :authenticate_and_authorized

  C_CLASS_NAME = Forms::Groups::NormalGroupsController

  include ControllerHelpers

  def update
    form = Form.find_full(the_params[:form_id])
    return true unless check_lock_for_item(form)
    normal = Form::Group::Normal.find(protect_from_bad_id(params))
    normal = normal.update(update_params)
    if normal.errors.empty?
      AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.first_update?
      render :json => {data: normal.to_h}, :status => 200
    else
      render :json => {:fieldErrors => format_editor_errors(normal.errors)}, :status => 200
    end
  end

private

  def the_params
    params.require(:normal_group).permit(:form_id)
  end

  def update_params
    params.require(:normal_group).permit(:completion, :note)
  end

  def model_klass
    Form
  end

end
