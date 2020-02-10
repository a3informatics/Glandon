# Thesaurus Search
#
# @author Dave Iberson-Hurst
# @since 2.22.0
class Thesaurus

  module Difference

    def differences(other)
      raw_results = {}
      query_string = %Q{
        SELECT ?e ?v ?d ?i ?cl ?l ?n WHERE
        {
          #{[self.uri, other.uri].map{|x| "{ #{x.to_ref} th:isTopConceptReference ?r . #{x.to_ref} isoT:creationDate ?d . #{x.to_ref} isoT:hasIdentifier ?si1 . ?si1 isoI:version ?v . BIND (#{x.to_ref} as ?e)} "}.join(" UNION\n")}
          ?r bo:reference ?cl .
          ?cl isoT:hasIdentifier ?si2 .
          ?cl isoC:label ?l .
          ?cl th:notation ?n .
          ?si2 isoI:identifier ?i .
        } ORDER BY ?l
      }
      query_results = Sparql::Query.new.query(query_string, "", [:isoI, :isoT, :isoC, :th, :bo])
      triples = query_results.by_object_set([:e, :v, :d, :i, :cl, :l, :n])
      triples.each do |entry|
        uri = entry[:e].to_s
        raw_results[uri] = {version: entry[:v].to_i, date: entry[:d].to_time_with_default.strftime("%Y-%m-%d"), children: []} if !raw_results.key?(uri)
        raw_results[uri][:children] << DiffResult[key: entry[:i], identifier: entry[:i].to_sym, uri: entry[:cl].to_s, id: entry[:cl].to_id, last_id: "", label: entry[:l], notation: entry[:n]]
      end
      this_version = raw_results[self.uri.to_s]
      other_version = raw_results[other.uri.to_s]
      new_items = other_version[:children] - this_version[:children]
      common_items = other_version[:children] & this_version[:children]
      deleted_items = this_version[:children] - other_version[:children]
      results = {created: finalize(new_items), updated: [], deleted: finalize(deleted_items)}
      common_items.each do |entry|
        this = this_version[:children].find{|x| x[:key] == entry[:key]}
        other = other_version[:children].find{|x| x[:key] == entry[:key]}
        next if other.no_change?(this)
        this[:last_id] = other[:id]
        this.delete(:key)
        this.delete(:uri)
        results[:updated] << this #.delete(:key)
      end
      results
    end

  private

    def finalize(data)
      data.each{|x| x.delete(:key)}
      data.each{|x| x.delete(:uri)}
    end

  end

end