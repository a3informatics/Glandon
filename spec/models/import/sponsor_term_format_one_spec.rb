require 'rails_helper'

describe "Import::SponsorTermFormatOne" do
	
	include DataHelpers
  include ImportHelpers
  include PublicFileHelpers
  include SparqlHelpers
  include ThesauriHelpers
  include NameValueHelpers
  
	def sub_dir
    return "models/import/sponsor_term_format_one"
  end

  def setup
    @object = Import.new(:type => "Import::SponsorTermFormatOne") # Use this rather than above.
    @job = Background.new
    @job.save
    @object.background_id = @job.id
    @object.save
  end


  def ct_custom_properties(uri)
    query_string = %Q{
      SELECT ?cl ?clid ?cln ?cli ?cliid ?clin ?custname ?custvalue WHERE  
      {
          VALUES ?s {#{uri.to_ref}}
          ?s th:isTopConceptReference/bo:reference ?cl .
          ?cl th:identifier ?clid .  
          ?cl th:notation ?cln .
          ?cl th:narrower ?cli .
          ?cli th:identifier ?cliid .  
          ?cli th:notation ?clin .
          OPTIONAL {
            ?cli ^isoC:appliesTo ?ext . 
            ?ext rdf:type isoC:CustomProperty .
            ?ext isoC:context ?cl . 
            ?ext isoC:value ?custvalue .
            ?ext isoC:customPropertyDefinedBy ?def .
            ?def isoC:label ?custname .
        }
      } ORDER BY ?cln ?clin ?custname
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoI, :isoT, :isoC, :th, :bo])
    query_results.by_object_set([:cl, :clid, :cln, :cli, :cliid, :clin, :custname, :custvalue]).map{|x| {cl_uri: x[:cl].to_s, cl_identifier: x[:clid], 
      cl_notation: x[:cln], cli_uri: x[:cli].to_s, cli_identifier: x[:cliid], cli_notation: x[:clin], cust_def_name: x[:custname], cust_def_value: x[:custvalue]}}
  end

  describe "Main Tests" do

  	before :each do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_process.ttl")
      load_data_file_into_triple_store("sponsor_one/custom_property/custom_properties.ttl")
      load_data_file_into_triple_store("sponsor_one/custom_property/custom_properties_migration_one.ttl")
      load_cdisc_term_versions(1..62)
      nv_destroy
      nv_create(parent: "1000", child: "10000")
      Import.destroy_all
      delete_all_public_test_files
      clear_stfo_objects
      setup
    end

    after :each do
      Import.destroy_all
      delete_all_public_test_files
    end

    it "returns the configuation" do
      expected =
      {
        description: "Import of Sponsor Terminology",
        parent_klass: Import::STFOClasses::STFOThesaurus,
        reader_klass: Excel,
        import_type: :sponsor_term_format_one,
        version_label: :date,
        format: :format,
        label: "Controlled Terminology"
      }
      expect(Import::SponsorTermFormatOne.new.configuration).to eq(expected)
    end

    it "sets the correct format" do
      object = Import::SponsorTermFormatOne.new
      expect(object.format({date: "01/01/2000"})).to eq(:version_2)
      expect(object.format({date: "30/05/2019"})).to eq(:version_2)
      expect(object.format({date: "01/09/2019"})).to eq(:version_2)
      expect(object.format({date: "31/08/2020"})).to eq(:version_2)
      expect(object.format({date: "01/09/2020"})).to eq(:version_3)
      expect(object.format({date: DateTime.now.to_date})).to eq(:version_3)
      expect(object.format({date: DateTime.now.to_date+100})).to eq(:version_3) # Future date
      expect(object.format({date: "01/01/2100"})).to eq(:version_3)
    end

    it "import, no errors, version 2, short I" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V62#TH"))
      full_path = test_file_path(sub_dir, "import_input_3.xlsx")
      fixes = test_file_path(sub_dir, "import_fixes_3.yaml")
      params = {identifier: "V2 I", version: "1", date: "2018-11-22", files: [full_path], fixes: fixes, version_label: "1.1.1", label: "Version 2 Test", semantic_version: "1.1.1", job: @job, uri: ct.uri}
      result = @object.import(params)
      filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
      #public_file_does_not_exist?("test", filename)
      public_file_exists?("test", filename)
      actual = read_public_yaml_file("test", filename)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_3.yaml")
      check_file_actual_expected(actual, sub_dir, "import_errors_expected_3.yaml")
      filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
      expect(public_file_exists?("test", filename)).to eq(true)
      copy_file_from_public_files("test", filename, sub_dir)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_3.ttl")
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_load_3.ttl")
      check_ttl_fix_v2(filename, "import_expected_3.ttl", {last_change_date: true})
      expect(@job.status).to eq("Complete")
      delete_data_file(sub_dir, filename)
  	end

    it "import, no errors, version 2, short I, load check" do
      results = Hash.new{|hash, key| hash[key]={}}
      load_local_file_into_triple_store(sub_dir, "import_load_3.ttl")
      ["http://www.s-cubed.dk/C66767/V1#C66767", "http://www.s-cubed.dk/SN000001/V1#SN000001", 
        "http://www.s-cubed.dk/NP001002P/V1#NP001002P"].each do |uri|
        parent = Thesaurus::ManagedConcept.find_full(Uri.new(uri: uri))
        results[parent.uri.to_s][""] = parent.load_custom_properties.name_value_pairs
        parent.narrower.each do |child|
          results[parent.uri.to_s][child.uri.to_s] = child.load_custom_properties(parent).name_value_pairs
        end
      end
      check_file_actual_expected(results, sub_dir, "custom_properties_expected_3.yaml", equate_method: :hash_equal)
    end

    it "import, no errors, version 2, short II" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V62#TH"))
      full_path = test_file_path(sub_dir, "import_input_4.xlsx")
      params = {identifier: "V2 II", version: "1", date: "2018-11-22", files: [full_path], version_label: "1.1.1", label: "Version 2 Test", semantic_version: "1.1.1", job: @job, uri: ct.uri}
      result = @object.import(params)
      filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
      #public_file_does_not_exist?("test", filename)
      actual = read_public_yaml_file("test", filename)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_4.yaml")
      check_file_actual_expected(actual, sub_dir, "import_errors_expected_4.yaml")
      filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
      #expect(public_file_exists?("test", filename)).to eq(true)
      copy_file_from_public_files("test", filename, sub_dir)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_4.ttl")
      check_ttl_fix_v2(filename, "import_expected_4.ttl", {last_change_date: true})
      expect(@job.status).to eq("Complete")
      delete_data_file(sub_dir, filename)
    end

    it "import, no errors, version 2, short III" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V62#TH"))
      full_path = test_file_path(sub_dir, "import_input_6.xlsx")
      params = {identifier: "V2 III", version: "1", date: "2018-11-22", files: [full_path], version_label: "1.1.1", label: "Version 2 Test", semantic_version: "1.1.1", job: @job, uri: ct.uri}
      result = @object.import(params)
      filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
      #public_file_does_not_exist?("test", filename)
      actual = read_public_yaml_file("test", filename)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_6.yaml")
      check_file_actual_expected(actual, sub_dir, "import_errors_expected_6.yaml")
      filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
      #expect(public_file_exists?("test", filename)).to eq(true)
      copy_file_from_public_files("test", filename, sub_dir)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_6.ttl")
      check_ttl_fix_v2(filename, "import_expected_6.ttl", {last_change_date: true})
      expect(@job.status).to eq("Complete")
      delete_data_file(sub_dir, filename)
      load_local_file_into_triple_store(sub_dir, "import_expected_6.ttl")
      actual = ct_custom_properties(Uri.new(uri: "http://www.s-cubed.dk/V2_III/V1#TH"))
      check_file_actual_expected(actual, sub_dir, "custom_properties_expected_6.yaml")
    end

    it "import, no errors, version 2, short IV" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V62#TH"))
      full_path = test_file_path(sub_dir, "import_input_8.xlsx")
      fixes = test_file_path(sub_dir, "import_fixes_8.yaml")
      params = {identifier: "V2 I", version: "1", date: "2018-11-22", files: [full_path], fixes: fixes, version_label: "1.1.1", label: "Version 2 Test", semantic_version: "1.1.1", job: @job, uri: ct.uri}
      result = @object.import(params)
      filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
      public_file_exists?("test", filename)
      #public_file_does_not_exist?("test", filename)
      actual = read_public_yaml_file("test", filename)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_8.yaml")
      check_file_actual_expected(actual, sub_dir, "import_errors_expected_8.yaml")
      filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
      public_file_exists?("test", filename)
      copy_file_from_public_files("test", filename, sub_dir)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_8.ttl")
      check_ttl_fix_v2(filename, "import_expected_8.ttl", {last_change_date: true})
      expect(@job.status).to eq("Complete")
      delete_data_file(sub_dir, filename)
    end

    it "import, no errors, multiple files, version 3, short V" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V62#TH"))
      full_path_a = test_file_path(sub_dir, "import_input_9a.xlsx")
      full_path_b = test_file_path(sub_dir, "import_input_9b.xlsx")
      params = {identifier: "V2 I", version: "1", date: "2020-09-10", files: [full_path_a, full_path_b], version_label: "1.1.1", label: "Version 3 Test", semantic_version: "1.1.1", job: @job, uri: ct.uri}
      result = @object.import(params)
      filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
      public_file_exists?("test", filename)
      #public_file_does_not_exist?("test", filename)
      actual = read_public_yaml_file("test", filename)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_9.yaml")
      check_file_actual_expected(actual, sub_dir, "import_errors_expected_9.yaml")
      filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
      public_file_exists?("test", filename)
      copy_file_from_public_files("test", filename, sub_dir)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_9.ttl")
      check_ttl_fix_v2(filename, "import_expected_9.ttl", {last_change_date: true})
      expect(@job.status).to eq("Complete")
      delete_data_file(sub_dir, filename)
    end

    it "import, no errors, rank, short VI" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V43#TH"))
      full_path = test_file_path(sub_dir, "import_input_22.xlsx")
      params = {identifier: "RANK", version: "1", date: "2018-11-22", files: [full_path], version_label: "1.1.1", label: "Version 2 Test", semantic_version: "1.1.1", job: @job, uri: ct.uri}
      result = @object.import(params)
      filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
      public_file_exists?("test", filename)
      #public_file_does_not_exist?("test", filename)
      actual = read_public_yaml_file("test", filename)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_22.yaml")
      check_file_actual_expected(actual, sub_dir, "import_errors_expected_22.yaml")
      filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
      public_file_exists?("test", filename)
      copy_file_from_public_files("test", filename, sub_dir)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_22.ttl")
      check_ttl_fix_v2(filename, "import_expected_22.ttl", {last_change_date: true})
      expect(@job.status).to eq("Complete")
      delete_data_file(sub_dir, filename)
    end

    it "import, no errors, 1st AGEU version" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V43#TH"))
      full_path = test_file_path(sub_dir, "import_input_24a.xlsx")
      params = {identifier: "AGEUTEST", version: "1", date: "2018-11-01", files: [full_path], version_label: "1", label: "AGEU TEST", semantic_version: "0.0.1", job: @job, uri: ct.uri}
      result = @object.import(params)
      filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
      public_file_exists?("test", filename)
      #public_file_does_not_exist?("test", filename)
      actual = read_public_yaml_file("test", filename)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_24a.yaml")
      check_file_actual_expected(actual, sub_dir, "import_errors_expected_24a.yaml")
      filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
      public_file_exists?("test", filename)
      copy_file_from_public_files("test", filename, sub_dir)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_24a.ttl")
      check_ttl_fix_v2(filename, "import_expected_24a.ttl", {last_change_date: true})
      expect(@job.status).to eq("Complete")
      delete_data_file(sub_dir, filename)
    end

    it "import, no errors, 2nd AGEU version" do
      load_local_file_into_triple_store(sub_dir, "import_load_24a.ttl")
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V53#TH"))
      full_path = test_file_path(sub_dir, "import_input_24b.xlsx")
      params = {identifier: "AGEUTEST", version: "2", date: "2018-12-01", files: [full_path], version_label: "2", label: "AGEU TEST", semantic_version: "0.0.2", job: @job, uri: ct.uri}
      result = @object.import(params)
      filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
      public_file_exists?("test", filename)
      #public_file_does_not_exist?("test", filename)
      actual = read_public_yaml_file("test", filename)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_24b.yaml")
      check_file_actual_expected(actual, sub_dir, "import_errors_expected_24b.yaml")
      filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
      public_file_exists?("test", filename)
      copy_file_from_public_files("test", filename, sub_dir)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_24b.ttl")
      check_ttl_fix_v2(filename, "import_expected_24b.ttl", {last_change_date: true})
      expect(@job.status).to eq("Complete")
      delete_data_file(sub_dir, filename)
    end

    it "import, no errors, 1st ABTESTCD version" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V43#TH"))
      full_path = test_file_path(sub_dir, "import_input_25a.xlsx")
      params = {identifier: "ABTESTCDTEST", version: "1", date: "2018-11-01", files: [full_path], version_label: "1", label: "ABTESTCD TEST", semantic_version: "0.0.1", job: @job, uri: ct.uri}
      result = @object.import(params)
      filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
      public_file_exists?("test", filename)
      #public_file_does_not_exist?("test", filename)
      actual = read_public_yaml_file("test", filename)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_25a.yaml")
      check_file_actual_expected(actual, sub_dir, "import_errors_expected_25a.yaml")
      filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
      public_file_exists?("test", filename)
      copy_file_from_public_files("test", filename, sub_dir)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_25a.ttl")
      check_ttl_fix_v2(filename, "import_expected_25a.ttl", {last_change_date: true})
      expect(@job.status).to eq("Complete")
      delete_data_file(sub_dir, filename)
    end

    it "import, no errors, 2nd ABTESTCD version" do
      load_local_file_into_triple_store(sub_dir, "import_load_25a.ttl")
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V53#TH"))
      full_path = test_file_path(sub_dir, "import_input_25b.xlsx")
      params = {identifier: "ABTESTCDTEST", version: "2", date: "2018-12-01", files: [full_path], version_label: "2", label: "ABTESTCD TEST", semantic_version: "0.0.2", job: @job, uri: ct.uri}
      result = @object.import(params)
      filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
      public_file_exists?("test", filename)
      #public_file_does_not_exist?("test", filename)
      actual = read_public_yaml_file("test", filename)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_25b.yaml")
      check_file_actual_expected(actual, sub_dir, "import_errors_expected_25b.yaml")
      filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
      public_file_exists?("test", filename)
      copy_file_from_public_files("test", filename, sub_dir)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_25b.ttl")
      check_ttl_fix_v2(filename, "import_expected_25b.ttl", {last_change_date: true})
      expect(@job.status).to eq("Complete")
      delete_data_file(sub_dir, filename)
    end

    it "import, no errors, 1st EDUCATE version" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V43#TH"))
      full_path = test_file_path(sub_dir, "import_input_26a.xlsx")
      params = {identifier: "ABTESTCDTEST", version: "1", date: "2018-11-01", files: [full_path], version_label: "1", label: "ABTESTCD TEST", semantic_version: "0.0.1", job: @job, uri: ct.uri}
      result = @object.import(params)
      filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
      public_file_exists?("test", filename)
      #public_file_does_not_exist?("test", filename)
      actual = read_public_yaml_file("test", filename)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_26a.yaml")
      check_file_actual_expected(actual, sub_dir, "import_errors_expected_26a.yaml")
      filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
      public_file_exists?("test", filename)
      copy_file_from_public_files("test", filename, sub_dir)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_26a.ttl")
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_load_26a.ttl")
      check_ttl_fix_v2(filename, "import_expected_26a.ttl", {last_change_date: true})
      expect(@job.status).to eq("Complete")
      delete_data_file(sub_dir, filename)
    end

    it "import, no errors, 2nd EDUCATE version" do
      load_local_file_into_triple_store(sub_dir, "import_load_26a.ttl")
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V53#TH"))
      full_path = test_file_path(sub_dir, "import_input_26b.xlsx")
      params = {identifier: "ABTESTCDTEST", version: "2", date: "2018-12-01", files: [full_path], version_label: "2", label: "ABTESTCD TEST", semantic_version: "0.0.2", job: @job, uri: ct.uri}
      result = @object.import(params)
      filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
      public_file_exists?("test", filename)
      #public_file_does_not_exist?("test", filename)
      actual = read_public_yaml_file("test", filename)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_26b.yaml")
      check_file_actual_expected(actual, sub_dir, "import_errors_expected_26b.yaml")
      filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
      public_file_exists?("test", filename)
      copy_file_from_public_files("test", filename, sub_dir)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_26b.ttl")
      check_ttl_fix_v2(filename, "import_expected_26b.ttl", {last_change_date: true})
      expect(@job.status).to eq("Complete")
      delete_data_file(sub_dir, filename)
    end

    it "import, EPOCH code list" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V53#TH"))
      full_path = test_file_path(sub_dir, "import_input_30a.xlsx")
      params = {identifier: "EPOCHTEST", version: "1", date: "2018-12-01", files: [full_path], version_label: "1", label: "ABTESTCD TEST", semantic_version: "0.0.1", job: @job, uri: ct.uri}
      result = @object.import(params)
      filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
      public_file_exists?("test", filename)
      #public_file_does_not_exist?("test", filename)
      actual = read_public_yaml_file("test", filename)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_30a.yaml")
      check_file_actual_expected(actual, sub_dir, "import_errors_expected_30a.yaml")
      filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
      public_file_exists?("test", filename)
      copy_file_from_public_files("test", filename, sub_dir)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_30a.ttl")
      check_ttl_fix_v2(filename, "import_expected_30a.ttl", {last_change_date: true})
      expect(@job.status).to eq("Complete")
      delete_data_file(sub_dir, filename)
    end

    it "import, SEVRS code list" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V53#TH"))
      full_path = test_file_path(sub_dir, "import_input_31a.xlsx")
      params = {identifier: "SEVRSTEST", version: "1", date: "2020-09-10", files: [full_path], version_label: "1", label: "ABTESTCD TEST", semantic_version: "0.0.1", job: @job, uri: ct.uri}
      result = @object.import(params)
      filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
      public_file_exists?("test", filename)
      #public_file_does_not_exist?("test", filename)
      actual = read_public_yaml_file("test", filename)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_31a.yaml")
      check_file_actual_expected(actual, sub_dir, "import_errors_expected_31a.yaml")
      filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
      public_file_exists?("test", filename)
      copy_file_from_public_files("test", filename, sub_dir)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_31a.ttl")
      check_ttl_fix_v2(filename, "import_expected_31a.ttl", {last_change_date: true})
      expect(@job.status).to eq("Complete")
      delete_data_file(sub_dir, filename)
    end

    it "import, AERELA code list" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V53#TH"))
      full_path = test_file_path(sub_dir, "import_input_32a.xlsx")
      params = {identifier: "AERELATEST", version: "1", date: "2018-12-10", files: [full_path], version_label: "1", label: "AERELA TEST", semantic_version: "0.0.1", job: @job, uri: ct.uri}
      result = @object.import(params)
      filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
      public_file_exists?("test", filename)
      #public_file_does_not_exist?("test", filename)
      actual = read_public_yaml_file("test", filename)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_32a.yaml")
      check_file_actual_expected(actual, sub_dir, "import_errors_expected_32a.yaml")
      filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
      public_file_exists?("test", filename)
      copy_file_from_public_files("test", filename, sub_dir)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_32a.ttl")
      check_ttl_fix_v2(filename, "import_expected_32a.ttl", {last_change_date: true})
      expect(@job.status).to eq("Complete")
      delete_data_file(sub_dir, filename)
    end

    it "import, AERELA and Subset code list with Custom Check" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V53#TH"))
      full_path = test_file_path(sub_dir, "import_input_33.xlsx")
      params = {identifier: "AERELATEST", version: "1", date: "2018-12-10", files: [full_path], version_label: "1", label: "AERELA TEST", semantic_version: "0.0.1", job: @job, uri: ct.uri}
      result = @object.import(params)
      filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
      public_file_exists?("test", filename)
      #public_file_does_not_exist?("test", filename)
      actual = read_public_yaml_file("test", filename)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_33.yaml")
      check_file_actual_expected(actual, sub_dir, "import_errors_expected_33.yaml")
      filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
      public_file_exists?("test", filename)
      copy_file_from_public_files("test", filename, sub_dir)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_33.ttl")
      check_ttl_fix_v2(filename, "import_expected_33.ttl", {last_change_date: true})
      expect(@job.status).to eq("Complete")
      delete_data_file(sub_dir, filename)
      # load_local_file_into_triple_store(sub_dir, "import_expected_33.ttl")
      # tc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/SN000012/V1#SN000012"))
      # results = tc.find_custom_property_values
      # check_file_actual_expected(results, sub_dir, "import_errors_custom_expected_33a.yaml")
      # tc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/NP001000P/V1#NP001000P"))
      # results = tc.find_custom_property_values
      # check_file_actual_expected(results, sub_dir, "import_errors_custom_expected_33b.yaml")
    end

    it "import, no errors, 1st ACSPCAT version" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V43#TH"))
      full_path = test_file_path(sub_dir, "import_input_34a.xlsx")
      params = {identifier: "ACSPCATTEST", version: "1", date: "2018-11-01", files: [full_path], version_label: "1", label: "ACSPCAT TEST", semantic_version: "0.0.1", job: @job, uri: ct.uri}
      result = @object.import(params)
      filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
      public_file_exists?("test", filename)
      #public_file_does_not_exist?("test", filename)
      actual = read_public_yaml_file("test", filename)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_34a.yaml")
      check_file_actual_expected(actual, sub_dir, "import_errors_expected_34a.yaml")
      filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
      public_file_exists?("test", filename)
      copy_file_from_public_files("test", filename, sub_dir)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_34a.ttl")
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_load_34a.ttl")
      check_ttl_fix_v2(filename, "import_expected_34a.ttl", {last_change_date: true})
      expect(@job.status).to eq("Complete")
      delete_data_file(sub_dir, filename)
    end

    it "import, no errors, 2nd ACSPCAT version" do
      load_local_file_into_triple_store(sub_dir, "import_load_34a.ttl")
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V53#TH"))
      full_path = test_file_path(sub_dir, "import_input_34b.xlsx")
      params = {identifier: "ACSPCATTEST", version: "2", date: "2018-12-01", files: [full_path], version_label: "2", label: "ACSPCAT TEST", semantic_version: "0.0.2", job: @job, uri: ct.uri}
      result = @object.import(params)
      filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
      public_file_exists?("test", filename)
      #public_file_does_not_exist?("test", filename)
      actual = read_public_yaml_file("test", filename)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_34b.yaml")
      check_file_actual_expected(actual, sub_dir, "import_errors_expected_34b.yaml")
      filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
      public_file_exists?("test", filename)
      copy_file_from_public_files("test", filename, sub_dir)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_34b.ttl")
      check_ttl_fix_v2(filename, "import_expected_34b.ttl", {last_change_date: true})
      expect(@job.status).to eq("Complete")
      delete_data_file(sub_dir, filename)
    end

    it "import, no errors, 1st DICTNAM version" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V43#TH"))
      full_path = test_file_path(sub_dir, "import_input_35a.xlsx")
      params = {identifier: "DICTNAMTEST", version: "1", date: "2018-11-01", files: [full_path], version_label: "1", label: "DICTNAM TEST", semantic_version: "0.0.1", job: @job, uri: ct.uri}
      result = @object.import(params)
      filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
      public_file_exists?("test", filename)
      #public_file_does_not_exist?("test", filename)
      actual = read_public_yaml_file("test", filename)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_35a.yaml")
      check_file_actual_expected(actual, sub_dir, "import_errors_expected_35a.yaml")
      filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
      public_file_exists?("test", filename)
      copy_file_from_public_files("test", filename, sub_dir)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_35a.ttl")
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_load_35a.ttl")
      check_ttl_fix_v2(filename, "import_expected_35a.ttl", {last_change_date: true})
      expect(@job.status).to eq("Complete")
      delete_data_file(sub_dir, filename)
    end

    it "import, no errors, 2nd DICTNAM version" do
      load_local_file_into_triple_store(sub_dir, "import_load_35a.ttl")
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V53#TH"))
      full_path = test_file_path(sub_dir, "import_input_35b.xlsx")
      params = {identifier: "DICTNAMTEST", version: "2", date: "2018-12-01", files: [full_path], version_label: "2", 
        label: "DICTNAM TEST", semantic_version: "0.0.2", job: @job, uri: ct.uri, release: false}
      result = @object.import(params)
      filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
      public_file_exists?("test", filename)
      #public_file_does_not_exist?("test", filename)
      actual = read_public_yaml_file("test", filename)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_35b.yaml")
      check_file_actual_expected(actual, sub_dir, "import_errors_expected_35b.yaml")
      filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
      public_file_exists?("test", filename)
      copy_file_from_public_files("test", filename, sub_dir)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_35b.ttl")
      check_ttl_fix_v2(filename, "import_expected_35b.ttl", {last_change_date: true})
      expect(@job.status).to eq("Complete")
      delete_data_file(sub_dir, filename)
    end

    it "paths test" do
      tc = Thesaurus::ManagedConcept.find_full(Uri.new(uri: "http://www.cdisc.org/C66767/V35#C66767"))
      check_file_actual_expected(tc.to_h, sub_dir, "find_full_paths_expected_1.yaml", equate_method: :hash_equal)
    end

    it "import, no errors, full version 3.0 with base, bug issue I" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V53#TH"))
  puts colourize("Load 2.6 triples ...", "blue")
      load_local_file_into_triple_store(sub_dir, "import_load_10.ttl")
  puts colourize("Load 3.0 excel ...", "blue")
      full_path = test_file_path(sub_dir, "import_input_10.xlsx")
      params = {identifier: "Q1 2020", version: "1", date: "2100-01-01", files: [full_path], version_label: "1.0.0", label: "Version 3-0 Test Upgrade", semantic_version: "1.0.0", job: @job, uri: ct.uri}
      result = @object.import(params)
      filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
      #expect(public_file_does_not_exist?("test", filename)).to eq(true)
      actual = read_public_yaml_file("test", filename)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_10.yaml")
      check_file_actual_expected(actual, sub_dir, "import_errors_expected_10.yaml")
      #copy_file_from_public_files("test", filename, sub_dir)
      filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
      #expect(public_file_exists?("test", filename)).to eq(true)
      copy_file_from_public_files("test", filename, sub_dir)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_10.ttl")
      check_ttl_fix_v2(filename, "import_expected_10.ttl", {last_change_date: true})
      expect(@job.status).to eq("Complete")
      delete_data_file(sub_dir, filename)
    end

    it "import, no errors, full version 3.0 with base, bug issue II" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V53#TH"))
  puts colourize("Load 2.6 triples ...", "blue")
      load_local_file_into_triple_store(sub_dir, "import_load_11.ttl")
  puts colourize("Load 3.0 excel ...", "blue")
      full_path = test_file_path(sub_dir, "import_input_11.xlsx")
      params = {identifier: "Q1 2020", version: "1", date: "2100-01-01", files: [full_path], version_label: "1.0.0", label: "Version 3-0 Test Upgrade", semantic_version: "1.0.0", job: @job, uri: ct.uri}
      result = @object.import(params)
      filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
      #expect(public_file_does_not_exist?("test", filename)).to eq(true)
      actual = read_public_yaml_file("test", filename)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_11.yaml")
      check_file_actual_expected(actual, sub_dir, "import_errors_expected_11.yaml")
      #copy_file_from_public_files("test", filename, sub_dir)
      filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
      #expect(public_file_exists?("test", filename)).to eq(true)
      copy_file_from_public_files("test", filename, sub_dir)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_11.ttl")
      check_ttl_fix_v2(filename, "import_expected_11.ttl", {last_change_date: true})
      expect(@job.status).to eq("Complete")
      delete_data_file(sub_dir, filename)
    end

    it "import, no errors, bug issue III" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V43#TH"))
      full_path = test_file_path(sub_dir, "import_input_12.xlsx")
      params = {identifier: "Q2 2019", version: "1", date: "2019-06-01", files: [full_path], version_label: "1.0.0", label: "Version 2-6 Test", semantic_version: "1.0.0", job: @job, uri: ct.uri}
      result = @object.import(params)
      filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
      #expect(public_file_does_not_exist?("test", filename)).to eq(true)
      actual = read_public_yaml_file("test", filename)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_12.yaml")
      check_file_actual_expected(actual, sub_dir, "import_errors_expected_12.yaml")
      #copy_file_from_public_files("test", filename, sub_dir)
      filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
      #expect(public_file_exists?("test", filename)).to eq(true)
      copy_file_from_public_files("test", filename, sub_dir)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_12.ttl")
      check_ttl_fix_v2(filename, "import_expected_12.ttl", {last_change_date: true})
      expect(@job.status).to eq("Complete")
      delete_data_file(sub_dir, filename)
    end

    it "import, no errors, bug issue IV" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V43#TH"))
      full_path = test_file_path(sub_dir, "import_input_14.xlsx")
      params = {identifier: "Q2 2019", version: "1", date: "2019-06-01", files: [full_path], version_label: "1.0.0", label: "Version 2-6 Test", semantic_version: "1.0.0", job: @job, uri: ct.uri}
      result = @object.import(params)
      filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
      #expect(public_file_does_not_exist?("test", filename)).to eq(true)
      actual = read_public_yaml_file("test", filename)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_14.yaml")
      check_file_actual_expected(actual, sub_dir, "import_errors_expected_14.yaml")
      #copy_file_from_public_files("test", filename, sub_dir)
      filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
      #expect(public_file_exists?("test", filename)).to eq(true)
      copy_file_from_public_files("test", filename, sub_dir)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_14.ttl")
      check_ttl_fix_v2(filename, "import_expected_14.ttl", {last_change_date: true})
      expect(@job.status).to eq("Complete")
      delete_data_file(sub_dir, filename)
    end

    it "import, no errors, bug issue V" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V43#TH"))
      full_path = test_file_path(sub_dir, "import_input_15.xlsx")
      params = {identifier: "TEST 15", version: "1", date: "2100-01-01", files: [full_path], version_label: "1.0.0", label: "Version 2-6 Test", semantic_version: "1.0.0", job: @job, uri: ct.uri}
      result = @object.import(params)
      filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
      #expect(public_file_does_not_exist?("test", filename)).to eq(true)
      actual = read_public_yaml_file("test", filename)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_15.yaml")
      check_file_actual_expected(actual, sub_dir, "import_errors_expected_15.yaml")
      #copy_file_from_public_files("test", filename, sub_dir)
      filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
      #expect(public_file_exists?("test", filename)).to eq(true)
      copy_file_from_public_files("test", filename, sub_dir)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_15.ttl")
      check_ttl_fix_v2(filename, "import_expected_15.ttl", {last_change_date: true})
      expect(@job.status).to eq("Complete")
      delete_data_file(sub_dir, filename)
    end

    it "import, no errors, bug issue VI" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V43#TH"))
      full_path = test_file_path(sub_dir, "import_input_16.xlsx")
      params = {identifier: "TEST 16", version: "1", date: "2019-06-01", files: [full_path], version_label: "1.0.0", label: "Version 2-6 Test", semantic_version: "1.0.0", job: @job, uri: ct.uri}
      result = @object.import(params)
      filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
      #expect(public_file_does_not_exist?("test", filename)).to eq(true)
      actual = read_public_yaml_file("test", filename)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_16.yaml")
      check_file_actual_expected(actual, sub_dir, "import_errors_expected_16.yaml")
      #copy_file_from_public_files("test", filename, sub_dir)
      filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
      #expect(public_file_exists?("test", filename)).to eq(true)
      copy_file_from_public_files("test", filename, sub_dir)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_16.ttl")
      check_ttl_fix_v2(filename, "import_expected_16.ttl", {last_change_date: true})
      expect(@job.status).to eq("Complete")
      delete_data_file(sub_dir, filename)
    end

    it "import, no errors, bug issue VII" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V43#TH"))
      full_path = test_file_path(sub_dir, "import_input_17.xlsx")
      params = {identifier: "TEST 16", version: "1", date: "2019-06-01", files: [full_path], version_label: "1.0.0", label: "Version 2-6 Test", semantic_version: "1.0.0", job: @job, uri: ct.uri}
      result = @object.import(params)
      filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
      #expect(public_file_does_not_exist?("test", filename)).to eq(true)
      actual = read_public_yaml_file("test", filename)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_17.yaml")
      check_file_actual_expected(actual, sub_dir, "import_errors_expected_17.yaml")
      #copy_file_from_public_files("test", filename, sub_dir)
      filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
      #expect(public_file_exists?("test", filename)).to eq(true)
      copy_file_from_public_files("test", filename, sub_dir)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_17.ttl")
      check_ttl_fix_v2(filename, "import_expected_17.ttl", {last_change_date: true})
      expect(@job.status).to eq("Complete")
      delete_data_file(sub_dir, filename)
    end

    it "import, no errors, bug issue VIII" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V43#TH"))
      full_path = test_file_path(sub_dir, "import_input_18.xlsx")
      params = {identifier: "TEST 16", version: "1", date: "2019-06-01", files: [full_path], version_label: "1.0.0", label: "Version 2-6 Test", semantic_version: "1.0.0", job: @job, uri: ct.uri}
      result = @object.import(params)
      filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
      #expect(public_file_does_not_exist?("test", filename)).to eq(true)
      actual = read_public_yaml_file("test", filename)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_18.yaml")
      check_file_actual_expected(actual, sub_dir, "import_errors_expected_18.yaml")
      #copy_file_from_public_files("test", filename, sub_dir)
      filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
      #expect(public_file_exists?("test", filename)).to eq(true)
      copy_file_from_public_files("test", filename, sub_dir)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_18.ttl")
      check_ttl_fix_v2(filename, "import_expected_18.ttl", {last_change_date: true})
      expect(@job.status).to eq("Complete")
      delete_data_file(sub_dir, filename)
    end

    it "import, no errors, bug issue IX" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V43#TH"))
      full_path = test_file_path(sub_dir, "import_input_20.xlsx")
      params = {identifier: "TEST 16", version: "1", date: "2019-06-01", files: [full_path], version_label: "1.0.0", label: "Version 2-6 Test", semantic_version: "1.0.0", job: @job, uri: ct.uri}
      result = @object.import(params)
      filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
      #expect(public_file_does_not_exist?("test", filename)).to eq(true)
      actual = read_public_yaml_file("test", filename)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_20.yaml")
      check_file_actual_expected(actual, sub_dir, "import_errors_expected_20.yaml")
      #copy_file_from_public_files("test", filename, sub_dir)
      filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
      #expect(public_file_exists?("test", filename)).to eq(true)
      copy_file_from_public_files("test", filename, sub_dir)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_20.ttl")
      check_ttl_fix_v2(filename, "import_expected_20.ttl", {last_change_date: true})
      expect(@job.status).to eq("Complete")
      delete_data_file(sub_dir, filename)
    end

    it "import, no errors, rank I" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V43#TH"))
      full_path = test_file_path(sub_dir, "import_input_21.xlsx")
      params = {identifier: "TEST 16", version: "1", date: "2019-06-01", files: [full_path], version_label: "1.0.0", label: "Version 2-6 Test", semantic_version: "1.0.0", job: @job, uri: ct.uri}
      result = @object.import(params)
      filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
      #expect(public_file_does_not_exist?("test", filename)).to eq(true)
      actual = read_public_yaml_file("test", filename)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_21.yaml")
      check_file_actual_expected(actual, sub_dir, "import_errors_expected_21.yaml")
      #copy_file_from_public_files("test", filename, sub_dir)
      filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
      #expect(public_file_exists?("test", filename)).to eq(true)
      copy_file_from_public_files("test", filename, sub_dir)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_21.ttl")
      check_ttl_fix_v2(filename, "import_expected_21.ttl", {last_change_date: true})
      expect(@job.status).to eq("Complete")
      delete_data_file(sub_dir, filename)
    end

    it "import, no errors, rank II" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V43#TH"))
      full_path = test_file_path(sub_dir, "import_input_23.xlsx")
      params = {identifier: "TEST 16", version: "1", date: "2019-06-01", files: [full_path], version_label: "1.0.0", label: "Version 2-6 Test", semantic_version: "1.0.0", job: @job, uri: ct.uri}
      result = @object.import(params)
      filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
      #expect(public_file_does_not_exist?("test", filename)).to eq(true)
      actual = read_public_yaml_file("test", filename)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_23.yaml")
      check_file_actual_expected(actual, sub_dir, "import_errors_expected_23.yaml")
      #copy_file_from_public_files("test", filename, sub_dir)
      filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
      #expect(public_file_exists?("test", filename)).to eq(true)
      copy_file_from_public_files("test", filename, sub_dir)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_23.ttl")
      check_ttl_fix_v2(filename, "import_expected_23.ttl", {last_change_date: true})
      expect(@job.status).to eq("Complete")
      delete_data_file(sub_dir, filename)
    end

    it "import, exception" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V47#TH"))
      expect_any_instance_of(Excel).to receive(:execute).and_raise(StandardError.new("error"))
      full_path = test_file_path(sub_dir, "import_input_3.xlsx")
      params = { version: "1", version_label: "1.1.1", date: "2018-11-22", files: [full_path], label: "ADAM IG", 
        semantic_version: "1.2.4", job: @job, uri: ct.uri}
      @object.import(params)
      expect(@job.status).to include("An exception was detected during the import processes.\nDetails: error.\nBacktrace: ")
    end

  end

  describe "Synonym Custom Property" do

    before :each do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_process.ttl")
      load_data_file_into_triple_store("sponsor_one/custom_property/custom_properties.ttl")
      load_data_file_into_triple_store("sponsor_one/custom_property/custom_properties_migration_one.ttl")
      load_cdisc_term_versions(1..62)
      nv_destroy
      nv_create(parent: "1000", child: "10000")
      Import.destroy_all
      delete_all_public_test_files
      clear_stfo_objects
      setup
    end

    after :each do
      Import.destroy_all
      delete_all_public_test_files
    end

    it "import, AERELA and Subset code list with Custom Check" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V53#TH"))
      full_path = test_file_path(sub_dir, "import_input_33.xlsx")
      params = {identifier: "AERELATEST", version: "1", date: "2018-12-10", files: [full_path], version_label: "1", label: "AERELA TEST", semantic_version: "0.0.1", job: @job, uri: ct.uri}
      result = @object.import(params)
      filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
      public_file_exists?("test", filename)
      #public_file_does_not_exist?("test", filename)
      actual = read_public_yaml_file("test", filename)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_100.yaml")
      check_file_actual_expected(actual, sub_dir, "import_errors_expected_100.yaml")
      filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
      public_file_exists?("test", filename)
      copy_file_from_public_files("test", filename, sub_dir)
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_100.ttl")
      check_ttl_fix_v2(filename, "import_expected_100.ttl", {last_change_date: true})
      expect(@job.status).to eq("Complete")
      delete_data_file(sub_dir, filename)
    end

  end

end