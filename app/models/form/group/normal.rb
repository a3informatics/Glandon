class Form::Group::Normal < Form::Group

  configure rdf_type: "http://www.assero.co.uk/BusinessForm#NormalGroup",
            uri_suffix: "NG",
            uri_property: :ordinal

  data_property :repeating

  object_property :has_sub_group, cardinality: :many, model_classes: [ "Form::Group::Normal", "Form::Group::Bc" ]

  object_property_class :has_item, model_classes: 
    [ 
      Form::Item::Mapping, Form::Item::Placeholder, Form::Item::Question, Form::Item::TextLabel 
    ]

  validates_with Validator::Field, attribute: :repeating, method: :valid_boolean?

  # Get Item
  #
  # @return [Array] Array of hashes, one per group, sub group and item.
  def get_item
    blank_fields = {datatype:"", format:"", question_text:"", mapping:"", free_text:"", label_text:"", has_coded_value: [], has_property: []}
    group = self.to_h.merge!(blank_fields)
    group.delete(:has_sub_group)
    group.delete(:has_item)
    results = [group]
    self.has_item.sort_by {|x| x.ordinal}.each do |item|
      results << item.get_item
    end
    self.has_sub_group.sort_by {|x| x.ordinal}.each do |sg|
      results += sg.get_item
    end
    results
  end

  def to_crf
    html = ""
    html += text_row(self.label)
    if self.repeating && self.is_question_only_group?
      html += repeating_question_group
    elsif self.repeating && self.is_bc_only_group?
      html += repeating_bc_group
    elsif self.is_bc_common?
      html += bc_common_group
    else 
      self.has_item.sort_by {|x| x.ordinal}.each do |item|
        html += item.to_crf
      end
      self.has_sub_group.sort_by {|x| x.ordinal}.each do |sg|
        html += sg.to_crf
      end
    end
    return html
  end

  # Is a Question only group
  def is_question_only_group?
    if self.class == Form::Group::Normal
      self.has_sub_group.each do |sg|
        sg.is_question_only_group? if sg.class == Form::Group::Normal
      end
    end
    self.has_item.each do |item|
      return true if item.class == Form::Item::Question || item.class == Form::Item::Mapping || item.class == Form::Item::TextLabel 
    end
    return false
  end

  # Is a BC only group
  def is_bc_only_group?
    self.has_item.each do |item|
      return false if item.class != Form::Item::BcProperty
    end
    if self.class == Form::Group::Normal
      self.has_sub_group.each do |sg|
        sg.is_bc_only_group? if sg.class == Form::Group::Normal
      end
    end
    return true
  end

  # Is a BC group with common group
  def is_bc_common?
    self.has_sub_group.each do |sg|
      if sg.class == Form::Group::Bc
        if !sg.has_common.empty?
          return true
        end
      end
    end
    return false
  end

  #BC common group
  def bc_common_group
    html = ""
    items = {}
    self.has_sub_group.sort_by {|x| x.ordinal}.each do |sg|
      html += text_row(sg.label)
      sg.has_item.sort_by {|x| x.ordinal}.each do |item|
        html += item.to_crf
      end
      sg.has_common.sort_by {|x| x.ordinal}.each do |cm|
        if !items.has_key?(cm.label)
            html += cm.to_crf
            items[cm.label] = cm.label
        end
      end   
    end
    return html
  end

  # Repeating Question group
  def repeating_question_group
    html = ""
    # Put the labels and mappings out first
    self.has_sub_group.sort_by {|x| x.ordinal}.each do |sg|
      html += sg.repeating_question_group
    end
    self.has_item.sort_by {|x| x.ordinal}.each do |item|
      html += item.to_crf unless item.class == Form::Item::Question
    end
    # Now the questions
    html += '<td colspan="3"><table class="table table-striped table-bordered table-condensed">'
    html += '<tr>'
    self.has_item.sort_by {|x| x.ordinal}.each do |item|
      html += item.question_cell(item.question_text) if item.class == Form::Item::Question
    end
    html += '</tr>'
    html += '<tr>'
    self.has_item.sort_by {|x| x.ordinal}.each do |item|
      html += item.input_field if item.class == Form::Item::Question
    end
    html += '</tr>'
    html += '</table></td>' 
    return html
  end

  # Repeating BC group
  def repeating_bc_group
    html = ""
    html += '<td colspan="3"><table class="table table-striped table-bordered table-condensed">'
    html += '<tr>'
    columns = {}
    self.has_sub_group.sort_by {|x| x.ordinal}.each do |sg|
      sg.has_item.sort_by {|x| x.ordinal}.each do |item|
        property = BiomedicalConcept::PropertyX.find(item.has_property.first.reference)
        #if property.enabled && property.collect
          if !columns.has_key?(property.uri.to_s)
            columns[property.uri.to_s] = property.uri.to_s
          end
        #end
      end
    end
    # Question text
    html += start_row(false)
    self.has_sub_group.sort_by {|x| x.ordinal}.each do |sg|
      sg.has_item.sort_by {|x| x.ordinal}.each do |item|
        property = BiomedicalConcept::PropertyX.find(item.has_property.first.reference)
          if !columns.has_key?(property.uri.to_s)
            html += question_cell(property.question_text)
          end
      end
    end
    html += end_row
    # BCs and the input fields
    self.has_sub_group.sort_by {|x| x.ordinal}.each do |sg|
      html += start_row(false)
      sg.has_item.sort_by {|x| x.ordinal}.each do |item|
        property = BiomedicalConcept::PropertyX.find(item.has_property.first.reference)
        if columns.has_key?(property.uri.to_s)
          if property.has_coded_value.length == 0
            html += property.input_field
          else
            html += terminology_cell(property)
          end
        end
      end
      html += end_row
      html += start_row(false)
      html += end_row
    end
    html += '</tr>'
    html += '</table></td>'
    return html
  end

  def terminology_cell(property)
    html = '<td>'
    property.has_coded_value.each do |cv|
      op_ref = OperationalReferenceV3.find(cv)
      tc = Thesaurus::UnmanagedConcept.find(op_ref.reference)
      if op_ref.enabled
        html += "<p><input type=\"radio\" name=\"#{tc.identifier}\" value=\"#{tc.identifier}\"></input>#{tc.label}</p>"
      end
    end
    html += '</td>'
  end

  def start_row(optional)
    return '<tr class="warning">' if optional
    return '<tr>'
  end

  def end_row
    return "</tr>"
  end

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