class Form::Item::BcProperty < Form::Item

  configure rdf_type: "http://www.assero.co.uk/BusinessForm#BcProperty",
            uri_suffix: "BP",  
            uri_property: :ordinal

  data_property :is_common

  object_property :has_property, cardinality: :many, model_class: "OperationalReferenceV3"
  object_property :has_coded_value, cardinality: :many, model_class: "OperationalReferenceV3::TucReference"

  @common_map = {}

  # Get Item
  #
  # @return [Hash] A hash of Bc Property Item with CLI and CL references.
  def get_item
    blank_fields = {datatype:"", format:"", question_text:"", mapping:"", free_text:"", label_text:""}
    item = self.to_h.merge!(blank_fields)
    item[:has_coded_value] = coded_values_to_hash(self.has_coded_value)
    item[:has_property] = []
    return item
  end

  def to_crf
    html = ""
    if !self.is_common
      property_ref = self.has_property.first.reference
      property = BiomedicalConcept::PropertyX.find(property_ref)
      html += start_row(self.optional)
      html += question_cell(property.question_text)
      if property.has_coded_value.length == 0
        html += input_field(property)
      else
        html += terminology_cell
      end
      html += end_row
    end
    return html
  end

  # Format input field
  def input_field(node)
byebug
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

  def terminology_cell
    html = '<td>'
    self.has_coded_value.each do |cv|
      tc = Thesaurus::UnmanagedConcept.find(cv.reference)
      if cv.enabled
        html += "<p><input type=\"radio\" name=\"#{tc.identifier}\" value=\"#{tc.identifier}\"></input>#{tc.label}</p>"
      end
    end
    html += '</td>'
    return html
  end

  def build_common_map
byebug
    if self.is_common
      property_ref = self.has_property.first.reference
      property = BiomedicalConcept::PropertyX.find(property_ref)
      node = property.to_h
      @common_map[property.uri.to_s] = node if !@common_map.has_key?(property.uri.to_s)        
    end
    return @common_map
  end

 end