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
    blank_fields = {datatype:"", format:"", question_text:"", mapping:"", free_text:"", has_coded_value: [], has_property: []}
    return self.to_h.merge!(item_blank_fields)
  end

  def to_crf
    html = ""
    html += markdown_row(self.label_text)
  end

  # # To XML
  # #
  # # @param [Nokogiri::Node] metadata_version the ODM MetaDataVersion node
  # # @param [Nokogiri::Node] form_def the ODM FormDef node
  # # @param [Nokogiri::Node] item_group_def the ODM ItemGroupDef node
  # # @return [void]
  # def to_xml(metadata_version, form_def, item_group_def)
  #   super(metadata_version, form_def, item_group_def)
  #   item_def = metadata_version.add_item_def("#{self.id}", "#{self.label}", "#{BaseDatatype.to_odm(BaseDatatype::C_STRING)}", "", "", "", "", "", "")
  #   question = item_def.add_question()
  #   question.add_translated_text("#{self.label_text}")
  # end

end