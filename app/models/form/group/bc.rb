class Form::Group::Bc < Form::Group

  configure rdf_type: "http://www.assero.co.uk/BusinessForm#BcGroup",
            uri_suffix: "BCG",
            uri_unique: true

  object_property :has_biomedical_concept, cardinality: :one, model_class: "OperationalReferenceV3"

  object_property_class :has_item, model_classes: 
    [ 
      Form::Item::BcProperty, Form::Item::Common
    ]

  # Get Item
  #
  # @return [Array] Array of hashes, one per group, sub group and item.
  def get_item
    blank_fields = {datatype:"", format:"", question_text:"", mapping:"", free_text:"", label_text:"", has_coded_value: [], has_property: {}}
    group = self.to_h.merge!(blank_fields)
    begin
      bci = BiomedicalConceptInstance.find_minimum(Uri.new(uri: group[:has_biomedical_concept][:reference]))
    rescue => e
      group.delete(:has_biomedical_concept)
    else
      group[:has_biomedical_concept][:reference] = bci.to_h
    end
    #bci = BiomedicalConceptInstance.find(Uri.new(uri: group[:has_biomedical_concept][:reference]))
    #group[:has_biomedical_concept][:reference] = bci.to_h
    group.delete(:has_item)
    results = [group]
    self.has_item.sort_by {|x| x.ordinal}.each do |item|
      results << item.get_item
    end
    results
  end

  # To CRF
  #
  # @return [String] An html string of BC Group
  def to_crf
    html = ""
    html += text_row(self.label)
    self.has_item.sort_by {|x| x.ordinal}.each do |item|
      html += item.to_crf
    end
    return html
  end

  def delete(parent)
    unless parent.has_common.empty? #Check if there is a common group
      common_group = Form::Group::Common.find(parent.has_common_objects.first.uri)
      delete_data = ""
      common_group.has_item_objects.each do |common_item|
        self.has_item_objects.each do |bc_property|
          if common_items_with_terminologies?(bc_property, common_item) || common_items_without_terminologies?(bc_property, common_item)
            delete_data += "#{common_item.uri.to_ref} bf:hasCommonItem #{bc_property.uri.to_ref} . "  
            if common_item.has_common_item_objects.count == 1
              common_item.delete(common_group)
            end
          end
        end
      end
    end 
    update_query = %Q{
      DELETE DATA
      {
        #{delete_data}
      };
      DELETE {?s ?p ?o} WHERE 
      {
        { #{self.uri.to_ref} bf:hasItem/bf:hasProperty ?x2 . 
          BIND (?x2 as ?s) . 
          ?s ?p ?o .
        }
        UNION
        { #{self.uri.to_ref} bf:hasItem/bf:hasCodedValue ?x3 . 
          BIND (?x3 as ?s) . 
          ?s ?p ?o .
        }
      }
    }
    partial_update(update_query, [:bf])
    super(parent)
    normal_group = Form::Group::Normal.find_full(parent.uri)
    normal_group = normal_group.full_data(normal_group.to_h)
  end


  def common_items_with_terminologies?(bc_property, common_item)
    common_property?(bc_property, common_item) && common_terminologies?(bc_property, common_item)
  end

  def common_items_without_terminologies?(bc_property, common_item)
    common_property?(bc_property, common_item) && bc_property.has_coded_value.empty?
  end

  def common_property?(bc_property,common_item)
    query_string = %Q{         
      SELECT ?result WHERE
      {BIND ( EXISTS {#{bc_property.uri.to_ref} bf:hasProperty/bo:reference/bc:isA ?ref. 
                      #{common_item.uri.to_ref} bf:hasProperty/bo:reference/bc:isA ?ref } as ?result )} 
    }     
    query_results = Sparql::Query.new.query(query_string, "", [:bf, :bo, :bc])
    query_results.by_object(:result).first.to_bool
  end

  def common_terminologies?(bc_property, common_item)
    query_string = %Q{
      SELECT ?result WHERE
      {BIND ( EXISTS {#{bc_property.uri.to_ref} bf:hasCodedValue/bo:reference ?cli. 
                      #{common_item.uri.to_ref} bf:hasCodedValue/bo:reference ?cli } as ?result )} 
    }
    query_results = Sparql::Query.new.query(query_string, "", [:bf, :bo])
    query_results.by_object(:result).first.to_bool
  end 

  def children_ordered
    self.has_item_objects.sort_by {|x| x.ordinal}
  end

  # Full parent
  #
  # @return [Hash] Return the data of the whole parent
  def full_data(parent)
    parent[:has_item].each do |item|
      get_ref_item(item) unless item[:has_coded_value].nil?
    end
    parent
  end

  def get_ref_item(node)
    node[:has_coded_value].each do |cv|
      cv[:reference] = Thesaurus::UnmanagedConcept.find(Uri.new(uri:cv[:reference])).to_h
    end
  end

end