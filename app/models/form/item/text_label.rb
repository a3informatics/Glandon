class Form::Item::TextLabel < Form::Item

  configure rdf_type: "http://www.assero.co.uk/BusinessForm#TextLabel",
            uri_suffix: "TL",  
            uri_property: :ordinal

  data_property :label_text
  
  validates_with Validator::Field, attribute: :label_text, method: :valid_markdown?

  # Get Item
  #
  # @return [Hash] A hash of Text Label Item
  def get_item
    blank_fields = {datatype:"", format:"", question_text:"", mapping:"", free_text:"", has_coded_value: [], has_property: {}}
    return self.to_h.merge!(blank_fields)
  end

  # To CRF
  #
  # @return [String] An html string of Text Label Item
  def to_crf
    html = ""
    html += markdown_row(self.label_text)
  end

end