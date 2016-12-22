class Form::Crf

	C_CLASS_NAME = "Form::Crf"

	# Create CRF
	#
	# @param node [Hash] The root node of the JSON object
	# @param annotations [] The form's annotations
	# @return [Null]
	def self.create(node, annotations=nil)
    html = "<style>"
    html += "table.crf-input-field { border-left: 1px solid black; border-right: 1px solid black; border-bottom: 1px solid black;}\n"
    html += "table.crf-input-field tr td { font-family: Arial, \"Helvetica Neue\", Helvetica, sans-serif; font-size: 8pt; text-align: center; vertical-align: center; padding: 5px; }\n"
    html += "table.crf-input-field td:not(:last-child){border-right: 1px dashed}\n"
    html += "</style>"
		html += crf_node(node, annotations)
		ConsoleLogger::log(C_CLASS_NAME,"create","html=#{html}")
		return html
	end

private

  def self.crf_node(node, annotations=nil)
  	html = ""
    ConsoleLogger::log(C_CLASS_NAME, "crf_node", "Type=#{node[:type]}")
    if node[:type] == Form::C_RDF_TYPE_URI.to_s
      html += '<table class="table table-striped table-bordered table-condensed">'
      html += '<tr>'
      html += '<td colspan="2"><h4>' + node[:label].to_s + '</h4></td>'
      if annotations != nil
        html += '<td><font color="red"><h4>' 
        domains = annotations.uniq {|entry| entry[:domain_prefix] }
        domains.each do |domain|
          #ConsoleLogger::log(C_CLASS_NAME,"crf_node","domain=" + domain.to_json.to_s)
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
        html += crf_node(child, annotations)
      end
      html += '</table>'
    elsif node[:type] == Form::Group::Common::C_RDF_TYPE_URI.to_s
      #ConsoleLogger::log(C_CLASS_NAME,"crf_node","node=" + node.to_json.to_s)
      html += '<tr>'
      html += '<td colspan="3"><h5>' + node[:label].to_s + '</h5></td>'
      html += '</tr>'
      node[:children].each do |child|
        html += crf_node(child, annotations)
      end
    elsif node[:type] == Form::Group::Normal::C_RDF_TYPE_URI.to_s
      html += '<tr>'
      html += '<td colspan="3"><h5>' + node[:label].to_s + '</h5></td>'
      html += '</tr>'
      if node[:repeating]
        html += '<tr>'
        html += '<td colspan="3"><table class="table table-striped table-bordered table-condensed">'
        html += '<tr>'
        node[:children].each do |child|
          html += '<th>' + child[:question_text] + '</th>'
        end 
        html += '</tr>'
        if annotations != nil
          html += '<tr>'
          node[:children].each do |child|
            html += '<td><font color="red">' + child[:mapping] + '</font></td>'
          end 
          html += '</tr>'
        end
        html += '<tr>'
        node[:children].each do |child|
          html += input_field(child, annotations)
        end 
        html += '</tr>'
        html += '</table></td>'
        html += '</tr>'
      else
        node[:children].each do |child|
          html += crf_node(child, annotations)
        end
      end
    elsif node[:type] == Form::Item::Placeholder::C_RDF_TYPE_URI.to_s
      html += '<tr>'
      html += "<td colspan=\"3\"><p>#{MarkdownEngine::render(node[:free_text])}</p></td>"
      html += '</tr>'
    elsif node[:type] == Form::Item::TextLabel::C_RDF_TYPE_URI.to_s
      html += '<tr>'
      html += "<td colspan=\"3\"><p>#{MarkdownEngine::render(node[:label_text])}</p></td>"
      html += '</tr>'
    elsif node[:type] == Form::Item::Question::C_RDF_TYPE_URI.to_s
      if node[:optional]
        html += '<tr class="warning">'
      else
        html += '<tr>'
      end
      html += '<td>' + node[:question_text].to_s + '</td>'
      if annotations != nil
        html += '<td><font color="red">' + node[:mapping].to_s + '</font></td>'
      else
        html += '<td></td>'
      end
      if node[:children].length == 0
      	html += input_field(node, annotations)
      else
      	html += '<td>'
      	node[:children].each do |child|
          html += crf_node(child, annotations)
        end
	      html += '</td>'
      end
      html += '</tr>'
    elsif node[:type] == Form::Item::BcProperty::C_RDF_TYPE_URI.to_s
      property_ref = node[:property_ref][:subject_ref]
      property = BiomedicalConceptCore::Property.find(property_ref[:id], property_ref[:namespace])
      node[:datatype] = property.datatype
      if node[:optional]
        html += '<tr class="warning">'
      else
        html += '<tr>'
      end
      html += "<td>#{property.qText}</td>"
      html += '<td>'
      first = true
      if annotations != nil
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
      html += input_field(node, annotations)
      html += '</tr>'
    elsif node[:type] == OperationalReferenceV2::C_TC_RDF_TYPE_URI.to_s
      ConsoleLogger::log(C_CLASS_NAME,"crf_node","TC_REF=#{node.to_json}")
    	tc_ref = node[:subject_ref]
      tc = ThesaurusConcept.find(tc_ref[:id], tc_ref[:namespace])
      if node[:enabled]
        html += "<p><input type=\"radio\" name=\"#{tc.identifier}\" value=\"#{tc.identifier}\"></input>#{tc.label}</p>"
      end
    else
      html += '<tr>'
      html += '<td>Not Recognized: ' + node[:type].to_s + '</td>'
      html += '<td></td>'
      html += '<td></td>'
      html += '</tr>'
    end
    return html
  end

  # Format input field
  def self.input_field(node, annotations)
    html = '<td>'
    if node[:datatype] == BaseDatatype::C_DATETIME
      html += field_table(["D", "D", "/", "M", "M", "M", "/", "Y", "Y", "Y", "Y", "", "H", "H", ":", "M", "M"])
    elsif node[:datatype] == BaseDatatype::C_DATE
      html += field_table(["D", "D", "/", "M", "M", "M", "/", "Y", "Y", "Y", "Y"])
    elsif node[:datatype] == BaseDatatype::C_TIME
      html += field_table(["H", "H", ":", "M", "M"])
    elsif node[:datatype] == BaseDatatype::C_FLOAT
      parts = node[:format].split('.')
      major = parts[0].to_i
      minor = parts[1].to_i
      pattern = ["#"] * major
      pattern[major-minor-1] = "."
      html += field_table(pattern)
    elsif node[:datatype] == BaseDatatype::C_INTEGER
      count = node[:format].to_i
      html += field_table(["#"]*count)
    elsif node[:datatype] == BaseDatatype::C_STRING
      length = node[:format].scan /\w/
      html += field_table([" "]*5 + ["S"] + length + [""]*5)
    else
      html += field_table(["?", "?", "?"])
    end
    html += '</td>'
    return html
  end

  # Format a field
  def self.field_table(cell_content)
    html = "<table class=\"crf-input-field\"><tr>"
    cell_content.each_with_index do |cell, index|
      html += "<td>#{cell}</td>"
    end
    html += "</tr></table>"
    return html
  end

end