class AuditTrailController < ApplicationController

  C_CLASS_NAME = "AuditTrailsController"

  def index
    authorize AuditTrail
    @items = AuditTrail.last(1000)
    @defaults = {:user => "", :identifier => "", :owner => "", :event => AuditTrail.event_types[:empty_action]}
    users_owners_events
  end

  def search
    authorize AuditTrail, :view?
    ConsoleLogger::log(C_CLASS_NAME, "search", "params1=#{the_params}")
    param_set = the_params
    remove_key(param_set, :user, "")
    remove_key(param_set, :identifier, "")
    remove_key(param_set, :owner, "")
    remove_key(param_set, :event, AuditTrail.event_types[:empty_action].to_s)
    ConsoleLogger::log(C_CLASS_NAME, "search", "params2=#{param_set}")
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
      ConsoleLogger::log(C_CLASS_NAME, "remove_key", "param=#{params[key]}")
      ConsoleLogger::log(C_CLASS_NAME, "remove_key", "key=#{key}")
      ConsoleLogger::log(C_CLASS_NAME, "remove_key", "value=#{value}")
      if params[key] == value
        params.delete key
      end
    end

end