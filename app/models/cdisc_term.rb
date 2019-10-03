# CDISC Terminology Model
#
# @author Dave Iberson-Hurst
# @since 2.22.0
class CdiscTerm < Thesaurus
  
  C_IDENTIFIER = "CT"

  @@cdisc_ra = nil

  # Owner
  #
  # @return [IsoRegistrationAuthority] the owner
  def self.owner
    return @@cdisc_ra if !@@cdisc_ra.nil?
    @@cdisc_ra = IsoRegistrationAuthority.find_by_short_name("CDISC")
    @@cdisc_ra.freeze
  end

  def self.child_klass
    ::CdiscCl
  end

  # Configuration
  #
  # @return [Hash] the configuration hash
  def self.configuration
    #schema_namespace = Namespaces.namespace(:iso25964)
    { 
      #schema_namespace: schema_namespace,
      #instance_namespace: Namespaces.namespace(:mdrTH),
      #cid_prefix: "TH",
      #rdf_type: Uri.new({namespace: schema_namespace, fragment: "Thesaurus"})
      identifier: C_IDENTIFIER
    }
  end

  # Configuration
  #
  # @return [Hash] the configuration hash
  def configuration
    self.class.configuration
  end

  def add(item, ordinal)
    ref = OperationalReferenceV3::TcReference.new(ordinal: ordinal, reference: item.uri)
    ref.uri = ref.create_uri(self.uri)
    self.is_top_concept_reference << ref
    self.is_top_concept << item.uri
  end

  # Version Dates. Get set of version dates
  #
  # @return [Array] array of hash containg the ids and dates
  def self.version_dates
    results = []
    query_string = %Q{
SELECT DISTINCT ?s ?d WHERE 
{             
  ?s rdf:type th:Thesaurus .
  ?s isoT:hasIdentifier ?si .
  ?si isoI:hasScope #{owner.ra_namespace.uri.to_ref} .
  ?s isoT:lastChangeDate ?d .
} ORDER BY ?d}
    query_results = Sparql::Query.new.query(query_string, "", [:th, :isoI, :isoT])
    query_results.by_object_set([:s, :d]).each do |x|
      results << {id: x[:s].to_id, date: x[:d].format_as_date}
    end
    results
  end

  # ---------
  # Test Only  
  # ---------
  if Rails.env.test?

    def self.clear_owner
      @@cdisc_ra = nil
    end

    def self.get_owner
      @@cdisc_ra
    end

  end

end
