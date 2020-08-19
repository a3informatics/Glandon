class Form::Group::Common < Form::Group

  configure rdf_type: "http://www.assero.co.uk/BusinessForm#CommonGroup",
            uri_suffix: "CG"

  # To CRF
  def to_crf
    html = ""
    html += text_row(self.label)
    self.has_item.each do |item|
      html += item.to_crf
    end
    return html
  end

#   # To XML
#   #
#   # @param [Nokogiri::Node] metadata_version the ODM MetaDataVersion node
#   # @param [Nokogiri::Node] form_def the ODM FormDef node
#   # @param [Nokogiri::Node] item_group_def the ODM ItemGroupDef node
#   # @return [void]
#   def to_xml(metadata_version, form_def)
#     super(metadata_version, form_def)
#   end

end