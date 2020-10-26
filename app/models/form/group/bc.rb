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
      op_ref = OperationalReferenceV3.find(Uri.new(uri:group[:has_biomedical_concept])).to_h
      bci = BiomedicalConceptInstance.find_minimum(Uri.new(uri: op_ref[:reference]))
      op_ref[:reference] = bci.to_h
    rescue => e
      group.delete(:has_biomedical_concept)
    else
      group[:has_biomedical_concept]= op_ref
    end
    group.delete(:has_item)
    results = [group]
    self.has_item_objects.sort_by {|x| x.ordinal}.each do |item|
      results += item.get_item
    end
    results
  end

  # To CRF
  #
  # @return [String] An html string of BC Group
  def to_crf
    html = ""
    html += text_row(self.label)
    self.has_item_objects.sort_by {|x| x.ordinal}.each do |item|
      html += item.to_crf
    end
    return html
  end

  # Delete. Delete the object. Clone if there are multiple parents.
  #
  # @param [Object] parent_object the parent object
  # @param [Object] managed_ancestor the managed ancestor object
  # @return [Object] the parent object, either new or the cloned new object with updates
  def delete(parent, managed_ancestor)
    if multiple_managed_ancestors?
      clone_and_unlink(managed_ancestor)
    else
      delete_node(parent)
    end
  end

  def clone_and_unlink(managed_ancestor)
    tx = transaction_begin
    new_parent = nil
    uris = managed_ancestor_path_uris(managed_ancestor)
    prev_object = managed_ancestor
    prev_object.transaction_set(tx)
    uris.each do |old_uri|
      old_object = self.class.klass_for(old_uri).find_children(old_uri)
      cloned_object = clone_and_save(old_object, prev_object, tx)
      if self.uri == old_object.uri
        prev_object.delete_link(old_object.managed_ancestors_predicate, old_object.uri)
        new_parent = prev_object
        new_parent.clone_children_and_save(tx)
      else
        prev_object.replace_link(old_object.managed_ancestors_predicate, old_object.uri, cloned_object.uri)
      end
      prev_object = cloned_object
    end
    transaction_execute
    new_parent.reset_ordinals
    new_parent = Form::Group.find_full(new_parent.id)
    unlink_common(new_parent)
    normal_group = Form::Group::Normal.find_full(new_parent.uri)
    normal_group = normal_group.full_data
  end

  def unlink_common(parent)
    unless parent.has_common.empty? #Check if there is a common group
      common_group = Form::Group::Common.find(parent.has_common_objects.first.uri)
      common_group.has_item_objects.each do |common_item|
        self.has_item_objects.each do |bc_property|
          if common_items_with_terminologies?(bc_property, common_item) || common_items_without_terminologies?(bc_property, common_item)
            common_group.delete_link(:has_item, common_item.uri)
          end
        end
      end
    end 
  end

  def delete_node(parent)
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
    normal_group = normal_group.full_data
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

  # Full data
  #
  # @return [Hash] Return the data of the whole node
  def full_data
    group = self.to_h
    group[:has_item] = []
    self.has_item_objects.sort_by {|x| x.ordinal}.each do |item|
      group[:has_item] << item.full_data
    end
    bci = BiomedicalConceptInstance.find_minimum(self.has_biomedical_concept_objects.reference)
    group[:has_biomedical_concept] = bci.to_h
    group
  end

end