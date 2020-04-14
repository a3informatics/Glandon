class Form::Item::BcProperty < Form::Item

  configure rdf_type: "http://www.assero.co.uk/BusinessForm#BcProperty",
            uri_suffix: "BP",  
            uri_property: :ordinal

  object_property :has_property, cardinality: :many, model_class: "OperationalReferenceV3"
  object_property :has_coded_value, cardinality: :many, model_class: "Thesaurus::UnmanagedConcept"


#   # To XML
#   #
#   # @param [Nokogiri::Node] metadata_version the ODM MetaDataVersion node
#   # @param [Nokogiri::Node] form_def the ODM FormDef node
#   # @param [Nokogiri::Node] item_group_def the ODM ItemGroupDef node
#   # @return [void]
#   def to_xml(metadata_version, form_def, item_group_def)
#     super(metadata_version, form_def, item_group_def)
#     bc_property = BiomedicalConceptCore::Property.find(property_ref.subject_ref.id, property_ref.subject_ref.namespace)
#     xml_datatype = BaseDatatype.to_odm(bc_property.simple_datatype)
#     xml_length = to_xml_length(bc_property.simple_datatype, bc_property.format)
#     xml_digits = to_xml_significant_digits(bc_property.simple_datatype, bc_property.format)
#     item_def = metadata_version.add_item_def("#{self.id}", "#{self.label}", "#{xml_datatype}", "#{xml_length}", "#{xml_digits}", "", "", "", "")
#     question = item_def.add_question()
#     question.add_translated_text("#{bc_property.question_text}")
#     if children.length > 0
#       code_list_ref = item_def.add_code_list_ref("#{self.id}-CL")
#       code_list = metadata_version.add_code_list("#{self.id}-CL", "Code list for #{self.label}", "text", "")
#       children.each do |tc_ref|
#       	#cli = ThesaurusConcept.find(tc_ref.subject_ref.id, tc_ref.subject_ref.namespace)
#         cli = Thesaurus::UnmanagedConcept.find(Uri.new(fragment: tc_ref.subject_ref.id, namespace: tc_ref.subject_ref.namespace))
#         code_list_item = code_list.add_code_list_item(cli.notation, "", "#{tc_ref.ordinal}")
#         decode = code_list_item.add_decode()
#         decode.add_translated_text(cli.label)
#       end
#     end
#   end

 end
