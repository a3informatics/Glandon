# Form Placeholder. Handles placeholder item specfic actions.
# Based on earlier implementation.
#
# @author Clarisa Romero
# @since 3.2.0
class Form::Item::Placeholder < Form::Item

  configure rdf_type: "http://www.assero.co.uk/BusinessForm#Placeholder",
            uri_suffix: "PL",
            uri_unique: true

   data_property :free_text

   validates_with Validator::Field, attribute: :free_text, method: :valid_markdown?

  # Get Item
  #
  # @return [Array] An array of Placeholder
  def get_item
    blank_fields = {datatype:"", format:"", question_text:"", mapping:"", label_text:"", has_coded_value: [], has_property: {}}
    [self.to_h.merge!(blank_fields)]
  end

  # To CRF
  #
  # @return [String] An html string of Placeholder item
  def to_crf(annotations)
    markdown_row(self.free_text)
  end

  # To XML
  #
  # @param [Nokogiri::Node] metadata_version the ODM MetaDataVersion node
  # @param [Nokogiri::Node] form_def the ODM FormDef node
  # @param [Nokogiri::Node] item_group_def the ODM ItemGroupDef node
  # @return [void]
  def to_xml(metadata_version, form_def, item_group_def)
    super(metadata_version, form_def, item_group_def)
    item_def = metadata_version.add_item_def("#{self.id}", "#{self.label}", "", "", "", "", "", "", "")
    question = item_def.add_question()
    question.add_translated_text("#{self.free_text}")
  end

 end
