class Form::Group::Normal < Form::Group

  configure rdf_type: "http://www.assero.co.uk/BusinessForm#NormalGroup",
            uri_suffix: "NG",
            uri_property: :ordinal

  data_property :repeating

  object_property :has_common, cardinality: :many, model_class: "Form::Group::Common"
  object_property :has_sub_group, cardinality: :many, model_class: "Form::Group::Normal"
  object_property :has_biomedical_concept, cardinality: :many, model_class: "OperationalReferenceV3"

  validates_with Validator::Field, attribute: :repeating, method: :valid_boolean?

  # Get Item
  #
  # @return [Array] Array of hashes, one per group, sub group and item.
  def get_item
    blank_fields = {datatype:"", format:"", question_text:"", mapping:"", free_text:"", label_text:"", has_coded_value: [], has_property: []}
    group = self.to_h.merge!(blank_fields)
    group.delete(:has_sub_group)
    group.delete(:has_item)
    results = [group]
    self.has_item.sort_by {|x| x.ordinal}.each do |item|
      results << item.get_item
    end
    self.has_sub_group.sort_by {|x| x.ordinal}.each do |sg|
      results += sg.get_item
    end
    results
  end

  def to_crf
    html = ""
    html += text_row(self.label)
    if self.repeating && self.is_question_only_group?
      html += repeating_question_group
    elsif self.repeating && self.is_bc_only_group?
      html += repeating_bc_group
    else
      self.has_item.sort_by {|x| x.ordinal}.each do |item|
        html += item.to_crf
      end
      self.has_common.sort_by {|x| x.ordinal}.each do |c|
        html += c.to_crf 
      end
      self.has_sub_group.sort_by {|x| x.ordinal}.each do |sg|
        html += sg.to_crf
      end
    end
    return html
  end

  # Is a Question only group
  def is_question_only_group?
    self.has_sub_group.each do |sg|
      sg.is_question_only_group?
    end
    self.has_item.each do |item|
      return true if item.class == Form::Item::Question || item.class == Form::Item::Mapping || item.class == Form::Item::TextLabel 
    end
    return false
  end

  # Is a BC only group
  def is_bc_only_group?
    self.has_item.each do |item|
      return false if item.class != Form::Item::BcProperty
    end
    self.has_sub_group.each do |sg|
      sg.is_bc_only_group?
    end
    return true
  end

  # Repeating Question group
  def repeating_question_group
    html = ""
    # Put the labels and mappings out first
    # node[:children].each do |child|
    #   if node[:type] == Form::Item::TextLabel::C_RDF_TYPE_URI.to_s
    #     html += markdown_row(node)
    #   elsif node[:type] == Form::Item::Mapping::C_RDF_TYPE_URI.to_s
    #     html += mapping_row(node)
    #   end
    # end
    self.has_sub_group.sort_by {|x| x.ordinal}.each do |sg|
      html += sg.repeating_question_group
    end
    self.has_item.sort_by {|x| x.ordinal}.each do |item|
      html += item.to_crf unless item.class == Form::Item::Question
    end
    # Now the questions
    html += '<td colspan="3"><table class="table table-striped table-bordered table-condensed">'
    html += '<tr>'
    # node[:children].each do |child|
    #   if child[:type] == Form::Item::Question::C_RDF_TYPE_URI.to_s
    #     html += question_cell(child[:question_text])
    #   elsif child[:type] == Form::Item::TextLabel::C_RDF_TYPE_URI.to_s ||
    #     child[:type] == Form::Item::Mapping::C_RDF_TYPE_URI.to_s
    #     # do nothing
    #   else
    #     html += question_cell("Incorrect type: #{child[:type]}")
    #   end
    # end
    self.has_item.sort_by {|x| x.ordinal}.each do |item|
      html += item.question_cell(item.question_text) if item.class == Form::Item::Question
    end
    html += '</tr>'
    # if options[:annotate]
    #   html += '<tr>'
    #   node[:children].each do |child|
    #     if child[:type] == Form::Item::Question::C_RDF_TYPE_URI.to_s
    #       qa = question_annotations(child[:id], child[:mapping], annotations, options)
    #       html += mapping_cell(qa, options)
    #     elsif child[:type] == Form::Item::TextLabel::C_RDF_TYPE_URI.to_s ||
    #       child[:type] == Form::Item::Mapping::C_RDF_TYPE_URI.to_s
    #       # do nothing
    #     else
    #       html += empty_cell
    #     end
    #   end 
    #   html += '</tr>'
    # end
    html += '<tr>'
    self.has_item.sort_by {|x| x.ordinal}.each do |item|
      html += item.input_field if item.class == Form::Item::Question
    end
    self.has_sub_group.sort_by {|x| x.ordinal}.each do |sg|
      html += sg.repeating_question_group
    end
    # node[:children].each do |child|
    #   if child[:type] == Form::Item::Question::C_RDF_TYPE_URI.to_s
    #     html += input_field(child, annotations)
    #   elsif child[:type] == Form::Item::TextLabel::C_RDF_TYPE_URI.to_s ||
    #     child[:type] == Form::Item::Mapping::C_RDF_TYPE_URI.to_s
    #     # do nothing
    #   else
    #     html += empty_cell
    #   end
    # end 
    html += '</tr>'
    html += '</table></td>' 
    return html
  end

  # Repeating BC group
  def repeating_bc_group
    html = ""
    html += '<td colspan="3"><table class="table table-striped table-bordered table-condensed">'
    html += '<tr>'
    columns = {}
    self.has_sub_group.sort_by {|x| x.ordinal}.each do |sg|
      sg.has_item.sort_by {|x| x.ordinal}.each do |item|
        property = BiomedicalConcept::PropertyX.find(item.has_property.first.reference)
        #if property.enabled && property.collect
          if !columns.has_key?(property.uri.to_s)
            columns[property.uri.to_s] = property.uri.to_s
          end
        #end
      end
    end
  byebug
    # node[:children].each do |bc_node|
    #   bc_node[:children].each do |property_node|
    #     ref = property_node[:property_ref][:subject_ref]
    #     property = BiomedicalConceptCore::Property.find(ref[:id], ref[:namespace])
    #     #property_node.deep_merge!(property.to_json)
    #     property_node[:bridg_path] = property.bridg_path
    #     property_node[:question_text] = property.question_text
    #     #property_node[:children] = property.tc_refs
    #     property_node[:datatype] = property.simple_datatype
          
    #     if property.enabled && property.collect
    #       if !columns.has_key?(property_node[:bridg_path])
    #         columns[property_node[:bridg_path]] = property_node[:bridg_path] 
    #       end
    #     end
    #   end
    # end
    # Question text
    html += start_row(false)
    self.has_sub_group.sort_by {|x| x.ordinal}.each do |sg|
      sg.has_item.sort_by {|x| x.ordinal}.each do |item|
        property = BiomedicalConcept::PropertyX.find(item.has_property.first.reference)
          if !columns.has_key?(property.uri.to_s)
            html += question_cell(property.question_text)
          end
      end
    end
    # bc_node = node[:children][0]
    # bc_node[:children].each do |property_node|
    #   if columns.has_key?(property_node[:bridg_path])
    #     html += question_cell(property_node[:question_text])
    #   end
    # end
    html += end_row
    # BCs and the input fields
    self.has_sub_group.sort_by {|x| x.ordinal}.each do |sg|
      html += start_row(false)
      sg.has_item.sort_by {|x| x.ordinal}.each do |item|
        property = BiomedicalConcept::PropertyX.find(item.has_property.first.reference)
          if columns.has_key?(property.uri.to_s)
            if property.has_coded_value.length == 0
              html += input_field(property)
            else
              html += terminology_cell(property)
            end
          end
      end
      html += end_row
    end
    # node[:children].each do |bc_node|
    #   html += start_row(false)
    #   bc_node[:children].each do |property_node|
    #     if columns.has_key?(property_node[:bridg_path])
    #       if property_node[:children].length == 0
    #         html += input_field(property_node, annotations)
    #       else
    #         html += terminology_cell(property_node, annotations, options)
    #       end
    #     end
    #   end
    #   html += end_row
    #   html += start_row(false)
    #   bc_node[:children].each do |property_node|
    #     if columns.has_key?(property_node[:bridg_path])
    #       pa = property_annotations(property_node[:id], annotations, options)
    #       html += mapping_cell(pa, options)
    #     end
    #   end
    #   html += end_row
    # end
    html += '</tr>'
    html += '</table></td>'
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

    # Format a field
  def field_table(cell_content)
    html = "<table class=\"crf-input-field\"><tr>"
    cell_content.each do |cell|
      html += "<td>#{cell}</td>"
    end
    html += "</tr></table>"
    return html
  end

  def start_row(optional)
    return '<tr class="warning">' if optional
    return '<tr>'
  end

  def end_row
    return "</tr>"
  end

  def build_common_map
    self.has_item.sort_by {|x| x.ordinal}.each do |item|
      item.build_common_map
    end
    self.has_sub_group.sort_by {|x| x.ordinal}.each do |sg|
      sg.build_common_map
    end
    self.has_common.sort_by {|x| x.ordinal}.each do |cg|
      cg.build_common_map
    end
  end

end