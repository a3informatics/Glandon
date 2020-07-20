class Form::Item::Common < Form::Item

  configure rdf_type: "http://www.assero.co.uk/BusinessForm#CommonItem",
            uri_suffix: "COI",  
            uri_property: :ordinal

  object_property :has_common_item, cardinality: :many, model_class: "Form::Item::BcProperty"

  # Get Item
  #
  # @return [Hash] A hash of Common Item
  def get_item
    blank_fields = {datatype:"", format:"", question_text:"", mapping:"", free_text:"", label_text:"", has_coded_value: [], has_property: []}
    return self.to_h.merge!(blank_fields)
  end

#   # To XML
#   #
#   # @param [Nokogiri::Node] metadata_version the ODM MetaDataVersion node
#   # @param [Nokogiri::Node] form_def the ODM FormDef node
#   # @param [Nokogiri::Node] item_group_def the ODM ItemGroupDef node
#   # @return [void]
#   def to_xml(metadata_version, form_def, item_group_def)
#     # Do nothing currently
#   end

end