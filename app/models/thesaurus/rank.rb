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
    Thesaurus::RankedMember
  end

  def parent_klass
    Thesaurus::ManagedConcept
  end

end