# Thesaurus Rank
#
# @author Dave Iberson-Hurst
# @since 2.40.0
class Thesaurus::Rank < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/Thesaurus#RankedCollection",
            base_uri: "http://#{ENV["url_authority"]}/TRC",
            uri_unique: true

  object_property :members, cardinality: :one, model_class: "Thesaurus::RankMember"

  include SKOS::OrderedCollection

  # Remove all. Removes all the rank members and Rank itself
  #
  def remove_all
    query_string = %Q{
      DELETE 
      {
        ?s ?p ?o
      } 
      WHERE 
      {
        {
          #{self.uri.to_ref} (th:members/th:memberNext*) ?s .
          ?s ?p ?o .
        }     
        UNION
        { 
          #{self.uri.to_ref} ?p ?o .
          BIND ( #{self.uri.to_ref} as ?s ) .
        }
        UNION
        { 
          #{self.uri.to_ref} ^th:isRanked ?mc
          BIND (?mc as ?s ) .
          BIND (th:isRanked as ?p)
          BIND (#{self.uri.to_ref} as ?o)
        }  
      }
    }
    partial_update(query_string, [:th])
  end

  # Parent. Find the parent of the Rank
  #
  # @return [Object] the parent object
  def parent
    objects = []
    query_string = %Q{
      SELECT DISTINCT ?s ?p ?o WHERE {
        #{self.uri.to_ref} (^th:isRanked) ?s .
        ?s ?p ?o
      }
    }
    Sparql::Query.new.query(query_string, "", [:th]).single_subject_as(target_klass)
  end

  # Remove. Remove a rank member of the Rank
  #
  # @param rank_member_id [String] the identifier of the rank member to be removed
  def remove_member(rank_member)
    sm = member_klass.find(rank_member)
    mc = parent
    prev_sm = sm.previous_member
    delete_link_clauses = []
    add_link_clause = ""
    if prev_sm.nil?
      delete_link_clauses << "#{self.uri.to_ref} th:members #{sm.uri.to_ref}"
      add_link_clause = "#{self.uri.to_ref} th:members #{sm.next_member.uri.to_ref} ." unless sm.next_member.nil?
    else
      delete_link_clauses << "#{prev_sm.uri.to_ref} th:memberNext #{sm.uri.to_ref}"
      add_link_clause = "#{prev_sm.uri.to_ref} th:memberNext #{sm.next_member.uri.to_ref} ." unless sm.next_member.nil?
    end
    query_string = %Q{
    DELETE DATA
    {
      #{delete_link_clauses.join(" .\n")}
    };
    INSERT DATA
    {
      #{add_link_clause} 
    };
    DELETE {?s ?p ?o} WHERE 
    { 
      #{sm.uri.to_ref} ?p ?o . 
      BIND (#{sm.uri.to_ref} as ?s) 
    }}
    results = Sparql::Update.new.sparql_update(query_string, "", [:th])
  end


  # Update. 
  #
  # @param cli [String] the id of the cli to be updated
  # @param rank [Integer] the rank to be asigned to the cli
  def update(params)
    params.each do |x|
      cli = Uri.new(id: x[:cli_id])
      update_query = %Q{ 
        DELETE 
          { ?member th:rank ?rank . }
        INSERT
          { ?member th:rank #{x[:rank]} . }
        WHERE 
          { ?member th:item #{cli.to_ref} .
            ?member th:rank ?rank . }
      }
      partial_update(update_query, [:th])
    end
  end

private

  def member_klass
    Thesaurus::RankMember
  end

  def parent_klass
    Thesaurus::ManagedConcept
  end

end