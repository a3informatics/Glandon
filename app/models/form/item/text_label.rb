# Form Text Label. Handles the text label item specfic actions.
# Based on earlier implementation.
#
# @author Clarisa Romero
# @since 3.2.0
class Form::Item::TextLabel < Form::Item

  configure rdf_type: "http://www.assero.co.uk/BusinessForm#TextLabel",
            uri_suffix: "TL", 
            uri_unique: true 
#           uri_property: :ordinal

  data_property :label_text
  
  validates_with Validator::Field, attribute: :label_text, method: :valid_markdown?

  # Get Item
  #
  # @return [Array] An array of Text Label Item
  def get_item
    blank_fields = {datatype:"", format:"", question_text:"", mapping:"", free_text:"", has_coded_value: [], has_property: {}}
    [self.to_h.merge!(blank_fields)]
  end

  # To CRF
  #
  # @return [String] An html string of Text Label Item
  def to_crf
    markdown_row(self.label_text)
  end

end