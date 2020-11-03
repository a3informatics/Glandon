 require 'rails_helper'
require 'csv'

describe "Import::SponsorTermFormatOne" do
  
  include DataHelpers
  include ImportHelpers
  include PublicFileHelpers
  include SparqlHelpers
  include ThesauriHelpers
  include InstallationHelpers
  include NameValueHelpers
  
  def sub_dir
    return "models/import/data/sponsor_one/ct"
  end

  describe "Main Tests" do

    def setup
      @object = Import.new(:type => "Import::SponsorTermFormatOne") # Use this rather than above.
      @job = Background.new
      @job.save
      @object.background_id = @job.id
      @object.save
      @release_details =
      [
        {identifier: "2019 R1", label: "2019 Release 1", date: "2019-08-08", uri: "http://www.sanofi.com/2019_R1/V1#TH"},
        {identifier: "2020 R1", label: "2020 Release 1", date: "2020-03-26", uri: "http://www.sanofi.com/2020_R1/V1#TH"},
        {identifier: "2020 R1", label: "2020 Release 1", date: "2020-09-26", uri: "http://www.sanofi.com/2020_R1/V2#TH"}
      ]
      @uri_2_6 = Uri.new(uri: "#{@release_details[0][:uri]}")
      @uri_3_0 = Uri.new(uri: "#{@release_details[1][:uri]}")
      @uri_3_1 = Uri.new(uri: "#{@release_details[2][:uri]}")
    end

    def read_installation(installation)
       content = YAML.load_file(Rails.root.join "config/installations/#{installation}/#{:thesauri}.yml").deep_symbolize_keys
       Rails.configuration.thesauri = content[Rails.env.to_sym]
    end

    def thesauri_identifiers(parent, child)
      nv_destroy
      nv_create(parent: "#{parent}", child: "#{child}")    
    end
      
    def current_thesauri_identifiers
      puts "Parent next value #{nv_predict_parent}"
      puts "Child next value #{nv_predict_child}"
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
      load_cdisc_term_versions(1..66)
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

    def cl_identifiers(th)
      query_string = %Q{
        SELECT DISTINCT ?identifier ?label WHERE 
        {
          #{th.uri.to_ref} th:isTopConceptReference/bo:reference ?s .
          ?s th:identifier ?identifier .
          ?s isoC:label ?label .
        }
      }
      query_results = Sparql::Query.new.query(query_string, "", [:isoC, :th, :bo]) 
      query_results.by_object_set([:identifier, :label])
    end

    def cl_items_unique(th)
      query_string = %Q{
        SELECT DISTINCT ?notation ?identifier WHERE 
        {
          #{th.uri.to_ref} th:isTopConceptReference/bo:reference ?s1 .
          ?s1 th:notation ?notation .
          ?s1 th:narrower ?s2 .
          ?s2 th:identifier ?identifier .
        } ORDER BY ?notation ?identifier
      }
      query_results = Sparql::Query.new.query(query_string, "", [:isoC, :th, :bo]) 
      query_results.by_object_set([:notation, :identifier])
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
        puts colourize("Notation: [A: <not found>, E: #{notation}] Count: [A: <not found>, E: #{count}]\n", "red")
      elsif result[:notation] == notation && result[:identifier] == identifier && "#{result[:count]}".to_i == "#{count}".to_i
        #puts colourize("#{long_name} : #{identifier}", "green")
      elsif result[:notation] == notation && result[:identifier] != identifier && "#{result[:count]}".to_i == "#{count}".to_i
        puts colourize("E: #{notation}, #{long_name}, #{identifier} != A: #{result[:identifier]}", "brown")
      else
        db_items = cl_items(th, long_name)
        puts colourize("#{long_name} : #{identifier}", "red")
        puts colourize("Notation: [A: #{result[:notation]}, E: #{notation}] Count: [A: #{result[:count]}, E: #{count}]", "red")
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

    describe "Import 2.6" do

      it "import version 2.6", :import_data => 'slow'  do
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
      #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "CT_V2-6.ttl")
        check_ttl_fix_v2(filename, "CT_V2-6.ttl", {last_change_date: true})
        expect(@job.status).to eq("Complete")
        delete_data_file(sub_dir, filename)
        current_thesauri_identifiers
      end
     
      it "import 2.6 QC", :import_data => 'slow' do
        load_local_file_into_triple_store(sub_dir, "CT_V2-6.ttl")
        th = Thesaurus.find_minimum(@uri_2_6)
        results = read_yaml_file(sub_dir, "import_results_expected_2-6.yaml")
        expect(cl_identifiers(th).map{|x| x[:identifier]}).to match_array(results.map{|x| x[:identifier]})
        expect(count_cl(th)).to eq(results.count)
        expect(count_cli(th)).to eq(22322)
        expect(count_distinct_cli(th)).to eq(20097)
        results.each do |x|
          check_cl(th, x[:name], x[:identifier], x[:short_name], x[:items].count, x[:items])
        end
      end

    end

    describe "Import 3.0" do

      it "import version 3.0", :import_data => 'slow' do
        thesauri_identifiers("3500", "15000")
        ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V53#TH"))
        load_local_file_into_triple_store(sub_dir, "CT_V2-6.ttl")
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
      #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_3-0.yaml")
        check_file_actual_expected(actual, sub_dir, "import_errors_expected_3-0.yaml", equate_method: :hash_equal)
        #copy_file_from_public_files("test", filename, sub_dir)
        filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
        #expect(public_file_exists?("test", filename)).to eq(true)
        copy_file_from_public_files("test", filename, sub_dir)
      #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "CT_V3-0.ttl")
        check_ttl_fix_v2(filename, "CT_V3-0.ttl", {last_change_date: true})
        expect(@job.status).to eq("Complete")
        delete_data_file(sub_dir, filename)
        current_thesauri_identifiers
      end

      it "import 3.0 QC", :import_data => 'slow' do
        load_local_file_into_triple_store(sub_dir, "CT_V2-6.ttl")
        load_local_file_into_triple_store(sub_dir, "CT_V3-0.ttl")
        th = Thesaurus.find_minimum(@uri_3_0)
        results = read_yaml_file(sub_dir, "import_results_expected_3-0.yaml")
        expect(cl_identifiers(th).map{|x| x[:identifier]}).to match_array(results.map{|x| x[:identifier]})
        expect(count_cl(th)).to eq(results.count)
        expect(count_cli(th)).to eq(31930)
        expect(count_distinct_cli(th)).to eq(29514)
        results.each do |x|
          check_cl(th, x[:name], x[:identifier], x[:short_name], x[:items].count, x[:items])
        end    
      end

    end

    describe "Import 3.1" do

      it "import version 3.1", :import_data => 'slow' do
        thesauri_identifiers("3600","16000")
        ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V53#TH"))
        load_local_file_into_triple_store(sub_dir, "CT_V2-6.ttl")
        load_local_file_into_triple_store(sub_dir, "CT_V3-0.ttl")
        full_path = db_load_file_path("sponsor_one/ct", "global_v3-1_CDISC_v53.xlsx")
        fixes = db_load_file_path("sponsor_one/ct", "fixes_v3-1.yaml")
        params = 
        {
          identifier: @release_details[2][:identifier], version: "2", 
          date: @release_details[2][:date], files: [full_path], fixes: fixes, 
          version_label: "2.0.0", label: @release_details[2][:label], 
          semantic_version: "2.0.0", job: @job, uri: ct.uri
        }
        result = @object.import(params)
        filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
        #expect(public_file_does_not_exist?("test", filename)).to eq(true)
        actual = read_public_yaml_file("test", filename)
      #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_3-1.yaml")
        check_file_actual_expected(actual, sub_dir, "import_errors_expected_3-1.yaml", equate_method: :hash_equal)
        #copy_file_from_public_files("test", filename, sub_dir)
        filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
        #expect(public_file_exists?("test", filename)).to eq(true)
        copy_file_from_public_files("test", filename, sub_dir)
      #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "CT_V3-1.ttl")
        check_ttl_fix_v2(filename, "CT_V3-1.ttl", {last_change_date: true})
        expect(@job.status).to eq("Complete")
        delete_data_file(sub_dir, filename)
        current_thesauri_identifiers
      end

      it "import 3.1 QC", :import_data => 'slow' do
        load_local_file_into_triple_store(sub_dir, "CT_V2-6.ttl")
        load_local_file_into_triple_store(sub_dir, "CT_V3-0.ttl")
        load_local_file_into_triple_store(sub_dir, "CT_V3-1.ttl")
        th = Thesaurus.find_minimum(@uri_3_1)
        results = read_yaml_file(sub_dir, "import_results_expected_3-1.yaml")
        expect(cl_identifiers(th).map{|x| x[:identifier]}).to match_array(results.map{|x| x[:identifier]})
        expect(count_cl(th)).to eq(results.count)
        expect(count_cli(th)).to eq(32800)
        expect(count_distinct_cli(th)).to eq(30224)
        results.each do |x|
          check_cl(th, x[:name], x[:identifier], x[:short_name], x[:items].count, x[:items])
        end    
      end

    end

  end

  describe "Differences" do

    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_sponsor_one_identification.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_process.ttl")
      load_cdisc_term_versions(1..62)
      load_local_file_into_triple_store(sub_dir, "CT_V2-6.ttl")
      load_local_file_into_triple_store(sub_dir, "CT_V3-0.ttl")
      load_local_file_into_triple_store(sub_dir, "CT_V3-1.ttl")
      delete_all_public_test_files
      @uri_2_6 = Uri.new(uri: "http://www.sanofi.com/2019_R1/V1#TH")
      @uri_3_0 = Uri.new(uri: "http://www.sanofi.com/2020_R1/V1#TH")
      @uri_3_1 = Uri.new(uri: "http://www.sanofi.com/2020_R1/V2#TH")
    end

    after :all do
      delete_all_public_test_files
    end

    it "2.6 versus 3.0 QC I", :import_data => 'slow' do
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
      expect(created).to match_array(curr - prev) # New now accounted for
      expect(deleted).to match_array(prev - curr)
    end

    it "3.0 versus 3.1 QC I", :import_data => 'slow' do
      th_2_6 = Thesaurus.find_minimum(@uri_3_0)
      th_3_0 = Thesaurus.find_minimum(@uri_3_1)
      results = th_3_0.differences(th_3_1)
      check_file_actual_expected(results, sub_dir, "import_differences_expected_2.yaml", equate_method: :hash_equal)
      r_3_0 = read_yaml_file(sub_dir, "import_results_expected_3-0.yaml")
      r_3_1 = read_yaml_file(sub_dir, "import_results_expected_3-1.yaml")
      prev = r_3_0.map{|x| x[:identifier].to_sym}.uniq
      curr = r_3_1.map{|x| x[:identifier].to_sym}.uniq
      created = results[:created].map{|x| x[:identifier]}
      deleted = results[:deleted].map{|x| x[:identifier]}
      expect(created).to match_array(curr - prev) # New now accounted for
      expect(deleted).to match_array(prev - curr)
    end

    it "2.6 versus 3.0 QC II", :import_data => 'slow' do
      results = {}
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

    it "3.0 versus 3.1 QC II", :import_data => 'slow' do
      results = {}
      th_3_0 = Thesaurus.find_minimum(@uri_3_0)
      th_3_1 = Thesaurus.find_minimum(@uri_3_1)
      diffs = th_3_0.differences(th_3_1)
      diffs[:updated].each do |cl|
        item = Thesaurus::ManagedConcept.find_minimum(cl[:id])
        next if item.owner_short_name != "Sanofi"
        results[cl[:identifier]] = {changes: item.changes(2), differences: item.differences}
      end
      check_file_actual_expected(results, sub_dir, "import_code_list_changes_expected_2.yaml", equate_method: :hash_equal, write_file: true)
    end

  end

  describe "Final Statistics & Checks" do

    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_sponsor_one_identification.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_process.ttl")
      load_cdisc_term_versions(1..62)
      load_local_file_into_triple_store(sub_dir, "CT_V2-6.ttl")
      load_local_file_into_triple_store(sub_dir, "CT_V3-0.ttl")
      load_local_file_into_triple_store(sub_dir, "CT_V3-1.ttl")
      delete_all_public_test_files
    end

    after :all do
      delete_all_public_test_files
    end

    def check_cls(code_lists, uri)
      puts colourize("\n\nCT: #{uri}\n", "blue")
      results = []
      ct = Thesaurus.find_minimum(uri)
      code_lists.each do |identifier|
        cls = ct.find_by_identifiers([identifier])
        cl = Thesaurus::ManagedConcept.find_minimum(cls[identifier])
        results << cl.uri if cl.owned? 
        puts colourize("CL: #{cl.uri}", cl.owned? ? "blue" : "red")
      end
      results
    end

    it "counts and ranks" do
      uri_26 = Uri.new(uri: "http://www.sanofi.com/2019_R1/V1#TH")
      uri_30 = Uri.new(uri: "http://www.sanofi.com/2020_R1/V1#TH")
      uri_31 = Uri.new(uri: "http://www.sanofi.com/2020_R1/V2#TH")
      {"2-6" => {uri: uri_26, count: 334824}, "3-0" => {uri: uri_30, count: 479363}, "3-1" => {uri: uri_31, count: 479363}}.each do |version, data|
        triples = triple_store.subject_triples_tree(data[:uri]) # Reading all triples as a test.
        expect(triples.count).to eq(data[:count])
      end
      {"rank_V2-6.yaml" => uri_26, "rank_V3-0.yaml" => uri_30, "rank_V3-1.yaml" => uri_31}.each do |file, uri|
        config = read_yaml_file(sub_dir, file)
        code_lists = config[:codelists].map{|x| x[:codelist_code]}
        results[uri.to_s] = check_cls(code_lists, uri).map{|x| x.to_s}
        expect(code_lists.count).to eq(results[uri.to_s].count)
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
      check_file_actual_expected(result, sub_dir, "ct_query_cli_count_1.yaml", equate_method: :hash_equal, write_file: false)
    end

    def ct_set
      query_string = %Q{
        SELECT DISTINCT ?s ?v WHERE
        {
          ?s rdf:type #{Thesaurus.rdf_type.to_ref} .
          ?s isoT:hasIdentifier/isoI:version ?v .
          ?s isoT:hasIdentifier/isoI:hasScope <http://www.assero.co.uk/NS#SANOFI>.
        } ORDER BY ?v
      }
      query_results = Sparql::Query.new.query(query_string, "", [:isoI, :isoT, :isoC, :th, :bo])
      query_results.by_object_set([:s, :v]).map{|x| {uri: x[:s], version: x[:v]}}
    end

    def ct_tags(uri)
      %Q{
        SELECT DISTINCT ?l ?v ?d ?clid ?cliid ?tag WHERE
        {
          #{uri.to_ref} isoC:label ?l .
          #{uri.to_ref} isoT:creationDate ?d .
          #{uri.to_ref} isoT:hasIdentifier/isoI:version ?v .
          #{uri.to_ref} th:isTopConceptReference/bo:reference ?cl .
          ?cl th:identifier ?clid . 
          ?cl th:narrower ?cli .
          ?cli th:identifier ?cliid .             
          ?cli ^isoC:appliesTo ?y .
          ?y isoC:context ?cl .
          ?y isoC:classifiedAs/isoC:prefLabel ?tag .
        } ORDER BY ?v ?clid ?cliid ?tag
      }
    end

    it "tag analysis" do
      ct_set.each_with_index do |v, index|
        print "Processing: #{v[:uri]}, v#{v[:version]}  "
        query_results = Sparql::Query.new.query(ct_tags(v[:uri]), "", [:isoI, :isoT, :isoC, :th, :bo])
        print ".."
        results = query_results.by_object_set([:l, :v, :d, :clid, :cliid, :tag]).map{|x| {label: x[:l], version: x[:v], date: x[:d], code_list: x[:clid], code_list_item: x[:cliid], tag: x[:tag]}}
        print ".."
        overall = {}
        overall[:label] = results[0][:label]
        overall[:version] = results[0][:version]
        overall[:date] = results[0][:date]
        overall[:results] = {}
        results.each do |x|
          key = "#{x[:code_list]}.#{x[:code_list_item]}"
          overall[:results][key] = [] unless overall[:results].key?(key) 
          overall[:results][key] << x[:tag]
        end
        puts ".."
        check_file_actual_expected(overall, sub_dir, "ct_query_tag_#{index+1}.yaml", equate_method: :hash_equal, write_file: true)
      end
  
    end

  end

end