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
  #   if self.repeating
  #     html += repeating_bc_group
  #   else
  #     self.has_item.sort_by {|x| x.ordinal}.each do |item|
  #       html += item.to_crf
  #     end
  #     self.has_common.sort_by {|x| x.ordinal}.each do |c|
  #       html += c.to_crf 
  #     end
  #     self.has_biomedical_concept.sort_by {|x| x.ordinal}.each do |bc|
  #       html += bc.to_crf 
  #     end
  #   end
  #   return html
  # end

  # # Repeating BC group
  # def repeating_bc_group
  #   html = ""
  #   html += '<td colspan="3"><table class="table table-striped table-bordered table-condensed">'
  #   html += '<tr>'
  #   columns = {}
  #   self.has_sub_group.sort_by {|x| x.ordinal}.each do |sg|
  #     sg.has_item.sort_by {|x| x.ordinal}.each do |item|
  #       property = BiomedicalConcept::PropertyX.find(item.has_property.first.reference)
  #       #if property.enabled && property.collect
  #         if !columns.has_key?(property.uri.to_s)
  #           columns[property.uri.to_s] = property.uri.to_s
  #         end
  #       #end
  #     end
  #   end
  #   # Question text
  #   html += start_row(false)
  #   self.has_sub_group.sort_by {|x| x.ordinal}.each do |sg|
  #     sg.has_item.sort_by {|x| x.ordinal}.each do |item|
  #       property = BiomedicalConcept::PropertyX.find(item.has_property.first.reference)
  #         if !columns.has_key?(property.uri.to_s)
  #           html += question_cell(property.question_text)
  #         end
  #     end
  #   end
  #   html += end_row
  #   # BCs and the input fields
  #   self.has_sub_group.sort_by {|x| x.ordinal}.each do |sg|
  #     html += start_row(false)
  #     sg.has_item.sort_by {|x| x.ordinal}.each do |item|
  #       property = BiomedicalConcept::PropertyX.find(item.has_property.first.reference)
  #         if columns.has_key?(property.uri.to_s)
  #           if property.has_coded_value.length == 0
  #             html += property.input_field
  #           else
  #             html += terminology_cell(property)
  #           end
  #         end
  #     end
  #     html += end_row
  #   end
  #   html += '</tr>'
  #   html += '</table></td>'
  #   return html
  # end

  # def terminology_cell(property)
  #   html = '<td>'
  #   property.has_coded_value.each do |cv|
  #     op_ref = OperationalReferenceV3.find(cv)
  #     tc = Thesaurus::UnmanagedConcept.find(op_ref.reference)
  #     if op_ref.enabled
  #       html += "<p><input type=\"radio\" name=\"#{tc.identifier}\" value=\"#{tc.identifier}\"></input>#{tc.label}</p>"
  #     end
  #   end
  #   html += '</td>'
  # end

  # def start_row(optional)
  #   return '<tr class="warning">' if optional
  #   return '<tr>'
  # end

  # def end_row
  #   return "</tr>"
  # end

  # def build_common_map
  #   self.has_item.sort_by {|x| x.ordinal}.each do |item|
  #     item.build_common_map
  #   end
  #   self.has_sub_group.sort_by {|x| x.ordinal}.each do |sg|
  #     sg.build_common_map
  #   end
  #   self.has_common.sort_by {|x| x.ordinal}.each do |cg|
  #     cg.build_common_map
  #   end
  # end

end