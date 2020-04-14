class Form::Item::Placeholder < Form::Item

   configure rdf_type: "http://www.assero.co.uk/BusinessForm#Placeholder",
             uri_suffix: "PL",  
            uri_property: :ordinal

   data_property :free_text
  
   validates_with Validator::Field, attribute: :free_text, method: :valid_markdown?
 
  # To XML
  #
  # @param [Nokogiri::Node] metadata_version the ODM MetaDataVersion node
  # @param [Nokogiri::Node] form_def the ODM FormDef node
  # @param [Nokogiri::Node] item_group_def the ODM ItemGroupDef node
  # @return [void]
  # def to_xml(metadata_version, form_def, item_group_def)
  #   super(metadata_version, form_def, item_group_def)
  #   item_def = metadata_version.add_item_def("#{self.id}", "#{self.label}", "", "", "", "", "", "", "")
  #   question = item_def.add_question()
  #   question.add_translated_text("#{self.free_text}")
  # end

 end
