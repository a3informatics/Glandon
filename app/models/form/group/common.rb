class Form::Group::Common < Form::Group

  configure rdf_type: "http://www.assero.co.uk/BusinessForm#CommonGroup",
            uri_suffix: "CG"
            
  object_property_class :has_item, model_class: Form::Item::Common

  # Get Item
  #
  # @return [Array] Array of hashes, one per group, sub group and item.
  def get_item
    blank_fields = {datatype:"", format:"", question_text:"", mapping:"", free_text:"", label_text:"", has_coded_value: [], has_property: {}}
    group = self.to_h.merge!(blank_fields)
    group.delete(:has_item)
    results = [group]
    self.has_item_objects.sort_by {|x| x.ordinal}.each do |item|
      results += item.get_item
    end
    results
  end

  # To CRF
  #
  # @return [String] An html string of Common group
  def to_crf
    html = ""
    html += text_row(self.label)
    self.has_item.sort_by {|x| x.ordinal}.each do |item|
      html += item.to_crf
    end
    return html
  end

  def delete(parent)
    super(parent)
    normal_group = Form::Group::Normal.find_full(parent.uri)
    normal_group = normal_group.full_data
  end

  def children_ordered
    self.has_item_objects.sort_by {|x| x.ordinal}
  end

  def get_normal_group
    query_string = %Q{         
      SELECT ?normal_group WHERE 
      { #{self.uri.to_ref} ^bf:hasCommon ?normal_group. }
    }     
    query_results = Sparql::Query.new.query(query_string, "", [:bf])
    query_results.by_object(:normal_group).first
  end

  # Full data
  #
  # @return [Hash] Return the data of the whole node
  def full_data
    group = self.to_h
    group[:has_item] = []
    self.has_item_objects.sort_by {|x| x.ordinal}.each do |item|
      group[:has_item] << item.full_data
    end
    group
  end

end