require 'controller_helpers.rb'

class Forms::Groups::BcGroupsController < ManagedItemsController

  include DatatablesHelpers

  before_action :authenticate_and_authorized

  C_CLASS_NAME = Forms::Groups::BcGroupsController

  include ControllerHelpers

  def update
    form = Form.find_full(the_params[:form_id])
    return true unless check_lock_for_item(form)
    bc = Form::Group::Bc.find(protect_from_bad_id(params))
    bc = bc.update(update_params)
    if bc.errors.empty?
      AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.first_update?
      render :json => {data: bc.to_h}, :status => 200
    else
      render :json => {:fieldErrors => format_editor_errors(bc.errors)}, :status => 200
    end
  end

private

  def the_params
    params.require(:bc_group).permit(:form_id)
  end

  def update_params
    params.require(:bc_group).permit(:label, :completion, :note)
  end

  def model_klass
    Form
  end

end
