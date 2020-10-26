class Form::Group < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/BusinessForm#Group",
            uri_suffix: "G",  
            uri_unique: true

  data_property :ordinal, default: 1
  data_property :note
  data_property :completion
  data_property :optional, default: false

  object_property :has_item, cardinality: :many, model_class: Form::Item, children: true

  validates_with Validator::Field, attribute: :ordinal, method: :valid_positive_integer?
  validates_with Validator::Field, attribute: :note, method: :valid_markdown?
  validates_with Validator::Field, attribute: :completion, method: :valid_markdown?
  validates :optional, inclusion: { in: [ true, false ] }

  include Form::Ordinal

  # Managed Ancestors Path. Returns the path from the managed ancestor to this class
  #
  # @return [String] the path as an expanded set of predicates
  def self.managed_ancestors_path
    [
      "<http://www.assero.co.uk/BusinessForm#hasGroup>",
      "<http://www.assero.co.uk/BusinessForm#hasSubGroup>*",
      "<http://www.assero.co.uk/BusinessForm#hasCommon>?"
    ]
  end

  # Managed Ancestors Predicate. Returns the predicate from the higher class in the managed ancestor path to this class
  #
  # @return [Symbol] the predicate property as a symbol
  def managed_ancestors_predicate
    top_level_group? ? :has_group : :has_sub_group
  end

  # Top Level Group? Is this group the top level group
  #
  # @result [Boolean] return true if this instance is a top level group or false if it is a SubGroup
  def top_level_group?
    Sparql::Query.new.query("ASK {#{self.uri.to_ref} ^bf:hasGroup ?o}", "", [:bf]).ask? 
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
      parent
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
    new_parent
  end

  # Clone the item and create. Use Sparql approach in case of children also need creating
  #   so we need to recruse. Also generate URI for this object and any children to ensure we catch the children.
  #   The Children are normally references. Also note the setting of the transaction in the cloned object and
  #   in the sparql generation, important both are done.
  def clone_children_and_save(tx)
    sparql = Sparql::Update.new(tx)
    set = self.has_item
    set.each do |child|
      object = child.clone
      object.transaction_set(tx)
      object.generate_uri(self.uri) 
      object.to_sparql(sparql, true)
      self.replace_link(child.managed_ancestors_predicate, child.uri, object.uri)
    end
    sparql.create
  end

  def delete_node(parent)
    update_query = %Q{
      DELETE DATA
      {
        #{parent.uri.to_ref} bf:hasCommon #{self.uri.to_ref} 
      };
      DELETE DATA
      {
        #{parent.uri.to_ref} bf:hasSubGroup #{self.uri.to_ref} 
      };
      DELETE DATA
      {
        #{parent.uri.to_ref} bf:hasGroup #{self.uri.to_ref} 
      };
      DELETE {?s ?p ?o} WHERE 
      { 
        { BIND (#{self.uri.to_ref} as ?s). 
          ?s ?p ?o
        }
        UNION
        { #{self.uri.to_ref} bf:hasItem ?o1 . 
          BIND (?o1 as ?s) . 
          ?s ?p ?o .
        }
        UNION
        { #{self.uri.to_ref} bf:hasSubGroup ?o2 . 
          BIND (?o2 as ?s) . 
          ?s ?p ?o .
        }
        UNION
        { #{self.uri.to_ref} bf:hasCommon ?o3 . 
          BIND (?o3 as ?s) . 
          ?s ?p ?o .
        }
        UNION
        { #{self.uri.to_ref} bf:hasBiomedicalConcept ?o4 . 
          BIND (?o4 as ?s) . 
          ?s ?p ?o .
        }
      }
    }
    partial_update(update_query, [:bf])
    parent.reset_ordinals
    1
  end
  
  def text_row(text)
    return "<tr><td colspan=\"3\"><h5>#{text}</h5></td></tr>"
  end

  # Next Ordinal. Get the next ordinal for a managed item collection
  #
  # @param [String] name the name of the property holding the collection
  # @return [Integer] the next ordinal
  def next_ordinal
    query_string = %Q{
      SELECT (MAX(?ordinal) AS ?max)
      {
        #{self.uri.to_ref} bf:hasSubGroup|bf:hasItem|bf:hasCommon ?s .
        ?s bf:ordinal ?ordinal
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:bf])
    return 1 if query_results.empty?
    query_results.by_object(:max).first.to_i + 1
  end

end