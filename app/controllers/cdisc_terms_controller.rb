# CDISC Terminology Controller
#
# @author Dave Iberson-Hurst
# @since 0.0.0

require 'controller_helpers.rb'

class CdiscTermsController < ApplicationController

  include ControllerHelpers

  before_action :authenticate_and_authorized

  # def find_submission
  #   authorize CdiscTerm, :view?
  #   ct = CdiscTerm.current
  #   if !ct.nil?
  #     uri = ct.find_submission(params[:notation])
  #     if !uri.nil?
  #       @cdiscCl = CdiscCl.find(uri.id, uri.namespace)
  #       render :template => "cdisc_cls/show"
  #     else
  #       flash[:error] = "Could not find the Code List."
  #       redirect_to request.referer
  #     end
  #   else
  #     flash[:error] = "Not current version of the terminology."
  #     redirect_to request.referer
  #   end
  # end

  def index
    @versions = CdiscTerm.version_dates
    @versions_normalized = normalize_versions(@versions)
    @versions_yr_span = [ @versions[0][:date].split('-')[0], @versions[-1][:date].split('-')[0] ]
    width = current_user.max_term_display.to_i
    current_index = @versions.length > width ? (@versions.length - width) : 0
    @current_id = @versions[current_index][:id]
    @latest_id = @versions.last[:id]
    render :index
  end

  def history
    respond_to do |format|
      format.html do
        results = Thesaurus.history_uris(identifier: CdiscTerm::C_IDENTIFIER, scope: IsoRegistrationAuthority.cdisc_scope)
        width = current_user.max_term_display.to_i
        current_index = results.length < width ? (results.length - 1) : (width - 1)
        @cdisc_term_id = results[current_index].to_id
        @identifier = CdiscTerm::C_IDENTIFIER
        @scope_id = IsoRegistrationAuthority.cdisc_scope.id
        @close_path = dashboard_index_path
        @ct = Thesaurus.find_minimum(@cdisc_term_id)
      end
      format.json do
        results = []
        history_results = Thesaurus.history_pagination(identifier: CdiscTerm::C_IDENTIFIER, scope: IsoRegistrationAuthority.cdisc_scope, count: the_params[:count], offset: the_params[:offset])
        current = Thesaurus.current(identifier: CdiscTerm::C_IDENTIFIER, scope: IsoRegistrationAuthority.cdisc_scope)
        results = add_history_paths(CdiscTerm, :thesauri, history_results, current)
        render json: {data: results, offset: the_params[:offset].to_i, count: results.count}
      end
    end
  end

  def changes
    results = {}
    versions = CdiscTerm.version_dates
    ct_from = Thesaurus.find_minimum(params[:id])
    from_index = versions.find_index {|x| x[:id] == ct_from.id}
    ct_to = Thesaurus.find_minimum(change_params[:other_id])
    to_index = versions.find_index {|x| x[:id] == ct_to.id}
    window_size = to_index - from_index + 1
    results = ct_from.changes_cdu(window_size)
    results.each do |k,v|
      next if k == :versions
      if k == :updated
       version_span = [results[:versions][0], results[:versions][-1]]
       v.each {|x| x[:changes_path] = changes_summary_thesauri_managed_concept_path({id: x[:id], last_id: x[:last_id], ver_span: version_span})}
      else
       v.each {|x| x[:changes_path] = changes_thesauri_managed_concept_path(x[:id])}
      end
    end
    render json: {data: results}
  end

private

  def the_params
    params.require(:cdisc_term).permit(:offset, :count)
  end

  def change_params
    params.require(:cdisc_term).permit(:other_id)
  end

  def authenticate_and_authorized
    authenticate_user!
    authorize CdiscTerm
  end

  def normalize_versions(versions)
    @normalized = Array.new
    min_i = strdate_to_f(versions[0])
    max_i = strdate_to_f(versions[-1])

    versions.each do |x|
      i = strdate_to_f(x[:date])
      normalized_i = (100)*(i - min_i) / (max_i - min_i) + 0
      @normalized.push(normalized_i)
    end
    return @normalized
  end

  def strdate_to_f(d)
    return Date.parse(d.to_s).strftime('%Q').to_f
  end

end
