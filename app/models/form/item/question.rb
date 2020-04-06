class Form::Item::Question < Form::Item

  configure rdf_type: "http://www.assero.co.uk/BusinessForm#Question",
            uri_suffix: "Q"

  data_property :datatype 
  data_property :format 
  data_property :mapping
  data_property :question_text 
  #data_property :tc_refs

  object_property :has_code_value, cardinality: :many, model_class: "Thesaurus::UnmanagedConcept"

  #validates_with Validator::Field, attribute: :datatype, method: :valid_datatype?
  validates_with Validator::Field, attribute: :format, method: :valid_format?
  validates_with Validator::Field, attribute: :mapping, method: :valid_mapping?
  validates_with Validator::Field, attribute: :question_text, method: :valid_question?
  
#   # Thesaurus Concepts
#   #
#   # @return [object] An array of Thesaurus Concepts
#   def thesaurus_concepts
#     results = Array.new
#     self.tc_refs.each do |ref|
#       results << ThesaurusConcept.find(ref.subject_ref.id, ref.subject_ref.namespace, false)
#     end
#     return results
#   end
  
#   # To XML
#   #
#   # @param [Nokogiri::Node] metadata_version the ODM MetaDataVersion node
#   # @param [Nokogiri::Node] form_def the ODM FormDef node
#   # @param [Nokogiri::Node] item_group_def the ODM ItemGroupDef node
#   # @return [void]
#   def to_xml(metadata_version, form_def, item_group_def)
#     super(metadata_version, form_def, item_group_def)
#     xml_datatype = BaseDatatype.to_odm(self.datatype)
#     xml_length = to_xml_length(self.datatype, self.format)
#     xml_digits = to_xml_significant_digits(self.datatype, self.format)
#     item_def = metadata_version.add_item_def("#{self.id}", "#{self.label}", "#{xml_datatype}", "#{xml_length}", "#{xml_digits}", "", "", "", "")
#     question = item_def.add_question()
#     question.add_translated_text("#{self.question_text}")
#     if tc_refs.length > 0
#       self.tc_refs.sort_by! {|u| u.ordinal}
#       code_list_ref = item_def.add_code_list_ref("#{self.id}-CL")
#       code_list = metadata_version.add_code_list("#{self.id}-CL", "Code list for #{self.label}", "text", "")
#       self.tc_refs.each do |tc_ref|
#         tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri: tc_ref.subject_ref.to_s))
#         code_list_item = code_list.add_code_list_item(tc.notation, "", "#{tc_ref.ordinal}")
#         decode = code_list_item.add_decode()
#         decode.add_translated_text(tc.label)
#       end
#     end
#   end

# private

#   def self.children_from_triples(object, triples, id)
#     links = object.get_links_v2(C_SCHEMA_PREFIX, "hasThesaurusConcept")
#     links.each do |link|
#       object.tc_refs << OperationalReferenceV2.find_from_triples(triples, link.id)
#     end      
#   end

end
