class Form::Item::Common < Form::Item

  configure rdf_type: "http://www.assero.co.uk/BusinessForm#CommonItem",
            uri_suffix: "COI",  
            uri_property: :ordinal

  object_property :has_common_item, cardinality: :many, model_class: "Form::Item::BcProperty"

  # Get Item
  #
  # @return [Hash] A hash of Common Item
  def get_item
    blank_fields = {datatype:"", format:"", question_text:"", mapping:"", free_text:"", label_text:"", has_coded_value: [], has_property: []}
    return self.to_h.merge!(blank_fields)
  end

  def to_crf
    pa = ""
    uris = []
    node[:item_refs].each { |ref| uris << UriV2.new({:id => ref[:id], :namespace => ref[:namespace]}).to_s } # order to make test result predictable
    uris.sort!
    uris.each do |uri| 
      if @common_map.has_key?(uri)
        other_node = @common_map[uri]
        pa += property_annotations(other_node[:id], annotations, options)
        node[:datatype] = other_node[:simple_datatype]
        node[:question_text] = other_node[:question_text]
        node[:format] = other_node[:format]
        node[:children] = other_node[:children]
      else
        node[:children] = []
      end
    end
    html += start_row(node[:optional])
    html += question_cell(node[:question_text])
    html += mapping_cell(pa, options)
    if node[:children].length == 0
      html += input_field(node, annotations)
    else
      html += terminology_cell(node, annotations, options)
    end
    html += end_row
  end

#   # To XML
#   #
#   # @param [Nokogiri::Node] metadata_version the ODM MetaDataVersion node
#   # @param [Nokogiri::Node] form_def the ODM FormDef node
#   # @param [Nokogiri::Node] item_group_def the ODM ItemGroupDef node
#   # @return [void]
#   def to_xml(metadata_version, form_def, item_group_def)
#     # Do nothing currently
#   end

end