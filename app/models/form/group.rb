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

  def delete(parent)
    # if parent.class == Form
    #   predicate = "<http://www.assero.co.uk/BusinessForm#hasGroup>"
    # elsif parent.class == Form::Group::Normal
    #   predicate = "<http://www.assero.co.uk/BusinessForm#hasSubGroup>"
    # end
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
    1
  end

private
  
  def text_row(text)
    return "<tr><td colspan=\"3\"><h5>#{text}</h5></td></tr>"
  end

  # Next Ordinal. Get the next ordinal for a managed item collection
  #
  # @param [String] name the name of the property holding the collection
  # @return [Integer] the next ordinal
  def next_ordinal(name)
    predicate = self.properties.property(name).predicate
    query_string = %Q{
      SELECT (MAX(?ordinal) AS ?max)
      {
        #{self.uri.to_ref} #{predicate.to_ref} ?s .
        ?s bf:ordinal ?ordinal
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:bf])
    return 1 if query_results.empty?
    query_results.by_object(:max).first.to_i + 1
  end

end