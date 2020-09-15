class Form::Group::Bc < Form::Group

  configure rdf_type: "http://www.assero.co.uk/BusinessForm#BcGroup",
            uri_suffix: "BCG",
            uri_property: :ordinal

  object_property :has_common, cardinality: :many, model_class: "Form::Group::Common"
  object_property :has_biomedical_concept, cardinality: :one, model_class: "OperationalReferenceV3"

  object_property_class :has_item, model_classes: 
    [ 
      Form::Item::BcProperty, Form::Item::Common
    ]

  # Get Item
  #
  # @return [Array] Array of hashes, one per group, sub group and item.
  def get_item
    blank_fields = {datatype:"", format:"", question_text:"", mapping:"", free_text:"", label_text:"", has_coded_value: [], has_property: {}}
    group = self.to_h.merge!(blank_fields)
    begin
      bci = BiomedicalConceptInstance.find(Uri.new(uri: group[:has_biomedical_concept][:reference]))
    rescue => e
      group.delete(:has_biomedical_concept)
    else
      group[:has_biomedical_concept][:reference] = bci.to_h
    end
    #bci = BiomedicalConceptInstance.find(Uri.new(uri: group[:has_biomedical_concept][:reference]))
    #group[:has_biomedical_concept][:reference] = bci.to_h
    group.delete(:has_item)
    results = [group]
    self.has_item.sort_by {|x| x.ordinal}.each do |item|
      results << item.get_item
    end
    self.has_common.sort_by {|x| x.ordinal}.each do |cm|
      results += cm.get_item
    end
    results
  end

  # To CRF
  #
  # @return [String] An html string of BC Group
  def to_crf
    html = ""
    html += text_row(self.label)
    self.has_item.sort_by {|x| x.ordinal}.each do |item|
      html += item.to_crf
    end
    self.has_common.sort_by {|x| x.ordinal}.each do |cm|
      html += cm.to_crf
    end
    return html
  end

  # # Add child. 
  # #
  # # @return 
  # def self.add_child(parent)
  #     ordinal = self.next_ordinal(:has_sub_group)
  #     child = Form::Group::Bc.create(ordinal: ordinal+1)
  #     return child if child.errors.any?
  #     self.add_link(:has_sub_group, child.uri)
  #     child
  # end

end