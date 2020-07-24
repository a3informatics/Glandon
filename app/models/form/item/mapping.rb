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
    blank_fields = {datatype:"", format:"", question_text:"", free_text:"", label_text:"", has_coded_value: [], has_property: []}
    return self.to_h.merge!(blank_fields)
  end

  # # To XML
  # #
  # # @param [Nokogiri::Node] metadata_version the ODM MetaDataVersion node
  # # @param [Nokogiri::Node] form_def the ODM FormDef node
  # # @param [Nokogiri::Node] item_group_def the ODM ItemGroupDef node
  # # @return [void]
  # def to_xml(metadata_version, form_def, item_group_def)
  #   # Do nothing currently
  # end

 end