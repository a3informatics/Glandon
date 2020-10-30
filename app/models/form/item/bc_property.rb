# Form Bc Property. Handles the bc property item specfic actions.
# Based on earlier implementation.
#
# @author Clarisa Romero
# @since 3.2.0
class Form::Item::BcProperty < Form::Item

  configure rdf_type: "http://www.assero.co.uk/BusinessForm#BcProperty",
            uri_suffix: "BCP",  
            uri_unique: true 

  object_property :has_property, cardinality: :one, model_class: "OperationalReferenceV3"
  object_property :has_coded_value, cardinality: :many, model_class: "OperationalReferenceV3::TucReference"

  # Managed Ancestors Children Set. Returns the set of children nodes. Normally this is children but can be a combination.
  #
  # @return [Form::Group::Normal] array of objects
  def managed_ancestors_children_set
    self.has_coded_value
  end

  # Managed Ancestors Path. Returns the path from the managed ancestor to this class
  #
  # @return [String] the path as an expanded set of predicates
  def self.managed_ancestors_path
    [
      "<http://www.assero.co.uk/BusinessForm#hasGroup>",
      "<http://www.assero.co.uk/BusinessForm#hasSubGroup>*",
      "<http://www.assero.co.uk/BusinessForm#hasItem>"
    ]
  end

  # Managed Ancestors Predicate. Returns the predicate from the higher class in the managed ancestor path to this class
  #
  # @return [Symbol] the predicate property as a symbol
  def managed_ancestors_predicate
    :has_item
  end

  # Get Item
  #
  # @return [Array] An array of Bc Property Item with CLI and CL references.
  def get_item
    blank_fields = {datatype:"", format:"", question_text:"", mapping:"", free_text:"", label_text:""}
    item = self.to_h.merge!(blank_fields)
    item[:has_coded_value] = coded_values_to_hash(self.has_coded_value_objects)
    item[:has_property] = property_to_hash(self.has_property_objects)
    [item]
  end

  # To CRF
  #
  # @return [String] An html string of BC Property
  def to_crf
    html = ""
    if !is_common?
      property_ref = self.has_property_objects.reference
      property = BiomedicalConcept::PropertyX.find(property_ref)
      html += start_row(self.optional)
      html += question_cell(property.question_text)
      if property.has_coded_value.length == 0
        html += input_field(property)
      else
        html += terminology_cell
      end
      html += end_row
    end
    return html
  end

  def children_ordered
    self.has_coded_value_objects.sort_by {|x| x.ordinal}
  end

  def make_common_with_clone(managed_ancestor)
    if multiple_managed_ancestors?
      new_bc_property = clone_nodes_and_children(self, managed_ancestor)
      new_bc_property.second.make_common
    else
      make_common
    end

  end

  def make_common
    unless get_common_group.empty? #Check if there is a common group
      common_group = Form::Group::Common.find(get_common_group.first)
      common_bcp = find_common_matches
      property = BiomedicalConcept::PropertyX.find(self.has_property_objects.reference)
      common_item = Form::Item::Common.create(label: property.alias, ordinal: common_group.next_ordinal, parent_uri: common_group.uri)
      common_group.has_item_push(common_item.uri)
      common_item.has_coded_value = []
      self.has_coded_value_objects.each do |ref|
        new_reference = ref.clone
        new_reference.uri = new_reference.create_uri(common_item.uri)
        new_reference.save
        common_item.has_coded_value << new_reference
      end
      new_property = self.has_property_objects.clone
      new_property.generate_uri(common_item.uri)
      new_property.save 
      common_item.has_property = new_property
      common_bcp.each do |common_uri|
        common_item.has_common_item_push(common_uri)
      end
      common_group.save
      common_item.save
      normal_group = Form::Group::Normal.find_full(get_normal_group.first)
      normal_group = normal_group.full_data
    else
      self.errors.add(:base, "There is no Common group")
    end  
  end

  def clone_nodes_and_children(child, managed_ancestor)
    new_parent = nil
    new_object = nil
    new_normal_group = nil
    tx = transaction_begin
    uris = child.managed_ancestor_path_uris(managed_ancestor)
    prev_object = managed_ancestor
    prev_object.transaction_set(tx)
    uris.each do |old_uri|
      old_object = self.class.klass_for(old_uri).find_children(old_uri)
      cloned_object = clone_and_save(old_object, prev_object, tx)
       if child.uri == old_object.uri
         new_parent = prev_object
         new_object = new_parent.clone_children_and_save_no_tx(tx, child.uri)
         new_normal_group = new_normal_group.clone_children_and_save_no_tx(tx) 
       end
      if old_object.class == Form::Group::Normal 
        new_normal_group = cloned_object unless old_object.has_common.empty?
      end
      prev_object.replace_link(old_object.managed_ancestors_predicate, old_object.uri, cloned_object.uri)
      prev_object = cloned_object
    end
    transaction_execute
    new_parent = Form::Item.find_full(new_parent.id)
    return new_parent, new_object
  end

  def to_h
    x = super
    x[:is_common] = is_common?
    x
  end

  def update_with_clone(params, managed_ancestor)
    if multiple_managed_ancestors?
      new_bc_property = clone_nodes(self.has_property_objects, managed_ancestor)
      new_bc_property.first.has_property_objects.update(params)
      new_bc_property.first.update(params.except(:enabled, :optional))
    else
      self.has_property_objects.update(params)
      self.update(params.except(:enabled, :optional))
    end
  end
  
  private

    def find_common_matches
      query_string = %Q{         
        SELECT ?common_bcp WHERE 
        {
          #{self.uri.to_ref} bf:hasProperty/bo:reference/bc:isA ?ref .
          #{self.uri.to_ref} ^bf:hasItem/^bf:hasSubGroup/bf:hasSubGroup/bf:hasItem ?common_bcp .
          ?common_bcp bf:hasProperty/bo:reference/bc:isA ?ref
        }
      }     
      query_results = Sparql::Query.new.query(query_string, "", [:bf, :bo, :bc])
      check_terminologies(query_results.by_object(:common_bcp))
    end

    def check_terminologies(uris)
      query_string = %Q{
      SELECT DISTINCT ?s WHERE 
        {
          
          VALUES ?s {#{uris.map{|x| x.to_ref}.join(" ")}}
          {
          #{self.uri.to_ref} bf:hasCodedValue/bo:reference ?cli .
          ?s bf:hasCodedValue/bo:reference ?cli
          }
        }
      }
      query_results = Sparql::Query.new.query(query_string, "", [:bf, :bo])
      return uris if query_results.empty?
      query_results.by_object(:s)
    end

    def get_common_group
      query_string = %Q{         
        SELECT ?common_group WHERE 
        {
          #{self.uri.to_ref} ^bf:hasItem ?bc_group. 
          ?bc_group ^bf:hasSubGroup ?normal_g. 
          ?normal_g bf:hasCommon ?common_group 
        }
      }     
      query_results = Sparql::Query.new.query(query_string, "", [:bf])
      query_results.by_object(:common_group)
    end

    def common_group?
      query_string = %Q{         
        SELECT ?result WHERE {BIND ( EXISTS {#{self.uri.to_ref} ^bf:hasItem ?bc_g. ?bc_g ^bf:hasSubGroup ?normal_g. ?normal_g bf:hasCommon ?c_g  } as ?result )}
      }     
      query_results = Sparql::Query.new.query(query_string, "", [:bf])
      query_results.by_object(:result).first.to_bool
    end

    def get_normal_group
      query_string = %Q{         
        SELECT ?normal_group WHERE 
        {
          #{self.uri.to_ref} ^bf:hasItem ?bc_group. 
          ?bc_group ^bf:hasSubGroup ?normal_group. 
        }
      }     
      query_results = Sparql::Query.new.query(query_string, "", [:bf])
      query_results.by_object(:normal_group)
    end

    def is_common?
      query_string = %Q{         
        SELECT ?result WHERE {BIND ( EXISTS {#{self.uri.to_ref} ^bf:hasCommonItem ?s} as ?result )}
      }     
      query_results = Sparql::Query.new.query(query_string, "", [:bf])
      query_results.by_object(:result).first.to_bool
    end

    def property_to_hash(property)
      ref = property.to_h
      ref[:reference] = BiomedicalConcept::PropertyX.find(ref[:id]).to_h
      ref
    end

 end