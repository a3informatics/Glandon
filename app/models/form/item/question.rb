class Form::Item::Question < Form::Item

  configure rdf_type: "http://www.assero.co.uk/BusinessForm#Question",
            uri_suffix: "Q",  
            uri_property: :ordinal

  data_property :datatype 
  data_property :format 
  data_property :mapping
  data_property :question_text 

  object_property :has_coded_value, cardinality: :many, model_class: "OperationalReferenceV3::TucReference"


  validates_with Validator::Field, attribute: :format, method: :valid_format?
  validates_with Validator::Field, attribute: :mapping, method: :valid_mapping?
  validates_with Validator::Field, attribute: :question_text, method: :valid_question?

  # Get Item
  #
  # @return [Hash] A hash of Question Item with CLI and CL references.
  def get_item
    blank_fields = {free_text:"", label_text:"", has_property: []}
    item = self.to_h.merge!(blank_fields)
    coded_value = []
    item[:has_coded_value].each do |cv|
      tc = OperationalReferenceV3::TucReference.find_children(Uri.new(uri:cv)).to_h
      parent = Thesaurus::ManagedConcept.find_with_properties(Uri.new(uri: tc[:context][:uri]))
      tc[:context] = {id: parent.id, uri: parent.uri.to_s, identifier: parent.has_identifier.identifier, notation: parent.notation, semantic_version: parent.has_identifier.semantic_version}
      coded_value << tc
    end
    item[:has_coded_value] = coded_value
    return item
  end
  
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

end