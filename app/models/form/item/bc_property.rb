class Form::Item::BcProperty < Form::Item

  configure rdf_type: "http://www.assero.co.uk/BusinessForm#BcProperty",
            uri_suffix: "BP",  
            uri_property: :ordinal

  data_property :is_common

  object_property :has_property, cardinality: :many, model_class: "OperationalReferenceV3"
  object_property :has_coded_value, cardinality: :many, model_class: "OperationalReferenceV3::TucReference"

  # Get Item
  #
  # @return [Hash] A hash of Bc Property Item with CLI and CL references.
  def get_item
    blank_fields = {datatype:"", format:"", question_text:"", mapping:"", free_text:"", label_text:""}
    item = self.to_h.merge!(blank_fields)
    item[:has_coded_value] = coded_values_to_hash(self.has_coded_value)
    item[:has_property] = properties_to_hash(self.has_property)
    return item
  end

  def properties_to_hash(properties)
    results = []
    properties.each do |pr|
      ref = pr.to_h
      ref[:reference] = BiomedicalConcept::PropertyX.find(ref[:id]).to_h
      results << ref
    end
    results
  end

  def to_crf
    html = ""
    if !self.is_common
      property_ref = self.has_property.first.reference
      property = BiomedicalConcept::PropertyX.find(property_ref)
      html += start_row(self.optional)
      html += question_cell(property.question_text)
      if property.has_coded_value.length == 0
        html += property.input_field
      else
        html += terminology_cell
      end
      html += end_row
    end
    return html
  end

  # def build_common_map
  #   if self.is_common
  #     property_ref = self.has_property.first.reference
  #     property = BiomedicalConcept::PropertyX.find(property_ref)
  #     node = property.to_h
  #     common_map[property.uri.to_s] = node if !common_map.has_key?(property.uri.to_s)        
  #   end
  #   return common_map
  # end

 end