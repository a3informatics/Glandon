class Reports::CrfReport

  C_CLASS_NAME = "Report::CrfReport"

  # Create the CRF report
  #
  # @param form [Form] the form object
  # @param options [Hash] the options
  # @param user [User] the user
  # @return [String] the HTML
  def create(form, options, user)
    history = build_history(form)
    @report = Reports::WickedCore.new
    @report.open("Case Report From", "#{form.identifier} #{form.version_label} (v#{form.semantic_version})", history, user) if options[:full]
    crf_title(form) if options[:full]
    crf_body(form, options)
    completion_notes_and_term(form) if options[:full]
    @report.close
    return @report.html
  end

  if Rails.env == "test"
    # Return the current HTML. Only available for testing.
    #
    # @return [String] the HTML
    def html
      return @report.html
    end
  end

private

  def build_history(form)
    doc_history = []
    history = IsoManaged::history(Form::C_RDF_TYPE, Form::C_SCHEMA_NS, {:identifier => form.identifier, :scope_id => form.owner_id})
    history.each do |item|
      if form.same_version?(item.version) || form.later_version?(item.version)
        doc_history << item.to_json
      end
    end
    return doc_history
  end

  def crf_title(form)
    html = "<h3>Form: #{form.label} <small>#{form.identifier} (#{form.versionLabel}, V#{form.version}, #{form.registrationStatus})</small></h3>"
    @report.add_to_body(html)
  end

  def crf_body(form, options)
    html = Form::Crf.create(form.to_json, form.annotations, options)
    @report.add_to_body(html)
    @report.add_page_break
  end

  def completion_notes_and_term(form)
    html = ""
    ci_nodes = []
    note_nodes = []
    terminology = []
    info_node(form.to_json, ci_nodes, note_nodes, terminology)
    # Completion instructions
    if ci_nodes.length > 0
      html += "<h3>Completion Instructions</h3>"
      html += "<table class=\"table table-striped table-bordered table-condensed\">"
      ci_nodes.each do |item|
        node = item[:node]
        if node[:optional]
          html += "<tr class=\"warning\">"
        else
          html += "<tr>"
        end
        html += "<td><strong>#{node[:label]}</strong></td><td>#{item[:html]}</td></tr>"
      end 
      html += "</table>"
    end
    @report.add_to_body(html)
    # Notes
    html = ""
    if note_nodes.length > 0
      @report.add_page_break
      html += "<h3>Notes</h3>"
      html += "<table class=\"table table-striped table-bordered table-condensed\">"
      note_nodes.each do |item|
        node = item[:node]
        if node[:optional]
          html += "<tr class=\"warning\">"
        else
          html += "<tr>"
        end
        html += "<td><strong>#{node[:label]}</strong></td><td>#{item[:html]}</td></tr>"
      end 
      html += "</table>"
    end
    @report.add_to_body(html)
    # Terminology
    html = ""
    if terminology.length > 0
      @report.add_page_break
      html += "<h3>Terminology</h3>"
      html += "<table class=\"table table-striped table-bordered table-condensed\">"
      html += "<thead><tr><th>Question</th><th>Identifier</th><th>Submission Value</th><th>Preferred Term</th></tr></thead>"
      terminology.each do |node|
        class_text = ""
        class_text = " class=\"warning\"" if node[:optional]
        node[:children].each do |child|
          if child[:enabled] 
            html += "<tr#{class_text}>"
            if child == node[:children].first
              html += "<td rowspan=\"#{node[:children].length}\">#{node[:question_text]}</td>"
            end
            tc = ThesaurusConcept.find(child[:subject_ref][:id], child[:subject_ref][:namespace])
            html += "<td>#{tc.identifier}</td><td>#{tc.notation}</td><td>#{tc.preferredTerm}</td>"
            html += "</tr>"
          end
        end   
      end 
      html += "</table>"
      @report.add_to_body(html)
    end
  end

  def info_node(node, ci_nodes, note_nodes, terminology)
    if node[:type] == Form::C_RDF_TYPE_URI.to_s
      add_nodes(node, ci_nodes, :completion)
      add_nodes(node, note_nodes, :note)
    elsif node[:type] == Form::Group::Normal::C_RDF_TYPE_URI.to_s
      add_nodes(node, ci_nodes, :completion)
      add_nodes(node, note_nodes, :note)
    elsif node[:type] == Form::Item::Placeholder::C_RDF_TYPE_URI.to_s
    elsif node[:type] == Form::Item::TextLabel::C_RDF_TYPE_URI.to_s
    elsif node[:type] == Form::Item::Mapping::C_RDF_TYPE_URI.to_s
    elsif node[:type] == OperationalReferenceV2::C_TC_RDF_TYPE_URI.to_s
    elsif node[:type] == Form::Item::Question::C_RDF_TYPE_URI.to_s
      add_nodes(node, ci_nodes, :completion)
      add_nodes(node, note_nodes, :note)
      terminology << node if node[:children].length > 0
    elsif node[:type] == Form::Item::BcProperty::C_RDF_TYPE_URI.to_s
      if !node[:is_common]
        add_nodes(node, ci_nodes, :completion)
        add_nodes(node, note_nodes, :note)
        property = BiomedicalConceptCore::Property.find(node[:property_ref][:subject_ref][:id], node[:property_ref][:subject_ref][:namespace])
        node.deep_merge!(property.to_json)
        terminology << node if node[:children].length > 0
      end
    elsif node[:type] == Form::Item::Common::C_RDF_TYPE_URI.to_s
      add_nodes(node, ci_nodes, :completion)
      add_nodes(node, note_nodes, :note)
      property = BiomedicalConceptCore::Property.find(node[:item_refs][0][:id], node[:item_refs][0][:namespace])
      node.deep_merge!(property.to_json)
      terminology << node if node[:children].length > 0
    end
    if !node[:children].blank?
      node[:children].each do |child|
        info_node(child, ci_nodes, note_nodes, terminology)
      end
    end
  end

  def add_nodes(node, nodes, field)
    text = node[field]
    nodes << {:node => node, :html => MarkdownEngine::render(text)} unless text.empty?
  end

end