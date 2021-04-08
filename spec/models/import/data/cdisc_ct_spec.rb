require 'rails_helper'

describe "Import::CdiscTerm CT Data" do

  include DataHelpers
  include PublicFileHelpers
  include SparqlHelpers
  include IsoHelpers

  def sub_dir
    return "models/import/data/cdisc/ct"
  end

  before :all do
    IsoHelpers.clear_cache
    load_files(schema_files, [])
    load_data_file_into_triple_store("mdr_identification.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
    create_maps
  end

  after :all do
    #
  end

  before :each do
    setup
  end

  after :each do
    Import.destroy_all
    delete_all_public_test_files
  end

  # ---------- IMPORTANT SWITCHES ----------
  
  def set_write_file
    false
  end

  def use_api
    false
  end

  # ----------------------------------------

  def excel_filename(version)
    "CT_V#{version}.ttl"
  end

  def api_filename(version)
    "CT_V#{version}_API.ttl"
  end
  
  def setup
    #@object = Import::CdiscTerm.new
    @object = Import.new(:type => "Import::CdiscTerm") # Use this rather than above.
    @job = Background.new
    @job.save
    @object.background_id = @job.id
    @object.save
  end

  def check_count(issue_date)
    version_index = @date_to_version_map.index(issue_date)
    version = version_index + 1
    expected = @version_to_info_map[version_index][:size]
    return if expected == -1
    uri_sting = "http://www.cdisc.org/CT/V#{version}#TH"
    query_string = %Q{
SELECT DISTINCT (count(?uri) as ?count) WHERE {            
  #{Uri.new(uri: uri_sting).to_ref} th:isTopConceptReference/bo:reference ?mc .
  { 
    ?mc th:identifier ?i .
    BIND(?i as ?pi)
    BIND(?mc as ?uri)
  } UNION
  {
    ?mc th:narrower ?uc .
    ?mc th:identifier ?pi .
    ?uc th:identifier ?i .
    BIND(?uc as ?uri)
  }
}}
    query_results = Sparql::Query.new.query(query_string, "", [:bo, :th])
    count = query_results.by_object_set([:count]).first[:count].to_i
    expect(count).to eq(expected)
  end

  def check_tags(issue_date)
    tag_objects = []
    version_index = @date_to_version_map.index(issue_date)
    version = version_index + 1
    expected = @version_to_tags_map[version_index]
    uri_sting = "http://www.cdisc.org/CT/V#{version}#TH"
    query_string = %Q{
SELECT DISTINCT ?s ?p ?o WHERE {            
  #{Uri.new(uri: uri_sting).to_ref} ^isoC:appliesTo/isoC:classifiedAs ?s .
  ?s ?p ?o
}}
    query_results = Sparql::Query.new.query(query_string, "", [:isoC])
    subjects = query_results.by_subject
    subjects.each do |subject, triples|
      tag_objects << IsoConceptSystem::Node.from_results(Uri.new(uri: subject), triples)
    end
    tags = tag_objects.map{|x| x.pref_label.to_sym}
    missing = expected[:th] - tags
    extra = tags - expected[:th]
    puts "***** Error checking tags: #{extra} are present but not expected *****" if extra.any?
    puts "***** Error checking tags: #{missing} are not present but expected *****" if missing.any?
    expect(extra.empty?).to be(true)
    expect(missing.empty?).to be(true)
  end

  def check_term_differences(results, expected)
    expect(results[:status]).to eq(expected[:status])
    expect(results[:result]).to eq(expected[:result])
    expect(results[:children].count).to eq(expected[:children].count)
    results[:children].each do |key, result|
      found = expected[:children][key]
      expect(result).to eq(found)
    end
  end

  def load_version(version)
    load_local_file_into_triple_store(sub_dir, "CT_V#{version}.ttl")
  end

  def set_params(version, date, files)
    file_type = !files.empty? ? "0" : "3"
    { version: "#{version}", date: "#{date}", files: files, version_label: "#{date} Release", label: "Controlled Terminology", 
      semantic_version: "#{version}.0.0", job: @job, file_type: file_type}
  end

	def check_cl_result(results, cl, status)
    return if status == :no_change && !results[:items].key?(cl)
  	puts "***** Error checking CL Result: #{cl} for expected result '#{status}', actual result '#{results[:items][cl.to_sym][:status][0][:status]}' *****" if results[:items][cl.to_sym][:status][0][:status] != status
    #expect(results[:items][cl.to_sym][:status][0][:status]).to eq(status)
  rescue => e
    puts "***** Exception Raised *****"
    puts "Error checking CL Result: #{cl} for expected result #{status}. *****" 
    puts "No key for #{cl} in results." if !results[:items].key?(cl)
  end

  def dump_errors_if_present(filename, version, date)
    full_path = Rails.root.join "public/test/#{filename}"
    return if !File.exists?(full_path)
    errors = YAML.load_file(full_path)
    puts colourize("***** ERRORS ON IMPORT - V#{version} for #{date} *****", "red")
    puts errors
  end

  def process_term(version, date, files, copy_file=false)
    params = set_params(version, date, files)
    result = @object.import(params)
    filename = "cdisc_term_#{@object.id}_errors.yml"
    dump_errors_if_present(filename, version, date)
    expect(public_file_does_not_exist?("test", filename)).to eq(true)
    filename = "cdisc_term_#{@object.id}_load.ttl"
    expect(public_file_exists?("test", filename)).to eq(true)
    copy_file_from_public_files("test", filename, sub_dir)
    target_filename = @object.api? ? api_filename(version) : excel_filename(version)
    if copy_file
      puts colourize("***** Warning! Copying result file to '#{target_filename}'. *****", "red")
      copy_file_from_public_files_rename("test", filename, sub_dir, target_filename) 
    end
    check_ttl_fix_v2(filename, target_filename, {last_change_date: true})
    expect(@job.status).to eq("Complete")
    delete_data_file(sub_dir, filename)
  end

  def check_cl_results(results, expected)
    expected.each {|e| check_cl_result(results, e[:cl], e[:status])}
  end

  def load_versions(range)
    range.each {|n| load_version(n)}
  end

  def file_pattern
    {
      adam: "adam/ADaM Terminology",
      cdash: "cdash/CDASH Terminology", 
      coa: "coa/COA Terminology", 
      sdtm: "sdtm/SDTM Terminology", 
      qrs: "qrs/QRS Terminology", 
      qs: "qs/QS Terminology",
      qsft: "qs-ft/QS-FT Terminology",
      send: "send/SEND Terminology",
      protocol: "protocol/Protocol Terminology",
      define: "define-xml/Define-XML Terminology"
    }
  end

  def process_load_and_compare(filenames, date, version, create_file=false)
    files = []
    filenames.each_with_index {|f, index| files << db_load_file_path("cdisc/ct", filenames[index])}
    puts colourize("File count: #{files.count}", "green")
    process_term(version, date, files, create_file)
    load_version(version)
    th = CdiscTerm.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V#{version}#TH"))
    results = th.changes(2)
  end

  def execute_import(issue_date, reqd_files, create_file=false, use_api=false)
    #expect(EnvironmentVariable).to receive(:read).with("url_authority").and_return("www.s-cubed.dk")
    files = []
    version_index = @date_to_version_map.index(issue_date)
    current_version = version_index + 1
    puts colourize("Version: #{current_version}, Date: #{issue_date}", "green")
    load_versions(1..(current_version-1))
    # Use API only if it is set for the version. Set files for non-api source
    if use_api && @version_to_info_map[version_index][:api]
      files = []
      @object.file_type = 3
      puts colourize("Loading from API", "green")
    else
      reqd_files.each {|k,v| files << "#{file_pattern[k]} #{v}.xlsx" if reqd_files.key?(k)}
      @object.file_type = 0
      puts colourize("Loading from Excel", "green")
    end
    @object.save
    results = process_load_and_compare(files, issue_date, current_version, create_file)
  end

  def create_maps
    @date_to_version_map = CdiscCtHelpers.date_version_map
    
    @version_to_info_map =
    [
      { api: false, size:  881}, { api: false, size: 1003 }, { api: false, size: 1003 }, { api: false, size: -1 }, { api: false, size: -1 },          # 2007
      { api: false, size: -1 }, { api: false, size: -1 }, { api: false, size: -1 }, { api: false, size: -1 }, { api: false, size: -1 }, 
        { api: false, size: 2301 }, { api: false, size: -1 }, { api: false, size: -1 },                                                               # 2008
      { api: false, size: -1 }, { api: false, size: -1 }, { api: false, size: -1 }, { api: false, size: -1 }, { api: false, size: -1 },               # 2009
      { api: false, size: -1 }, { api: false, size: -1 }, { api: false, size: 4190+134+26 }, { api: false, size: -1 }, { api: false, size: -1 },      # 2010
      { api: false, size: -1 }, { api: false, size: -1 }, { api: false, size: -1 }, { api: false, size: -1 }, { api: false, size: -1 },               # 2011
      { api: false, size: -1 }, { api: false, size: -1 }, { api: false, size: -1 }, { api: false, size: 10142}, { api: false, size: -1 },             # 2012
      { api: false, size: -1 }, { api: false, size: -1 }, { api: false, size: 12963 }, { api: false, size: -1 },                                      # 2013
      { api: false, size: -1 }, { api: false, size: -1 }, { api: true, size: -1 }, { api: false, size: -1 }, { api: true, size: 16593 },              # 2014
      { api: true, size: -1 }, { api: true, size: -1 }, { api: true, size: -1 }, { api: true, size: 19065 },                                          # 2015
      { api: true, size: -1 }, { api: true, size: -1 }, { api: true, size: -1 }, { api: true, size: -1 },                                             # 2016
      { api: true, size: -1 }, { api: true, size: 24291 }, { api: true, size: -1 }, { api: true, size: -1 },                                          # 2017
      { api: true, size: -1 }, { api: true, size: -1 }, { api: true, size: -1 }, { api: true, size: -1 },                                             # 2018
      { api: true, size: 31267 }, { api: true, size: 31934 }, { api: true, size: -1 }, { api: true, size: 33397 },                                    # 2019
      { api: true, size: 33765 }, { api: true, size: 33886 }, { api: true, size: 34182 }, { api: true, size: 34417 }, { api: true, size: 34417 }, 
        { api: true, size: 35181 },                                                                                                                   # 2020                      
      { api: true, size: 35644 }                                                                                                                      # 2021
    ]
  
    @version_to_tags_map =
    [
      { th: [:SDTM], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]}, # 1
      { th: [:SDTM], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},
      { th: [:SDTM], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},
      { th: [:SDTM], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},
      { th: [:SDTM], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},
      { th: [:SDTM], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},
      { th: [:SDTM], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},
      { th: [:SDTM], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},
      { th: [:SDTM], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},
      { th: [:SDTM], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},                                   # 10
      { th: [:SDTM], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},
      { th: [:SDTM], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},
      { th: [:SDTM], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},
      { th: [:SDTM], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},                                   # 14 - 2009
      { th: [:SDTM], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},
      { th: [:SDTM], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},
      { th: [:SDTM], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},
      { th: [:SDTM], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},
      { th: [:SDTM, :CDASH, :ADaM], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},                    # 19 - 2010
      { th: [:SDTM, :CDASH, :ADaM], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},                    # 20
      { th: [:SDTM, :CDASH, :ADaM], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},
      { th: [:SDTM, :CDASH, :ADaM], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},
      { th: [:SDTM, :CDASH, :ADaM], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},
      { th: [:SDTM, :CDASH, :ADaM], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},                    # 24 - 2011 
      { th: [:SDTM, :CDASH, :ADaM], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},
      { th: [:SDTM, :CDASH, :ADaM, :SEND], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},             # 26
      { th: [:SDTM, :CDASH, :ADaM, :SEND], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},
      { th: [:SDTM, :CDASH, :ADaM, :SEND], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},
      { th: [:SDTM, :CDASH, :ADaM, :SEND], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},             # 29 - 2012
      { th: [:SDTM, :CDASH, :ADaM, :SEND, :QS], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},        # 30
      { th: [:SDTM, :CDASH, :ADaM, :SEND, :QS], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},
      { th: [:SDTM, :CDASH, :ADaM, :SEND, :QS], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},
      { th: [:SDTM, :CDASH, :ADaM, :SEND, :QS], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},
      { th: [:SDTM, :CDASH, :ADaM, :SEND, :QS], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},        # 34 - 2013
      { th: [:SDTM, :CDASH, :ADaM, :SEND, :QS], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},
      { th: [:SDTM, :CDASH, :ADaM, :SEND, :QS], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},
      { th: [:SDTM, :CDASH, :ADaM, :SEND, :QS], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},
      { th: [:SDTM, :CDASH, :ADaM, :SEND, :QS], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},        # 38 - 2014
      { th: [:SDTM, :CDASH, :ADaM, :SEND, :"QS-FT"], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},
      { th: [:SDTM, :CDASH, :ADaM, :SEND, :"QS-FT"], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},   # 40
      { th: [:SDTM, :CDASH, :ADaM, :SEND, :"QS-FT"], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},
      { th: [:SDTM, :CDASH, :ADaM, :SEND, :COA], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},
      { th: [:SDTM, :CDASH, :ADaM, :SEND, :COA], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},       # 43 - 2015
      { th: [:SDTM, :CDASH, :ADaM, :SEND, :QRS], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},       
      { th: [:SDTM, :CDASH, :ADaM, :SEND, :QRS], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},
      { th: [:SDTM, :CDASH, :ADaM, :SEND], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},             # 47 - 2016
      { th: [:SDTM, :CDASH, :ADaM, :SEND], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},
      { th: [:SDTM, :CDASH, :ADaM, :SEND], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},
      { th: [:SDTM, :CDASH, :ADaM, :SEND], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},
      { th: [:SDTM, :CDASH, :ADaM, :SEND], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},             # 50
      { th: [:SDTM, :CDASH, :ADaM, :SEND, :Protocol], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},  # 51 - 2017
      { th: [:SDTM, :CDASH, :ADaM, :SEND, :Protocol], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},
      { th: [:SDTM, :CDASH, :ADaM, :SEND, :Protocol], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},
      { th: [:SDTM, :CDASH, :ADaM, :SEND, :Protocol], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},
      { th: [:SDTM, :CDASH, :ADaM, :SEND, :Protocol], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},  # 55 - 2018
      { th: [:SDTM, :CDASH, :ADaM, :SEND, :Protocol], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},
      { th: [:SDTM, :CDASH, :ADaM, :SEND, :Protocol], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},
      { th: [:SDTM, :CDASH, :ADaM, :SEND, :Protocol], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},
      { th: [:SDTM, :CDASH, :ADaM, :SEND, :Protocol], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},  # 59 - 2019
      { th: [:SDTM, :CDASH, :ADaM, :SEND, :Protocol], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},  # 60
      { th: [:SDTM, :CDASH, :ADaM, :SEND, :Protocol], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},
      { th: [:SDTM, :CDASH, :ADaM, :SEND, :Protocol, :"Define-XML"], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},
      { th: [:SDTM, :CDASH, :ADaM, :SEND, :Protocol, :"Define-XML"], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},
      { th: [:SDTM, :CDASH, :ADaM, :SEND, :Protocol, :"Define-XML"], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},
      { th: [:SDTM, :CDASH, :ADaM, :SEND, :Protocol, :"Define-XML"], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},
      { th: [:SDTM, :CDASH, :ADaM, :SEND, :Protocol, :"Define-XML"], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},
      { th: [:SDTM, :CDASH, :ADaM, :SEND, :Protocol, :"Define-XML"], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},
      { th: [:SDTM, :CDASH, :ADaM, :SEND, :Protocol, :"Define-XML"], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]},
      { th: [:SDTM, :CDASH, :ADaM, :SEND, :Protocol, :"Define-XML"], cl: [ C16564: [:SDTM], C49499: [:SDTM] ]}
    ]

  end

  describe "2007" do

    it "Base create, 2007-03-06", :import_data => 'slow' do
      release_date = "2007-03-06"
      results = execute_import(release_date, {sdtm: "2007-03-06"}, set_write_file, use_api)
      expected = [
        {cl: :C16564, status: :created},
        {cl: :C20587, status: :created},
        {cl: :C49627, status: :created},
        {cl: :C49660, status: :created},
        {cl: :C49499, status: :created}
      ]
      check_cl_results(results, expected)
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2007-04-20", :import_data => 'slow' do
      release_date = "2007-04-20"
      results = execute_import(release_date, {sdtm: "2007-04-20"}, set_write_file, use_api)
      expected = [
        {cl: :C16564, status: :deleted},
        {cl: :C20587, status: :deleted},
        {cl: :C49627, status: :deleted},
        {cl: :C49660, status: :deleted},
        {cl: :C49499, status: :deleted},
        {cl: :C66787, status: :created},
        {cl: :C66790, status: :created},
        {cl: :C67153, status: :created},
        {cl: :C66737, status: :created}
      ]
      check_cl_results(results, expected) 
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2007-04-26", :import_data => 'slow' do
      release_date = "2007-04-26"
      results = execute_import(release_date, {sdtm: "2007-04-26"}, set_write_file, use_api)
      expected = [
        {cl: :C66785, status: :created},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67153, status: :no_change},
        {cl: :C66737, status: :updated}
      ]
      check_cl_results(results, expected) 
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2007-05-31", :import_data => 'slow' do
      release_date = "2007-05-31"
      #version = 4
      results = execute_import(release_date, {sdtm: "2007-05-31"}, set_write_file, use_api)
      expected = [
        {cl: :C66785, status: :updated},
        {cl: :C66787, status: :updated},
        {cl: :C66790, status: :updated},
        {cl: :C67153, status: :updated},
        {cl: :C66737, status: :updated},
        {cl: :C67152, status: :updated}
      ]
      check_cl_results(results, expected) 
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2007-06-05", :import_data => 'slow' do
      release_date = "2007-06-05"
      results = execute_import(release_date, {sdtm: "2007-06-05"}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :updated},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :no_change},
        {cl: :C67153, status: :no_change}
      ]
      check_cl_results(results, expected) 
      check_count(release_date)
      check_tags(release_date)
    end

  end

  describe "2008" do

    it "Create 2008-01-15", :import_data => 'slow' do
      release_date = "2008-01-15"
      results = execute_import(release_date, {sdtm: "2008-01-15"}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :no_change},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :no_change},
        {cl: :C67153, status: :no_change},
        {cl: :C71153, status: :created},
        {cl: :C71620, status: :created}
      ]
      check_cl_results(results, expected) 
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2008-01-25", :import_data => 'slow' do
      release_date = "2008-01-25"
      results = execute_import(release_date, {sdtm: "2008-01-25"}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :no_change},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :no_change},
        {cl: :C67153, status: :no_change},
        {cl: :C71153, status: :no_change},
        {cl: :C71620, status: :no_change}
      ]
      check_cl_results(results, expected) 
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2008-08-26", :import_data => 'slow' do
      release_date = "2008-08-26"
      results = execute_import(release_date, {sdtm: "2008-08-26"}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :updated},
        {cl: :C66738, status: :no_change},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :no_change},
        {cl: :C67153, status: :no_change},
        {cl: :C71153, status: :no_change},
        {cl: :C71620, status: :no_change},
        {cl: :C74559, status: :created}
      ]
      check_cl_results(results, expected) 
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2008-09-22", :import_data => 'slow' do
      release_date = "2008-09-22"
      results = execute_import(release_date, {sdtm: "2008-09-22"}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :updated},
        {cl: :C66738, status: :no_change},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :no_change},
        {cl: :C67153, status: :no_change},
        {cl: :C71153, status: :no_change},
        {cl: :C71620, status: :updated},
        {cl: :C74559, status: :no_change}
      ]
      check_cl_results(results, expected) 
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2008-09-24", :import_data => 'slow' do
      release_date = "2008-09-24"
      results = execute_import(release_date, {sdtm: "2008-09-24"}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :no_change},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :no_change},
        {cl: :C67153, status: :no_change},
        {cl: :C71153, status: :no_change},
        {cl: :C71620, status: :no_change},
        {cl: :C74559, status: :updated},
        {cl: :C74456, status: :no_change},
        {cl: :C76351, status: :created},
        {cl: :C25188, status: :deleted}
      ]
      check_cl_results(results, expected) 
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2008-09-30", :import_data => 'slow' do
      release_date = "2008-09-30"
      results = execute_import(release_date, {sdtm: "2008-09-30"}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :no_change},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :no_change},
        {cl: :C67153, status: :no_change},
        {cl: :C71153, status: :no_change},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :no_change},
        {cl: :C76351, status: :no_change}
      ]
      check_cl_results(results, expected)
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2008-10-09", :import_data => 'slow' do
      release_date = "2008-10-09"
      results = execute_import(release_date, {sdtm: "2008-10-09"}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :no_change},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :no_change},
        {cl: :C67153, status: :no_change},
        {cl: :C71153, status: :no_change},
        {cl: :C71620, status: :no_change},
        {cl: :C74456, status: :no_change},
        {cl: :C76351, status: :no_change}
      ]
      check_cl_results(results, expected)
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2008-10-15", :import_data => 'slow' do
      release_date = "2008-10-15"
      results = execute_import(release_date, {sdtm: "2008-10-15"}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :no_change},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :updated},
        {cl: :C67152, status: :no_change},
        {cl: :C67153, status: :no_change},
        {cl: :C71153, status: :no_change},
        {cl: :C71620, status: :no_change},
        {cl: :C74456, status: :no_change},
        {cl: :C76351, status: :no_change}
      ]
      check_cl_results(results, expected)
      check_count(release_date)
      check_tags(release_date)
    end

  end

  describe "2009" do

    it "Create 2009-02-17", :import_data => 'slow' do
      release_date = "2009-02-17"
      results = execute_import(release_date, {sdtm: "2009-02-17"}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :no_change},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :no_change},
        {cl: :C67153, status: :updated},
        {cl: :C71153, status: :no_change},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :no_change},
        {cl: :C76351, status: :no_change}
      ]
      check_cl_results(results, expected)
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2009-02-18", :import_data => 'slow' do
      release_date = "2009-02-18"
      results = execute_import(release_date, {sdtm: "2009-02-18"}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :no_change},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :no_change},
        {cl: :C67153, status: :no_change},
        {cl: :C71153, status: :no_change},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :no_change},
        {cl: :C76351, status: :no_change}
      ]
      check_cl_results(results, expected)
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2009-05-01", :import_data => 'slow' do
      release_date = "2009-05-01"
      results = execute_import(release_date, {sdtm: "2009-05-01"}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :updated},
        {cl: :C66738, status: :updated},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :updated},
        {cl: :C66790, status: :updated},
        {cl: :C67152, status: :updated},
        {cl: :C67153, status: :updated},
        {cl: :C71153, status: :no_change},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :updated},
        {cl: :C76351, status: :updated}
      ]
      check_cl_results(results, expected)
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2009-07-06", :import_data => 'slow' do
      release_date = "2009-07-06"
      results = execute_import(release_date, {sdtm: "2009-07-06"}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :no_change},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :no_change},
        {cl: :C67153, status: :no_change},
        {cl: :C71153, status: :no_change},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :no_change},
        {cl: :C76351, status: :no_change}
      ]
      check_cl_results(results, expected)
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2009-10-06", :import_data => 'slow' do
      release_date = "2009-10-06"
      results = execute_import(release_date, {sdtm: "2009-10-06"}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :updated},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :updated},
        {cl: :C67152, status: :updated},
        {cl: :C67153, status: :no_change},
        {cl: :C71153, status: :no_change},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :no_change},
        {cl: :C76351, status: :no_change}
      ]
      check_cl_results(results, expected)
      check_count(release_date)
      check_tags(release_date)
    end

  end

  describe "2010" do

    it "Create 2010-03-05", :import_data => 'slow' do
      release_date = "2010-03-05"
      results = execute_import(release_date, {sdtm: "2010-03-05", cdash: "2010-03-05", adam: "2010-03-05"}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :updated},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :updated},
        {cl: :C67152, status: :updated},
        {cl: :C67153, status: :updated},
        {cl: :C71153, status: :no_change},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :no_change},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :updated}
      ]
      check_cl_results(results, expected)
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2010-04-08", :import_data => 'slow' do
      release_date = "2010-04-08"
      results = execute_import(release_date, {sdtm: "2010-04-08", cdash: "2010-04-08", adam: "2010-04-08"}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :no_change},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :no_change},
        {cl: :C67153, status: :updated},
        {cl: :C71153, status: :no_change},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :updated},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :no_change}
      ]
      check_cl_results(results, expected)
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2010-07-02", :import_data => 'slow' do
      release_date = "2010-07-02"
      results = execute_import(release_date, {sdtm: "2010-07-02", cdash: "2010-04-08", adam: "2010-04-08"}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :no_change},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :no_change},
        {cl: :C67153, status: :no_change},
        {cl: :C71153, status: :no_change},
        {cl: :C71620, status: :no_change},
        {cl: :C74456, status: :no_change},
        {cl: :C76351, status: :updated},
        {cl: :C78735, status: :no_change}
      ]
      check_cl_results(results, expected)
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2010-10-06", :import_data => 'slow' do
      release_date = "2010-10-06"
      results = execute_import(release_date, {sdtm: "2010-10-06", cdash: "2010-04-08", adam: "2010-10-06"}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :updated},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :updated},
        {cl: :C67153, status: :no_change},
        {cl: :C71153, status: :no_change},
        {cl: :C71620, status: :no_change},
        {cl: :C74456, status: :updated},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :no_change}
      ]
      check_cl_results(results, expected)
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2010-10-22", :import_data => 'slow' do
      release_date = "2010-10-22"
      results = execute_import(release_date, {sdtm: "2010-10-22", cdash: "2010-04-08", adam: "2010-10-06"}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :no_change},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :no_change},
        {cl: :C67153, status: :no_change},
        {cl: :C71153, status: :no_change},
        {cl: :C71620, status: :no_change},
        {cl: :C74456, status: :no_change},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :no_change}
      ]
      check_cl_results(results, expected)
      check_count(release_date)
      check_tags(release_date)
    end

  end

  describe "2011" do

    it "Create 2011-01-07", :import_data => 'slow' do
      release_date = "2011-01-07"
      results = execute_import(release_date, {sdtm: "2011-01-07", adam: "2011-01-07", cdash: "2011-01-07"}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :no_change},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :no_change},
        {cl: :C67153, status: :no_change},
        {cl: :C71153, status: :no_change},
        {cl: :C71620, status: :no_change},
        {cl: :C74456, status: :no_change},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :no_change}
      ]
      check_cl_results(results, expected)
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2011-04-08", :import_data => 'slow' do
      release_date = "2011-04-08"
      results = execute_import(release_date, {sdtm: "2011-04-08", adam: "2011-01-07", cdash: "2011-04-08"}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :no_change},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :updated},
        {cl: :C67153, status: :no_change},
        {cl: :C71153, status: :no_change},
        {cl: :C71620, status: :no_change},
        {cl: :C74456, status: :no_change},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :no_change}
      ]
      check_cl_results(results, expected)
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2011-06-10", :import_data => 'slow' do
      release_date = "2011-06-10"
      results = execute_import(release_date, {sdtm: "2011-06-10", adam: "2011-01-07", cdash: "2011-04-08", send: "2011-06-10"}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :no_change},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :no_change},
        {cl: :C67153, status: :no_change},
        {cl: :C71153, status: :updated},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :updated},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :no_change},
        {cl: :C90007, status: :created},
        {cl: :C89969, status: :created},
        {cl: :C89970, status: :created}
      ]
      check_cl_results(results, expected)
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2011-07-22", :import_data => 'slow' do
      release_date = "2011-07-22"
      results = execute_import(release_date, {sdtm: "2011-07-22", adam: "2011-07-22", cdash: "2011-07-22", send: "2011-07-22"}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :updated},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :updated},
        {cl: :C67153, status: :no_change},
        {cl: :C71153, status: :no_change},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :updated},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :no_change}
      ]
      check_cl_results(results, expected)
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2011-12-09", :import_data => 'slow' do
      release_date = "2011-12-09"
      results = execute_import(release_date, {sdtm: "2011-12-09", adam: "2011-07-22", cdash: "2011-12-09", send: "2011-12-09"}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :updated},
        {cl: :C66785, status: :updated},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :updated},
        {cl: :C67153, status: :updated},
        {cl: :C71153, status: :no_change},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :updated},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :no_change},
        {cl: :C88025, status: :created}
      ]
      check_cl_results(results, expected)
      check_count(release_date)
      check_tags(release_date)
    end

  end

  describe "2012" do

    it "Create 2012-01-02", :import_data => 'slow' do
      release_date = "2012-01-02"
      results = execute_import(release_date, {sdtm: "2011-12-09", adam: "2011-07-22", cdash: "2011-12-09", send: release_date}, set_write_file, use_api)
      expected = [] # No logical changes, release removed spaces from some entries. 
      check_cl_results(results, expected)
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2012-03-23", :import_data => 'slow' do
      release_date = "2012-03-23"
      results = execute_import(release_date, {sdtm: "2012-03-23", adam: "2011-07-22", cdash: "2011-12-09", qs: "2012-03-23", send: release_date}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :updated},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :updated},
        {cl: :C67153, status: :updated},
        {cl: :C71153, status: :updated},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :updated},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :updated},
        {cl: :C88025, status: :no_change}
      ]
      check_cl_results(results, expected)
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2012-06-29", :import_data => 'slow' do
      release_date = "2012-06-29"
      # Note the SEND file used for this release has been hand crafted. If not there would have been serious misalignment.
      results = execute_import(release_date, {sdtm: "2012-06-29", adam: "2011-07-22", cdash: "2012-06-29", qs: "2012-06-29", send: release_date}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :no_change},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :no_change},
        {cl: :C67153, status: :no_change},
        {cl: :C71153, status: :updated},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :updated},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :no_change},
        {cl: :C88025, status: :updated}
      ]
      check_cl_results(results, expected)
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2012-08-03", :import_data => 'slow' do
      release_date = "2012-08-03"
      results = execute_import(release_date, {sdtm: "2012-08-03", adam: "2011-07-22", cdash: "2012-06-29", qs: "2012-08-03", send: release_date}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :no_change},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :no_change},
        {cl: :C67153, status: :no_change},
        {cl: :C71153, status: :no_change},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :updated},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :no_change},
        {cl: :C88025, status: :no_change}
      ]
      check_cl_results(results, expected)
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2012-12-21", :import_data => 'slow' do
      release_date = "2012-12-21"
      results = execute_import(release_date, {sdtm: "2012-12-21", qs: "2012-12-21", cdash: "2012-12-21", adam: "2011-07-22", send: release_date}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :updated},
        {cl: :C66738, status: :updated},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :updated},
        {cl: :C67153, status: :updated},
        {cl: :C71153, status: :no_change},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :updated},
        {cl: :C76351, status: :updated},
        {cl: :C78735, status: :updated},
        {cl: :C88025, status: :updated}
      ]
      check_cl_results(results, expected)
      check_count(release_date)
      check_tags(release_date)
    end

  end

  describe "2013" do

    it "Create 2013-04-12", :import_data => 'slow' do
      release_date = "2013-04-12"
      results = execute_import(release_date, {sdtm: "2013-04-12", qs: "2013-04-12", cdash: "2012-12-21", adam: "2011-07-22", send: release_date}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :no_change},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :updated},
        {cl: :C67152, status: :updated},
        {cl: :C67153, status: :updated},
        {cl: :C71153, status: :updated},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :updated},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :updated},
        {cl: :C88025, status: :updated}
      ]
      check_cl_results(results, expected)
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2013-06-28", :import_data => 'slow' do
      release_date = "2013-06-28"
      results = execute_import(release_date, {sdtm: "2013-06-28", qs: "2013-06-28", cdash: "2013-06-28", adam: "2011-07-22", send: release_date}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :no_change},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :no_change},
        {cl: :C67153, status: :updated},
        {cl: :C71153, status: :no_change},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :updated},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :updated},
        {cl: :C88025, status: :no_change} 
      ]
      check_cl_results(results, expected) 
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2013-10-04", :import_data => 'slow' do
      release_date = "2013-10-04"
      results = execute_import(release_date, {sdtm: "2013-10-04", qs: "2013-10-04", cdash: "2013-10-04", adam: "2011-07-22", send: release_date}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :updated},
        {cl: :C66738, status: :updated},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :updated},
        {cl: :C67153, status: :no_change},
        {cl: :C71153, status: :updated},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :updated},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :no_change},    
        {cl: :C88025, status: :updated}
      ]
      check_cl_results(results, expected)
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2013-12-20", :import_data => 'slow' do
      release_date = "2013-12-20"
      results = execute_import(release_date, {sdtm: "2013-12-20", qs: "2013-12-20", cdash: "2013-12-20", adam: "2011-07-22", send: release_date}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :updated},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :updated},
        {cl: :C67153, status: :updated},
        {cl: :C71153, status: :updated},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :updated},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :no_change},
        {cl: :C88025, status: :updated}
      ]
      check_cl_results(results, expected)
      check_count(release_date)
      check_tags(release_date)
    end

  end

  describe "2014" do

    it "Create 2014-03-28", :import_data => 'slow' do
      release_date = "2014-03-28"
      results = execute_import(release_date, {sdtm: "2014-03-28", qs: "2014-03-28", cdash: "2014-03-28", adam: "2011-07-22", send: release_date}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :updated},
        {cl: :C66738, status: :updated},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :updated},
        {cl: :C67153, status: :no_change},
        {cl: :C71153, status: :no_change},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :updated},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :no_change},  
        {cl: :C88025, status: :updated}
      ]
      check_cl_results(results, expected) 
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2014-06-27", :import_data => 'slow' do
      release_date = "2014-06-27"
      results = execute_import(release_date, {sdtm: "2014-06-27", qsft: "2014-06-27", cdash: "2014-03-28", adam: "2011-07-22", send: release_date}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :updated},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :updated},
        {cl: :C67153, status: :no_change},
        {cl: :C71153, status: :updated},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :updated},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :no_change},
        {cl: :C88025, status: :updated}
      ]
      check_cl_results(results, expected) 
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2014-09-26", :import_data => 'slow' do
      release_date = "2014-09-26"
      results = execute_import(release_date, {sdtm: "2014-09-26", qsft: "2014-09-26", cdash: "2014-09-26", adam: "2014-09-26", send: release_date}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :updated},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :updated},
        {cl: :C67153, status: :updated},
        {cl: :C71153, status: :updated},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :updated},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :no_change},
        {cl: :C88025, status: :updated}
      ]
      check_cl_results(results, expected) 
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2014-10-06", :import_data => 'slow' do
      release_date = "2014-10-06"
      results = execute_import(release_date, {sdtm: "2014-10-06", qsft: "2014-09-26", cdash: "2014-09-26", adam: "2014-09-26", send: "2014-09-26"}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :updated},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :updated},
        {cl: :C67153, status: :no_change},
        {cl: :C71153, status: :no_change},
        {cl: :C71620, status: :no_change},
        {cl: :C74456, status: :no_change},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :no_change},
        {cl: :C88025, status: :no_change}
      ]
      check_cl_results(results, expected) 
      check_count(release_date)
      check_tags(release_date)
   end

    it "Create 2014-12-19", :import_data => 'slow' do
      release_date = "2014-12-19"
      results = execute_import(release_date, {sdtm: "2014-12-19", coa: "2014-12-19", cdash: "2014-09-26", adam: "2014-09-26", send: release_date}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :updated},
        {cl: :C66738, status: :updated},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :updated},
        {cl: :C67153, status: :no_change},
        {cl: :C71153, status: :updated},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :updated},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :updated},
        {cl: :C88025, status: :updated}
      ]
      check_cl_results(results, expected) 
      check_count(release_date)
      check_tags(release_date)
    end

  end

  describe "2015" do

    it "Create 2015-03-27", :import_data => 'slow' do
      release_date = "2015-03-27"
      results = execute_import(release_date, {sdtm: "2015-03-27", coa: "2015-03-27", cdash: "2015-03-27", adam: "2014-09-26", send: release_date}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :updated},
        {cl: :C66785, status: :updated},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :updated},
        {cl: :C67153, status: :no_change},
        {cl: :C71153, status: :updated},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :updated},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :no_change},
        {cl: :C88025, status: :updated}
      ]
      check_cl_results(results, expected) 
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2015-06-26", :import_data => 'slow' do
      release_date = "2015-06-26"
      results = execute_import(release_date, {sdtm: "2015-06-26", qrs: "2015-06-26", cdash: "2015-03-27", adam: "2014-09-26", send: release_date}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :updated},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :updated},
        {cl: :C67153, status: :updated},
        {cl: :C71153, status: :updated},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :updated},
        {cl: :C76351, status: :updated},
        {cl: :C78735, status: :no_change},
        {cl: :C88025, status: :updated}
      ]
      check_cl_results(results, expected) 
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2015-09-25", :import_data => 'slow' do
      release_date = "2015-09-25"
      results = execute_import(release_date, {sdtm: "2015-09-25", qrs: "2015-09-25", cdash: "2015-03-27", adam: "2014-09-26", send: release_date}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :updated},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :updated},
        {cl: :C67153, status: :no_change},
        {cl: :C71153, status: :updated},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :updated},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :no_change},
        {cl: :C88025, status: :updated}
      ]
      check_cl_results(results, expected) 
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2015-12-18", :import_data => 'slow' do
      release_date = "2015-12-18"
      results = execute_import(release_date, {sdtm: "2015-12-18", cdash: "2015-03-27", adam: "2015-12-18", send: release_date}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :updated},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :updated},
        {cl: :C67153, status: :updated},
        {cl: :C71153, status: :updated},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :updated},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :no_change},
        {cl: :C88025, status: :updated}
      ]
      check_cl_results(results, expected) 
      check_count(release_date)
      check_tags(release_date)
    end

  end

  describe "2016" do

    it "Create 2016-03-25", :import_data => 'slow' do
      release_date = "2016-03-25"
      results = execute_import(release_date, {sdtm: "2016-03-25", cdash: "2016-03-25", adam: "2016-03-25", send: release_date}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :updated},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :updated},
        {cl: :C67153, status: :updated},
        {cl: :C71153, status: :no_change},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :updated},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :no_change},
        {cl: :C88025, status: :updated}
      ]
      check_cl_results(results, expected) 
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2016-06-24", :import_data => 'slow' do
      release_date = "2016-06-24"
      results = execute_import(release_date, {sdtm: "2016-06-24", cdash: "2016-03-25", adam: "2016-03-25", send: release_date}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :updated},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :updated},
        {cl: :C67153, status: :no_change},
        {cl: :C71153, status: :no_change},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :updated},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :no_change},
        {cl: :C88025, status: :updated}
      ]
      check_cl_results(results, expected) 
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2016-09-30", :import_data => 'slow' do
      release_date = "2016-09-30"
      results = execute_import(release_date, {sdtm: "2016-09-30", cdash: "2016-09-30", adam: "2016-09-30", send: release_date}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :updated},
        {cl: :C66738, status: :updated},
        {cl: :C66785, status: :updated},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :updated},
        {cl: :C67153, status: :updated},
        {cl: :C71153, status: :no_change},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :updated},
        {cl: :C76351, status: :updated},
        {cl: :C78735, status: :no_change},
        {cl: :C88025, status: :updated}
      ]
      check_cl_results(results, expected) 
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2016-12-16", :import_data => 'slow' do
      release_date = "2016-12-16"
      results = execute_import(release_date, {sdtm: "2016-12-16", cdash: "2016-12-16", adam: "2016-12-16", send: release_date}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :updated},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :updated},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :updated},
        {cl: :C67153, status: :no_change},
        {cl: :C71153, status: :no_change},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :updated},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :no_change}
      ]
      check_cl_results(results, expected) 
      check_count(release_date)
      check_tags(release_date)
    end

  end

  describe "2017" do

    it "Create 2017-03-31", :import_data => 'slow' do
      release_date = "2017-03-31"
      results = execute_import(release_date, {sdtm: "2017-03-31", cdash: "2016-12-16", adam: "2017-03-31", send: release_date, protocol: release_date}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :no_change},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :no_change},
        {cl: :C67153, status: :updated},
        {cl: :C71153, status: :no_change},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :updated},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :updated}
      ]
      check_cl_results(results, expected) 
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2017-06-30", :import_data => 'slow' do
      release_date = "2017-06-30"
      results = execute_import(release_date, {sdtm: "2017-06-30", cdash: "2016-12-16", adam: "2017-03-31", send: release_date, protocol: release_date}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :updated},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :updated},
        {cl: :C67153, status: :updated},
        {cl: :C71153, status: :no_change},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :no_change},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :no_change}
      ]
      check_cl_results(results, expected)
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2017-09-29", :import_data => 'slow' do
      release_date = "2017-09-29"
      results = execute_import(release_date, {sdtm: "2017-09-29", cdash: "2017-09-29", adam: "2017-09-29", send: release_date, protocol: release_date}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :updated},
        {cl: :C66738, status: :updated},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :updated},
        {cl: :C67153, status: :no_change},
        {cl: :C71153, status: :updated},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :updated},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :no_change}
      ]
      check_cl_results(results, expected) 
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2017-12-22", :import_data => 'slow' do
      release_date = "2017-12-22"
      results = execute_import(release_date, {sdtm: "2017-12-22", cdash: "2017-09-29", adam: "2017-09-29", send: release_date, protocol: release_date}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :updated},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :updated},
        {cl: :C67152, status: :updated},
        {cl: :C67153, status: :no_change},
        {cl: :C71153, status: :no_change},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :updated},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :no_change}
      ]
      check_cl_results(results, expected) 
      check_count(release_date)
      check_tags(release_date)
    end

  end

  describe "2018" do

    it "Create 2018-03-30", :import_data => 'slow' do
      release_date = "2018-03-30"
      results = execute_import(release_date, {sdtm: "2018-03-30", cdash: "2018-03-30", adam: "2017-09-29", send: release_date, protocol: release_date}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :updated},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :updated},
        {cl: :C67153, status: :updated},
        {cl: :C71153, status: :no_change},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :updated},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :updated}
      ]
      check_cl_results(results, expected)
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2018-06-29", :import_data => 'slow' do
      release_date = "2018-06-29"
      results = execute_import(release_date, {sdtm: "2018-06-29", cdash: "2018-06-29", adam: "2017-09-29", send: release_date, protocol: release_date}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :updated},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :updated},
        {cl: :C67152, status: :updated},
        {cl: :C67153, status: :no_change},
        {cl: :C71153, status: :no_change},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :updated},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :updated}
      ]
      check_cl_results(results, expected)
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2018-09-28", :import_data => 'slow' do
      release_date = "2018-09-28"
      results = execute_import(release_date, {sdtm: "2018-09-28", cdash: "2018-09-28", adam: "2017-09-29", send: release_date, protocol: release_date}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :updated},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :updated},
        {cl: :C67153, status: :updated},
        {cl: :C71153, status: :no_change},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :updated},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :updated}
      ]
      check_cl_results(results, expected) 
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2018-12-21", :import_data => 'slow' do
      release_date = "2018-12-21"
      results = execute_import(release_date, {sdtm: "2018-12-21", cdash: "2018-12-21", adam: "2018-12-21", send: release_date, protocol: "2018-09-28"}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :updated},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :updated},
        {cl: :C67153, status: :updated},
        {cl: :C71153, status: :no_change},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :updated},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :no_change}
      ]
      check_cl_results(results, expected) 
      check_count(release_date)
      check_tags(release_date)
    end

  end

  describe "2019" do

    it "Create 2019-03-29", :import_data => 'slow' do
      release_date = "2019-03-29"
      results = execute_import(release_date, {sdtm: "2019-03-29", cdash: "2019-03-29", adam: "2019-03-29", send: release_date, protocol: release_date}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :updated},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :updated},
        {cl: :C67153, status: :updated},
        {cl: :C71153, status: :no_change},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :updated},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :no_change}
      ]
      check_cl_results(results, expected)
      check_count(release_date) # Duplicates (155) in CDASH C128690, C128689 
      check_tags(release_date)
    end

    it "Create 2019-06-28", :import_data => 'slow' do
      release_date = "2019-06-28"
      results = execute_import(release_date, {sdtm: "2019-06-28", cdash: "2019-06-28", adam: "2019-03-29", send: release_date, protocol: release_date}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :updated},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :deleted},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :updated},
        {cl: :C67153, status: :no_change},
        {cl: :C71153, status: :updated},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :updated},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :no_change}
      ]
      check_cl_results(results, expected) 
      check_count(release_date) # Duplicates (159) in CDASH C128690, C128689 
      check_tags(release_date)
    end

    it "Create 2019-09-27", :import_data => 'slow' do
      release_date = "2019-09-27"
      results = execute_import(release_date, {sdtm: release_date, cdash: "2019-06-28", adam: "2019-03-29", send: release_date, protocol: release_date}, set_write_file, use_api)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :updated},
        {cl: :C66785, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :updated},
        {cl: :C67153, status: :updated},
        {cl: :C67154, status: :updated},
        {cl: :C71153, status: :no_change},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :updated},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :no_change},
        {cl: :C128689, status: :no_change},
        {cl: :C147069, status: :updated},
        {cl: :C160930, status: :updated},
        {cl: :C163026, status: :created},
        {cl: :C163028, status: :created}
      ]
      check_cl_results(results, expected) 
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2019-12-20", :import_data => 'slow' do
      release_date = "2019-12-20"
      results = execute_import(release_date, {sdtm: release_date, cdash: release_date, adam: release_date, send: release_date, protocol: release_date, define: release_date}, set_write_file, use_api)
      expected = [
        {cl: :C66737,  status: :no_change},     # TPHASE
        {cl: :C66738,  status: :no_change},     # TSPARMCD
        {cl: :C66785,  status: :no_change},     # TCNTRL
        {cl: :C66790,  status: :no_change},     # ETHNIC
        {cl: :C67152,  status: :no_change},     # TSPARM
        {cl: :C67153,  status: :no_change},     # VSTEST
        {cl: :C67154,  status: :updated},       # LBTEST
        {cl: :C71153,  status: :no_change},     # EGTESTCD
        {cl: :C71148,  status: :updated},       # POSITION
        {cl: :C71620,  status: :updated},       # UNIT
        {cl: :C74456,  status: :updated},       # LOC
        {cl: :C76351,  status: :updated},       # SKINCLAS
        {cl: :C78431,  status: :updated},       # VSPOS
        {cl: :C78735,  status: :no_change},     # EVAL
        {cl: :C99079,  status: :updated},       # EPOCH
        {cl: :C118971, status: :updated},       # CCCAT
        {cl: :C128689, status: :no_change},     # RACEC
        {cl: :C147069, status: :no_change},     # Randomization Type Value Set
        {cl: :C160930, status: :no_change},     # CHAGNAMR
        {cl: :C161625, status: :updated},       # BPR02TC 
        {cl: :C163026, status: :no_change},     # Study Monitoring Attribute Terminology
        {cl: :C163028, status: :no_change},     # D1FATS
        {cl: :C165641, status: :created},       # Outcome Measure Attribute Terminology
        {cl: :C165644, status: :created},       # POOLINT
        {cl: :C165635, status: :created},       # BDSSC
        {cl: :C165636, status: :created}        # BDSISC
      ]
      check_cl_results(results, expected) 
      check_count(release_date)
      check_tags(release_date)
    end

  end

  describe "2020" do

    it "Create 2020-03-27", :import_data => 'slow' do
      release_date = "2020-03-27"
      results = execute_import(release_date, {sdtm: release_date, cdash: "2019-12-20", adam: release_date, send: release_date, protocol: release_date, define: release_date}, set_write_file, use_api)
      expected = [
        {cl: :C66737,  status: :no_change},     # TPHASE
        {cl: :C66738,  status: :updated},       # TSPARMCD
        {cl: :C66785,  status: :no_change},     # TCNTRL
        {cl: :C66790,  status: :no_change},     # ETHNIC
        {cl: :C67152,  status: :updated},       # TSPARM
        {cl: :C67153,  status: :updated},       # VSTEST
        {cl: :C67154,  status: :updated},       # LBTEST
        {cl: :C71153,  status: :no_change},     # EGTESTCD
        {cl: :C71148,  status: :no_change},     # POSITION
        {cl: :C71620,  status: :updated},       # UNIT
        {cl: :C74456,  status: :updated},       # LOC
        {cl: :C76351,  status: :no_change},     # SKINCLAS
        {cl: :C78431,  status: :no_change},     # VSPOS
        {cl: :C78735,  status: :no_change},     # EVAL
        {cl: :C99079,  status: :no_change},     # EPOCH
        {cl: :C118971, status: :updated},       # CCCAT
        {cl: :C128689, status: :no_change},     # RACEC
        {cl: :C147069, status: :updated},       # Randomization Type Value Set
        {cl: :C160930, status: :no_change},     # CHAGNAMR
        {cl: :C161625, status: :no_change},     # BPR02TC 
        {cl: :C163026, status: :no_change},     # Study Monitoring Attribute Terminology
        {cl: :C163028, status: :no_change}      # D1FATS
      ]
      check_cl_results(results, expected) 
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2020-05-08", :import_data => 'slow' do
      release_date = "2020-05-08"
      results = execute_import(release_date, {sdtm: release_date, cdash: release_date, adam: "2020-03-27", send: release_date, protocol: "2020-03-27", define: "2020-03-27"}, set_write_file, use_api)
      expected = [
        {cl: :C65047,  status: :updated},       # LBTESTCD
        {cl: :C66741,  status: :updated},       # VSTESTCD
        {cl: :C66737,  status: :no_change},     # TPHASE
        {cl: :C66738,  status: :updated},       # TSPARMCD
        {cl: :C66785,  status: :no_change},     # TCNTRL
        {cl: :C66790,  status: :no_change},     # ETHNIC
        {cl: :C67152,  status: :updated},       # TSPARM
        {cl: :C67153,  status: :updated},       # VSTEST
        {cl: :C67154,  status: :updated},       # LBTEST
        {cl: :C71153,  status: :no_change},     # EGTESTCD
        {cl: :C71620,  status: :updated},       # UNIT
        {cl: :C74456,  status: :no_change},     # LOC
        {cl: :C74559,  status: :updated},       # SCTESTCD
        {cl: :C76351,  status: :no_change},     # SKINCLAS
        {cl: :C78431,  status: :no_change},     # VSPOS
        {cl: :C78735,  status: :no_change},     # EVAL
        {cl: :C85494,  status: :updated},       # PKUNIT
        {cl: :C99079,  status: :no_change},     # EPOCH
        {cl: :C118971, status: :updated},       # CCCAT
        {cl: :C128689, status: :updated},       # RACEC
        {cl: :C103330, status: :updated},       # SCTEST
        {cl: :C147069, status: :no_change},     # Randomization Type Value Set
        {cl: :C160930, status: :no_change},     # CHAGNAMR
        {cl: :C163026, status: :no_change},     # Study Monitoring Attribute Terminology
        {cl: :C163028, status: :no_change}      # D1FATS
      ]
      check_cl_results(results, expected) 
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2020-06-26", :import_data => 'slow' do
      release_date = "2020-06-26"
      results = execute_import(release_date, {sdtm: release_date, cdash: "2020-05-08", adam: release_date, send: release_date, protocol: release_date, define: release_date}, set_write_file, use_api)
      expected = [
        {cl: :C65047,  status: :updated},       # LBTESTCD
        {cl: :C66741,  status: :updated},       # VSTESTCD
        {cl: :C66737,  status: :no_change},     # TPHASE
        {cl: :C66738,  status: :updated},       # TSPARMCD
        {cl: :C66785,  status: :no_change},     # TCNTRL
        {cl: :C66790,  status: :no_change},     # ETHNIC
        {cl: :C67152,  status: :updated},       # TSPARM
        {cl: :C67153,  status: :updated},       # VSTEST
        {cl: :C67154,  status: :updated},       # LBTEST
        {cl: :C71153,  status: :no_change},     # EGTESTCD
        {cl: :C71620,  status: :updated},       # UNIT
        {cl: :C74456,  status: :updated},       # LOC
        {cl: :C74559,  status: :updated},       # SCTESTCD
        {cl: :C76351,  status: :no_change},     # SKINCLAS
        {cl: :C78431,  status: :no_change},     # VSPOS
        {cl: :C78735,  status: :no_change},     # EVAL
        {cl: :C85494,  status: :updated},       # PKUNIT
        {cl: :C99079,  status: :no_change},     # EPOCH
        {cl: :C118971, status: :updated},       # CCCAT
        {cl: :C128689, status: :no_change},     # RACEC
        {cl: :C103330, status: :updated},       # SCTEST
        {cl: :C147069, status: :no_change},     # Randomization Type Value Set
        {cl: :C160930, status: :updated},       # CHAGNAMR
        {cl: :C163026, status: :no_change},     # Study Monitoring Attribute Terminology
        {cl: :C163028, status: :updated}        # D1FATS
      ]
      check_cl_results(results, expected) 
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2020-09-25", :import_data => 'slow' do
      release_date = "2020-09-25"
      results = execute_import(release_date, {sdtm: release_date, cdash: release_date, adam: release_date, send: release_date, protocol: release_date, define: "2020-06-26"}, set_write_file, use_api)
      expected = [
        {cl: :C65047,  status: :updated},       # LBTESTCD
        {cl: :C66741,  status: :updated},       # VSTESTCD
        {cl: :C66737,  status: :no_change},     # TPHASE
        {cl: :C66738,  status: :updated},       # TSPARMCD
        {cl: :C66785,  status: :updated},       # TCNTRL
        {cl: :C66790,  status: :no_change},     # ETHNIC
        {cl: :C67152,  status: :updated},       # TSPARM
        {cl: :C67153,  status: :updated},       # VSTEST
        {cl: :C67154,  status: :updated},       # LBTEST
        {cl: :C71153,  status: :updated},       # EGTESTCD
        {cl: :C71620,  status: :updated},       # UNIT
        {cl: :C74456,  status: :updated},       # LOC
        {cl: :C74559,  status: :updated},       # SCTESTCD
        {cl: :C76351,  status: :no_change},     # SKINCLAS
        {cl: :C78431,  status: :no_change},     # VSPOS
        {cl: :C78735,  status: :updated},       # EVAL
        {cl: :C85494,  status: :updated},       # PKUNIT
        {cl: :C99079,  status: :no_change},     # EPOCH
        {cl: :C118971, status: :updated},       # CCCAT
        {cl: :C128689, status: :no_change},     # RACEC
        {cl: :C103330, status: :updated},       # SCTEST
        {cl: :C147069, status: :no_change},     # Randomization Type Value Set
        {cl: :C160930, status: :no_change},     # CHAGNAMR
        {cl: :C163026, status: :no_change},     # Study Monitoring Attribute Terminology
        {cl: :C163028, status: :updated}        # D1FATS
      ]
      check_cl_results(results, expected) 
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2020-11-06", :import_data => 'slow' do
      release_date = "2020-11-06"
      results = execute_import(release_date, {sdtm: release_date, cdash: release_date, adam: release_date, send: release_date, protocol: release_date, define: release_date}, set_write_file, use_api)
      expected = [
        {cl: :C65047,  status: :no_change},     # LBTESTCD
        {cl: :C66741,  status: :no_change},     # VSTESTCD
        {cl: :C67153,  status: :updated},       # VSTEST
        {cl: :C66737,  status: :no_change},     # TPHASE
        {cl: :C66738,  status: :no_change},     # TSPARMCD
        {cl: :C66785,  status: :no_change},     # TCNTRL
        {cl: :C66790,  status: :no_change},     # ETHNIC
        {cl: :C67152,  status: :no_change},     # TSPARM
        {cl: :C67153,  status: :no_change},     # VSTEST
        {cl: :C67154,  status: :no_change},     # LBTEST
        {cl: :C71153,  status: :no_change},     # EGTESTCD
        {cl: :C71620,  status: :no_change},     # UNIT
        {cl: :C74456,  status: :no_change},     # LOC
        {cl: :C74559,  status: :no_change},     # SCTESTCD
        {cl: :C76351,  status: :no_change},     # SKINCLAS
        {cl: :C78431,  status: :no_change},     # VSPOS
        {cl: :C78735,  status: :no_change},     # EVAL
        {cl: :C85494,  status: :no_change},     # PKUNIT
        {cl: :C99079,  status: :no_change},     # EPOCH
        {cl: :C118971, status: :no_change},     # CCCAT
        {cl: :C128689, status: :no_change},     # RACEC
        {cl: :C103330, status: :no_change},     # SCTEST
        {cl: :C147069, status: :no_change},     # Randomization Type Value Set
        {cl: :C160930, status: :no_change},     # CHAGNAMR
        {cl: :C163026, status: :no_change},     # Study Monitoring Attribute Terminology
        {cl: :C163028, status: :no_change}      # D1FATS
      ]
      check_cl_results(results, expected) 
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2020-12-18", :import_data => 'slow' do
      release_date = "2020-12-18"
      results = execute_import(release_date, {sdtm: release_date, cdash: release_date, adam: "2020-11-06", send: release_date, protocol: release_date, define: release_date}, set_write_file, use_api)
      expected = [
        {cl: :C65047,  status: :updated},       # LBTESTCD
        {cl: :C66741,  status: :no_change},     # VSTESTCD
        {cl: :C67153,  status: :no_change},     # VSTEST
        {cl: :C66737,  status: :no_change},     # TPHASE
        {cl: :C66738,  status: :updated},       # TSPARMCD
        {cl: :C66785,  status: :no_change},     # TCNTRL
        {cl: :C66790,  status: :no_change},     # ETHNIC
        {cl: :C67152,  status: :updated},       # TSPARM
        {cl: :C67153,  status: :no_change},     # VSTEST
        {cl: :C67154,  status: :updated},       # LBTEST
        {cl: :C71153,  status: :updated},       # EGTESTCD
        {cl: :C71620,  status: :updated},       # UNIT
        {cl: :C74456,  status: :updated},       # LOC
        {cl: :C74559,  status: :updated},       # SCTESTCD
        {cl: :C76351,  status: :no_change},     # SKINCLAS
        {cl: :C78431,  status: :no_change},     # VSPOS
        {cl: :C78735,  status: :no_change},     # EVAL
        {cl: :C85494,  status: :updated},       # PKUNIT
        {cl: :C99079,  status: :no_change},     # EPOCH
        {cl: :C118971, status: :updated},       # CCCAT
        {cl: :C128689, status: :no_change},     # RACEC
        {cl: :C103330, status: :updated},       # SCTEST
        {cl: :C147069, status: :no_change},     # Randomization Type Value Set
        {cl: :C160930, status: :no_change},     # CHAGNAMR
        {cl: :C163026, status: :no_change},     # Study Monitoring Attribute Terminology
        {cl: :C163028, status: :no_change}      # D1FATS
      ]
      check_cl_results(results, expected) 
      check_count(release_date)
      check_tags(release_date)
    end

    it "Create 2021-03-26", :import_data => 'slow' do
      release_date = "2021-03-26"
      results = execute_import(release_date, {sdtm: release_date, cdash: release_date, adam: "2020-11-06", send: release_date, protocol: release_date, define: release_date}, set_write_file, use_api)
      expected = [
        {cl: :C65047,  status: :updated},       # LBTESTCD
        {cl: :C66741,  status: :updated},       # VSTESTCD
        {cl: :C67153,  status: :updated},       # VSTEST
        {cl: :C66737,  status: :no_change},     # TPHASE
        {cl: :C66738,  status: :updated},       # TSPARMCD
        {cl: :C66785,  status: :no_change},     # TCNTRL
        {cl: :C66790,  status: :no_change},     # ETHNIC
        {cl: :C67152,  status: :updated},       # TSPARM
        {cl: :C67153,  status: :updated},       # VSTEST
        {cl: :C67154,  status: :updated},       # LBTEST
        {cl: :C71153,  status: :no_change},     # EGTESTCD
        {cl: :C71620,  status: :updated},       # UNIT
        {cl: :C74456,  status: :updated},       # LOC
        {cl: :C74559,  status: :updated},       # SCTESTCD
        {cl: :C76351,  status: :no_change},     # SKINCLAS
        {cl: :C78431,  status: :no_change},     # VSPOS
        {cl: :C78735,  status: :updated},       # EVAL
        {cl: :C85494,  status: :updated},       # PKUNIT
        {cl: :C99079,  status: :no_change},     # EPOCH
        {cl: :C118971, status: :updated},       # CCCAT
        {cl: :C128689, status: :no_change},     # RACEC
        {cl: :C103330, status: :updated},       # SCTEST
        {cl: :C147069, status: :no_change},     # Randomization Type Value Set
        {cl: :C160930, status: :no_change},     # CHAGNAMR
        {cl: :C163026, status: :no_change},     # Study Monitoring Attribute Terminology
        {cl: :C163028, status: :no_change}      # D1FATS
      ]
      check_cl_results(results, expected) 
      check_count(release_date)
      check_tags(release_date)
    end

  end

  describe "Compare Excel and API" do

    before :all do
      #
    end

    it "blank" do
    end

    it "compare excel and api results - WILL CURRENTLY FAIL - API login issue", :requires => 'cdisc_library_api' do
      [40, 42, 43, 44, 45, 46, 47, 48, 49, 50, 52, 57, 59, 60, 61, 62, 63, 65].each do |version|
        excel_file = excel_filename(version)
        api_file = api_filename(version)
        check_ttl_fix_v2(excel_file, api_file, {last_change_date: true})
      end
    end

    it "checks v55 files - WILL CURRENTLY FAIL - V55 error in CDISC library", :requires => 'cdisc_library_api' do
      [55].each do |version|
        excel_file = excel_filename(version)
        api_file = api_filename(version)
        check_ttl_fix_v2(excel_file, api_file, {last_change_date: true})
      end
    end

  end

  describe "Simple Statistics" do

    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
      CdiscCtHelpers.version_range.each do |version|
        load_local_file_into_triple_store(sub_dir, excel_filename(version))
      end
    end

    it "code list count by version" do
      query_string = %Q{
        SELECT ?s ?d ?v (COUNT(?item) as ?count) WHERE
        {
          ?s rdf:type #{Thesaurus.rdf_type.to_ref} .
          ?s isoT:creationDate ?d .
          ?s isoT:hasIdentifier ?si .
          ?si isoI:version ?v .
          ?s th:isTopConceptReference/bo:reference ?item .
        } GROUP BY ?s ?d ?v ORDER BY ?v
      }
      query_results = Sparql::Query.new.query(query_string, "", [:isoI, :isoT, :isoC, :th, :bo])
      result = query_results.by_object_set([:d, :v, :count]).map{|x| {date: x[:d], version: x[:v], count: x[:count], uri: x[:s].to_s}}
      check_file_actual_expected(result, sub_dir, "ct_query_cl_count_1.yaml", equate_method: :hash_equal, write_file: false)
    end

    it "code list items count by version" do
      query_string = %Q{
        SELECT ?s ?d ?v (COUNT(?item) as ?count) WHERE
        {
          ?s rdf:type #{Thesaurus.rdf_type.to_ref} .
          ?s isoT:creationDate ?d .
          ?s isoT:hasIdentifier ?si .
          ?si isoI:version ?v .
          ?s th:isTopConceptReference/bo:reference/th:narrower ?item .
        } GROUP BY ?s ?d ?v ORDER BY ?v
      }
      query_results = Sparql::Query.new.query(query_string, "", [:isoI, :isoT, :isoC, :th, :bo])
      result = query_results.by_object_set([:d, :v, :count]).map{|x| {date: x[:d], version: x[:v], count: x[:count], uri: x[:s].to_s}}
      check_file_actual_expected(result, sub_dir, "ct_query_cl_count_2.yaml", equate_method: :hash_equal, write_file: false)
    end

    def ct_set
      query_string = %Q{
        SELECT DISTINCT ?s ?v WHERE
        {
          ?s rdf:type #{Thesaurus.rdf_type.to_ref} .
          ?s isoT:hasIdentifier/isoI:version ?v .
        } ORDER BY ?v
      }
      query_results = Sparql::Query.new.query(query_string, "", [:isoI, :isoT, :isoC, :th, :bo])
      query_results.by_object_set([:s, :v]).map{|x| {uri: x[:s], version: x[:v]}}
    end

    def ct_tags(uri)
      %Q{
        SELECT DISTINCT ?v ?d ?clid ?cliid ?tag WHERE
        {
          #{uri.to_ref} isoT:creationDate ?d .
          #{uri.to_ref} isoT:hasIdentifier/isoI:version ?v .
          #{uri.to_ref} th:isTopConceptReference/bo:reference ?cl .
          ?cl th:identifier ?clid . 
          {               
            ?cl ^isoC:appliesTo ?x .
            ?x isoC:context #{uri.to_ref} .
            ?x isoC:classifiedAs/isoC:prefLabel ?tag .
            BIND ("" as ?cliid)
          }
          UNION
          {
            ?cl th:narrower ?cli .
            ?cli th:identifier ?cliid .             
            ?cli ^isoC:appliesTo ?y .
            ?y isoC:context #{uri.to_ref} .
            ?y isoC:classifiedAs/isoC:prefLabel ?tag .
          }
        } ORDER BY ?v ?clid ?cliid ?tag
      }
    end

    def ct_misaligned_tags(uri)
      %Q{
        SELECT DISTINCT ?v ?d ?clid ?cliid ?cltag ?clitag WHERE
        {
          #{uri.to_ref} isoT:creationDate ?d .
          #{uri.to_ref} isoT:hasIdentifier/isoI:version ?v .
          #{uri.to_ref} th:isTopConceptReference/bo:reference ?cl .
          ?cl th:identifier ?clid . 
          ?cl ^isoC:appliesTo ?x .
          ?x isoC:context #{uri.to_ref} .
          ?cl th:narrower ?cli .
          ?cli th:identifier ?cliid .             
          ?cli ^isoC:appliesTo ?y .
          ?y isoC:context #{uri.to_ref} .
          ?x isoC:classifiedAs/isoC:prefLabel ?cltag .
          FILTER NOT EXISTS {
            ?y isoC:classifiedAs/isoC:prefLabel ?clitag .
            FILTER(?cltag = ?clitag)
          }
        } ORDER BY ?v ?clid ?cliid ?cltag ?clitag
      }
    end

    it "tag analysis" do
      ct_set.each do |v|
        #next if v[:version] != "26"
        print "Processing: #{v[:uri]}, v#{v[:version]}  "
        query_results = Sparql::Query.new.query(ct_tags(v[:uri]), "", [:isoI, :isoT, :isoC, :th, :bo])
        print ".."
        results = query_results.by_object_set([:v, :d, :clid, :cliid, :tag]).map{|x| {version: x[:v], date: x[:d], code_list: x[:clid], code_list_item: x[:cliid], tag: x[:tag]}}
        print ".."
        overall = {}
        overall[:version] = results[0][:version]
        overall[:date] = results[0][:date]
        overall[:results] = {}
        results.each do |x|
          key = x[:code_list_item].empty? ? "#{x[:code_list]}" : "#{x[:code_list]}.#{x[:code_list_item]}"
          overall[:results][key] = [] unless overall[:results].key?(key) 
          overall[:results][key] << x[:tag]
        end
        puts ".."
        check_file_actual_expected(overall, sub_dir, "ct_query_tag_#{v[:version]}.yaml", equate_method: :hash_equal, write_file: false)
      end
    end

  end

  describe "Version Check" do

    def versions
      query = %Q{
        SELECT DISTINCT ?e ?l ?i ?v WHERE
        {
          ?e rdf:type <http://www.assero.co.uk/Thesaurus#ManagedConcept> .
          ?e isoC:label ?l .
          ?e isoT:hasIdentifier/isoI:identifier ?i .
          ?e isoT:hasIdentifier/isoI:version ?v .
          ?e isoT:hasIdentifier/isoI:hasScope/isoI:shortName ?sn .
        } ORDER BY ?i ?v
      }
      query_results = Sparql::Query.new.query(query, "", [:isoI, :isoT, :isoC, :th, :bo])
      query_results.by_object_set([:e, :l, :i, :v]).map{|x| {uri: x[:e].to_s, label: x[:l], code_list: x[:i], version: x[:v]}}
    end

    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
      CdiscCtHelpers.version_range.each do |version|
        load_local_file_into_triple_store(sub_dir, excel_filename(version))
      end
    end

    it "versions" do
      results = versions
      check_file_actual_expected(results, sub_dir, "ct_versions_check.yaml", equate_method: :hash_equal, write_file: false)
      processed = Hash.new{ |k,v| k[v] = [] }
      results.each {|item| processed[item[:code_list]] << item[:version]}
      processed.each do |cl, ver_set|
        puts "Code list: #{cl}"
        ver_set.each_with_index do |ver, index|
          puts "Version: #{ver}"
          expect(ver.to_i).to eq(index+1)
        end
      end
    end

  end

end