# Operational Reference (v3) Thesaurus Unmanaged Concept Reference
#
# @author Dave Iberson-Hurst
# @since 2.22.0
class OperationalReferenceV3::TucReference < OperationalReferenceV3

  configure rdf_type: "http://www.assero.co.uk/BusinessOperational#TucReference",
            uri_suffix: "TUC",
            uri_property: :ordinal

  data_property :local_label, default: ""
  object_property :reference, cardinality: :one, model_class: "Thesaurus::UnmanagedConcept", delete_exclude: true, read_exclude: true
  object_property :context, cardinality: :one, model_class: "Thesaurus", delete_exclude: true, read_exclude: true
  
  validates_with Validator::Field, attribute: :local_label, method: :valid_label?

  include Form::Ordinal

  def delete(parent)
    update_query = %Q{
      DELETE DATA
      {
        #{parent.uri.to_ref} bf:hasCodedValue #{self.uri.to_ref} 
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
    1
  end

  def reset_ordinals(parent)
    unless uris_ordered(parent).empty?
      string_uris = ""
      uris_ordered(parent).each_with_index do |s, index|
        string_uris += "#{s.to_ref} bo:ordinal #{index+1} . "
      end
      query_string = %Q{
        DELETE 
        { ?s bo:ordinal ?x . }
        INSERT
        { #{string_uris} }
        WHERE 
        { ?s bo:ordinal ?x . }
      }
      results = Sparql::Update.new.sparql_update(query_string, "", [:bf, :bo])
    end
  end

  def uris_ordered(parent)
    query_string = %Q{
      SELECT ?s WHERE {
        #{parent.uri.to_ref} bf:hasCodedValue ?s. ?s bo:ordinal ?ordinal .
      } ORDER BY ?ordinal
    }
    query_results = Sparql::Query.new.query(query_string, "", [:bf, :bo])
    query_results.by_object(:s)
  end

end