class AuditTrailController < ApplicationController

  before_action :authenticate_user!

  C_CLASS_NAME = "AuditTrailsController"
  C_RECORDS = 2000

  def index
    authorize AuditTrail
    @items = AuditTrail.last(C_RECORDS)
    @defaults = {:user => "", :identifier => "", :owner => "", :event => AuditTrail.event_types[:empty_action]}
    users_owners_events
  end

  def search
    authorize AuditTrail
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

  def export_csv
    authorize AuditTrail
    send_data AuditTrail.to_csv, filename: "audit_trail.csv", :type => 'text/csv; charset=utf-8; header=present', disposition: "attachment"
  end

  def stats_by_year
    authorize AuditTrail, :index?
    render json: {data: AuditTrail.users_by_year}
  end

   def stats_by_domain
    authorize AuditTrail, :index?
    render json: {data: AuditTrail.users_by_domain}
  end

  def stats_by_current_week
    authorize AuditTrail, :index?
    render json: {data: AuditTrail.users_by_current_week}
  end

  def stats_by_year_by_month
    authorize AuditTrail, :index?
    render json: {data: AuditTrail.users_by_year_by_month}
  end

  def stats_by_year_by_week
    authorize AuditTrail, :index?
    render json: {data: AuditTrail.users_by_year_by_week}
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