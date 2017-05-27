class CdiscTermsController < ApplicationController
  
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
    @files = Dir.glob(Rails.root.join("public","upload") + "*.owl")
    @cdiscTerm = CdiscTerm.new
    all = CdiscTerm.all
    @next_version = all.last.next_version
  end
  
  def create
    authorize CdiscTerm, :import?
    hash = CdiscTerm.create(this_params)
    @cdiscTerm = hash[:object]
    @job = hash[:job]
    if @cdiscTerm.errors.empty?
      redirect_to backgrounds_path
    else
      flash[:error] = @cdiscTerm.errors.full_messages.to_sentence
      redirect_to import_cdisc_terms_path
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
    @close_path = history_thesauri_index_path(identifier: @cdiscTerm.identifier, scope_id: @cdiscTerm.owner_id)
  end
  
  def search_results
    authorize CdiscTerm, :view?
    results = Thesaurus.search(params)
    render json: { :draw => params[:draw], :recordsTotal => params[:length], :recordsFiltered => results[:count].to_s, 
    	:data => results[:items] }
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
    @trimmed_results = CdiscCtChanges.read(CdiscCtChanges::C_TWO_CT, version_hash)
    @cls = CdiscTerm::Utility.transpose_results(@trimmed_results)
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
    version = get_version
    ct = CdiscTerm.current
    @identifier = ct.nil? ? CdiscTerm::C_IDENTIFIER : ct.identifier
    full_results = CdiscCtChanges.read(CdiscCtChanges::C_ALL_CT)
  	@trimmed_results = CdiscTerm::Utility.trim_results(full_results, version, current_user.max_term_display.to_i)
    @previous_version = CdiscTerm::Utility.previous_version(full_results, @trimmed_results.first[:version])
    @next_version = CdiscTerm::Utility.next_version(full_results, @trimmed_results.first[:version], 
    	current_user.max_term_display.to_i, full_results.length)
  	@cls = CdiscTerm::Utility.transpose_results(@trimmed_results)
  end

  def changes_report
    authorize CdiscTerm, :view?
    results = CdiscCtChanges.read(CdiscCtChanges::C_ALL_CT)
    cls = CdiscTerm::Utility.transpose_results(results)
    respond_to do |format|
      format.pdf do
        @html = Reports::CdiscChangesReport.new.create(results, cls, current_user)
        render pdf: "cdisc_changes.pdf", page_size: current_user.paper_size, orientation: 'Landscape'
      end
    end
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
    version = get_version
    full_results = CdiscCtChanges.read(CdiscCtChanges::C_ALL_SUB)
    @results = CdiscTerm::Utility.trim_submission_results(full_results, version, current_user.max_term_display.to_i)
    @previous_version = CdiscTerm::Utility.previous_version(full_results[:versions], @results[:versions].first[:version])
    @next_version = CdiscTerm::Utility.next_version(full_results[:versions], @results[:versions].first[:version], 
    	current_user.max_term_display.to_i, full_results[:versions].length)
  end

  def submission_report
    authorize CdiscTerm, :view?
    results = CdiscCtChanges.read(CdiscCtChanges::C_ALL_SUB)
    respond_to do |format|
      format.pdf do
        @html = Reports::CdiscSubmissionReport.new.create(results, current_user)
        render pdf: 'cdisc_submission.pdf', page_size: current_user.paper_size, orientation: 'Landscape'
      end
    end
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

  def get_version
  	return nil if params[:cdisc_term].blank? 
  	return this_params[:version].to_i
  end

=begin 
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
=end

end
