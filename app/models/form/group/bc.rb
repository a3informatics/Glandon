class Form::Group::Bc < Form::Group

  configure rdf_type: "http://www.assero.co.uk/BusinessForm#BcGroup",
            uri_suffix: "BCG",
            uri_property: :ordinal

  object_property :has_common, cardinality: :many, model_class: "Form::Group::Common"
  object_property :has_biomedical_concept, cardinality: :many, model_class: "OperationalReferenceV3"

  object_property_class :has_item, model_classes: 
    [ 
      Form::Item::BcProperty, Form::Item::Common
    ]

  # Get Item
  #
  # @return [Array] Array of hashes, one per group, sub group and item.
  def get_item
    blank_fields = {datatype:"", format:"", question_text:"", mapping:"", free_text:"", label_text:"", has_coded_value: [], has_property: []}
    group = self.to_h.merge!(blank_fields)
    group.delete(:has_item)
    results = [group]
    self.has_item.sort_by {|x| x.ordinal}.each do |item|
      results << item.get_item
    end
    self.has_biomedical_concept.sort_by {|x| x.ordinal}.each do |bc|
      bc = BiomedicalConceptInstance.find(bc.reference)
      blank_fields = {datatype:"", format:"", question_text:"", mapping:"", free_text:"", label_text:""}
      bc = bc.to_h.merge!(blank_fields)
      results << bc
    end
    self.has_common.sort_by {|x| x.ordinal}.each do |cm|
      results += cm.get_item
    end
    results
  end

  # def to_crf
  #   html = ""
  #   html += text_row(self.label)
  #   self.has_item.sort_by {|x| x.ordinal}.each do |item|
  #     html += item.to_crf
  #   end
  #   self.has_common.sort_by {|x| x.ordinal}.each do |cm|
  #     html += cm.to_crf
  #   end
  #   return html
  # end

end