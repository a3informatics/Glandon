class Form::Group::Common < Form::Group

  configure rdf_type: "http://www.assero.co.uk/BusinessForm#CommonGroup",
            uri_suffix: "CG"

  object_property_class :has_item, model_class: Form::Item::Common

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
    results
  end

  # To CRF
  def to_crf
    html = ""
    html += text_row(self.label)
    self.has_item.sort_by {|x| x.ordinal}.each do |item|
      html += item.to_crf
    end
    return html
  end

  # def build_common_map
  #   self.has_item.sort_by {|x| x.ordinal}.each do |item|
  #     item.build_common_map
  #   end
  # end

end