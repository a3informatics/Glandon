# Form Mapping. Handles the mapping item specfic actions.
# Based on earlier implementation.
#
# @author Clarisa Romero
# @since 3.2.0
class Form::Item::Mapping < Form::Item

  configure rdf_type: "http://www.assero.co.uk/BusinessForm#Mapping",
            uri_suffix: "MA",  
            uri_unique: true 

  data_property :mapping

  validates_with Validator::Field, attribute: :mapping, method: :valid_mapping?

  # Get Item
  #
  # @return [Array] An array of Mapping Item
  def get_item
    blank_fields = {datatype:"", format:"", question_text:"", free_text:"", label_text:"", has_coded_value: [], has_property: {}}
    [self.to_h.merge!(blank_fields)]
  end

  # To CRF
  #
  # @return [String] An html string of Mapping item
  def to_crf(annotations)
    html = ""
    html += mapping_row(self.mapping) if !annotations.nil?
    html
  end

private
  
  def mapping_row(mapping)
    "<tr><td>#{mapping}</td><td colspan=\"2\"></td></tr>"
  end

end