# CDISC Terminology Controller
#
# @author Dave Iberson-Hurst
# @since 0.0.0
class CdiscTermsController < ApplicationController
  
  include ControllerHelpers

  before_action :authenticate_user!
  
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

  def history
    authorize CdiscTerm
    results = Thesaurus.history_pagination(identifier: CdiscTerm::C_IDENTIFIER, scope: CdiscTerm.owner, count: 1, offset: 1)
    @cdisc_term = results.first
  end

  def history_results
    authorize CdiscTerm, :history?
    results = []
    history_results = Thesaurus.history_pagination(identifier: CdiscTerm::C_IDENTIFIER, scope: CdiscTerm.owner, count: params[:count], offset: params[:offset])
    history_results.each do |object|
      results << object.to_h.reverse_merge!(add_history_paths(:thesauri, object))
    end
    render json: {data: results, offset: params[:offset].to_i, count: results.count}
  end

  # def import
  #   authorize CdiscTerm
  #   @files = Dir.glob(Rails.root.join("public", "upload") + "*.owl")
  #   @cdiscTerm = CdiscTerm.new
  #   all = CdiscTerm.all
  #   @next_version = all.last.next_version
  # end
  
  # def import_cross_reference
  #   authorize CdiscTerm, :import?
  #   @files = Dir.glob(Rails.root.join("public", "upload") + "*.xlsx")
  #   @cdisc_term = CdiscTerm.find(params[:id], this_params[:namespace], false)
  # end
  
  # def create
  #   authorize CdiscTerm, :import?
  #   hash = CdiscTerm.create(this_params)
  #   @cdiscTerm = hash[:object]
  #   @job = hash[:job]
  #   if @cdiscTerm.errors.empty?
  #     redirect_to backgrounds_path
  #   else
  #     flash[:error] = @cdiscTerm.errors.full_messages.to_sentence
  #     redirect_to import_cdisc_terms_path
  #   end
  # end
  
  # def create_cross_reference
  #   authorize CdiscTerm, :import?
  #   cdisc_term = CdiscTerm.find(params[:id], this_params[:namespace], false)
  #   hash = cdisc_term.create_cross_reference(this_params)
  #   if hash[:object].errors.empty?
  #     redirect_to backgrounds_path
  #   else
  #     flash[:error] = hash[:object].errors.full_messages.to_sentence
  #     redirect_to import_cdisc_terms_path
  #   end
  # end
  
  # def search
  #   authorize CdiscTerm, :view?
  #   @cdiscTerm = CdiscTerm.find(params[:id], params[:namespace], false)
  #   # @items = Notepad.where(user_id: current_user).find_each
  #   @close_path = history_thesauri_index_path(identifier: @cdiscTerm.identifier, scope_id: @cdiscTerm.scope.id)
  # end
  
  # def search_results
  #   authorize CdiscTerm, :view?
  #   results = Thesaurus.search(params)
  #   render json: { :draw => params[:draw], :recordsTotal => params[:length], :recordsFiltered => results[:count].to_s, 
  #   	:data => results[:items] }
  # end

  # def compare_calc
  #   authorize CdiscTerm, :view?
  #   old_cdisc_term = CdiscTerm.find(params[:oldId], params[:oldNamespace], false)
  #   new_cdisc_term = CdiscTerm.find(params[:newId], params[:newNamespace], false)
  #   # If results already prepared redirect, else calculate.
  #   version_hash = {:new_version => new_cdisc_term.version.to_s, :old_version => old_cdisc_term.version.to_s}
  #   if CdiscCtChanges.exists?(CdiscCtChanges::C_TWO_CT, version_hash)
  #     redirect_to compare_cdisc_terms_path(params.symbolize_keys)
  #   else
  #     hash = CdiscTerm.compare(old_cdisc_term, new_cdisc_term)
  #     @cdiscTerm = hash[:object]
  #     @job = hash[:job]
  #     if @cdiscTerm.errors.empty?
  #       redirect_to backgrounds_path
  #     else
  #       flash[:error] = @cdiscTerm.errors.full_messages.to_sentence
  #       redirect_to history_cdisc_terms_path
  #     end
  #   end
  # end

  # def compare
  #   authorize CdiscTerm, :view?
  #   old_cdisc_term = CdiscTerm.find(params[:oldId], params[:oldNamespace], false)
  #   new_cdisc_term = CdiscTerm.find(params[:newId], params[:newNamespace], false)
  #   version_hash = {:new_version => new_cdisc_term.version.to_s, :old_version => old_cdisc_term.version.to_s}
  #   @identifier = old_cdisc_term.identifier
  #   @trimmed_results = CdiscCtChanges.read(CdiscCtChanges::C_TWO_CT, version_hash)
  #   @cls = CdiscTerm::Utility.transpose_results(@trimmed_results)
  #   render "changes"
  # end
  
  # def changes_calc
  #   authorize CdiscTerm, :view?
  #   if CdiscCtChanges.exists?(CdiscCtChanges::C_ALL_CT)
  #       redirect_to changes_cdisc_terms_path
  #   else
  #     hash = CdiscTerm.changes()
  #     @cdiscTerm = hash[:object]
  #     @job = hash[:job]
  #     if @cdiscTerm.errors.empty?
  #       redirect_to backgrounds_path
  #     else
  #       flash[:error] = @cdiscTerm.errors.full_messages.to_sentence
  #       redirect_to history_cdisc_terms_path
  #     end
  #   end
  # end

  def changes
    authorize CdiscTerm, :view?
    @version_count = current_user.max_term_display.to_i
    @ct = CdiscTerm.find(params[:id], false)
    link_objects = @ct.forward_backward(1, current_user.max_term_display.to_i)
    @links = {}
    link_objects.each {|k,v| @links[k] = v.nil? ? "" : changes_cdisc_term_path(v)}
  end

  def changes_results
    authorize CdiscTerm, :view?
    ct = CdiscTerm.find(params[:id], false)
    cls = ct.changes(current_user.max_term_display.to_i)
    render json: {data: cls}
  end

  def changes_report
    authorize CdiscTerm, :view?
    ct = CdiscTerm.find(params[:id], false)
    cls = ct.changes(current_user.max_term_display.to_i)
    respond_to do |format|
      format.pdf do
        @html = Reports::CdiscChangesReport.new.create(cls, current_user)
        render pdf: "cdisc_changes.pdf", page_size: current_user.paper_size, orientation: 'Landscape', lowquality: true
      end
    end
  end

  def submission
    authorize CdiscTerm, :view?
    @version_count = current_user.max_term_display.to_i
    @ct = CdiscTerm.find(params[:id], false)
    link_objects = @ct.forward_backward(1, current_user.max_term_display.to_i)
    @links = {}
    link_objects.each {|k,v| @links[k] = v.nil? ? "" : submission_cdisc_term_path(v)}
  end

  def submission_results
    authorize CdiscTerm, :view?
    ct = CdiscTerm.find(params[:id], false)
    cls = ct.submission(current_user.max_term_display.to_i)
    render json: {data: cls}
  end

  def submission_report
    authorize CdiscTerm, :view?
    ct = CdiscTerm.find(params[:id], false)
    cls = ct.submission(current_user.max_term_display.to_i)
    respond_to do |format|
      format.pdf do
        @html = Reports::CdiscSubmissionReport.new.create(cls, current_user)
        @render_args = {pdf: 'cdisc_submission', page_size: current_user.paper_size, orientation: 'Landscape', lowquality: true}
        render @render_args
      end
    end
  end

  # def file
  #   authorize CdiscTerm, :import?
  #   @files = Dir.glob(CdiscCtChanges.dir_path + "*")
  # end

  # def file_delete
  #   authorize CdiscTerm, :import?
  #   files = this_params[:files]
  #   files.each do |file|
  #     File.delete(file) if File.exist?(file)
  #   end 
  #   redirect_to file_cdisc_terms_path
  # end

  # def cross_reference
  # 	authorize CdiscTerm, :show?
  # 	@direction = this_params[:direction]
  # 	@cdisc_term = CdiscTerm.find(params[:id], this_params[:namespace], false)
  # end

  # def export_csv
  #   authorize CdiscTerm, :show?
  #   uri = UriV3.new(id: params[:id]) # Using new mechanism
  #   ct = CdiscTerm.find(uri.fragment, uri.namespace)
  #   send_data ct.to_csv, filename: "CDISC_Term_#{ct.version_label}.csv", :type => 'text/csv; charset=utf-8; header=present', disposition: "attachment"
  # end

private

  def this_params
    params.require(:cdisc_term).permit(:version, :date, :term, :textSearch, :namespace, :uri, :direction, :cCodeSearch, :files => [] )
  end

  def get_version
  	return nil if params[:cdisc_term].blank? 
  	return this_params[:version].to_i
  end

end
