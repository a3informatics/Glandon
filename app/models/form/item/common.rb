class Form::Item::Common < Form::Item

  configure rdf_type: "http://www.assero.co.uk/BusinessForm#CommonItem",
            uri_suffix: "CI",  
            uri_property: :ordinal

  object_property :has_common_item, cardinality: :many, model_class: "Form::Item::BcProperty"

  # Get Item
  #
  # @return [Hash] A hash of Common Item
  def get_item
    blank_fields = {datatype:"", format:"", question_text:"", mapping:"", free_text:"", label_text:"", has_coded_value: [], has_property: []}
    return self.to_h.merge!(blank_fields)
  end

  def to_crf
    html = ""
    self.has_common_item.each do |ci|
      property = BiomedicalConcept::PropertyX.find(ci.uri)
    #node[:item_refs].each { |ref| uris << UriV2.new({:id => ref[:id], :namespace => ref[:namespace]}).to_s } # order to make test result predictable
    #uris.sort!
    # uris.each do |uri| 
    #   if @common_map.has_key?(uri)
    #     other_node = @common_map[uri]
    #     pa += property_annotations(other_node[:id], annotations, options)
    #     node[:datatype] = other_node[:simple_datatype]
    #     node[:question_text] = other_node[:question_text]
    #     node[:format] = other_node[:format]
    #     node[:children] = other_node[:children]
    #   else
    #     node[:children] = []
    #   end
    # end
      html += start_row(self.optional)
      html += question_cell(property.question_text)
      if property.has_coded_value.length == 0
        html += input_field(property)
      else
        html += terminology_cell(property)
      end
    end
    html += end_row
    return html
  end

# Format input field
  def input_field(node)
    html = '<td>'
    prop = ComplexDatatype::PropertyX.find(node.is_complex_datatype_property)
    datatype = XSDDatatype.new(prop.simple_datatype)
    if datatype.datetime?
      html += field_table(["D", "D", "/", "M", "M", "M", "/", "Y", "Y", "Y", "Y", "", "H", "H", ":", "M", "M"])
    #elsif datatype.date?
    #  html += field_table(["D", "D", "/", "M", "M", "M", "/", "Y", "Y", "Y", "Y"])
    #elsif datatype.time?
    #  html += field_table(["H", "H", ":", "M", "M"])
    elsif datatype.float?
      node.format = "5.1" if node.format.blank?
      parts = node.format.split('.')
      major = parts[0].to_i
      minor = parts[1].to_i
      pattern = ["#"] * major
      pattern[major-minor-1] = "."
      html += field_table(pattern)
    elsif datatype.integer?
      count = node.format.to_i
      html += field_table(["#"]*count)
    elsif datatype.string?
      length = node.format.scan /\w/
      html += field_table([" "]*5 + ["S"] + length + [""]*5)
    elsif datatype.boolean?
      html += '<input type="checkbox">'
    else
      html += field_table(["?", "?", "?"])
    end
    html += '</td>'
    return html
  end

  def terminology_cell(property)
    html = '<td>'
    property.has_coded_value.each do |cv|
      op_ref = OperationalReferenceV3.find(cv)
      tc = Thesaurus::UnmanagedConcept.find(op_ref.reference)
      if op_ref.enabled
        html += "<p><input type=\"radio\" name=\"#{tc.identifier}\" value=\"#{tc.identifier}\"></input>#{tc.label}</p>"
      end
    end
    html += '</td>'
    return html
  end

end