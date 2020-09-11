class Form::Item::BcProperty < Form::Item

  configure rdf_type: "http://www.assero.co.uk/BusinessForm#BcProperty",
            uri_suffix: "BP",  
            uri_property: :ordinal

  data_property :is_common, default: false

  object_property :has_property, cardinality: :one, model_class: "OperationalReferenceV3"
  object_property :has_coded_value, cardinality: :many, model_class: "OperationalReferenceV3::TucReference"

  validates :is_common, inclusion: { in: [ true, false ] }

  # Get Item
  #
  # @return [Hash] A hash of Bc Property Item with CLI and CL references.
  def get_item
    blank_fields = {datatype:"", format:"", question_text:"", mapping:"", free_text:"", label_text:""}
    item = self.to_h.merge!(blank_fields)
    item[:has_coded_value] = coded_values_to_hash(self.has_coded_value)
    item[:has_property] = property_to_hash(self.has_property)
    return item
  end

  # To CRF
  #
  # @return [String] An html string of BC Property
  def to_crf
    html = ""
    if !self.is_common
      property_ref = self.has_property.reference
      property = BiomedicalConcept::PropertyX.find(property_ref)
      html += start_row(self.optional)
      html += question_cell(property.question_text)
      if property.has_coded_value.length == 0
        html += input_field(property)
      else
        html += terminology_cell
      end
      html += end_row
    end
    return html
  end

  private

    def property_to_hash(property)
      ref = property.to_h
      ref[:reference] = BiomedicalConcept::PropertyX.find(ref[:id]).to_h
      ref
    end

 end