class Form::Item::Common < Form::Item::BcProperty

  configure rdf_type: "http://www.assero.co.uk/BusinessForm#CommonItem",
            uri_suffix: "CI",  
            uri_property: :ordinal

  object_property :has_common_item, cardinality: :many, model_class: "Form::Item::BcProperty"

  # Get Item
  #
  # @return [Hash] A hash of Common Item
  def get_item
    blank_fields = {datatype:"", format:"", question_text:"", mapping:"", free_text:"", label_text:"", has_coded_value: [], has_property: {}}
    return self.to_h.merge!(blank_fields)
  end

  # To CRF
  #
  # @return [String] An html string of Common Item
  def to_crf
    html = ""
    common_item = self.has_common_item.first
    property = BiomedicalConcept::PropertyX.find(common_item.has_property.reference)
    html += start_row(self.optional)
    html += question_cell(property.question_text)
    if property.has_coded_value.length == 0
      html += input_field(property)
    else
      html += terminology_cell(property)
    end
    html += end_row
  end

  def children_ordered(child)
    self.has_common_item_objects.sort_by {|x| x.ordinal} 
  end

  def delete(parent)
    update_query = %Q{
      DELETE DATA
      {
        #{parent.uri.to_ref} bf:hasItem #{self.uri.to_ref} 
      };
      DELETE {?s ?p ?o} WHERE 
      { 
        {  
          BIND (#{self.uri.to_ref} as ?s) .
          ?s ?p ?o .
        }
      }
    }
    partial_update(update_query, [:bf])
    reset_ordinals(parent)
    common_group = Form::Group::Common.find(parent.uri)
    normal_group_hash = Form::Group::Normal.find_full(get_normal_group(common_group).first).to_h
    full_normal_group(normal_group_hash)
    normal_group_hash
  end

  private

    # Normal group hash
    #
    # @return [Hash] Return the data of the whole parent Normal Group, all its children BC Groups, Common Group + any referenced item data.
    def full_normal_group(normal_group)
      normal_group[:has_item].each do |item|
        get_referenced_item(item)
      end
      normal_group[:has_common].first[:has_item].each do |item|
        get_referenced_item(item)
      end
      normal_group[:has_common].first[:has_item].each do |item|
        item[:has_common_item].each do |ci|
          get_referenced_item(ci)
        end
      end
      normal_group[:has_sub_group].each do |sg|
        sg[:has_item].each do |item|
          get_referenced_item(item)
        end
      end
      normal_group
    end

    def get_normal_group(common_group)
      query_string = %Q{         
        SELECT ?normal_group WHERE 
        {
          #{common_group.uri.to_ref} ^bf:hasCommon ?normal_group. 
        }
      }     
      query_results = Sparql::Query.new.query(query_string, "", [:bf])
      query_results.by_object(:normal_group)
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

end