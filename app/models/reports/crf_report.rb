class Reports::CrfReport

  C_CLASS_NAME = "Report::CrfReport"

  def self.create(node, options, annotations, history, user)
    paper_size = user.paper_size
    html = page_header()
    html += title_page(node, user)
    # Document history
    if history.length > 0 && options[:full] 
      html += page_break
      html += "<h3>Item History</h3>"
      html += "<table class=\"simple\">"
      html += "<thead><tr><th>Date</th><th>Change</th><th>Comment</th><th>References</th></tr></thead>"
      history.each do |item|
        changed_date = Timestamp.new(item[:last_changed_date]).to_date
        description = MarkdownEngine::render(item[:change_description])
        comment = MarkdownEngine::render(item[:comment])
        refs = MarkdownEngine::render(item[:references])
        html += "<td>#{changed_date}</td><td>#{description}</td><td>#{comment}</td><td>#{refs}</td></tr>"
      end 
      html += "</table>"
      html += page_break
    end
    # Create the form. Build the completion instructions and notes
    # as we do.
    ci_nodes = Array.new
    note_nodes = Array.new
    terminology = Array.new
    html += "<h3>Form: #{node[:label]} <small>#{node[:scoped_identifier][:identifier]} (#{node[:scoped_identifier][:version_label]}, V#{node[:scoped_identifier][:version]}, #{node[:registration_state][:registration_status]})</small></h3>"
    html += crf_node(node, options, annotations, ci_nodes, note_nodes, terminology)
    # Completion instructions
    if ci_nodes.length > 0 && options[:full] 
      html += page_break
      html += "<h3>Completion Instructions</h3>"
      html += "<table class=\"ci\">"
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
    # Notes
    if note_nodes.length > 0 && options[:full] 
      html += page_break
      html += "<h3>Notes</h3>"
      html += "<table class=\"note\">"
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
    # Terminology
    if terminology.length > 0 && options[:full] 
      html += page_break
      html += "<h3>Terminology</h3>"
      html += "<table class=\"simple\">"
      html += "<thead><tr><th>Question</th><th>Identifier</th><th>Submission Value</th><th>Preferred Term</th></tr></thead>"
      terminology.each do |node|
        if node[:optional]
          html += "<tr class=\"warning\">"
        else
          html += "<tr>"
        end
        length = node[:children].length == 0 ? 1 : node[:children].length
        html += "<td rowspan=\"#{length}\">#{node[:label]}</td>"
        node[:children].each do |child|
          if child[:enabled]
            tc_ref = child[:subject_ref]
            tc = ThesaurusConcept.find(tc_ref[:id], tc_ref[:namespace])
            html += "<td>#{tc.identifier}</td><td>#{tc.notation}</td><td>#{tc.preferredTerm}</td>"
            if child != node[:children].last
              html += "</tr><tr>"
            end
          end
        end
        html += "</tr>"
      end 
      html += "</table>"
    end
    html += page_footer()
    ConsoleLogger.log(C_CLASS_NAME, "create", "HTML=" + html.to_s)
    pdf = WickedPdf.new.pdf_from_string(html, :page_size => paper_size, :footer => {:font_size => "10", :font_name => "Arial, \"Helvetica Neue\", Helvetica, sans-serif", :left => "", :center => "", :right => "[page] of [topage]"} )
    return pdf
  end

private

  def self.page_header
    html = "<html><head>"
    html += "<style>"
    html += "h1 { font-family: Arial, \"Helvetica Neue\", Helvetica, sans-serif; font-size: 24pt; line-height: 34pt; }\n"
    html += "h1.title { font-family: Arial, \"Helvetica Neue\", Helvetica, sans-serif; font-size: 24pt; line-height: 30pt; text-align: center; margin-top: 0; }\n"
    html += "h2 { font-family: Arial, \"Helvetica Neue\", Helvetica, sans-serif; font-size: 18pt; line-height: 28pt; }\n"
    html += "h2.title { font-family: Arial, \"Helvetica Neue\", Helvetica, sans-serif; font-size: 18pt; line-height: 24pt; text-align: center; margin-top: 0; }\n"
    html += "h3 { font-family: Arial, \"Helvetica Neue\", Helvetica, sans-serif; font-size: 16pt; }\n"
    html += "h4 { font-family: Arial, \"Helvetica Neue\", Helvetica, sans-serif; font-size: 14pt; }\n"
    html += "h5 { font-family: Arial, \"Helvetica Neue\", Helvetica, sans-serif; font-size: 12pt; }\n"
    html += "p { font-family: Arial, \"Helvetica Neue\", Helvetica, sans-serif; font-size: 10pt; }\n"
    html += "table tr td { font-family: Arial, \"Helvetica Neue\", Helvetica, sans-serif; font-size: 10pt; text-align: left; vertical-align: top; padding: 5px;}\n"
    html += "table.simple { border: 1px solid black; border-collapse: collapse; width: 100%;}\n"
    html += "table.simple tr td { border: 1px solid black; font-family: Arial, \"Helvetica Neue\", Helvetica, sans-serif; font-size: 10pt; text-align: left; vertical-align: top; padding: 5px;}\n"
    html += "table.simple tr th { border: 1px solid black; font-family: Arial, \"Helvetica Neue\", Helvetica, sans-serif; font-size: 10pt; text-align: left; vertical-align: top; padding: 5px;}\n"
    html += "table.form_table { border: 1px solid black; width: 100%;}\n"
    html += "table.form_table tr td { font-family: Arial, \"Helvetica Neue\", Helvetica, sans-serif; font-size: 10pt; text-align: left; vertical-align: top; padding: 5px;}\n"
    html += "table.form_table h4 { vertical-align: middle;}\n"
    html += "table.form_table td:first-child{ font: bold; }\n"
    html += "table.form_repeat { border: 1px solid black; width: 100%;}\n"
    html += "table.form_repeat th { font-family: Arial, \"Helvetica Neue\", Helvetica, sans-serif; font-size: 10pt; text-align: left; vertical-align: top; }\n"
    html += "table.form_repeat tr td { font-family: Arial, \"Helvetica Neue\", Helvetica, sans-serif; font-size: 10pt; text-align: left; vertical-align: top;}\n"
    html += "table.details tr td { font-family: Arial, \"Helvetica Neue\", Helvetica, sans-serif; font-size: 11pt; text-align: left; vertical-align: top; padding: 1px; }\n"
    html += "table.ci { border: 1px solid black; width: 100%; border-collapse: collapse;}\n"
    html += "table.ci tr td { font-family: Arial, \"Helvetica Neue\", Helvetica, sans-serif; font-size: 10pt; text-align: left; vertical-align: top; padding: 5px; border-bottom: 1pt solid black; }\n"
    html += ".ci td table, .ci td table tbody, .ci td table td { border:none; }\n" # Stops inheritence into markdown
    html += "table.note { border: 1px solid black; width: 100%;}\n"
    html += "table.note tr td { font-family: Arial, \"Helvetica Neue\", Helvetica, sans-serif; font-size: 10pt; font: bold; text-align: left; vertical-align: top; }\n"
    html += "table.input_field { border-left: 1px solid black; border-right: 1px solid black; border-bottom: 1px solid black;}\n"
    html += "table.input_field tr td { font-family: Arial, \"Helvetica Neue\", Helvetica, sans-serif; font-size: 8pt; text-align: center; vertical-align: center; padding: 5px; }\n"
    html += "table.input_field td:not(:last-child){border-right: 1px dashed}\n"
    html += "table.cl_field tr td { font-family: Arial, \"Helvetica Neue\", Helvetica, sans-serif; font-size: 10pt; text-align: left; vertical-align: center; padding: 2px; }\n"
    html += "table.cl_field td:first-child{ border: 1px solid black; }\n"
    html += "tr.warning { background-color: #fcf8e3 !important; }\n"
    html += "</style>"
    html += "</head><body>"
    return html
  end

  def self.page_footer
    html = "</body></html>"
    return html
  end

  def self.title_page(node, user)
    name = APP_CONFIG['organization_title']
    title = "#{node[:label]}<br>#{node[:identifier]}"
    image_file = APP_CONFIG['organization_image_file']
    dir = Rails.root.join("app", "assets", "images")
    file = File.join(dir, image_file)
    time_generated = Time.now
    # Generate HTML
    html = "<br><br><div style=\"text-align: center;\"><img src=\"#{file}\" style=\"height:75px;\"></div>"
    html += "<h2 class=\"title\">#{name}</h2>"
    html += "<br>" * 10
    html += "<h1 class=\"title\">CRF<br>#{title}</h1>"
    html += "<br>" * 23
    html += "<table class=\"details\" align=\"right\"><tr><td>Run at:</td><td>#{time_generated.strftime("%Y-%b-%d, %H:%M:%S")}</td></tr><tr><td>Run by:</td><td>#{user.email}</td></tr></table>"
    html += page_break
    return html
  end

  def self.crf_node(node, options, annotations, ci_nodes, note_nodes, terminology)
    html = ""
    #ConsoleLogger.log("Mdr", "crfNode", "Node=" + node.to_s)
    if node[:type] == Form::C_RDF_TYPE_URI.to_s
      add_nodes(node, ci_nodes, {:form => :formCompletion, :default => :completion})
      add_nodes(node, note_nodes, {:form => :formNote, :default => :note})
      html += '<table class="form_table">'
      html += '<tr>'
      html += '<td colspan="2"><h4>' + node[:label].to_s + '</h4></td>'
      if options[:annotate] 
        html += '<td><font color="red"><h4>' 
        domains = annotations.uniq {|entry| entry[:domain_prefix] }
        domains.each do |domain|
          ConsoleLogger::log(C_CLASS_NAME,"crf_node","domain=" + domain.to_json.to_s)
          suffix = ""
          prefix = domain[:domain_prefix]
          if domain[:domain_long_name] != ""
            suffix = "=" + domain[:domain_long_name]
          end
          html += domain[:domain_prefix].to_s + suffix + '<br/>'
        end
        html += '</h4></font></td>'
      else
        html += '<td></td>'
      end
      html += '</tr>'
      node[:children].each do |child|
        html += crf_node(child, options, annotations, ci_nodes, note_nodes, terminology)
      end
      html += '</table>'
    elsif node[:type] == Form::Group::Common::C_RDF_TYPE_URI.to_s
      #ConsoleLogger::log(C_CLASS_NAME,"crf_node","node=" + node.to_json.to_s)
      html += '<tr>'
      html += '<td colspan="3"><h5>' + node[:label].to_s + '</h5></td>'
      html += '</tr>'
      node[:children].each do |child|
        html += crf_node(child, options, annotations, ci_nodes, note_nodes, terminology)
      end
    elsif node[:type] == Form::Group::Normal::C_RDF_TYPE_URI.to_s
      add_nodes(node, ci_nodes, {:form => :formCompletion, :default => :completion})
      add_nodes(node, note_nodes, {:form => :formNote, :default => :note})
      html += '<tr>'
      html += '<td colspan="3"><h5>' + node[:label].to_s + '</h5></td>'
      html += '</tr>'
      if node[:repeating]
        html += '<tr>'
        html += '<td colspan="3"><table class="form_repeat">'
        html += '<tr>'
        node[:children].each do |child|
          html += '<th>' + child[:question_text] + '</th>'
        end 
        html += '</tr>'
        if options[:annotate] 
          html += '<tr>'
          node[:children].each do |child|
            html += '<td><font color="red">' + child[:mapping] + '</font></td>'
          end 
          html += '</tr>'
        end
        html += '<tr>'
        node[:children].each do |child|
          html += input_field(child, terminology)
        end 
        html += '</tr>'
        html += '</table></td>'
        html += '</tr>'
      else
        node[:children].each do |child|
          html += crf_node(child, options, annotations, ci_nodes, note_nodes, terminology)
        end
      end
    #elsif node[:type] == "BCGroup"
    #  add_nodes(node, ci_nodes, {:form => :formCompletion, :default => :completion})
    #  add_nodes(node, note_nodes, {:form => :formNote, :default => :note})
    #  html += '<tr>'
    #  html += '<td colspan="3"><h5>' + node[:label].to_s + '</h5></td>'
    #  html += '</tr>'
    #  node[:children].each do |child|
    #    html += crf_node(child, options, annotations, ci_nodes, note_nodes, terminology)
    #  end
    elsif node[:type] == Form::Item::Placeholder::C_RDF_TYPE_URI.to_s
      html += '<tr>'
      html += "<td colspan=\"3\"><p>#{MarkdownEngine::render(node[:free_text])}</p></td>"
      html += '</tr>'
      node[:children].each do |child|
        html += crf_node(child, options, annotations, ci_nodes, note_nodes, terminology)
      end
    elsif node[:type] == Form::Item::Question::C_RDF_TYPE_URI.to_s
      add_nodes(node, ci_nodes, {:form => :completion, :default => :completion})
      add_nodes(node, note_nodes, {:form => :note, :default => :note})
      ConsoleLogger::log(C_CLASS_NAME,"crf_node", "node=" + node.to_json.to_s)
      if node[:optional]
        html += '<tr class="warning">'
      else
        html += '<tr>'
      end
      html += '<td>' + node[:question_text].to_s + '</td>'
      if options[:annotate] 
        html += '<td><font color="red">' + node[:mapping].to_s + '</font></td>'
      else
        html += '<td></td>'
      end
      html += input_field(node, terminology)
      html += '</tr>'
    elsif node[:type] == Form::Item::BcProperty::C_RDF_TYPE_URI.to_s
      add_nodes(node, ci_nodes, {:form => :formCompletion, :default => :completion})
      add_nodes(node, note_nodes, {:form => :formNote, :default => :note})
      property_ref = node[:property_ref][:subject_ref]
      property = BiomedicalConceptCore::Property.find(property_ref[:id], property_ref[:namespace])
      node[:datatype] = property.datatype
      node[:format] = property.format
      node[:question_text] = property.qText
      node[:enabled] = property.enabled
      if node[:optional]
        html += '<tr class="warning">'
      else
        html += '<tr>'
      end
      html += '<td>' + node[:question_text].to_s + '</td>'
      html += '<td>'
      first = true
      if options[:annotate] 
        entries = annotations.select {|item| item[:id] == node[:id]}
        entries.each do |entry|
          if !first
            html += '<br/>'
          end
          html += '<font color="red">' + entry[:sdtm_variable] + ' where ' + entry[:sdtm_topic_variable] + '=' + entry[:sdtm_topic_value] + '</font>'
          first = false
        end
        node[:otherCommon].each do |child|
          entries = annotations.select {|item| item[:id] == child[:id]}
          entries.each do |entry|
            if !first
              html += '<br/>'
            end
            html += '<font color="red">' + entry[:sdtm_variable] + ' where ' + entry[:sdtm_topic_variable] + '=' + entry[:sdtm_topic_value] + '</font>'
            first = false
          end
        end
      end
      html += '</td>'
      html += input_field(node, terminology)
      html += '</tr>'
    elsif node[:type] == OperationalReferenceV2::C_TC_RDF_TYPE_URI.to_s
      # Ignore, processed.
    else
      html += '<tr>'
      html += '<td>Not Recognized: ' + node[:type].to_s + '</td>'
      html += '<td></td>'
      html += '<td></td>'
      html += '</tr>'
    end
    return html
  end

  def self.input_field(node, terminology)
    html = "<td>"
    if node[:datatype] == "CL"
      terminology << node
      values = Array.new
      node[:children].each do |child|
        if node[:enabled]
          tc_ref = child[:subject_ref]
          tc = ThesaurusConcept.find(tc_ref[:id], tc_ref[:namespace])
          values << "#{tc.label}"
        end
      end
      html += cl_table(values)
    elsif node[:datatype] == "D+T"
      html += field_table(["D", "D", "/", "M", "M", "M", "/", "Y", "Y", "Y", "Y", "", "H", "H", ":", "M", "M"])
    elsif node[:datatype] == "D"
      html += field_table(["D", "D", "/", "M", "M", "M", "/", "Y", "Y", "Y", "Y"])
    elsif node[:datatype] == "T"
      html += field_table(["H", "H", ":", "M", "M"])
    elsif node[:datatype] == "S"
      length = node[:format].scan /\w/
      html += field_table([" "]*5 + ["S"] + length + [""]*5)
    elsif node[:datatype] == "F"
      parts = node[:format].split('.')
      major = parts[0].to_i
      minor = parts[1].to_i
      pattern = ["#"] * major
      pattern[major-minor-1] = "."
      html += field_table(pattern)
    elsif node[:datatype] == "I"
      count = node[:format].to_i
      html += field_table(["#"]*count)
    else
      html += field_table(["?", "?", "?"])
    end
    html += "</td>"
    return html
  end

  def self.field_table(cell_content)
    html = "<table class=\"input_field\"><tr>"
    cell_content.each_with_index do |cell, index|
      html += "<td>#{cell}</td>"
    end
    html += "</tr></table>"
    ConsoleLogger::log(C_CLASS_NAME,"field_table", "HTML=" + html.to_s)
    return html
  end

  def self.cl_table(cell_content)
    html = "<table class=\"cl_field\">"
    cell_content.each do |cell|
      html += "<tr><td>&nbsp;&nbsp;</td><td>#{cell}</td></tr>"
    end
    html += "</table>"
    return html
  end

  def self.add_nodes(node, nodes, symbols)
    text = ""
    symbol = symbols[:default]
    symbol = symbols[:form] if node[:type] == "Form"
    text = node[symbol]
    ConsoleLogger::log(C_CLASS_NAME,"add_nodes", "Text=" + text.to_s)
    nodes << {:node => node, :html => MarkdownEngine::render(text)} unless text.empty?
  end

  def self.page_break
    return "<p style='page-break-after:always;'></p>"
  end

end