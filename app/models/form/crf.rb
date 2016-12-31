class Form::Crf

	C_CLASS_NAME = "Form::Crf"
  C_DOMAIN_CLASS_COUNT = 5

  @@domain_map = {}
  @@common_map = {}

	# Create CRF
	#
	# @param node [Hash] The root node of the JSON object
	# @param annotations [] The form's annotations
	# @return [Null]
	def self.create(node, annotations, options)
    ConsoleLogger::log(C_CLASS_NAME, "create", "annotations=#{annotations}")
    html = "<style>"
    html += "table.crf-input-field { border-left: 1px solid black; border-right: 1px solid black; border-bottom: 1px solid black;}\n"
    html += "table.crf-input-field tr td { font-family: Arial, \"Helvetica Neue\", Helvetica, sans-serif; font-size: 8pt; text-align: center; " 
    html += "vertical-align: center; padding: 5px; }\n"
    html += "table.crf-input-field td:not(:last-child){border-right: 1px dashed}\n"
    html += "h4.domain-1 {border-radius: 5px; background: #A3E4D7; padding: 5px; }\n"
    html += "p.domain-1 {border-radius: 5px; background: #A3E4D7; padding: 5px; }\n"
    html += "h4.domain-2 {border-radius: 5px; background: #AED6F1; padding: 5px; }\n"
    html += "p.domain-2 {border-radius: 5px; background: #AED6F1; padding: 5px; }\n"
    html += "h4.domain-3 {border-radius: 5px; background: #D2B4DE; padding: 5px; }\n"
    html += "p.domain-3 {border-radius: 5px; background: #D2B4DE; padding: 5px; }\n"
    html += "h4.domain-4 {border-radius: 5px; background: #FAD7A0; padding: 5px; }\n"
    html += "p.domain-4 {border-radius: 5px; background: #FAD7A0; padding: 5px; }\n"
    html += "h4.domain-5 {border-radius: 5px; background: #F5B7B1; padding: 5px; }\n"
    html += "p.domain-5 {border-radius: 5px; background: #F5B7B1; padding: 5px; }\n"
    html += "h4.domain-other {border-radius: 5px; background: #BDC3C7; padding: 5px; }\n"
    html += "p.domain-other {border-radius: 5px; background: #BDC3C7; padding: 5px; }\n"
    html += "</style>"
		build_common_map(node)
    html += crf_node(node, annotations, options)
		#ConsoleLogger::log(C_CLASS_NAME,"create","html=#{html}")
		return html
	end

private

  def self.crf_node(node, annotations, options)
  	html = ""
    #ConsoleLogger::log(C_CLASS_NAME, "crf_node", "Node=#{node}")
    if node[:type] == Form::C_RDF_TYPE_URI.to_s
      html += '<table class="table table-striped table-bordered table-condensed">'
      html += '<tr>'
      html += '<td colspan="2"><h4>' + node[:label].to_s + '</h4></td>'
      if options[:annotate]
        html += '<td>' 
        domains = annotations.uniq {|entry| entry[:domain_prefix] }
        domains.each_with_index do |domain, index|
          domain_annotation = domain[:domain_prefix]
          if !domain[:domain_long_name].empty?
            domain_annotation += "=" + domain[:domain_long_name]
          end
          class_suffix = index < C_DOMAIN_CLASS_COUNT ? "#{index + 1}" : "other"
          class_name = "domain-#{class_suffix}"
          html += "<h4 class=\"#{class_name}\">#{domain_annotation}</h4>"
          domain[:class] = class_name
          @@domain_map[domain[:domain_prefix]] = domain
        end
        html += '</td>'
      else
        html += empty_cell
      end
      html += '</tr>'
      node[:children].each do |child|
        html += crf_node(child, annotations, options)
      end
      html += '</table>'
    elsif node[:type] == Form::Group::Common::C_RDF_TYPE_URI.to_s
      html += text_row(node[:label])
      node[:children].each do |child|
        html += crf_node(child, annotations, options)
      end
    elsif node[:type] == Form::Group::Normal::C_RDF_TYPE_URI.to_s
      html += text_row(node[:label])
      if node[:repeating] && is_question_only_group?(node)
        html += repeating_question_group(node, annotations, options)
      elsif node[:repeating] && is_bc_only_group?(node)
        html += repeating_bc_group(node, annotations, options)
      else
        node[:children].each do |child|
          html += crf_node(child, annotations, options)
        end
      end
    elsif node[:type] == Form::Item::Placeholder::C_RDF_TYPE_URI.to_s
      html += markdown_row(node[:free_text])
    elsif node[:type] == Form::Item::TextLabel::C_RDF_TYPE_URI.to_s
      html += markdown_row(node[:label_text])
    elsif node[:type] == Form::Item::Mapping::C_RDF_TYPE_URI.to_s
      html += mapping_row(node[:mapping]) if options[:annotate]
    elsif node[:type] == Form::Item::Question::C_RDF_TYPE_URI.to_s
      html += start_row(node[:optional])
      html += question_cell(node[:question_text])
      qa = question_annotations(node[:id], node[:mapping], annotations, options)
      html += mapping_cell(qa, options)
      if node[:children].length == 0
      	html += input_field(node, annotations)
      else
      	html += terminology_cell(node, annotations, options)
      end
      html += end_row
    elsif node[:type] == Form::Item::BcProperty::C_RDF_TYPE_URI.to_s
      if !node[:is_common]
        property_ref = node[:property_ref][:subject_ref]
        property = BiomedicalConceptCore::Property.find(property_ref[:id], property_ref[:namespace])
        node = property.to_json.merge(node)
        node[:datatype] = node[:simple_datatype]
        html += start_row(node[:optional])
        html += question_cell(node[:question_text])
        pa = property_annotations(node[:id], annotations, options)
        html += mapping_cell(pa, options)
        if node[:children].length == 0
          html += input_field(node, annotations)
        else
          html += terminology_cell(node, annotations, options)
        end
        html += end_row
      end
    elsif node[:type] == Form::Item::Common::C_RDF_TYPE_URI.to_s
      pa = ""
      node[:item_refs].each do |ref|
        uri = UriV2.new({:id => ref[:id], :namespace => ref[:namespace]})
        if @@common_map.has_key?(uri.to_s)
          other_node = @@common_map[uri.to_s]
          pa += property_annotations(other_node[:id], annotations, options)
          node[:datatype] = other_node[:simple_datatype]
          node[:question_text] = other_node[:question_text]
          node[:format] = other_node[:format]
          node[:children] = other_node[:children]
        else
          node[:children] = []
        end
      end
      html += start_row(node[:optional])
      html += question_cell(node[:question_text])
      html += mapping_cell(pa, options)
      if node[:children].length == 0
        html += input_field(node, annotations)
      else
        html += terminology_cell(node, annotations, options)
      end
      html += end_row
    elsif node[:type] == OperationalReferenceV2::C_TC_RDF_TYPE_URI.to_s
      tc = ThesaurusConcept.find(node[:subject_ref][:id], node[:subject_ref][:namespace])
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
      node[:format] = "5.1" if node[:format].blank?
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

  # Is a BC only group
  def self.is_bc_only_group?(node)
    node[:children].each do |child|
      return false if child[:type] != Form::Group::Normal::C_RDF_TYPE_URI.to_s 
      return false if child[:bc_ref].blank? 
      return false if child[:bc_ref][:subject_ref].blank? 
    end
    return true
  end

  # Is a Question only group
  def self.is_question_only_group?(node)
    node[:children].each do |child|
      return false if child[:type] != Form::Item::Question::C_RDF_TYPE_URI.to_s && 
        child[:type] != Form::Item::Mapping::C_RDF_TYPE_URI.to_s &&
        child[:type] != Form::Item::TextLabel::C_RDF_TYPE_URI.to_s 
    end
    return true
  end

  # Repeating Question group
  def self.repeating_question_group(node, annotations, options)
    html = ""
    # Put the labels and mappings out first
    node[:children].each do |child|
      if node[:type] == Form::Item::TextLabel::C_RDF_TYPE_URI.to_s
        html += markdown_row(node)
      elsif node[:type] == Form::Item::Mapping::C_RDF_TYPE_URI.to_s
        html += mapping_row(node)
      end
    end
    # Now the questions
    html += '<td colspan="3"><table class="table table-striped table-bordered table-condensed">'
    html += '<tr>'
    node[:children].each do |child|
      if child[:type] == Form::Item::Question::C_RDF_TYPE_URI.to_s
        html += question_cell(child[:question_text])
      elsif child[:type] == Form::Item::TextLabel::C_RDF_TYPE_URI.to_s ||
        child[:type] == Form::Item::Mapping::C_RDF_TYPE_URI.to_s
        # do nothing
      else
        html += question_cell("Incorrect type: #{child[:type]}")
      end
    end
    html += '</tr>'
    if options[:annotate]
      html += '<tr>'
      node[:children].each do |child|
        if child[:type] == Form::Item::Question::C_RDF_TYPE_URI.to_s
          qa = question_annotations(child[:id], child[:mapping], annotations, options)
          html += mapping_cell(qa, options)
        elsif child[:type] == Form::Item::TextLabel::C_RDF_TYPE_URI.to_s ||
          child[:type] == Form::Item::Mapping::C_RDF_TYPE_URI.to_s
          # do nothing
        else
          html += empty_cell
        end
      end 
      html += '</tr>'
    end
    html += '<tr>'
    node[:children].each do |child|
      if child[:type] == Form::Item::Question::C_RDF_TYPE_URI.to_s
        html += input_field(child, annotations)
      elsif child[:type] == Form::Item::TextLabel::C_RDF_TYPE_URI.to_s ||
        child[:type] == Form::Item::Mapping::C_RDF_TYPE_URI.to_s
        # do nothing
      else
        html += empty_cell
      end
    end 
    html += '</tr>'
    html += '</table></td>'
    #ConsoleLogger::log(C_CLASS_NAME, "repeating_question_group", "html=#{html}")  
    return html
  end

  # Repeating BC group
  def self.repeating_bc_group(node, annotations, options)
    html = ""
    html += '<td colspan="3"><table class="table table-striped table-bordered table-condensed">'
    html += '<tr>'
    columns = {}
    node[:children].each do |bc_node|
      bc_node[:children].each do |property_node|
        ref = property_node[:property_ref][:subject_ref]
        property = BiomedicalConceptCore::Property.find(ref[:id], ref[:namespace])
        #property_node.deep_merge!(property.to_json)
        property_node[:bridg_path] = property.bridg_path
        property_node[:question_text] = property.question_text
        #property_node[:children] = property.tc_refs
        property_node[:datatype] = property.simple_datatype
          
        if property.enabled && property.collect
          if !columns.has_key?(property_node[:bridg_path])
            columns[property_node[:bridg_path]] = property_node[:bridg_path] 
          end
        end
      end
    end
    # Question text
    html += start_row(false)
    bc_node = node[:children][0]
    bc_node[:children].each do |property_node|
      if columns.has_key?(property_node[:bridg_path])
        html += question_cell(property_node[:question_text])
      end
    end
    html += end_row
    # Annotation. Commented out, gives a block of annotations
    #html += start_row(false)
    #columns.each do |key, bridg_path|
    #  pa = ""
    #  node[:children].each do |bc_node|
    #    bc_node[:children].each do |property_node|
    #      if property_node[:bridg_path] == bridg_path
    #        pa += property_annotations(property_node[:id], annotations, options)
    #      end
    #    end
    #  end
    #  html += mapping_cell(pa, options)
    #end
    #html += end_row
    # BCs and the input fields
    node[:children].each do |bc_node|
      html += start_row(false)
      bc_node[:children].each do |property_node|
        if columns.has_key?(property_node[:bridg_path])
          if property_node[:children].length == 0
            html += input_field(property_node, annotations)
          else
            html += terminology_cell(property_node, annotations, options)
          end
        end
      end
      html += end_row
      html += start_row(false)
      bc_node[:children].each do |property_node|
        if columns.has_key?(property_node[:bridg_path])
          pa = property_annotations(property_node[:id], annotations, options)
          html += mapping_cell(pa, options)
        end
      end
      html += end_row
    end
    html += '</tr>'
    html += '</table></td>'
    return html
  end

  # Text Label
  def self.markdown_row(markdown)
    return "<tr><td colspan=\"3\"><p>#{MarkdownEngine::render(markdown)}</p></td></tr>"
  end

  # Mapping
  def self.mapping_row(mapping)
    return "<tr><td>#{mapping}</td><td colspan=\"2\"></td></tr>"
  end

  def self.start_row(optional)
    return '<tr class="warning">' if optional
    return '<tr>'
  end

  def self.end_row
    return "</tr>"
  end

  def self.text_row(text)
    return "<tr><td colspan=\"3\"><h5>#{text}</h5></td></tr>"
  end

  def self.question_cell(text)
    return "<td>#{text}</td>"
  end

  def self.mapping_cell(text, options)
    return "<td>#{text}</td>" if !text.empty? && options[:annotate]
    return empty_cell
  end
  
  def self.empty_cell
    return "<td></td>"
  end
  
  def self.text_cell(text)
    return "<td>#{text}</td>"
  end

  def self.terminology_cell(node, annotations, options)
    html = '<td>'
    node[:children].each do |child|
      html += crf_node(child, annotations, options)
    end
    html += '</td>'
    return html
  end

  def self.property_annotations(node_id, annotations, options)
    return "" if !options[:annotate]
    html = ""
    first = true
    entries = annotations.select {|item| item[:id] == node_id}
    entries.each do |entry|
      if !first
        html += "<br/>"
      end
      p_class = @@domain_map[entry[:domain_prefix]][:class]
      html += "<p class=\"#{p_class}\">#{entry[:sdtm_variable]} where #{entry[:sdtm_topic_variable]}=#{entry[:sdtm_topic_value]}</p>"
      first = false
    end
    return html
  end

  def self.question_annotations(node_id, mapping, annotations, options)
    return "" if !options[:annotate]
    html = ""
    entries = annotations.select {|item| item[:id] == node_id}
    if entries.count > 0
      first = true
      entries.each do |entry|
        if !first
          html += "<br/>"
        end
        p_class = @@domain_map[entry[:domain_prefix]][:class]
        html += "<p class=\"#{p_class}\">#{mapping}</p>"
        first = false
      end
    else
      html = "<p class=\"domain-other\">#{mapping}</p>"
    end
    return html
  end

  def self.build_common_map(node)
    if node[:type] == Form::Item::BcProperty::C_RDF_TYPE_URI.to_s
      if node[:is_common]
        property_ref = node[:property_ref][:subject_ref]
        property = BiomedicalConceptCore::Property.find(property_ref[:id], property_ref[:namespace])
        node = property.to_json.merge(node)
        @@common_map[property.uri.to_s] = node if !@@common_map.has_key?(property.uri.to_s)
      end
    end
    if !node[:children].blank?
      node[:children].each do |child|
        build_common_map(child)
      end
    end
  end
end