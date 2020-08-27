class Form::Item < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/BusinessForm#Item",
            uri_suffix: "I",
            uri_property: :ordinal

  data_property :ordinal, default: 1
  data_property :note
  data_property :completion
  data_property :optional, default: false

  validates_with Validator::Field, attribute: :ordinal, method: :valid_positive_integer?
  validates_with Validator::Field, attribute: :note, method: :valid_markdown?
  validates_with Validator::Field, attribute: :completion, method: :valid_markdown?
  validates :optional, inclusion: { in: [ true, false ] }

  # def build_common_map
  #   if self.class == Form::Item::BcProperty
  #     self.build_common_map
  #   end
  # end

  def start_row(optional)
    return '<tr class="warning">' if optional
    return '<tr>'
  end

  def end_row
    return "</tr>"
  end

  def markdown_row(markdown)
    return "<tr><td colspan=\"3\"><p>#{MarkdownEngine::render(markdown)}</p></td></tr>"
  end

  def question_cell(text)
    return "<td>#{text}</td>"
  end

  def mapping_cell(text, options)
    return "<td>#{text}</td>" if !text.empty? && options[:annotate]
    return empty_cell
  end

  def empty_cell
    return "<td></td>"
  end

  # Format input field
  def input_field
    html = '<td>'
    datatype = XSDDatatype.new(self.datatype)
    if datatype.datetime?
      html += field_table(["D", "D", "/", "M", "M", "M", "/", "Y", "Y", "Y", "Y", "", "H", "H", ":", "M", "M"])
    #elsif datatype.date?
    #  html += field_table(["D", "D", "/", "M", "M", "M", "/", "Y", "Y", "Y", "Y"])
    #elsif datatype.time?
    #  html += field_table(["H", "H", ":", "M", "M"])
    elsif datatype.float?
      self.format = "5.1" if self.format.blank?
      parts = self.format.split('.')
      major = parts[0].to_i
      minor = parts[1].to_i
      pattern = ["#"] * major
      pattern[major-minor-1] = "."
      html += field_table(pattern)
    elsif datatype.integer?
      count = self.format.to_i
      html += field_table(["#"]*count)
    elsif datatype.string?
      length = self.format.scan /\w/
      html += field_table([" "]*5 + ["S"] + length + [""]*5)
    elsif datatype.boolean?
      html += '<input type="checkbox">'
    else
      html += field_table(["?", "?", "?"])
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

  def coded_values_to_hash(coded_values)
    results = []
    coded_values.each do |cv|
      ref = cv.to_h
      ref[:reference] = Thesaurus::UnmanagedConcept.find(cv.reference).to_h
      parent = Thesaurus::ManagedConcept.find_with_properties(cv.context)
      ref[:context] = {id: parent.id, uri: parent.uri.to_s, identifier: parent.has_identifier.identifier, notation: parent.notation, semantic_version: parent.has_identifier.semantic_version}
      results << ref
    end
    results
  end

end