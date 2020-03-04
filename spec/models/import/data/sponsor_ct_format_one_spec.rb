require 'rails_helper'
require 'csv'

describe "Import::SponsorTermFormatOne" do
	
	include DataHelpers
  include ImportHelpers
  include PublicFileHelpers
  include SparqlHelpers
  include ThesauriHelpers
  
	def sub_dir
    return "models/import/data/sponsor_one/ct"
  end

  def setup
    @object = Import.new(:type => "Import::SponsorTermFormatOne") # Use this rather than above.
    @job = Background.new
    @job.save
    @object.background_id = @job.id
    @object.save
  end

	before :each do
    load_files(schema_files, [])
    load_data_file_into_triple_store("mdr_identification.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems_process.ttl")
    load_cdisc_term_versions(1..62)
    NameValue.destroy_all
    NameValue.create(name: "thesaurus_parent_identifier", value: "1000")
    NameValue.create(name: "thesaurus_child_identifier", value: "10000")
    Import.destroy_all
    delete_all_public_test_files
    setup
  end

  after :each do
    Import.destroy_all
    delete_all_public_test_files
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
      SELECT ?n (COUNT(?cli) as ?count) WHERE 
      {
        #{th.uri.to_ref} th:isTopConceptReference/bo:reference ?s .
        ?s isoC:label "#{key}" .
        ?s th:notation ?n .
        ?s th:narrower ?cli .
      } GROUP BY ?n
    }
    query_results = Sparql::Query.new.query(query_string, "", [:th, :bo, :isoC]) 
    result = query_results.by_object_set([:n, :count]).map{|x| {notation: x[:n], count: x[:count]}}
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
    elsif result[:notation] == notation && "#{result[:count]}".to_i == "#{count}".to_i
      #puts colourize("#{long_name} : #{identifier}", "green")
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
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V43#TH"))
    full_path = db_load_file_path("sponsor_one/ct", "global_v2-6_CDISC_v43.xlsx")
    fixes = db_load_file_path("sponsor_one/ct", "fixes_v2-6.yaml")
    params = {identifier: "Q3 2019", version: "1", date: "2019-08-08", files: [full_path], fixes: fixes, version_label: "1.0.0", label: "Version 2-6, Q3 2019", semantic_version: "1.0.0", job: @job, uri: ct.uri}
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
    uri = Uri.new(uri: "http://www.s-cubed.dk/Q3_2019/V1#TH")
    th = Thesaurus.find_minimum(uri)
    results = read_yaml_file(sub_dir, "import_results_expected_2-6.yaml")
    expect(count_cl(th)).to eq(results.count)
    expect(count_cli(th)).to eq(22322)
    expect(count_distinct_cli(th)).to eq(20096)
    results.each do |x|
      check_cl(th, x[:name], x[:identifier], x[:short_name], x[:items].count, x[:items])
    end
  end

  it "import version 3.0", :speed => 'slow' do
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V53#TH"))
    load_local_file_into_triple_store(sub_dir, "import_expected_2-6.ttl")
    full_path = db_load_file_path("sponsor_one/ct", "global_v3-0_CDISC_v53.xlsx")
    fixes = db_load_file_path("sponsor_one/ct", "fixes_v3-0.yaml")
    params = {identifier: "Q1 2020", version: "1", date: "2020-01-01", files: [full_path], fixes: fixes, version_label: "1.0.0", label: "Version 3-0, Q1 2020", semantic_version: "1.0.0", job: @job, uri: ct.uri}
    result = @object.import(params)
    filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
    #expect(public_file_does_not_exist?("test", filename)).to eq(true)
    actual = read_public_yaml_file("test", filename)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_3-0.yaml")
    check_file_actual_expected(actual, sub_dir, "import_errors_expected_3-0.yaml", equate_method: :hash_equal)
    #copy_file_from_public_files("test", filename, sub_dir)
    filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
    #expect(public_file_exists?("test", filename)).to eq(true)
    copy_file_from_public_files("test", filename, sub_dir)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_3-0.ttl")
    check_ttl_fix_v2(filename, "import_expected_3-0.ttl", {last_change_date: true})
    expect(@job.status).to eq("Complete")
    delete_data_file(sub_dir, filename)
  end

  it "import 3.0 QC", :speed => 'slow' do
    load_local_file_into_triple_store(sub_dir, "import_expected_2-6.ttl")
    load_local_file_into_triple_store(sub_dir, "import_expected_3-0.ttl")
    uri = Uri.new(uri: "http://www.s-cubed.dk/Q1_2020/V1#TH")
    th = Thesaurus.find_minimum(uri)
    results = read_yaml_file(sub_dir, "import_results_expected_3-0.yaml")
    #expect(count_cl(th)).to eq(results.count)
    #expect(count_cli(th)).to eq(22322)
    #expect(count_distinct_cli(th)).to eq(20096)
    results.each do |x|
      check_cl(th, x[:name], x[:identifier], x[:short_name], x[:items].count, x[:items])
    end
  end

end