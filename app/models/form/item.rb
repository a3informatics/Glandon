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

private

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

  def terminology_cell(node, annotations, options)
    html = '<td>'
    node[:children].each do |child|
      html += crf_node(child, annotations, options)
    end
    html += '</td>'
    return html
  end

  # Format input field
  def input_field(node, annotations)
    html = '<td>'
  byebug
    if self.datatype == BaseDatatype::C_DATETIME
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
    elsif node[:datatype] == BaseDatatype::C_BOOLEAN
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
    cell_content.each_with_index do |cell, index|
      html += "<td>#{cell}</td>"
    end
    html += "</tr></table>"
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