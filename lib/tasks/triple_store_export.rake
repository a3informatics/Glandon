namespace :triple_store do
  desc "Triple Store Export"

  def item_to_ttl(item)
    uri = item.has_identifier.has_scope.uri
    item.has_identifier.has_scope = uri
    uri = item.has_state.by_authority.uri
    item.has_state.by_authority = uri
    item.to_ttl
  end

  def force_schema_load
    [IsoManagedV2, Form, BiomedicalConceptInstance, SdtmSponsorDomain, ManagedCollection].each { |x| x.new}
  end

  task :export => :environment do
    force_schema_load
    ARGV.each { |a| task a.to_sym do ; end }
    abort("A single URI should be supplied") if ARGV.count == 1
    abort("Only a single parameter (a URI) should be supplied") unless ARGV.count == 2
    uri_s = URI.parse(ARGV[1])
    abort("URIdoes not look valid: #{uri_s}") unless uri_s.is_a?(URI::HTTP) && !uri_s.host.nil?
    uri = Uri.new(uri: ARGV[1])
    item = IsoManagedV2.klass_for(uri).find_full(uri, :export_paths)
    filename = item_to_ttl(item)
    puts "Exported #{uri} to #{filename}"
  end

end
