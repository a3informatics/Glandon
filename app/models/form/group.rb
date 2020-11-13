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

  # # Managed Ancestors Children Set. Returns the set of children nodes. Normally this is children but can be a combination.
  # #
  # # @return [Form::Group::Normal] array of objects
  # def managed_ancestors_children_set
  #   self.has_item
  # end

  # Children Ordered. Returns the set of children nodes ordered by ordinal. Note, will read the objects
  #
  # @return [Form::Group::Normal] array of objects
  def children_ordered
    self.children_objects.sort_by {|x| x.ordinal}
  end

  # # Managed Ancestors Predicate. Returns the predicate from the higher class in the managed ancestor path to this class
  # #
  # # @return [Symbol] the predicate property as a symbol
  # def managed_ancestors_predicate
  #   top_level_group? ? :has_group : :has_sub_group
  # end

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
  # @return [Object] the parent object, either new or the cloned new parent
  def delete(parent, managed_ancestor)
    if multiple_managed_ancestors?
      parent = delete_with_clone(parent, managed_ancestor)
      parent = Form::Group.find_full(parent.id)
      parent.reset_ordinals
      parent
    else
      delete_node(parent)
      parent
    end
  end

  def move_up_with_clone(child, managed_ancestor)
    if multiple_managed_ancestors?
      parent_and_child = self.replicate_siblings_with_clone(child, managed_ancestor)
      parent_and_child.first.move_up(parent_and_child.second)
    else
      move_up(child)
    end
  end

  def move_down_with_clone(child, managed_ancestor)
    if multiple_managed_ancestors?
      parent_and_child = self.replicate_siblings_with_clone(child, managed_ancestor)
      parent_and_child.first.move_down(parent_and_child.second)
    else
      move_down(child)
    end
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

private

  # Query to delete a node
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

end
