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
    coded_value = []
    blank_fields = {free_text:"", label_text:"", has_property: []}
    item = self.to_h.merge!(blank_fields)
    item[:has_coded_value] = coded_values_to_hash(self.has_coded_value)
    # self.has_coded_value.each do |cv|
    #   ref = cv.to_h
    #   ref[:reference] = Thesaurus::ManagedConcept.find(cv.reference).to_h
    #   parent = Thesaurus::ManagedConcept.find_with_properties(cv.context)
    #   ref[:context] = {id: parent.id, uri: parent.uri.to_s, identifier: parent.has_identifier.identifier, notation: parent.notation, semantic_version: parent.has_identifier.semantic_version}
    #   coded_value << ref
    # end
    # item[:has_coded_value] = coded_value
    return item
  end

  def to_crf
    html = ""
    html += start_row(self.optional)
    html += question_cell(self.question_text)
    #qa = question_annotations(node[:id], node[:mapping], annotations, options)
    #html += mapping_cell(qa, options)
    #if node[:children].length == 0
      #html += input_field(node, annotations)
      #html += input_field
    #else
      #html += terminology_cell(node, annotations, options)
      #html += terminology_cell
    #end
    html += end_row
  end

private
  
  def question_cell(text)
    return "<td>#{text}</td>"
  end

end