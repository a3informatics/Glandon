class Form::Group::Normal < Form::Group

  configure rdf_type: "http://www.assero.co.uk/BusinessForm#NormalGroup",
            uri_suffix: "NG",
            uri_property: :ordinal

  data_property :repeating

  object_property :has_common, cardinality: :many, model_class: "Form::Group::Common"
  object_property :has_sub_group, cardinality: :many, model_class: "Form::Group::Normal"
  object_property :has_biomedical_concept, cardinality: :many, model_class: "OperationalReferenceV3"


  validates_with Validator::Field, attribute: :repeating, method: :valid_boolean?

  # Get Item
  #
  # @return [Array] Array of hashes, one per group, sub group and item.
  def get_item
    blank_fields = {datatype:"", format:"", question_text:"", mapping:"", free_text:"", label_text:"", has_coded_value: [], has_property: []}
    groups = []
    items = []
    results = [self.to_h.merge!(blank_fields)]
    self.has_item_objects.sort_by {|x| x.ordinal}.each do |item|
      items << item.get_item
    end
    results += items
    self.has_sub_group_objects.sort_by {|x| x.ordinal}.each do |sg|
      groups += sg.get_item
    end
    results += groups
    return results
  end

end