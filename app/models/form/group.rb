class Form::Group < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/BusinessForm#Group",
            uri_suffix: "G",  
            uri_unique: true

  data_property :ordinal, default: 1
  data_property :note
  data_property :completion
  data_property :optional, default: false

  object_property :has_item, cardinality: :many, model_class: Form::Item, 
    model_classes: 
    [ 
      Form::Item::BcProperty, Form::Item::Common, Form::Item::Mapping,
      Form::Item::Placeholder, Form::Item::Question, Form::Item::TextLabel 
    ],
    children: true

  validates_with Validator::Field, attribute: :ordinal, method: :valid_positive_integer?
  validates_with Validator::Field, attribute: :note, method: :valid_markdown?
  validates_with Validator::Field, attribute: :completion, method: :valid_markdown?
  validates :optional, inclusion: { in: [ true, false ] }
  
#   # To XML
#   #
#   # @param [Nokogiri::Node] metadata_version the ODM MetaDataVersion node
#   # @param [Nokogiri::Node] form_def the ODM FormDef node
#   # @param [Nokogiri::Node] item_group_def the ODM ItemGroupDef node
#   # @return [void]
#   def to_xml(metadata_version, form_def)
#     form_def.add_item_group_ref("#{self.id}", "#{self.ordinal}", "No", "")
#     item_group_def = metadata_version.add_item_group_def("#{self.id}", "#{self.label}", "No", "", "", "", "", "", "")
#     self.children.sort_by! {|u| u.ordinal}
#     self.children.each do |item|
#       item.to_xml(metadata_version, form_def, item_group_def)
#     end
#   end

end