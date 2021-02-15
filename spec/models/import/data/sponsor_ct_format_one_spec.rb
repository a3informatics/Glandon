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

  def release_uris
    @uri_2_6 = Uri.new(uri: "http://www.sanofi.com/2019_Release_1/V1#TH")
    @uri_3_0 = Uri.new(uri: "http://www.sanofi.com/2020_Release_1/V1#TH")
    @uri_3_1 = Uri.new(uri: "http://www.sanofi.com/2020_Release_2/V1#TH")
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
        {identifier: "2019 Release 1", label: "CT 2.6 2015-03-27", date: "2019-08-08", release: true},
        {identifier: "2020 Release 1", label: "CT 3.0 2017-09-27", date: "2020-03-26", release: true},
        {identifier: "2020 Release 2", label: "CT 3.1 2017-09-27", date: "2020-09-26", release: false}
      ]
      release_uris
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
      load_data_file_into_triple_store("sponsor_one/custom_property/custom_properties.ttl")
      load_data_file_into_triple_store("sponsor_one/custom_property/custom_properties_migration_one.ttl")
      load_data_file_into_triple_store("sponsor_one/custom_property/custom_properties_migration_two.ttl")
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
        SELECT DISTINCT ?identifier ?label ?notation WHERE 
        {
          #{th.uri.to_ref} th:isTopConceptReference/bo:reference ?s .
          ?s th:identifier ?identifier .
          ?s th:notation ?notation .
          ?s isoC:label ?label .
        }
      }
      query_results = Sparql::Query.new.query(query_string, "", [:isoC, :th, :bo]) 
      query_results.by_object_set([:notation, :identifier, :label])
    end

    def cl_items_unique(th)
      query_string = %Q{
        SELECT DISTINCT ?notation ?identifier WHERE 
        {
          #{th.uri.to_ref} th:isTopConceptReference/bo:reference ?s1 .
          ?s1 th:notation ?notation .
          ?s1 th:identifier ?identifier .
        } ORDER BY ?notation ?identifier
      }
      query_results = Sparql::Query.new.query(query_string, "", [:isoC, :th, :bo]) 
      query_results.by_object_set([:notation, :identifier])
    end

    def build_identifier_map(th, filename, write_file=false)
      final_results = {}
      results = cl_items_unique(th)
      results.each.each { |e| final_results[e[:notation]] = e[:identifier] }
      check_file_actual_expected(final_results, sub_dir, "#{filename}", equate_method: :hash_equal, write_file: write_file)
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
          version_label: @release_details[0][:label], label: @release_details[0][:label], 
          semantic_version: "1.0.0", job: @job, uri: ct.uri,
          release: @release_details[0][:release]
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
      copy_file_from_public_files_rename("test", filename, sub_dir, "CT_V2-6.ttl")
        check_ttl_fix_v2(filename, "CT_V2-6.ttl", {last_change_date: true})
        expect(@job.status).to eq("Complete")
        delete_data_file(sub_dir, filename)
        current_thesauri_identifiers
      end
     
      it "import 2.6 QC", :import_data => 'slow' do
        load_local_file_into_triple_store(sub_dir, "CT_V2-6.ttl")
        th = Thesaurus.find_minimum(@uri_2_6)
        build_identifier_map(th, "identifier_map_2-6.yaml", false)
        results = read_yaml_file(sub_dir, "import_results_expected_2-6.yaml")
        actual = cl_identifiers(th).map{|x| x[:notation]}
        expected = results.map{|x| x[:short_name]}
        missing = expected - actual
        extra = actual - expected
        expect(missing).to eq([])
        expect(extra).to eq([])
        expect(count_cl(th)).to eq(results.count)
        expect(count_cli(th)).to eq(22321) 
        expect(count_distinct_cli(th)).to eq(20096)
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
          version_label: @release_details[1][:label], label: @release_details[1][:label], 
          semantic_version: "1.0.0", job: @job, uri: ct.uri,
          release: @release_details[1][:release]
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
      copy_file_from_public_files_rename("test", filename, sub_dir, "CT_V3-0.ttl")
        check_ttl_fix_v2(filename, "CT_V3-0.ttl", {last_change_date: true})
        expect(@job.status).to eq("Complete")
        delete_data_file(sub_dir, filename)
        current_thesauri_identifiers
      end

      it "import 3.0 QC", :import_data => 'slow' do
        load_local_file_into_triple_store(sub_dir, "CT_V2-6.ttl")
        load_local_file_into_triple_store(sub_dir, "CT_V3-0.ttl")
        th = Thesaurus.find_minimum(@uri_3_0)
        build_identifier_map(th, "identifier_map_3-0.yaml", false)
        results = read_yaml_file(sub_dir, "import_results_expected_3-0.yaml")
        actual = cl_identifiers(th).map{|x| x[:notation]}
        expected = results.map{|x| x[:short_name]}
        missing = expected - actual
        extra = actual - expected
        expect(missing).to eq([])
        expect(extra).to eq([])
        expect(count_cl(th)).to eq(results.count)
        expect(count_cli(th)).to eq(31929)
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
          identifier: @release_details[2][:identifier], version: "1", 
          date: @release_details[2][:date], files: [full_path], fixes: fixes, 
          version_label: @release_details[2][:label], label: @release_details[2][:label], 
          semantic_version: "1.0.0", job: @job, uri: ct.uri,
          release: @release_details[2][:release]
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
      copy_file_from_public_files_rename("test", filename, sub_dir, "CT_V3-1.ttl")
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
        build_identifier_map(th, "identifier_map_3-1.yaml", false)
        results = read_yaml_file(sub_dir, "import_results_expected_3-1.yaml")
        actual = cl_identifiers(th).map{|x| x[:notation]}
        expected = results.map{|x| x[:short_name]}
        missing = expected - actual
        extra = actual - expected
        expect(missing).to eq([])
        expect(extra).to eq([])
        expect(count_cl(th)).to eq(results.count)
        expect(count_cli(th)).to eq(32779)
        expect(count_distinct_cli(th)).to eq(30210)
        results.each do |x|
          check_cl(th, x[:name], x[:identifier], x[:short_name], x[:items].count, x[:items])
        end    
      end

    end

  end

  describe "Differences, Statistics & Checks" do

    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_sponsor_one_identification.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_process.ttl")
      load_data_file_into_triple_store("sponsor_one/custom_property/custom_properties.ttl")
      load_data_file_into_triple_store("sponsor_one/custom_property/custom_properties_migration_one.ttl")
      load_data_file_into_triple_store("sponsor_one/custom_property/custom_properties_migration_two.ttl")
      load_cdisc_term_versions(1..66)
      load_local_file_into_triple_store(sub_dir, "CT_V2-6.ttl")
      load_local_file_into_triple_store(sub_dir, "CT_V3-0.ttl")
      load_local_file_into_triple_store(sub_dir, "CT_V3-1.ttl")
      delete_all_public_test_files
      release_uris
    end

    after :all do
      delete_all_public_test_files
    end

    it "2.6 versus 3.0 QC I", :import_data => 'slow' do
      th_2_6 = Thesaurus.find_minimum(@uri_2_6)
      th_3_0 = Thesaurus.find_minimum(@uri_3_0)
      results = th_2_6.differences(th_3_0)
      check_file_actual_expected(results, sub_dir, "import_differences_expected_1.yaml", equate_method: :hash_equal, write_file: false)
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
      th_3_0 = Thesaurus.find_minimum(@uri_3_0)
      th_3_1 = Thesaurus.find_minimum(@uri_3_1)
      results = th_3_0.differences(th_3_1)
      check_file_actual_expected(results, sub_dir, "import_differences_expected_2.yaml", equate_method: :hash_equal, write_file: false)
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
      # expected = read_yaml_file(sub_dir, "import_code_list_changes_expected_1.yaml")
      # expected.each do |k, v|
      #   actual = results[k]
      #   byebug if actual != v 
      # end
      check_file_actual_expected(results, sub_dir, "import_code_list_changes_expected_1.yaml", equate_method: :hash_equal, write_file: false)
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
      # expected = read_yaml_file(sub_dir, "import_code_list_changes_expected_1.yaml")
      # expected.each do |k, v|
      #   actual = results[k]
      #   byebug if actual != v 
      # end
      check_file_actual_expected(results, sub_dir, "import_code_list_changes_expected_2.yaml", equate_method: :hash_equal, write_file: false)
    end

    def check_cls(code_lists, uri)
      puts colourize("\n\nCT: #{uri}\n", "blue")
      results = []
      ct = Thesaurus.find_minimum(uri)
      code_lists.each do |identifier|
        begin
          cls = ct.find_by_identifiers([identifier])
          cl = Thesaurus::ManagedConcept.find_with_properties(cls[identifier])
          results << cl.uri if cl.owned? 
          puts colourize("CL: #{cl.notation} (#{cl.identifier})", cl.owned? ? "blue" : "red")
        rescue => e
          byebug
        end
      end
      results
    end

    def th_triples_tree(subject)
      query_string = %Q{
        SELECT DISTINCT?s ?p ?o WHERE
        {
          {
            #{subject.to_ref} th:isTopConceptReference*/bo:reference*/th:narrower* ?s .
            ?s ?p ?o 
          }
          UNION
          {
            #{subject.to_ref} ?p ?o
            BIND (#{subject.to_ref} as ?s)
          }
        }
      }
      query_results = Sparql::Query.new.query(query_string, subject.namespace, [:th, :bo]) 
      results = query_results.by_object_set([:s, :p, :o])
      puts colourize("Subject #{subject}, count=#{results.count}", "blue")
      results
    end

    it "counts and ranks" do
      {"2-6" => {uri: @uri_2_6, count: 215199}, "3-0" => {uri: @uri_3_0, count: 316635}, "3-1" => {uri: @uri_3_1, count: 325418}}.each do |version, data|
        triples = th_triples_tree(data[:uri]) # Reading all triples as a test.
        expect(triples.count).to eq(data[:count])
      end
      results = {}
      {"rank_V2-6.yaml" => @uri_2_6, "rank_V3-0.yaml" => @uri_3_0, "rank_V3-1.yaml" => @uri_3_1}.each do |file, uri|
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

    def ct_custom_properties(uri)
      %Q{
        SELECT ?cl ?clid ?cln ?cli ?cliid ?clin ?custname ?custvalue WHERE  
        {
          VALUES ?s {#{uri.to_ref}}
          ?s th:isTopConceptReference/bo:reference ?cl .
          ?cl th:identifier ?clid .  
          ?cl th:notation ?cln .
          ?cl th:narrower ?cli .
          ?cli th:identifier ?cliid .  
          ?cli th:notation ?clin .
          OPTIONAL 
          {
            ?cli ^isoC:appliesTo ?ext . 
            ?ext rdf:type isoC:CustomProperty .
            ?ext isoC:context ?cl . 
            ?ext isoC:value ?custvalue .
            ?ext isoC:customPropertyDefinedBy ?def .
            ?def isoC:label ?custname .
          }
        } ORDER BY ?cln ?clin ?custname
      }
    end

    def empty_code_lists(expected)
      results = []
      expected.each do |cl_id, cl|
        cl_result = true
        cl[:items].each do |cli_id, tags|
          cl_result = cl_result && tags.empty?
        end
        results << cl_id if cl_result
      end
      results
    end

    def subsets_and_refers_to
      # Could use this in the query below but used the more verbose filter to make it obvious and test
      # FILTER (EXISTS {?cl th:narrower ?x} && NOT EXISTS {?cl th:refersTo ?x})
      query = %Q{
        SELECT ?clid ?cln ?cliid ?clin WHERE  
        {
          ?s th:isTopConceptReference/bo:reference ?cl .
          ?cl th:identifier ?clid .  
          ?cl th:subsets ?y .
          BIND (EXISTS {?cl th:narrower ?x} as ?n)
          BIND (EXISTS {?cl th:refersTo ?x} as ?rt)
          FILTER (!?n || !?rt)           
          ?cl th:narrower ?cli .
          ?cl th:notation ?cln .
          ?cli th:identifier ?cliid .  
          ?cli th:notation ?clin .
        } ORDER BY ?cln ?clin ?custname
      }
      query_results = Sparql::Query.new.query(query, "", [:isoI, :isoT, :isoC, :th, :bo])
      query_results.by_object_set([:clid, :cln, :cliid, :clin])
    end

    def subsets_and_ordering(ct)
      results = []
      query_string = %Q{
        SELECT ?cl ?cln ?s ?i ?n ?ordinal
        {
          FILTER (?ordinal > 0)
          ?m th:item ?s
          {
            SELECT ?cl ?m (COUNT(?mid) as ?ordinal) WHERE {
              #{ct.to_ref} th:isTopConceptReference/bo:reference ?cl .
              ?cl th:subsets ?x .
              ?cl th:isOrdered/th:members/th:memberNext* ?mid . 
              ?mid th:memberNext* ?m .
              ?m th:item ?e
            } 
            GROUP BY ?cl ?m
          }
          ?s th:identifier ?i .
          ?s th:notation ?n .
          ?cl th:notation ?cln .
        } ORDER BY ?cl ?ordinal
      }
      query_results = Sparql::Query.new.query(query_string, "", [:th, :bo])
      query_results.by_object_set([:cl, :cln, :s, :i, :n, :ordinal])
    end

    def ranking_and_ordering(ct)
      results = []
      query_string = %Q{
        SELECT ?cl ?cln ?s ?r ?i ?n ?ordinal
        {
          FILTER (?ordinal > 0)
          ?m th:item ?s .
          ?m th:rank ?r .
          {
            SELECT ?cl ?m (COUNT(?mid) as ?ordinal) WHERE {
              #{ct.to_ref} th:isTopConceptReference/bo:reference ?cl .
              ?cl th:isRanked/th:members/th:memberNext* ?mid . 
              ?mid th:memberNext* ?m .
            } 
            GROUP BY ?cl ?m
          }
          ?s th:identifier ?i .
          ?s th:notation ?n .
          ?cl th:notation ?cln .
        } ORDER BY ?cl ?ordinal ?rank
      }
      query_results = Sparql::Query.new.query(query_string, "", [:th, :bo])
      query_results.by_object_set([:cl, :cln, :s, :r, :i, :n, :ordinal])
    end

    it "subset ordering analysis I" do
      ct_set.each_with_index do |v, index|
        results = subsets_and_ordering(v[:uri])
        check_file_actual_expected(results.map{|x| {code_list: x[:cl].to_s, cl_submission: x[:cln], item: x[:s].to_s, identifier: x[:i], cli_submission: x[:n], ordinal: x[:ordinal]}}, sub_dir, "subset_ordering_expected_#{index+1}.yaml", equate_method: :hash_equal, write_file: false)       
      end
    end

    it "rank ordering analysis I" do
      ct_set.each_with_index do |v, index|
        results = ranking_and_ordering(v[:uri])
        check_file_actual_expected(results.map{|x| {code_list: x[:cl].to_s, cl_submission: x[:cln], item: x[:s].to_s, identifier: x[:i], cli_submission: x[:n], ranks: x[:r], ordinal: x[:ordinal]}}, sub_dir, "rank_ordering_expected_#{index+1}.yaml", equate_method: :hash_equal, write_file: false)        
      end
    end

    it "custom property analysis I" do
      results = subsets_and_refers_to
      expect(results.empty?).to be(true)
    end

    it "custom property analysis II" do
      counts = [
        {cl: 803, cli: 22321},
        {cl: 1080, cli: 31929},
        {cl: 1171, cli: 32779},
      ]
      ct_set.each_with_index do |v, index|
        print "Processing: #{v[:uri]}, v#{v[:version]}  "
        query_results = Sparql::Query.new.query(ct_custom_properties(v[:uri]), "", [:isoI, :isoT, :isoC, :th, :bo])
        print ".."
        results = query_results.by_object_set([:cl, :clid, :cln, :cli, :cliid, :clin, :custname, :custvalue]).map{|x| {cl_uri: x[:cl], cl_identifier: x[:clid], 
          cl_notation: x[:cln], cli_uri: x[:cli], cli_identifier: x[:cliid], cli_notation: x[:clin], cust_def_name: x[:custname], cust_def_value: x[:custvalue]}}
        print ".."
        overall = {}
        cl_count = 0
        cli_count = 0
        results.each do |x|
          key = x[:cl_identifier].to_sym
          if !overall.key?(key) 
            overall[key] = {}
            overall[key][:notation] = x[:cl_notation]
            overall[key][:items] = {}
            cl_count += 1
          end
          second_key = x[:cli_identifier].to_sym
          if !overall[key][:items].key?(second_key) 
            overall[key][:items][second_key] = {} 
            overall[key][:items][second_key][:notation] = x[:cli_notation]
            cli_count += 1
          end
          third_key = x[:cust_def_name].to_variable_style.to_sym
          overall[key][:items][second_key][third_key] = x[:cust_def_value]
        end
        puts ".."
        check_file_actual_expected(overall, sub_dir, "custom_properties_expected_#{index+1}.yaml", equate_method: :hash_equal, write_file: false)        
        expect(cl_count).to eq(counts[index][:cl])
        expect(cli_count).to eq(counts[index][:cli])
      end
  
    end

  end

  describe "Custom Property Checks" do

    before :all do
    end

    after :all do
    end

    it "custom property comparison" do
      (1..3).each_with_index do |v, index|
        puts "-------"
        puts "Index #{index+1}"
        puts "-------"
        puts ""
        expected = read_yaml_file(sub_dir, "custom_actual_#{index+1}.yaml")             # Actual yaml file is export from Excel source file
        actual = read_yaml_file(sub_dir, "custom_properties_expected_#{index+1}.yaml")  # Expected is actual query on TTL load file created above
        expected.each do |key, expected_result|
          actual_result = actual.find{|k,v| v[:notation] == key}
          expected_items = expected_result[:items]
          expected_keys = expected_items.keys.map{|x| x.to_sym}
          expected_keys = expected_keys.map{|x| "#{x}".start_with?("SC") ? "#{x}"[1..-1].to_sym : x}
          actual_items = actual_result.last[:items]
          actual_keys = actual_items.keys.map{|x| x.to_sym}
          actual_keys = actual_keys.map{|x| "#{x}".start_with?("SC") ? "#{x}"[1..-1].to_sym : x}
          they_match = actual_keys - expected_keys == [] && expected_keys - actual_keys == []
          puts colourize("Mismatch on children: #{key} ... Extra: #{actual_keys - expected_keys}, Missing: #{expected_keys - actual_keys}", "red") unless they_match
          expected_items.each do |id, expected_item|
            ref = id.start_with?("SC") ? id[1..-1].to_sym : id
            actual_item = actual_items[ref.to_sym] if actual_items.key?(ref.to_sym)
            actual_item = actual_items[id.to_sym] if actual_items.key?(id.to_sym)
            actual_flags = []
            actual_item.each{|k,v| actual_flags << k if v == 'true'}
            expected_flags = expected_item.map{|x| x.to_variable_style.to_sym}
            expected_flags = expected.nil? ? [] : expected_flags
            they_match = actual_flags - expected_flags == [] && expected_flags - actual_flags == []
            puts colourize("Mismatch on flags: #{key}, #{id} ... Actual: #{actual_flags}, Expected: #{expected_flags}" , "red") unless they_match
          rescue => e
            puts colourize("Missing child: #{key}, #{id}", "red")
          end
        end
        puts ""
        puts ""
      end
  
    end

  end

end