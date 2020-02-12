# Thesaurus Search
#
# @author Dave Iberson-Hurst
# @since 2.32.0
class Thesaurus

  module Difference

    # Differences. Find the differences between two thesaurus
    #
    # @param [Thesaurus] other the other thesaurus to be compared against. Self should be the earlier version.
    # @return [Hash] the results hash
    def differences(other)
      raw_results = {}
      raw_results["#{self.uri.to_s}"] = {version: self.version, date: self.creation_date.strftime("%Y-%m-%d"), children: []}
      raw_results["#{other.uri.to_s}"] = {version: other.version, date: other.creation_date.strftime("%Y-%m-%d"), children: []}
      query_string = %Q{
        SELECT ?e ?v ?d ?i ?cl ?l ?n WHERE
        {
          #{[self.uri, other.uri].map{|x| "{ #{x.to_ref} th:isTopConceptReference ?r . BIND (#{x.to_ref} as ?e)} "}.join(" UNION\n")}
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
        results[:updated] << this.to_h
      end
      results[:versions] = [this_version[:date], other_version[:date]]
      results
    end

  private

    # Clean up results hash
    def finalize(data)
      results = []
      data.each do |x| 
        x.delete(:key)
        x.delete(:uri)
        results << x.to_h
      end
      results
    end

  end

end