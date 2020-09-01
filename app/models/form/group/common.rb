class Form::Group::Common < Form::Group

  configure rdf_type: "http://www.assero.co.uk/BusinessForm#CommonGroup",
            uri_suffix: "CG"

  object_property_class :has_item, model_class: Form::Item::Common

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