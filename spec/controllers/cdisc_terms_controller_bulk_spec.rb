require 'rails_helper'

describe CdiscTermsController do

  include DataHelpers
  include PauseHelpers
  include PublicFileHelpers
  
  describe "Bulk CDISC Terminology Changes" do
  	
    login_curator

    def sub_dir
      return "controllers"
    end

    before :all do
      clear_triple_store
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Basic.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Data.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("ISO25964.ttl")
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      load_data_file_into_triple_store("CT_V35.ttl")
      load_data_file_into_triple_store("CT_V36.ttl")
      load_data_file_into_triple_store("CT_V37.ttl")
      load_data_file_into_triple_store("CT_V38.ttl")
      load_data_file_into_triple_store("CT_V39.ttl")
      load_data_file_into_triple_store("CT_V40.ttl")
      load_data_file_into_triple_store("CT_V41.ttl")
      load_data_file_into_triple_store("CT_V42.ttl")
      load_data_file_into_triple_store("CT_V43.ttl")
      load_data_file_into_triple_store("CT_V44.ttl")
      load_data_file_into_triple_store("CT_V45.ttl")
      load_data_file_into_triple_store("CT_V46.ttl")
      load_data_file_into_triple_store("CT_V47.ttl")
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
      delete_all_public_files
    end

    def date
      dates = 
      [
        "2014-03-28", "2014-06-27", "2014-09-24", "2014-10-06", 
        "2014-12-16", "2015-03-27", "2015-06-26", "2015-09-25", 
        "2015-12-18", "2016-03-25", "2016-06-24", "2016-09-30",
        "2016-12-13"
      ] 
      return dates
    end

    def changes_comparison(results, expected)
    	puts "All Changes"
    	expect(results.length).to eq(expected.length)
    	expected.each_with_index do |expected_version, index|
	    	puts "Version: #{expected_version[:version]}"
    		results_version = results.select {|x| x[:version] == expected_version[:version]}
    		if results_version.length == 1
	    		expect(results_version[0][:children].length).to eq(expected_version[:children].length)   
	    		expected_version[:children].each do |key, expected_child|
			    	puts "CL: #{key}"
		    		results_child = results_version[0][:children][key]
				    expect(results_child).to eq(expected_child)
	    		end
	      else
	        expect(true).to eq(false)
	      end
    	end
    end

    def submission_status(results, version_date, code_list_item, previous, current)
      term = results[:children].select {|key, item| key == code_list_item}
      if term.length == 1
        index = date.index(version_date)
        item = term[code_list_item][:result][index]
        expect(item[:status]).to eq(:updated)
        expect(item[:previous]).to eq(previous)
        expect(item[:current]).to eq(current)
      else
        expect(true).to eq(false)
      end
    end

    def code_list_status(results, version_date, code_list, status)
      term = results.select {|r| r[:date] == version_date }
      if term.length == 1
        if term[0][:children][code_list].nil? && status == :not_present
          #puts "Nil entry, D=#{version_date}, CL=#{code_list}, S=#{status}" 
        else
          expect(term[0][:children][code_list][:status]).to eq(status)
        end
      else
        expect(true).to eq(false)
      end
    end

    def code_list_history(results, code_list, status)
      status_map = {:~ => :not_present, :- => :no_change, :C => :created, :U => :updated, :D => :deleted}
      status.each_with_index do |s, index|
        puts "D=#{date[index]}, CL=#{code_list}, S=#{s}, SM=#{status_map[s]}" 
        code_list_status(results, date[index], code_list, status_map[s])
      end
    end

    it "calculates the bulk changes results", :ct_bulk_test => true do
      file = CdiscCtChanges.dir_path + "CDISC_CT_Changes.yaml"
      File.delete(file) if File.exist?(file)
      get :changes_calc
      expect(response).to redirect_to("/backgrounds")
      results = CdiscCtChanges.read(CdiscCtChanges::C_ALL_CT)
    #write_yaml_file(results, sub_dir, "cdisc_terms_controller_bulk_all_changes.yaml")
      expected = read_yaml_file(sub_dir, "cdisc_terms_controller_bulk_all_changes.yaml")
      #expect(results).to eq(expected) # Old Method
      changes_comparison(results, expected) # New method
    end

    it "calculates the bulk submission change results", :ct_bulk_test => true do
      file = CdiscCtChanges.dir_path + "CDISC_CT_Submission_Changes.yaml"
      File.delete(file) if File.exist?(file)
      get :submission_calc
      expect(response).to redirect_to("/backgrounds")
      results = CdiscCtChanges.read(CdiscCtChanges::C_ALL_SUB)
    #write_yaml_file(results, sub_dir, "cdisc_terms_controller_bulk_submission_changes.yaml")
      expected = read_yaml_file(sub_dir, "cdisc_terms_controller_bulk_submission_changes.yaml")
      expect(results).to eq(expected)
    end

    it "allows comparison with CDISC reported changes", :ct_bulk_test => true do
      results = CdiscCtChanges.read(CdiscCtChanges::C_ALL_CT)
      # Created = :C, Update= :U, Deleted = :D, No change = :-, Not present = :~
      code_list_history(results, :C100143, [:C, :U, :-, :-, :-, :-, :-, :-, :U, :U, :-, :-, :-])
      code_list_history(results, :C100150, [:C, :U, :-, :-, :-, :-, :-, :-, :U, :U, :-, :-, :-])
      code_list_history(results, :C100151, [:C, :U, :-, :-, :-, :-, :-, :-, :U, :U, :-, :-, :-])
      code_list_history(results, :C100161, [:C, :U, :-, :-, :-, :-, :-, :-, :U, :U, :-, :-, :-])
      code_list_history(results, :C100169, [:C, :U, :-, :-, :-, :-, :-, :-, :U, :U, :-, :-, :-])
      code_list_history(results, :C101808, [:C, :U, :-, :-, :-, :-, :-, :-, :U, :U, :-, :-, :-])
      code_list_history(results, :C101832, [:C, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :D, :~])
      code_list_history(results, :C101849, [:C, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-])
      code_list_history(results, :C101860, [:C, :-, :-, :-, :U, :-, :-, :-, :-, :-, :-, :-, :-])
      code_list_history(results, :C101867, [:C, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-])
      code_list_history(results, :C102583, [:C, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-])
      code_list_history(results, :C103460, [:C, :U, :U, :-, :-, :-, :-, :U, :U, :U, :-, :-, :-])
      code_list_history(results, :C103472, [:C, :U, :-, :-, :-, :-, :-, :-, :U, :U, :-, :-, :-])
      code_list_history(results, :C105137, [:C, :U, :-, :-, :-, :-, :-, :-, :U, :U, :-, :-, :-])
      code_list_history(results, :C106480, [:C, :-, :-, :-, :U, :U, :U, :-, :-, :-, :-, :-, :-])
      code_list_history(results, :C106658, [:C, :U, :U, :-, :U, :-, :-, :U, :U, :U, :-, :-, :-])
      code_list_history(results, :C115406, [:~, :C, :-, :-, :-, :-, :-, :-, :U, :U, :-, :-, :-])
      code_list_history(results, :C120986, [:~, :~, :~, :~, :~, :C, :U, :-, :U, :U, :-, :-, :-])
      code_list_history(results, :C122006, [:~, :~, :~, :~, :~, :~, :C, :-, :U, :-, :-, :-, :-])
    end

    it "allows comparison with CDISC reported changes", :ct_bulk_test => true do
      results = CdiscCtChanges.read(CdiscCtChanges::C_ALL_SUB)

      # June 2014
      submission_status(results, "2014-06-27", :"C101859.C17998", "Unknown", "UNKNOWN")

      # December 2014
      submission_status(results, "2014-12-16", :"C101841.C100040", "GRADE 0", "TIMI GRADE 0")
      submission_status(results, "2014-12-16", :"C66737.C15600", "Phase I Trial", "PHASE I TRIAL")
      submission_status(results, "2014-12-16", :"C71620.C48500", "IN", "in")
      submission_status(results, "2014-12-16", :"C101840.C77271", "Killip CLASS III", "KILLIP CLASS III")

      # December 2015
      submission_status(results, "2015-12-18", :"C71620.C66965", "per sec", "/sec")
      submission_status(results, "2015-12-18", :"C71620.C66967", "per min", "/min")
      submission_status(results, "2015-12-18", :"C100129.C102121", "SF36 v2.0 ACUTE", "SF36 V2.0 ACUTE")
      submission_status(results, "2015-12-18", :"C100129.C100775", "SF36 v1.0 STANDARD", "SF36 V1.0 STANDARD")

      # December 2016
      submission_status(results, "2016-12-13", :"C128689.C43823", "BHUTANESE", "BARBADIAN")
      submission_status(results, "2016-12-13", :"C67154.C106514", "Cytokeratin Fragment 21-1", "Cytokeratin 19 Fragment 21-1")
      submission_status(results, "2016-12-13", :"C101847.C116146", "LATELOSS", "LLMLOSS")
      submission_status(results, "2016-12-13", :"C71620.C122230", "ugeq/L", "ugEq/L")
    end

  end

end