require 'rails_helper'
require 'csv'

describe "Import::SponsorTermFormatOne" do
	
	include DataHelpers
  include ImportHelpers
  include PublicFileHelpers
  include SparqlHelpers
  include ThesauriHelpers
  include InstallationHelpers
  
	def sub_dir
    return "models/import/data/sponsor_one/ct"
  end

  def setup
    @object = Import.new(:type => "Import::SponsorTermFormatOne") # Use this rather than above.
    @job = Background.new
    @job.save
    @object.background_id = @job.id
    @object.save
    @release_details =
    [
      {identifier: "2019 R1", label: "2019 Release 1", date: "2019-08-08", uri: "http://www.sanofi.com/2019_R1/V1#TH"},
      {identifier: "2020 R1", label: "2020 Release 1", date: "2020-03-26", uri: "http://www.sanofi.com/2020_R1/V1#TH"}
    ]
    @uri_2_6 = Uri.new(uri: "#{@release_details[0][:uri]}")
    @uri_3_0 = Uri.new(uri: "#{@release_details[1][:uri]}")
  end

  def read_installation(installation)
     content = YAML.load_file(Rails.root.join "config/installations/#{installation}/#{:thesauri}.yml").deep_symbolize_keys
     Rails.configuration.thesauri = content[Rails.env.to_sym]
  end

  def thesauri_identifiers(parent, child)
    NameValue.destroy_all
    NameValue.create(name: "thesaurus_parent_identifier", value: "#{parent}")
    NameValue.create(name: "thesaurus_child_identifier", value: "#{child}")    
  end
    
	before :all do
    select_installation(:thesauri, :sanofi)
  end

  before :each do
    load_files(schema_files, [])
    load_data_file_into_triple_store("mdr_sponsor_one_identification.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems_process.ttl")
    load_cdisc_term_versions(1..62)
    Import.destroy_all
    delete_all_public_test_files
    setup
  end

  after :each do
    Import.destroy_all
    delete_all_public_test_files
  end

  after :all do
    restore_installation(:thesauri)
  end

  def count_cl(th)
    query_string = %Q{
      SELECT (COUNT(DISTINCT ?s) as ?count) WHERE 
      {
        #{th.uri.to_ref} th:isTopConceptReference/bo:reference ?s
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:th, :bo]) 
    result = query_results.by_object(:count).first.to_i
    puts colourize("Total CL count=#{result}", "blue")
    result
  end

  def cl_identifiers(th)
    query_string = %Q{
      SELECT DISTINCT ?identifier ?label WHERE 
      {
        #{th.uri.to_ref} th:isTopConceptReference/bo:reference ?s .
        ?s th:identifier ?identifier .
        ?s isoC:label ?label .
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:th, :bo]) 
    query_results.by_object(:identifier, :label)
  end

  def count_cli(th)
    query_string = %Q{
      SELECT (COUNT(?s) as ?count) WHERE 
      {
        #{th.uri.to_ref} th:isTopConceptReference/bo:reference/th:narrower ?s
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:th, :bo]) 
    result = query_results.by_object(:count).first.to_i
    puts colourize("Total CLI count=#{result}", "blue")
    result
  end
  
  def count_distinct_cli(th)
    query_string = %Q{
      SELECT (COUNT(DISTINCT ?s) as ?count) WHERE 
      {
        #{th.uri.to_ref} th:isTopConceptReference/bo:reference/th:narrower ?s
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:th, :bo]) 
    result = query_results.by_object(:count).first.to_i
    puts colourize("Total Distinct CLI count=#{result}", "blue")
    result
  end
  
  def cl_list(th)
    query_string = %Q{
      SELECT ?cid WHERE 
      {
        #{th.uri.to_ref} th:isTopConceptReference/bo:reference ?s .
        ?s th:identifier ?cid .
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:th, :bo]) 
    query_results.by_object_set([:cid]).map{|x| x[:cid]}
  end

  def cl_info(th, key)
    query_string = %Q{
      SELECT ?n ?i (COUNT(?cli) as ?count) WHERE 
      {
        #{th.uri.to_ref} th:isTopConceptReference/bo:reference ?s .
        ?s isoC:label "#{key}" .
        ?s th:notation ?n .
        ?s th:identifier ?i .
        ?s th:narrower ?cli .
      } GROUP BY ?n ?i
    }
    query_results = Sparql::Query.new.query(query_string, "", [:th, :bo, :isoC]) 
    result = query_results.by_object_set([:n, :i, :count]).map{|x| {notation: x[:n], identifier: x[:i], count: x[:count]}}
    result.first
  end

  def cl_items(th, key)
    query_string = %Q{
      SELECT DISTINCT ?i WHERE 
      {
        #{th.uri.to_ref} th:isTopConceptReference/bo:reference ?s .
        ?s isoC:label "#{key}" .
        ?s th:narrower ?cli .
        ?cli th:identifier ?i
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:th, :bo, :isoC]) 
    query_results.by_object_set([:i]).map{|x| x[:i]}
  end

  def check_cl(th, long_name, identifier, notation, count, items)
    result = cl_info(th, long_name)
    if result.nil?
      puts colourize("#{long_name} : #{identifier}", "red")
      puts colourize("Notation: [<not found>, #{notation}] Count: [<not found>, #{count}]\n", "red")
    elsif result[:notation] == notation && result[:identifier] == identifier && "#{result[:count]}".to_i == "#{count}".to_i
      #puts colourize("#{long_name} : #{identifier}", "green")
    elsif result[:notation] == notation && result[:identifier] != identifier && "#{result[:count]}".to_i == "#{count}".to_i
      puts colourize("#{notation} : #{long_name} : #{identifier} != #{result[:identifier]}", "brown")
    else
      db_items = cl_items(th, long_name)
      puts colourize("#{long_name} : #{identifier}", "red")
      puts colourize("Notation: [#{result[:notation]}, #{notation}] Count: [#{result[:count]}, #{count}]", "red")
      puts colourize("Missing:  #{items - db_items}", "red")
      puts colourize("Extra:    #{db_items - items}\n", "red")
    end
  end

  class CodeListInfo
    
    @name =""
    @identifier =""
    @short_name
    @items = nil

    def initialize(name, short_name, identifier)
      @name = name
      @short_name = short_name
      @identifier = identifier
      @items = []
    end

    def add(identifier)
      @items << identifier
    end

    def to_h
      {name: @name, short_name: @short_name, identifier: @identifier, items: @items}
    end

  end

  def cl_target(filename)
    cls = []
    item = nil
    full_path = set_path(sub_dir, filename)
    results = CSV.read(full_path)
    code_list_name = ""
    results[1..results.count-1].each do |result|
      if result[0] != code_list_name
        item = CodeListInfo.new(remove_unicode_chars(result[0]), result[1], result[2]) 
        cls << item
      end
      item.add(result[3])
      code_list_name = result[0]
    end
    cls.map{|x| x.to_h}
  end

  def remove_unicode_chars(text)
    text = text.gsub(/[\u2013]/, "-")
    text = text.gsub(/[\u003E]/, ">")
    text = text.gsub(/[\u003C]/, "<")
    text = text.gsub(/[\u2018\u2019\u0092]/, "'")
    text.gsub(/[\u201C\u201D]/, '"')
  end

  it "prepare comparison files", :speed => 'slow' do
    #actual = cl_target("import_global_study_results_raw_2-6.csv")
    actual = cl_target("import_global_results_raw_2-6.csv")
    check_file_actual_expected(actual, sub_dir, "import_results_expected_2-6.yaml", equate_method: :hash_equal)
    actual = cl_target("import_global_results_raw_3-0.csv")
    check_file_actual_expected(actual, sub_dir, "import_results_expected_3-0.yaml", equate_method: :hash_equal)
  end

  it "import version 2.6", :speed => 'slow'  do
    thesauri_identifiers("3000", "10000")
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V43#TH"))
    full_path = db_load_file_path("sponsor_one/ct", "global_v2-6_CDISC_v43.xlsx")
    fixes = db_load_file_path("sponsor_one/ct", "fixes_v2-6.yaml")
    params = 
    {
      identifier: @release_details[0][:identifier], version: "1", 
      date: @release_details[0][:date], files: [full_path], fixes: fixes, 
      version_label: "1.0.0", label: @release_details[0][:label], 
      semantic_version: "1.0.0", job: @job, uri: ct.uri
    }
    result = @object.import(params)
    filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
    #expect(public_file_does_not_exist?("test", filename)).to eq(true)
    actual = read_public_yaml_file("test", filename)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_2-6.yaml")
    check_file_actual_expected(actual, sub_dir, "import_errors_expected_2-6.yaml", equate_method: :hash_equal)
    #copy_file_from_public_files("test", filename, sub_dir)
    filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
    #expect(public_file_exists?("test", filename)).to eq(true)
    copy_file_from_public_files("test", filename, sub_dir)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_2-6.ttl")
    check_ttl_fix_v2(filename, "import_expected_2-6.ttl", {last_change_date: true})
    expect(@job.status).to eq("Complete")
    delete_data_file(sub_dir, filename)
  end
 
  it "import 2.6 QC", :speed => 'slow' do
    load_local_file_into_triple_store(sub_dir, "import_expected_2-6.ttl")
    th = Thesaurus.find_minimum(@uri_2_6)
    results = read_yaml_file(sub_dir, "import_results_expected_2-6.yaml")
    expect(count_cl(th)).to eq(results.count)
    expect(count_cli(th)).to eq(22322)
    expect(count_distinct_cli(th)).to eq(20096)
    results.each do |x|
      check_cl(th, x[:name], x[:identifier], x[:short_name], x[:items].count, x[:items])
    end
  end

  it "import version 3.0", :speed => 'slow' do
    thesauri_identifiers("3500", "15000")
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V53#TH"))
    load_local_file_into_triple_store(sub_dir, "import_expected_2-6.ttl")
    full_path = db_load_file_path("sponsor_one/ct", "global_v3-0_CDISC_v53.xlsx")
    fixes = db_load_file_path("sponsor_one/ct", "fixes_v3-0.yaml")
    params = 
    {
      identifier: @release_details[1][:identifier], version: "1", 
      date: @release_details[1][:date], files: [full_path], fixes: fixes, 
      version_label: "1.0.0", label: @release_details[1][:label], 
      semantic_version: "1.0.0", job: @job, uri: ct.uri
    }
    result = @object.import(params)
    filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
    #expect(public_file_does_not_exist?("test", filename)).to eq(true)
    actual = read_public_yaml_file("test", filename)
  copy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_3-0.yaml")
    check_file_actual_expected(actual, sub_dir, "import_errors_expected_3-0.yaml", equate_method: :hash_equal)
    #copy_file_from_public_files("test", filename, sub_dir)
    filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
    #expect(public_file_exists?("test", filename)).to eq(true)
    copy_file_from_public_files("test", filename, sub_dir)
  copy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_3-0.ttl")
    check_ttl_fix_v2(filename, "import_expected_3-0.ttl", {last_change_date: true})
    expect(@job.status).to eq("Complete")
    delete_data_file(sub_dir, filename)
  end

  it "import 3.0 QC", :speed => 'slow' do
    load_local_file_into_triple_store(sub_dir, "import_expected_2-6.ttl")
    load_local_file_into_triple_store(sub_dir, "import_expected_3-0.ttl")
    th = Thesaurus.find_minimum(@uri_3_0)
    results = read_yaml_file(sub_dir, "import_results_expected_3-0.yaml")
byebug
    expect(cl_identifiers(th).map{|x| x[:identifier]}).to match_array(results.map{|x| x[:identifier]})
    #expect(count_cl(th)).to eq(results.count)
    expect(count_cli(th)).to eq(31929)
    expect(count_distinct_cli(th)).to eq(29513)
    results.each do |x|
      check_cl(th, x[:name], x[:identifier], x[:short_name], x[:items].count, x[:items])
    end
  end

  it "2-6 versus 3.0 QC I", :speed => 'slow' do
    new_items = 
    [
      :SN003500, :SN003501, :SN003502, :SN003503, :SN003504, :SN003505, :SN003506, 
      :SN003507, :SN003508, :SN003509, :SN003510, :SN003511, :SN003512, :SN003513, 
      :SN003514, :SN003515, :SN003516, :SN003517
    ]
    deleted_items =
    [
      :SN003003, :SN003041, :SN003042, :SN003043, :SN003045, :SN003054, :SN003055, 
      :SN003056, :SN003057, :SN003058, :SN003070, :SN003071, :SN003072, :SN003073, 
      :SN003074, :SN003075, :SN003087, :SN003094
    ]
    load_local_file_into_triple_store(sub_dir, "import_expected_2-6.ttl")
    load_local_file_into_triple_store(sub_dir, "import_expected_3-0.ttl")
    th_2_6 = Thesaurus.find_minimum(@uri_2_6)
    th_3_0 = Thesaurus.find_minimum(@uri_3_0)
    results = th_2_6.differences(th_3_0)
    check_file_actual_expected(results, sub_dir, "import_differences_expected_1.yaml", equate_method: :hash_equal)
    r_2_6 = read_yaml_file(sub_dir, "import_results_expected_2-6.yaml")
    r_3_0 = read_yaml_file(sub_dir, "import_results_expected_3-0.yaml")
    prev = r_2_6.map{|x| x[:identifier].to_sym}.uniq
    curr = r_3_0.map{|x| x[:identifier].to_sym}.uniq
    created = results[:created].map{|x| x[:identifier]}
    deleted = results[:deleted].map{|x| x[:identifier]}
    expect(created).to match_array(new_items + curr - prev)
    expect(deleted).to match_array(prev - curr + deleted_items)
  end

  it "2-6 versus 3.0 QC II", :speed => 'slow' do
    results = {}
    load_local_file_into_triple_store(sub_dir, "import_expected_2-6.ttl")
    load_local_file_into_triple_store(sub_dir, "import_expected_3-0.ttl")
    th_2_6 = Thesaurus.find_minimum(@uri_2_6)
    th_3_0 = Thesaurus.find_minimum(@uri_3_0)
    diffs = th_2_6.differences(th_3_0)
    diffs[:updated].each do |cl|
      item = Thesaurus::ManagedConcept.find_minimum(cl[:id])
      next if item.owner_short_name != "Sanofi"
      results[cl[:identifier]] = {changes: item.changes(2), differences: item.differences}
    end
    check_file_actual_expected(results, sub_dir, "import_code_list_changes_expected_1.yaml", equate_method: :hash_equal)
  end

end