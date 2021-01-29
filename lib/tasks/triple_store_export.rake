# Triple Store Export Rake Task
#
# @author Dave Iberson-Hurst
# @since 3.8.0
namespace :triple_store do
  desc "Triple Store Export"

  # Force load to get the schema read
  def force_schema_load
    [ Thesaurus, Thesaurus::ManagedConcept, Form, BiomedicalConceptInstance, 
      SdtmSponsorDomain, ManagedCollection ].each { |x| x.new}
  end

  # Main task. Allows for a single parameter that is a URI.
  task :export => :environment do
    force_schema_load
    ARGV.each { |a| task a.to_sym do ; end }
    abort("A single URI should be supplied") if ARGV.count == 1
    abort("Only a single parameter (a URI) should be supplied") unless ARGV.count == 2
    uri_s = URI.parse(ARGV[1])
    abort("URI does not look valid: #{uri_s}") unless uri_s.is_a?(URI::HTTP) && !uri_s.host.nil?
    uri = Uri.new(uri: ARGV[1])
    item = IsoManagedV2.klass_for(uri).find_full(uri, :export_paths)
    filename = item.to_ttl!
    puts "Exported #{uri} to #{filename}"
  end

end