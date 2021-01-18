# Studies Controller

require 'controller_helpers.rb'

class StudiesController < ManagedItemsController

  include ControllerHelpers

  before_action :authenticate_user!

  C_CLASS_NAME = self.name

  def index
    authorize Form
    super
  end

  # def update

  # end

  def create
    authorize Form, :create?
    params = the_params.slice(:identifier, :label, :description)
    protocol = Protocol.find(the_params[:protocol_id])
    params[:implements] = protocol.uri
    study = Study.create(params)
    if study.errors.empty?
      result = study.to_h
      result[:history_path] = history_studies_path({study: {identifier: study.scoped_identifier, scope_id: study.scope}})
      render :json => {data: result}, :status => 200
    else
      render json: {errors: [study.errors.full_messages]}, status: 422
    end
  end

  def history
    authorize Form, :show?
    respond_to do |format|
      format.html do
        super
      end
      format.json do
        results = []
        history_results = Study.history_pagination(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]), count: the_params[:count], offset: the_params[:offset])
        current = Study.current_uri(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]))
        latest = Study.latest_uri(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]))
        results = add_history_paths(Form, history_results, current, latest)
        render json: {data: results, offset: the_params[:offset].to_i, count: results.count}
      end
    end
  end

  def build
    authorize Form, :edit?
    @study = Study.find_minimum(protect_from_bad_id(params))
    respond_to do |format|
      format.html do
        return true unless edit_lock(@study)
        @study = Study.find_with_properties(@study.id)
        @study_build_tabs = study_build_tabs
        # Get tab type from params, default to :content
        @active_tab = params.fetch( :tab, :content ).to_sym
        # 404 if invalid tab type passed in params 
        page_not_found if !study_build_tab_valid? @active_tab
        #@study_empty = @study.protocol.design.empty?
        @close_path = history_studies_path({ study:{ identifier: @study.scoped_identifier, scope_id: @study.scope }})
      end
      format.json do
        return true unless check_lock_for_item(@study)
        render :json => { data: [] }, :status => 200
      end
    end

  end

  def design
    authorize Form, :edit?
    study = Study.find_minimum(protect_from_bad_id(params))
    render json: {data: study.protocol.design}
  end

  def soa
    authorize Form, :show?
    study = Study.find_minimum(protect_from_bad_id(params))
    render json: {data: study.soa}
  end

  def visits
    authorize Form, :show?
    study = Study.find_minimum(protect_from_bad_id(params))
    render json: {data: study.visits}
  end

private

  def the_params
    params.require(:study).permit(:identifier, :label, :description, :protocol_id, :scope_id, :count, :offset)
  end

  # Path for given action
  def path_for(action, object)
    case action
      when :show
        return ""
      when :edit
        return ""
      when :build
        return build_study_path(object)
      else
        return ""
    end
  end

  def model_klass
    Study
  end

  def history_path_for(identifier, scope_id)
    return {history_path: history_studies_path({study:{identifier: identifier, scope_id: scope_id}})}
  end

  def close_path_for
    studies_path
  end

  def study_build_tabs
    {
      content: { title: 'Content', partial: 'content_tab' },
      design: { title: 'Design and Interventions', partial: 'design_tab' },
      objectives: { title: 'Objectives', partial: 'objectives_tab' },
      endpoints: { title: 'Endpoints', partial: 'endpoints_tab' },
      timeline: { title: 'Timeline', partial: 'timeline_tab' },
      soa: { title: 'SoA', partial: 'soa_tab' },
      detail: { title: 'Detail', partial: 'detail_tab' },
      acrf: { title: 'aCRF', partial: 'acrf_tab' },
      domains: { title: 'Domains', partial: 'domains_tab' },
      export: { title: 'Export', partial: 'export_tab' }
    }
  end

  def study_build_tab_valid?(tab)
    study_build_tabs.keys.include? tab
  end 

end
