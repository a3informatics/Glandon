# AdamModel. Class for processing ADaM Model Excel Files
#
# @!attribute children
#   @return [Array] the array of child variables
# @!attribute prefix
#   @return [String] @todo not sure needed
# @!attribute structure
#   @return [String] @todo not sure needed
# @author Dave Iberson-Hurst
# @since 2.21.0
class AdamIgDataset < Tabulation

  configure rdf_type: "http://www.assero.co.uk/Tabulation#ADaMDataset",
            uri_suffix: "ADS"

  data_property :prefix
  data_property :structure

  # Get Children.
  #
  # @return [Array] array of objects
  def get_children
    results = []
    query_string = %Q{
      SELECT DISTINCT ?ordinal ?c ?type ?label ?name ?ct ?notes ?compliance ?typedas WHERE
      {
        #{self.uri.to_ref} bd:includesColumn ?c .
        ?c bd:ordinal ?ordinal .
        ?c rdf:type ?type .
        ?c isoC:label ?label . 
        ?c bd:name ?name .
        ?c bd:typedAs/isoC:prefLabel ?typedas .
        ?c bd:ct ?ct .
        ?c bd:notes ?notes .
      } ORDER BY ?ordinal
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoC, :bd])
    query_results.by_object_set([:ordinal, :var, :type, :label, :name, :ct, :ct_notes, :notes, :compliance, :typedas]).each do |x|
      results << {uri: x[:c].to_s, ordinal: x[:ordinal].to_i, rdf_type: x[:type].to_s, label: x[:label], name: x[:name],
                  ct: x[:ct], notes: x[:notes], compliance: x[:compliance], typed_as: x[:typedas]}
    end
    results
  end

  # Owner
  #
  # @return [IsoRegistrationAuthority] the owner
  def self.owner
    SdtmIg.owner
  end
  
end
