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
    if self.repeating && is_question_only_group?
      html += repeating_question_group(node, annotations, options)
    elsif self.repeating && is_bc_only_group?
      html += repeating_bc_group(node, annotations, options)
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

private

  # Is a BC only group
  def is_bc_only_group?
    # node[:children].each do |child|
    #   return false if child[:type] != Form::Group::Normal::C_RDF_TYPE_URI.to_s 
    #   return false if child[:bc_ref].blank? 
    #   return false if child[:bc_ref][:subject_ref].blank? 
    # end
    return true
  end

  # Is a Question only group
  def is_question_only_group?
    # node[:children].each do |child|
    #   return false if child[:type] != Form::Item::Question::C_RDF_TYPE_URI.to_s && 
    #     child[:type] != Form::Item::Mapping::C_RDF_TYPE_URI.to_s &&
    #     child[:type] != Form::Item::TextLabel::C_RDF_TYPE_URI.to_s 
    # end
    return true
  end

  # Repeating Question group
  def self.repeating_question_group(node, annotations, options)
    html = ""
    # Put the labels and mappings out first
    node[:children].each do |child|
      if node[:type] == Form::Item::TextLabel::C_RDF_TYPE_URI.to_s
        html += markdown_row(node)
      elsif node[:type] == Form::Item::Mapping::C_RDF_TYPE_URI.to_s
        html += mapping_row(node)
      end
    end
    # Now the questions
    html += '<td colspan="3"><table class="table table-striped table-bordered table-condensed">'
    html += '<tr>'
    node[:children].each do |child|
      if child[:type] == Form::Item::Question::C_RDF_TYPE_URI.to_s
        html += question_cell(child[:question_text])
      elsif child[:type] == Form::Item::TextLabel::C_RDF_TYPE_URI.to_s ||
        child[:type] == Form::Item::Mapping::C_RDF_TYPE_URI.to_s
        # do nothing
      else
        html += question_cell("Incorrect type: #{child[:type]}")
      end
    end
    html += '</tr>'
    if options[:annotate]
      html += '<tr>'
      node[:children].each do |child|
        if child[:type] == Form::Item::Question::C_RDF_TYPE_URI.to_s
          qa = question_annotations(child[:id], child[:mapping], annotations, options)
          html += mapping_cell(qa, options)
        elsif child[:type] == Form::Item::TextLabel::C_RDF_TYPE_URI.to_s ||
          child[:type] == Form::Item::Mapping::C_RDF_TYPE_URI.to_s
          # do nothing
        else
          html += empty_cell
        end
      end 
      html += '</tr>'
    end
    html += '<tr>'
    node[:children].each do |child|
      if child[:type] == Form::Item::Question::C_RDF_TYPE_URI.to_s
        html += input_field(child, annotations)
      elsif child[:type] == Form::Item::TextLabel::C_RDF_TYPE_URI.to_s ||
        child[:type] == Form::Item::Mapping::C_RDF_TYPE_URI.to_s
        # do nothing
      else
        html += empty_cell
      end
    end 
    html += '</tr>'
    html += '</table></td>'
    #ConsoleLogger::log(C_CLASS_NAME, "repeating_question_group", "html=#{html}")  
    return html
  end

  # Repeating BC group
  def self.repeating_bc_group(node, annotations, options)
    html = ""
    html += '<td colspan="3"><table class="table table-striped table-bordered table-condensed">'
    html += '<tr>'
    columns = {}
    node[:children].each do |bc_node|
      bc_node[:children].each do |property_node|
        ref = property_node[:property_ref][:subject_ref]
        property = BiomedicalConceptCore::Property.find(ref[:id], ref[:namespace])
        #property_node.deep_merge!(property.to_json)
        property_node[:bridg_path] = property.bridg_path
        property_node[:question_text] = property.question_text
        #property_node[:children] = property.tc_refs
        property_node[:datatype] = property.simple_datatype
          
        if property.enabled && property.collect
          if !columns.has_key?(property_node[:bridg_path])
            columns[property_node[:bridg_path]] = property_node[:bridg_path] 
          end
        end
      end
    end
    # Question text
    html += start_row(false)
    bc_node = node[:children][0]
    bc_node[:children].each do |property_node|
      if columns.has_key?(property_node[:bridg_path])
        html += question_cell(property_node[:question_text])
      end
    end
    html += end_row
    # Annotation. Commented out, gives a block of annotations
    #html += start_row(false)
    #columns.each do |key, bridg_path|
    #  pa = ""
    #  node[:children].each do |bc_node|
    #    bc_node[:children].each do |property_node|
    #      if property_node[:bridg_path] == bridg_path
    #        pa += property_annotations(property_node[:id], annotations, options)
    #      end
    #    end
    #  end
    #  html += mapping_cell(pa, options)
    #end
    #html += end_row
    # BCs and the input fields
    node[:children].each do |bc_node|
      html += start_row(false)
      bc_node[:children].each do |property_node|
        if columns.has_key?(property_node[:bridg_path])
          if property_node[:children].length == 0
            html += input_field(property_node, annotations)
          else
            html += terminology_cell(property_node, annotations, options)
          end
        end
      end
      html += end_row
      html += start_row(false)
      bc_node[:children].each do |property_node|
        if columns.has_key?(property_node[:bridg_path])
          pa = property_annotations(property_node[:id], annotations, options)
          html += mapping_cell(pa, options)
        end
      end
      html += end_row
    end
    html += '</tr>'
    html += '</table></td>'
    return html
  end

end