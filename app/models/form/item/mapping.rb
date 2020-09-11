class Form::Item::Mapping < Form::Item

  configure rdf_type: "http://www.assero.co.uk/BusinessForm#Mapping",
            uri_suffix: "MA",  
            uri_property: :ordinal

  data_property :mapping

  validates_with Validator::Field, attribute: :mapping, method: :valid_mapping?

  # Get Item
  #
  # @return [Hash] A hash of Mapping Item
  def get_item
    blank_fields = {datatype:"", format:"", question_text:"", free_text:"", label_text:"", has_coded_value: [], has_property: {}}
    return self.to_h.merge!(blank_fields)
  end

  # To CRF
  #
  # @return [String] An html string of Mapping item
  def to_crf
    html = ""
    #html += mapping_row(self.mapping) #if options[:annotate]
  end

private
  
  def mapping_row(mapping)
    return "<tr><td>#{mapping}</td><td colspan=\"2\"></td></tr>"
  end

end