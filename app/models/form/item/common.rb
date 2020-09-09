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
    common_item = self.has_common_item.first
    property = BiomedicalConcept::PropertyX.find(common_item.uri)
    html += start_row(self.optional)
    html += question_cell(property.question_text)
    if property.has_coded_value.length == 0
      html += input_field(property)
    else
      html += terminology_cell(property)
    end
    html += end_row
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
  end

end