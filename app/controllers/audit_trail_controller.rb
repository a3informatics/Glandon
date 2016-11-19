class AuditTrailController < ApplicationController

  before_action :authenticate_user!

  C_CLASS_NAME = "AuditTrailsController"

  def index
    authorize AuditTrail
    @items = AuditTrail.last(1000)
    @defaults = {:user => "", :identifier => "", :owner => "", :event => AuditTrail.event_types[:empty_action]}
    users_owners_events
  end

  def search
    authorize AuditTrail, :view?
    param_set = the_params
    remove_key(param_set, :user, "")
    remove_key(param_set, :identifier, "")
    remove_key(param_set, :owner, "")
    remove_key(param_set, :event, AuditTrail.event_types[:empty_action].to_s)
    @items = AuditTrail.where(param_set).all
    @defaults = the_params
    users_owners_events
    render "index"
  end

private

    def the_params
      params.require(:audit_trail).permit(:user, :identifier, :owner, :event)
    end

    def users_owners_events
      @users = User.all
      @users.unshift(User.new)
      @owners = IsoNamespace.all
      @owners.unshift(IsoNamespace.new)
      @events = AuditTrail.event_types
    end

    def remove_key(params, key, value)
      if params[key] == value
        params.delete key
      end
    end

end