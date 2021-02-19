require 'rails_helper'

RSpec.describe AdHocReport, type: :model do
  
  include DataHelpers
  include PublicFileHelpers
  include CdiscCtHelpers
  include NameValueHelpers

	def sub_dir
    return "models/ad_hoc_report"
  end

  # def import_dir
  #   return "models/import/data/sponsor_one/ct"
  # end

  C_CL_NOTATION = 1
  C_CL_CODE_COL = 4
  C_CLI_CODE_COL = 5
  C_RANK_COL = 14

  def save_selected_results(results, filename, items, write_file)
    selected_results = {}
    full_results = key_data(results)
    items.each do |key|
      selected_results[key] = full_results[key]
    end
    check_file_actual_expected(selected_results, sub_dir, filename, equate_method: :hash_equal, write_file: write_file)
  end
  
  def extract_ranks(rows)
    results = Hash.new {|h,k| h[k] = []}
    rows[:data].each do |row|
      next if row[C_RANK_COL].empty? # <<< Important, the rank column. Might change!
      results[row[C_CL_NOTATION]] << {item: row[C_CLI_CODE_COL], rank: row[C_RANK_COL]}
    end
    results
  end

  def key_data(rows)
    results = Hash.new {|h,k| h[k] = []}
    rows[:data].each do |row| 
      results[row[C_CL_NOTATION]] << row
    end
    results
  end

  describe "Simple Reports" do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "ad_hoc_reports_thesaurus.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(CdiscCtHelpers.version_range)   
      AdHocReport.delete_all
      delete_all_public_files
    end

    after :all do
      delete_all_public_files
    end

    it "executes a submission impact report" do
      copy_report_to_public_files("submission_impact_sparql.yaml", "test")
      job = Background.create
      report = AdHocReport.new
      report.background_id = job.id
      report.sparql_file = "submission_impact_sparql.yaml"
      report.results_file = "submission_impact_results_1.yaml"
      job.start("Rspec test", "Starting...") {report.execute([Uri.new(uri: "http://www.acme-pharma.com/AIRPORTS/V1#TH").to_id])}
      results = AdHocReportFiles.read("submission_impact_results_1.yaml")
      check_file_actual_expected(results, sub_dir, "submission_impact_expected_1.yaml", equate_method: :hash_equal)
    end

    it "executes a ct references inconsistencies report" do
      copy_report_to_public_files("ct_references_inconsistencies_sparql.yaml", "test")
      job = Background.create
      report = AdHocReport.new
      report.background_id = job.id
      report.sparql_file = "ct_references_inconsistencies_sparql.yaml"
      report.results_file = "ct_references_inconsistencies_results_1.yaml"
      job.start("Rspec test", "Starting...") {report.execute([Uri.new(uri: "http://www.acme-pharma.com/AIRPORTS/V1#TH").to_id])}
      results = AdHocReportFiles.read("ct_references_inconsistencies_results_1.yaml")
      check_file_actual_expected(results, sub_dir, "ct_references_inconsistencies_expected_1.yaml", equate_method: :hash_equal)
    end

    it "executes a missing tags report" do
      copy_report_to_public_files("missing_tags_sparql.yaml", "test")
      job = Background.create
      report = AdHocReport.new
      report.background_id = job.id
      report.sparql_file = "missing_tags_sparql.yaml"
      report.results_file = "missing_tags_results_1.yaml"
      job.start("Rspec test", "Starting...") {report.execute([Uri.new(uri: "http://www.acme-pharma.com/AIRPORTS/V1#TH").to_id])}
      results = AdHocReportFiles.read("missing_tags_results_1.yaml")
      check_file_actual_expected(results, sub_dir, "missing_tags_expected_1.yaml", equate_method: :hash_equal)
    end

  end

  describe "Change Instructions Export Tests" do

    def load_versions(range)
      range.each {|n| load_data_file_into_triple_store("cdisc/ct/CT_V#{n}.ttl")}
    end

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_versions(1..54)
      load_data_file_into_triple_store("cdisc/ct/changes/change_instructions_v47.ttl")
      load_data_file_into_triple_store("cdisc/ct/changes/change_instructions_v52.ttl")
      load_data_file_into_triple_store("cdisc/ct/changes/change_instructions_v53.ttl")
      AdHocReport.delete_all
      delete_all_public_files
    end

    after :all do
      delete_all_public_files
    end

    it "executes a change instructions export report V47" do
      copy_report_to_public_files("change_instructions_export_sparql.yaml", "test")
      job = Background.create
      report = AdHocReport.new
      report.background_id = job.id
      report.sparql_file = "change_instructions_export_sparql.yaml"
      report.results_file = "change_instructions_export_results_1.yaml"
      job.start("Rspec test", "Starting...") {report.execute([Uri.new(uri: "http://www.cdisc.org/CT/V47#TH").to_id])}
      results = AdHocReportFiles.read("change_instructions_export_results_1.yaml")
      check_file_actual_expected(results, sub_dir, "change_instructions_export_expected_1.yaml", equate_method: :hash_equal)
    end

    it "executes a change instructions export report V52 " do
      copy_report_to_public_files("change_instructions_export_sparql.yaml", "test")
      job = Background.create
      report = AdHocReport.new
      report.background_id = job.id
      report.sparql_file = "change_instructions_export_sparql.yaml"
      report.results_file = "change_instructions_export_results_2.yaml"
      job.start("Rspec test", "Starting...") {report.execute([Uri.new(uri: "http://www.cdisc.org/CT/V52#TH").to_id])}
      results = AdHocReportFiles.read("change_instructions_export_results_2.yaml")
      check_file_actual_expected(results, sub_dir, "change_instructions_export_expected_2.yaml", equate_method: :hash_equal)
    end

    it "executes a change instructions export report V53 " do
      copy_report_to_public_files("change_instructions_export_sparql.yaml", "test")
      job = Background.create
      report = AdHocReport.new
      report.background_id = job.id
      report.sparql_file = "change_instructions_export_sparql.yaml"
      report.results_file = "change_instructions_export_results_3.yaml"
      job.start("Rspec test", "Starting...") {report.execute([Uri.new(uri: "http://www.cdisc.org/CT/V53#TH").to_id])}
      results = AdHocReportFiles.read("change_instructions_export_results_3.yaml")
      check_file_actual_expected(results, sub_dir, "change_instructions_export_expected_3.yaml", equate_method: :hash_equal)
    end
  
  end

  describe "Sponsor Export Tests" do
    
    before :all do
      load_files(schema_files, [])
      load_all_cdisc_term_versions
      load_data_file_into_triple_store("mdr_sponsor_one_identification.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_process.ttl")
      load_data_file_into_triple_store("sponsor_one/custom_property/custom_properties.ttl")
      load_data_file_into_triple_store("sponsor_one/custom_property/custom_properties_migration_one.ttl")
      load_data_file_into_triple_store("sponsor_one/custom_property/custom_properties_migration_two.ttl")
      load_data_file_into_triple_store("sponsor_one/ct/CT_V2-6.ttl")
      load_data_file_into_triple_store("sponsor_one/ct/CT_V3-0.ttl")
      load_data_file_into_triple_store("sponsor_one/ct/CT_V3-1.ttl")
      AdHocReport.delete_all
      delete_all_public_files
    end

    after :all do
      delete_all_public_files
    end

    it "executes an sponsor CT export report, 2019", :ad_hoc_report => 'slow' do
      copy_report_to_public_files("sponsor_ct_export_sparql.yaml", "test")
      job = Background.create
      report = AdHocReport.new
      report.background_id = job.id
      report.sparql_file = "sponsor_ct_export_sparql.yaml"
      report.results_file = "sponsor_ct_export_results_1.yaml"
      job.start("Rspec test", "Starting...") {report.execute([Uri.new(uri: "http://www.sanofi.com/2019_Release_1/V1#TH").to_id])}
      results = AdHocReportFiles.read("sponsor_ct_export_results_1.yaml")
      expect(results[:data].count).to eq(22321) 
      save_selected_results(results, "sponsor_ct_export_selected_results_1.yaml", ["ACN_01", "ACN_03", "AERELA","SUAM_01", "LOC_01", "RACEC", "TRTEST", "NSA-16 TESTCD", "COWS TESTCD", "OUT", "AESEV", "AGEGRPEN", "RACEN", "MRS01R"], false)
      ranks = extract_ranks(results)
      check_file_actual_expected(ranks, sub_dir, "sponsor_ct_export_rank_results_1.yaml", equate_method: :hash_equal)
      expect(ranks.count).to eq(44)
    #Xwrite_yaml_file(key_data(results), sub_dir, "sponsor_ct_export_full_results_1.yaml")
    end
  
    it "executes an sponsor CT export report, 2020 R1", :ad_hoc_report => 'slow' do
      copy_report_to_public_files("sponsor_ct_export_sparql.yaml", "test")
      job = Background.create
      report = AdHocReport.new
      report.background_id = job.id
      report.sparql_file = "sponsor_ct_export_sparql.yaml"
      report.results_file = "sponsor_ct_export_results_2.yaml"
      job.start("Rspec test", "Starting...") {report.execute([Uri.new(uri: "http://www.sanofi.com/2020_Release_1/V1#TH").to_id])}
      full_path = File.join(AdHocReportFiles.dir_path, "sponsor_ct_export_results_2.yaml")
      results = AdHocReportFiles.read("sponsor_ct_export_results_2.yaml")
      expect(results[:data].count).to eq(31929) 
      save_selected_results(results, "sponsor_ct_export_selected_results_2.yaml", ["ACN_01", "ACN_03", "AERELA", "SUAM_01", "LOC_01", "RACEC", "TRTEST", "NSA-16 TESTCD", "COWS TESTCD", "OUT", "AESEV", "AGEGRPEN", "RACEN", "KPSSR_01"], false)
      ranks = extract_ranks(results)
      check_file_actual_expected(ranks, sub_dir, "sponsor_ct_export_rank_results_2.yaml", equate_method: :hash_equal)
      expect(ranks.count).to eq(47)
    #Xwrite_yaml_file(key_data(results), sub_dir, "sponsor_ct_export_full_results_2.yaml")
    end
  
    it "executes an sponsor CT export report, 2020 R2", :ad_hoc_report => 'slow' do
      copy_report_to_public_files("sponsor_ct_export_sparql.yaml", "test")
      job = Background.create
      report = AdHocReport.new
      report.background_id = job.id
      report.sparql_file = "sponsor_ct_export_sparql.yaml"
      report.results_file = "sponsor_ct_export_results_3.yaml"
      job.start("Rspec test", "Starting...") {report.execute([Uri.new(uri: "http://www.sanofi.com/2020_Release_2/V1#TH").to_id])}
      full_path = File.join(AdHocReportFiles.dir_path, "sponsor_ct_export_results_3.yaml")
      results = AdHocReportFiles.read("sponsor_ct_export_results_3.yaml")
      expect(results[:data].count).to eq(32780) 
      save_selected_results(results, "sponsor_ct_export_selected_results_3.yaml", ["ACN", "AERELA", "AERELDEV_01", "AGEGRPE", "AGEGRPPN", "NORMEDN", "SEVRS", "SHIFT2N", "TOXGR_01", "TOXGRN", "LBPARMN", "POEM9R", "NORMEDN"], false)
      ranks = extract_ranks(results)
      check_file_actual_expected(ranks, sub_dir, "sponsor_ct_export_rank_results_3.yaml", equate_method: :hash_equal)
      expect(ranks.count).to eq(30)
    #Xwrite_yaml_file(key_data(results), sub_dir, "sponsor_ct_export_full_results_3.yaml")
    end
  
    it "executes an sponsor CT export subsets report 2019", :ad_hoc_report => 'slow' do
      copy_report_to_public_files("sponsor_ct_export_subsets_sparql.yaml", "test")
      job = Background.create
      report = AdHocReport.new
      report.background_id = job.id
      report.sparql_file = "sponsor_ct_export_subsets_sparql.yaml"
      report.results_file = "sponsor_ct_export_subsets_results_1.yaml"
      job.start("Rspec test", "Starting...") {report.execute([Uri.new(uri: "http://www.sanofi.com/2019_Release_1/V1#TH").to_id])}
      results = AdHocReportFiles.read("sponsor_ct_export_subsets_results_1.yaml")
      expect(results[:data].count).to eq(1974)
      save_selected_results(results, "sponsor_ct_export_subsets_selected_results_1.yaml", ["ACN_01", "ACN_03", "SUAM_01", "LOC_01"], false)
      ranks = extract_ranks(results)
      check_file_actual_expected(ranks, sub_dir, "sponsor_ct_export_subsets_rank_results_1.yaml", equate_method: :hash_equal)
      expect(ranks.count).to eq(3)
    end
  
    it "executes an sponsor CT export subsets report, 2020", :ad_hoc_report => 'slow' do
      copy_report_to_public_files("sponsor_ct_export_subsets_sparql.yaml", "test")
      job = Background.create
      report = AdHocReport.new
      report.background_id = job.id
      report.sparql_file = "sponsor_ct_export_subsets_sparql.yaml"
      report.results_file = "sponsor_ct_export_subsets_results_2.yaml"
      job.start("Rspec test", "Starting...") {report.execute([Uri.new(uri: "http://www.sanofi.com/2020_Release_1/V1#TH").to_id])}
      results = AdHocReportFiles.read("sponsor_ct_export_subsets_results_2.yaml")
      expect(results[:data].count).to eq(1945)
      save_selected_results(results, "sponsor_ct_export_subsets_selected_results_2.yaml", ["ACN_01", "ACN_03", "SUAM_01", "LOC_01"], false)
      ranks = extract_ranks(results)
      check_file_actual_expected(ranks, sub_dir, "sponsor_ct_export_subsets_rank_results_2.yaml", equate_method: :hash_equal)
      expect(ranks.count).to eq(3)
    end
  
    it "executes an extension count report I", :ad_hoc_report => 'slow' do
      copy_report_to_public_files("extension_count_sparql.yaml", "test")
      job = Background.create
      report = AdHocReport.new
      report.background_id = job.id
      report.sparql_file = "extension_count_sparql.yaml"
      report.results_file = "extension_count_results_1.yaml"
      job.start("Rspec test", "Starting...") {report.execute([Uri.new(uri: "http://www.sanofi.com/2019_Release_1/V1#TH").to_id])}
      results = AdHocReportFiles.read("extension_count_results_1.yaml")
      check_file_actual_expected(results, sub_dir, "extension_count_expected_1.yaml", equate_method: :hash_equal)
    end


    it "executes an extension count report II", :ad_hoc_report => 'slow' do
      copy_report_to_public_files("extension_count_sparql.yaml", "test")
      job = Background.create
      report = AdHocReport.new
      report.background_id = job.id
      report.sparql_file = "extension_count_sparql.yaml"
      report.results_file = "extension_count_results_2.yaml"
      job.start("Rspec test", "Starting...") {report.execute([Uri.new(uri: "http://www.sanofi.com/2020_Release_1/V1#TH").to_id])}
      results = AdHocReportFiles.read("extension_count_results_2.yaml")
      check_file_actual_expected(results, sub_dir, "extension_count_expected_2.yaml", equate_method: :hash_equal)
    end
  
  end

  describe "Sponsor Export Checks" do
    
    before :all do
      load_files(schema_files, [])
    end

    after :all do
    end

    def full_compare(version, with_decode=true)
      version_map = {"1": "2-6", "2": "3-0", "3": "3-1"}
      dt_cl = {}
      ignore_col = [4, 5]
      boolean_col = [false, false, true, false, false, false, false, false, false, false, false, false, false, false, true, true, true, true, false]
      actual_map = [0, 1, 2, 3, 4, 5, 6, 7, 8, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19]
      known_issues = read_yaml_file(sub_dir, "sponsor_ct_export_known_issues_#{version}.yaml")
      export = read_yaml_file(sub_dir, "sponsor_ct_export_full_results_#{version}.yaml")
      spreadsheet = read_yaml_file(sub_dir, "full_spreadsheet_export_#{version_map[version.to_sym]}.yaml")
      spreadsheet.each do |cl, rows|
        actual_cl = export[cl]
        rows.each do |row|
          actual_row = actual_cl.find{ |r| r[6].strip == row[6].strip }
          if actual_row.nil? 
            issue = known_issues.dig(cl.to_sym, row[6].to_sym)
            if issue.nil? || issue[:column] != 7
              puts colourize("\nError, cl: #{cl}, failed to match item '#{row[6]}' in the code list.", "red")
            else
              puts colourize("\nWarning, cl: #{cl}, failed to match item '#{row[6]}' in the code list.\nReason: #{issue[:reason]}", "yellow")
            end
            next
          end
          #next if actual_row.nil?      
          row.each_with_index do |cell, index|
            next if ignore_col.include?(index)
            actual_index = actual_map[index]
            cell_value = row[index]
            actual_value = actual_row[actual_index]
            cell_value = "" if cell_value.nil?
            actual_value = "" if actual_value.nil?
            cell_value = boolean_col[index] ? cell_value.strip.to_bool : cell_value.strip
            actual_value = boolean_col[index] ? actual_value.strip.to_bool : actual_value.strip
            next if index == 7 && !with_decode # Decode issue, mapping
            next if cell_value != actual_value && index == 9 && actual_value == 'Not defined.' # Definitions cannot be empty
            next if cell_value != actual_value && index == 8 && row[index] == actual_row[9] # Synonyms and the use of the custom property
            next if cell_value != actual_value && index == 12 && row[0].include?("Subset") # Subsets have order
            if cell_value != actual_value && index == 10 # Datatype issue
              dt_cl[cl] = cl
            end
            issue = known_issues.dig(cl.to_sym, row[6].to_sym)
            if issue.nil? || issue[:column] != index + 1
              puts colourize("\nError, cl: #{actual_row[4]}, cli: #{actual_row[5]}, col: #{index+1}, SS: '#{cell_value}' v A: '#{actual_value}'", "red") if cell_value != actual_value
            else
              puts colourize("\nWarning, cl: #{actual_row[4]}, cli: #{actual_row[5]}, col: #{index+1}, SS: '#{cell_value}' v A: '#{actual_value}'.\nReason: #{issue[:reason]}", "yellow")
            end
          end
        end
      end  
      puts colourize("\nDatatype CLs: #{dt_cl.keys}", "red") if dt_cl.keys.any?
    end

    it "2019 R1 Compare, no decode" do
      full_compare("1", false)
    end
  
    it "2020 R1 Compare, no decode" do
      full_compare("2", false)
    end

    it "2020 R2 Compare, no decode" do
      full_compare("3", false)
    end

    it "2019 R1 Compare, decode" do
      full_compare("1")
    end
  
    it "2020 R1 Compare, decode" do
      full_compare("2")
    end

    it "2020 R2 Compare, decode" do
      full_compare("3")
    end

  end

  describe "Export Pair Tests" do
    
    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_sponsor_one_identification.ttl")
      AdHocReport.delete_all
      nv_destroy
      nv_create(parent: "10", child: "999")
      delete_all_public_files
    end

    after :all do
      delete_all_public_files
    end

    def prep_data
      @th = Thesaurus.create({identifier: "AAA", notation: "A"})
      @tc_1 = @th.add_child
      @tc_2 = @th.add_child
      @tc_1.update(notation: "AATESTCD")
      @tc_2.update(notation: "AATEST")
      @tc_11 = @tc_1.add_child(notation: "AA1", definition: "Must match 1", preferred_term: Thesaurus::PreferredTerm.where_only_or_create("A1"))
      @tc_12 = @tc_1.add_child(notation: "AA2", definition: "Must match 2", preferred_term: Thesaurus::PreferredTerm.where_only_or_create("A2"))
      @tc_13 = @tc_1.add_child(notation: "AA3", definition: "Must match 3", preferred_term: Thesaurus::PreferredTerm.where_only_or_create("A3"))
      @tc_21 = @tc_2.add_child(notation: "AAX1", definition: "Must match 1", preferred_term: Thesaurus::PreferredTerm.where_only_or_create("A1"))
      @tc_22 = @tc_2.add_child(notation: "AAX2", definition: "Must match 2", preferred_term: Thesaurus::PreferredTerm.where_only_or_create("A2"))
      @tc_23 = @tc_2.add_child(notation: "AAX3", definition: "Must match opps", preferred_term: Thesaurus::PreferredTerm.where_only_or_create("A3"))
      @tc_1.validate_and_pair(@tc_2.id)
      triple_store.rdf_type_count(Thesaurus::ManagedConcept.rdf_type, false)
      triple_store.rdf_type_count(Thesaurus::UnmanagedConcept.rdf_type, false)
    end

    it "executes an sponsor CT export paired report, 2020" do
      prep_data
      copy_report_to_public_files("sponsor_ct_export_paired_child_sparql.yaml", "test")
      job = Background.create
      report = AdHocReport.new
      report.background_id = job.id
      report.sparql_file = "sponsor_ct_export_paired_child_sparql.yaml"
      report.results_file = "sponsor_ct_export_paired_child_results_1.yaml"
      job.start("Rspec test", "Starting...") {report.execute([@th.uri.to_id])}
      results = AdHocReportFiles.read("sponsor_ct_export_paired_child_results_1.yaml")
      expect(results[:data].count).to eq(5)
      check_file_actual_expected(results, sub_dir, "sponsor_ct_export_paired_results_1.yaml", equate_method: :hash_equal)
    end
  
  end

end