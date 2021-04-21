class Form::Group::Bc < Form::Group

  configure rdf_type: "http://www.assero.co.uk/BusinessForm#BcGroup",
            uri_suffix: "BCG",
            uri_unique: true

  object_property :has_biomedical_concept, cardinality: :one, model_class: "OperationalReferenceV3"

  object_property_class :has_item, model_classes: [Form::Item::BcProperty, Form::Item::Common]

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
  def to_crf(annotations)
    html = ""
    html += text_row(self.label)
    self.has_item_objects.sort_by {|x| x.ordinal}.each do |item|
      html += item.to_crf(annotations)
    end
    return html
  end

  # Info node. Adds ci, notes and terminology information to generate a report
  #
  # @param [Array] form the form object
  # @param [Array] options the options for the report
  # @param [Array] user the user running the report
  # @return [Array] Array ci_nodes, note_nodes and terminology
  def info_node(ci_nodes, note_nodes, terminology)
    add_nodes(self.to_h, ci_nodes, :completion)
    add_nodes(self.to_h, note_nodes, :note)
    self.children_ordered.each do |node|
      node.info_node(ci_nodes, note_nodes, terminology)
    end
  end

  def delete(parent, managed_ancestor)
    if multiple_managed_ancestors?
      parent = delete_with_clone(parent, managed_ancestor)
      parent = Form::Group.find_full(parent.uri)
      parent.reset_ordinals
      parent = parent.full_data
    else
      parent = delete_node(parent)
      parent = Form.find_full(parent.uri)
      parent = parent.full_data
    end
  end

  def delete_with_clone(parent, managed_ancestor)
    new_parent = super
    new_parent = Form::Group.find_full(new_parent.id)
    new_parent.reset_ordinals
    delete_with_clone_common(managed_ancestor, new_parent) unless new_parent.has_common.empty?
    new_parent = Form::Group.find_full(new_parent.id)
  end

  def delete_with_clone_common(managed_ancestor, parent)
    ty = transaction_begin
    bc_properties = bc_properties_uris.map{|x| x.to_s}
    common_group = Form::Group::Common.find_children(parent.has_common_objects.first.uri)
    common_group.clone_children_common(managed_ancestor, ty, bc_properties)
    transaction_execute
  end

  def delete_node(parent)
    unless parent.has_common.empty? #Check if there is a common group
      common_group = Form::Group::Common.find(parent.has_common_objects.first.uri)
      delete_data = ""
      common_group.has_item_objects.each do |common_item|
        self.has_item_objects.each do |bc_property|
          if common_items_with_terminologies?(bc_property, common_item) || common_items_without_terminologies?(bc_property, common_item)
            delete_data += "#{common_item.uri.to_ref} bf:hasCommonItem #{bc_property.uri.to_ref} . "
            common_item.delete(common_group, common_group) if common_item.has_common_item_objects.count == 1
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
    parent
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

  # Bc Properties Uris
  #
  # @return [Array] Array of child property uri.
  def bc_properties_uris
    bc_properties = []
    self.has_item_objects.each do |bc_property|
      bc_properties << bc_property.uri
    end
    bc_properties
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
