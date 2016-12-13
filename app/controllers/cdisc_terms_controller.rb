class CdiscTermsController < ApplicationController
  
  include CdiscTermHelpers

  before_action :authenticate_user!
  
  C_CLASS_NAME = "CdiscTermsController"
  
  def find_submission
    authorize CdiscTerm, :view?
    ct = CdiscTerm.current
    if !ct.nil?
      uri = ct.find_submission(params[:notation])
      if !uri.nil?
        @cdiscCl = CdiscCl.find(uri.id, uri.namespace)
        render :template => "cdisc_cls/show"
      else
        flash[:error] = "Could not find the Code List."
        redirect_to request.referer
      end
    else
      flash[:error] = "Not current version of the terminology."
      redirect_to request.referer
    end
  end

  def history
    authorize CdiscTerm
    @cdiscTerms = CdiscTerm.history
  end
  
  def import
    authorize CdiscTerm
    @files = Dir.glob(Rails.root.join("public","upload") + "*")
    @cdiscTerm = CdiscTerm.new
  end
  
  def create
    authorize CdiscTerm
    hash = CdiscTerm.create(this_params)
    @cdiscTerm = hash[:object]
    @job = hash[:job]
    if @cdiscTerm.errors.empty?
      redirect_to backgrounds_path
    else
      flash[:error] = @cdiscTerm.errors.full_messages.to_sentence
      redirect_to history_cdisc_terms_path
    end
  end
  
  def show
    authorize CdiscTerm
    @cdiscTerm = CdiscTerm.find(params[:id], params[:namespace])
    @cdiscTerms = CdiscTerm.all_previous(@cdiscTerm.version)
  end
  
  def search
    authorize CdiscTerm, :view?
    @cdiscTerm = CdiscTerm.find(params[:id], params[:namespace], false)
    @items = Notepad.where(user_id: current_user).find_each
  end
  
  def next
    authorize CdiscTerm, :view?
    items = []
    more = true
    @cdiscTerm = CdiscTerm.find(params[:id], params[:namespace], false)
    limit = params[:limit].to_i
    offset = params[:offset].to_i
    items = CdiscTerm.next(offset, limit, params[:namespace])
    if items.count < limit
      more = false
    end
    results = {}
    results[:offset] = offset + items.count
    results[:limit] = limit
    results[:more] = more
    results[:data] = items
    render :json => results, :status => 200
  end

  def compare_calc
    authorize CdiscTerm, :view?
    old_cdisc_term = CdiscTerm.find(params[:oldId], params[:oldNamespace], false)
    new_cdisc_term = CdiscTerm.find(params[:newId], params[:newNamespace], false)
    # If results already prepared redirect, else calculate.
    version_hash = {:new_version => new_cdisc_term.version.to_s, :old_version => old_cdisc_term.version.to_s}
    if CdiscCtChanges.exists?(CdiscCtChanges::C_TWO_CT, version_hash)
      redirect_to compare_cdisc_terms_path(params.symbolize_keys)
    else
      hash = CdiscTerm.compare(old_cdisc_term, new_cdisc_term)
      @cdiscTerm = hash[:object]
      @job = hash[:job]
      if @cdiscTerm.errors.empty?
        redirect_to backgrounds_path
      else
        flash[:error] = @cdiscTerm.errors.full_messages.to_sentence
        redirect_to history_cdisc_terms_path
      end
    end
  end

  def compare
    authorize CdiscTerm, :view?
    old_cdisc_term = CdiscTerm.find(params[:oldId], params[:oldNamespace], false)
    new_cdisc_term = CdiscTerm.find(params[:newId], params[:newNamespace], false)
    version_hash = {:new_version => new_cdisc_term.version.to_s, :old_version => old_cdisc_term.version.to_s}
    @identifier = old_cdisc_term.identifier
    @results = CdiscCtChanges.read(CdiscCtChanges::C_TWO_CT, version_hash)
    @cls = transpose_results(@results)
    render "changes"
  end
  
  def changes_calc
    authorize CdiscTerm, :view?
    if CdiscCtChanges.exists?(CdiscCtChanges::C_ALL_CT)
        redirect_to changes_cdisc_terms_path
    else
      hash = CdiscTerm.changes()
      @cdiscTerm = hash[:object]
      @job = hash[:job]
      if @cdiscTerm.errors.empty?
        redirect_to backgrounds_path
      else
        flash[:error] = @cdiscTerm.errors.full_messages.to_sentence
        redirect_to history_cdisc_terms_path
      end
    end
  end

  def changes
    authorize CdiscTerm, :view?
    ct = CdiscTerm.current
    @identifier = ct.identifier
    @results = CdiscCtChanges.read(CdiscCtChanges::C_ALL_CT)
    @cls = transpose_results(@results)
  end

  def changes_report
    authorize CdiscTerm, :view?
    results = CdiscCtChanges.read(CdiscCtChanges::C_ALL_CT)
    cls = transpose_results(results)
    @pdf = Reports::CdiscChangesReport.new.create(results, cls, current_user)
    send_data @pdf, filename: 'cdisc_changes.pdf', type: 'application/pdf', disposition: 'inline'
  end

  def submission_calc
    authorize CdiscTerm, :view?
    if CdiscCtChanges.exists?(CdiscCtChanges::C_ALL_SUB)
      redirect_to submission_cdisc_terms_path
    else
      hash = CdiscTerm.submission_changes
      @cdiscTerm = hash[:object]
      @job = hash[:job]
      if @cdiscTerm.errors.empty?
        redirect_to backgrounds_path
      else
        flash[:error] = @cdiscTerm.errors.full_messages.to_sentence
        redirect_to history_cdisc_terms_path
      end
    end
  end

  def submission
    authorize CdiscTerm, :view?
    @results = CdiscCtChanges.read(CdiscCtChanges::C_ALL_SUB)
  end

  def submission_report
    authorize CdiscTerm, :view?
    results = CdiscCtChanges.read(CdiscCtChanges::C_ALL_SUB)
    @pdf = Reports::CdiscSubmissionReport.new.create(results, current_user)
    send_data @pdf, filename: 'cdisc_submission.pdf', type: 'application/pdf', disposition: 'inline'
  end

  def impact_calc
    authorize CdiscTerm, :view?
    if CdiscCtChanges.exists?(CdiscCtChanges::C_TWO_CT_IMPACT, params)
      redirect_to impact_cdisc_terms_path(params)
    else
      hash = CdiscTerm.impact(params)
      @cdiscTerm = hash[:object]
      @job = hash[:job]
      if @cdiscTerm.errors.empty?
        redirect_to backgrounds_path
      else
        flash[:error] = @cdiscTerm.errors.full_messages.to_sentence
        redirect_to history_cdisc_terms_path
      end
    end
  end

  def impact
    authorize CdiscTerm, :view?
    @new_cdisc_term = CdiscTerm.find_only(params[:new_id], params[:new_ns])
    @old_cdisc_term = CdiscTerm.find_only(params[:old_id], params[:old_ns])
    @new_version = params[:new_version]
    @old_version = params[:old_version]
    results = CdiscCtChanges.read(CdiscCtChanges::C_TWO_CT_IMPACT, params)
    @results = impact_flatten(results)
  end

  def impact_graph
    authorize CdiscTerm, :view?
    @new_cdisc_term = CdiscTerm.find_only(params[:new_id], params[:new_ns])
    @old_cdisc_term = CdiscTerm.find_only(params[:old_id], params[:old_ns])
    @new_version = params[:new_version]
    @old_version = params[:old_version]
    results = CdiscCtChanges.read(CdiscCtChanges::C_TWO_CT_IMPACT, params)
    @graph = impact_graph_root(results) 
  end

  def impact_report
    authorize CdiscTerm, :view?
    results = CdiscCtChanges.read(CdiscCtChanges::C_TWO_CT_IMPACT, params)
    @results = impact_flatten(results)
    pdf = Reports::CdiscImpactReport.new(@results, current_user)
    send_data pdf.render, filename: 'cdisc_impact.pdf', type: 'application/pdf', disposition: 'inline'
  end

  def file
    authorize CdiscTerm, :import?
    @files = Dir.glob(CdiscCtChanges.dir_path + "*")
  end

  def file_delete
    authorize CdiscTerm, :import?
    files = this_params[:files]
    files.each do |file|
      File.delete(file) if File.exist?(file)
    end 
    redirect_to file_cdisc_terms_path
  end

private

  def this_params
    params.require(:cdisc_term).permit(:version, :date, :term, :textSearch, :cCodeSearch, :files => [] )
  end
  
  def impact_flatten(tree_array)
    results = Array.new
    tree_array.each do |tree|
      #ConsoleLogger::log(C_CLASS_NAME,"impact_flatten", "Tree=#{tree.to_json}")  
      if tree["children"].length > 0
        tree["children"].each do |child|
          #ConsoleLogger::log(C_CLASS_NAME,"impact_flatten", "Child=#{child}")  
          results += impact_node(tree, child)
        end
      else
        result = Hash.new
        result = 
          {
            :label => tree["label"], 
            :identifier => tree["identifier"], 
            :old_notation=> tree["old_notation"], 
            :new_notation=> tree["new_notation"], 
            :parent_identifier => tree["parent_identifier"],
            :item_type => "", 
            :item_id => "", 
            :item_nampespace => "", 
            :item_identifier => "", 
            :item_label => "",
            :item_via => ""
          }
        results << result
      end
    end
    #ConsoleLogger::log(C_CLASS_NAME,"impact_flatten", "Results=#{results.to_json}")  
    return results
  end

  def impact_node(root, node)
    results = Array.new
    result = Hash.new
    result = 
        {
          :label => root["label"], 
          :identifier => root["identifier"], 
          :old_notation=> root["old_notation"], 
          :new_notation=> root["new_notation"], 
          :parent_identifier => root["parent_identifier"],
          :item_type => node["type"], 
          :item_id => node["id"], 
          :item_nampespace => node["namespace"], 
          :item_identifier => node["identifier"], 
          :item_label => node["label"],
          :item_via => node["via"]
        }
    results << result
    if node["children"].length > 0
      node["children"].each do |child|
        results += impact_node(root, child)
      end
    end
    #ConsoleLogger::log(C_CLASS_NAME,"impact_node", "Result=#{result.to_json}")  
    return results
  end

  def impact_graph_root(tree_array)
    map = Hash.new
    results = Hash.new
    results[:nodes] = Array.new
    results[:links] = Array.new
    index = 0
    tree_array.each do |tree|
      if tree["children"].length > 0
        key = "#{tree["id"]}##{tree["namespace"]}"
        if map.has_key?(key)
          result = map[key]
        else
          result = Hash.new
          result = 
            {
              :name => "#{tree["identifier"]} (#{tree["old_notation"]})", 
              :label => tree["label"], 
              :identifier => tree["identifier"], 
              :old_notation=> tree["old_notation"], 
              :new_notation=> tree["new_notation"], 
              :parent_identifier => tree["parent_identifier"],
              :type => "Code List Item", 
              :index => index
            }
          results[:nodes] << result
          map[key] = result
          index += 1
        end
        tree["children"].each do |child|
          index = impact_graph_node(results, map, child, result[:index], index)
        end
      end
    end
    return results
  end

  def impact_graph_node(results, map, node, parent_index, index)
    key = "#{node["id"]}##{node["namespace"]}"
    if map.has_key?(key)
      result = map[key]
      results[:links] << {:source =>  parent_index, :target =>  result[:index]}
    else
      result = Hash.new
      result = 
          {
            :name => "#{node["label"]} (#{node["identifier"]})", 
            :label => node["label"],
            :id => node["id"], 
            :nampespace => node["namespace"], 
            :identifier => node["identifier"], 
            :type => node["type"], 
            :index => index
          }
      results[:nodes] << result
      results[:links] << {:source =>  parent_index, :target =>  index}
      map[key] = result
      index += 1
    end
    if node["children"].length > 0
      node["children"].each do |child|
        index = impact_graph_node(results, map, child, result[:index], index)
      end
    end
    #ConsoleLogger::log(C_CLASS_NAME,"impact_node", "Result=#{result.to_json}")  
    return index
  end

end
