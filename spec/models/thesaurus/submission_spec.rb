require 'rails_helper'

describe Thesaurus do

  include DataHelpers
  include PublicFileHelpers
  include SparqlHelpers

  def sub_dir
    return "models/thesaurus/changes"
  end

  before :all do
    schema_files = 
    [
      "ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", 
      "ISO11179Concepts.ttl", "BusinessOperational.ttl", "thesaurus.ttl"
    ]
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
    load_versions((1..59))
    @status_map = {:~ => :not_present, :- => :no_change, :C => :created, :U => :updated, :D => :deleted}
  end

  after :all do
    delete_all_public_test_files
  end

  def load_version(version)
    load_data_file_into_triple_store("cdisc/ct/CT_V#{version}.ttl")
  end

  def load_versions(range)
    range.each {|n| load_version(n)}
  end

  # def cli(version, name)
  #   return CdiscCli.find("CLI-#{name}", "http://www.assero.co.uk/MDRThesaurus/CDISC/V#{version}")
  # rescue => e
  #   return nil
  # end

  # def cli_difference(checks)
  #   item_difference(checks) { |version, name| cli(version, name) }
  # end

  #   def changes_comparison(results, expected)
  #   	puts "All Changes"
  #   	expect(results.length).to eq(expected.length)
  #   	expected.each_with_index do |expected_version, index|
	 #    	puts "Version: #{expected_version[:version]}"
  #   		results_version = results.select {|x| x[:version] == expected_version[:version]}
  #   		if results_version.length == 1
	 #    		expect(results_version[0][:children].length).to eq(expected_version[:children].length)   
	 #    		expected_version[:children].each do |key, expected_child|
		# 	    	puts "CL: #{key}"
		#     		results_child = results_version[0][:children][key]
		# 		    expect(results_child).to eq(expected_child)
	 #    		end
	 #      else
	 #        expect(true).to eq(false)
	 #      end
  #   	end
  #   end

  #   def submission_comparison(results, expected)
  #   	puts "Submission Changes"
  #   	expect(results[:children].length).to eq(expected[:children].length)
	 #    expected[:children].each do |key, expected_child|
  #   		puts "CLI: #{key}"
		#     results_child = results[:children][key]
  #   		expect(results_child).to eq(expected_child)
  #   	end
  #   end

  #   def submission_status(results, version_date, code_list_item, previous, current)
  #     term = results[:children].select {|key, item| key == code_list_item}
  #     if term.length == 1
  #       index = date.index(version_date)
  #       item = term[code_list_item][:result][index]
  #       expect(item[:status],.to eq(:updated)
  #       expect(item[:previous],.to eq(previous)
  #       expect(item[:current],.to eq(current)
  #     else
  #       expect(true).to eq(false)
  #     end
  #   end

  def code_list_status(results, expected)
  end

  def check_changes(actual, expected, base_version)
    result = true
    expected.each do |cl, expect|
      actual[:items][cl][:status].each_with_index do |s, index|
        correct = @status_map[expect[index]] == s[:status]
        puts colourize("Mismatch for #{cl}, version: #{base_version+index} found ':#{s[:status]}', expected ':#{@status_map[expect[index]]}'", "red") if !correct
        result = result && correct
      end
    end
    expect(result).to be(true)
  end

  it "submission changes" do
    expected = 
    {
      #        Created = :C, Update= :U, Deleted = :D, No change = :-, Not present = :~
      #        [ 2007             | 2008                          | 2009              | 2010              | 2011              | 2012          | 2013          | 2014              | 2015          | 2016          | 2017          | 2018          | 2019  ]
      #        [ 1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59]
      C66787:  [:~, :C, :-, :U, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :U, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :U, :-, :-, :-, :-, :-, :-, :-, :-, :-, :D],
      C67152:  [:~, :C, :-, :U, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :U, :-, :U, :U, :-, :-, :U, :-, :-, :U, :-, :U, :U, :U, :-, :-, :U, :U, :-, :U, :U, :U, :U, :U, :U, :U, :U, :U, :U, :U, :U, :U, :U, :U, :-, :U, :U, :U, :U, :U, :U, :U, :U, :U], # TSPARM 
      C71620:  [:~, :~, :~, :~, :~, :C, :-, :-, :U, :-, :U, :-, :-, :U, :U, :U, :U, :U, :U, :U, :-, :-, :-, :-, :-, :U, :U, :U, :U, :U, :U, :U, :U, :U, :U, :U, :U, :U, :U, :-, :U, :U, :U, :U, :U, :U, :U, :U, :U, :U, :U, :U, :U, :U, :U, :U, :U, :U, :U], # UNIT
      C78417:  [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :-, :-, :-, :-, :-, :-, :-, :U, :U, :-, :-, :-, :-, :-, :-, :U, :-, :U, :-, :U, :-, :-, :-, :-, :-, :-, :U, :-, :U, :U, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-], #
      C100142: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :-, :-, :U, :D, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :-, :-, :-, :U, :-, :-, :-, :-],
      C100143: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :-, :-, :U, :-, :-, :-, :U, :-, :U, :-, :-, :-, :-, :-, :-, :U, :U, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-], # NPI1TN <<< Check
      C100150: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :-, :-, :-, :-, :-, :-, :-, :-, :U, :-, :-, :-, :-, :-, :-, :U, :U, :-, :-, :-, :-, :D, :~, :~, :~, :~, :~, :~, :~, :~], # CGI01TC <<< Check
      C100151: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :-, :-, :-, :-, :-, :-, :-, :-, :U, :-, :-, :-, :-, :-, :-, :U, :U, :-, :-, :-, :-, :D, :~, :~, :~, :~, :~, :~, :~, :~], # MNSI1TN
      C100161: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :-, :-, :-, :-, :-, :-, :-, :-, :U, :-, :-, :-, :-, :-, :-, :U, :U, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-],
      C100169: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :-, :-, :-, :-, :-, :-, :-, :-, :U, :-, :-, :-, :-, :-, :-, :U, :U, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-],
      C101808: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :U, :-, :-, :-, :-, :U, :-, :U, :-, :-, :-, :-, :-, :-, :U, :U, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-],
      C101832: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :-, :U, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :D, :~, :~, :~, :~, :~, :-, :-, :-, :-, :-, :-],
      C101848: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :-, :U, :-, :-, :U, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :U, :-, :-, :U, :-, :-, :-, :-],
      C101849: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :-, :U, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-],
      C101860: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :-, :U, :-, :-, :-, :-, :-, :-, :-, :-, :U, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-],
      C101867: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :-, :U, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-],
      C102583: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :U, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-],
      C103460: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :U, :-, :U, :-, :-, :U, :U, :-, :-, :-, :-, :U, :U, :U, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-],
      C103472: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :-, :-, :-, :-, :-, :U, :-, :-, :-, :-, :-, :-, :U, :U, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-],
      C105137: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :-, :-, :-, :-, :U, :-, :-, :-, :-, :-, :-, :U, :U, :-, :-, :-, :U, :-, :-, :-, :-, :-, :-, :-, :-, :-],
      C106480: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :U, :U, :-, :-, :-, :-, :U, :U, :U, :-, :-, :-, :-, :-, :-, :U, :-, :-, :-, :-, :-, :-, :-, :-, :-],
      C106658: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :U, :-, :-, :U, :U, :-, :U, :-, :-, :U, :U, :U, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-],
      C115406: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :-, :-, :-, :-, :-, :-, :U, :U, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-],
      C117991: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :-, :-, :-, :-, :-, :U, :U, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-],
      C120522: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :U, :-, :-, :-, :-, :-, :-, :-, :U, :-, :U, :-, :-, :-, :-, :-, :U], # HESTRESC
      C120986: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :U, :-, :U, :U, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-],
      C122006: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :-, :U, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-],
      C141655: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :-, :-, :-, :-, :-, :-],
      C141660: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :U, :-, :-, :-, :-, :-],
      C141669: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :-, :-, :-, :-, :-, :-],
      C141671: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :-, :-, :-, :-, :-, :-],
      C142187: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :-, :U, :-, :-, :-, :-]
    }
    ct = CdiscTerm.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"))
    actual = ct.submission(59)
  byebug
    check_submisision(actual, expected, 1)
  end

  #   it "allows comparison with CDISC reported changes", :ct_bulk_test => true do
  #     results = CdiscCtChanges.read(CdiscCtChanges::C_ALL_CT)
  #   end

  #   it "allows comparison with CDISC reported changes", :ct_bulk_test => true do
  #     results = CdiscCtChanges.read(CdiscCtChanges::C_ALL_SUB)

  #     # June 2014
  #     submission_status(results, "2014-06-27", :"C101859.C17998", "Unknown", "UNKNOWN")

  #     # December 2014
  #     submission_status(results, "2014-12-16", :"C101841.C100040", "GRADE 0", "TIMI GRADE 0")
  #     submission_status(results, "2014-12-16", :"C66737.C15600", "Phase I Trial", "PHASE I TRIAL")
  #     submission_status(results, "2014-12-16", :"C71620.C48500", "IN", "in")
  #     submission_status(results, "2014-12-16", :"C101840.C77271", "Killip CLASS III", "KILLIP CLASS III")

  #     # December 2015
  #     submission_status(results, "2015-12-18", :"C71620.C66965", "per sec", "/sec")
  #     submission_status(results, "2015-12-18", :"C71620.C66967", "per min", "/min")
  #     submission_status(results, "2015-12-18", :"C100129.C102121", "SF36 v2.0 ACUTE", "SF36 V2.0 ACUTE")
  #     submission_status(results, "2015-12-18", :"C100129.C100775", "SF36 v1.0 STANDARD", "SF36 V1.0 STANDARD")

  #     # December 2016
  #     submission_status(results, "2016-12-13", :"C128689.C43823", "BHUTANESE", "BARBADIAN")
  #     submission_status(results, "2016-12-13", :"C67154.C106514", "Cytokeratin Fragment 21-1", "Cytokeratin 19 Fragment 21-1")
  #     submission_status(results, "2016-12-13", :"C101847.C116146", "LATELOSS", "LLMLOSS")
  #     submission_status(results, "2016-12-13", :"C71620.C122230", "ugeq/L", "ugEq/L")

  #     # March 2017
  #     submission_status(results, "2017-03-31", :"C65047.C116210", "PRA", "PRAB")
  #     submission_status(results, "2017-03-31", :"C106650.C106926", "ADL03-Select items Without Help", "ADL03-Select Items Without Help")
  #     submission_status(results, "2017-03-31", :"C100153.C101013", "FPSR1-How Much do you Hurt", "FPSR1-How Much Do You Hurt")
  #     submission_status(results, "2017-03-31", :"C112450.C112688", "SGRQ02-If You Have Ever Held a job", "SGRQ02-If You Have Ever Held a Job")

  #     # June 2017
  #     submission_status(results, "2017-06-30", :"C85491.C112031", "FILOVIRUS", "FILOVIRIDAE")
  #     submission_status(results, "2017-06-30", :"C100129.C100763", "CGI", "CGI GUY")
  #     submission_status(results, "2017-06-30", :"C124298.C125992", "BRUGGERMAN MRD 2010", "BRUGGEMANN MRD 2010")
  #     submission_status(results, "2017-06-30", :"C124298.C126013", "HARTMANN PANCREATIC CANCER 2012", "HARTMAN PANCREATIC CANCER 2012")

  #     # September 2017
  #     submission_status(results, "2017-09-29", :"C74456.C12774", "ARTERY, PULMONARY", "PULMONARY ARTERY BRANCH")
  #     submission_status(results, "2017-09-29", :"C120528.C128982", "Mycobacterium Tuberculosis", "Mycobacterium tuberculosis")

  #     # December 2017
  #     submission_status(results, "2017-12-22", :"C120528.C128983", "Mycobacterium Tuberculosis Complex", "Mycobacterium tuberculosis Complex")
  #   end

  #   it "allows for change details to be reported" do
  #     checks = 
  #     [ 
  #       { name: "C66734_C95101", 
  #         result: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :D, :~, :~, :~, :C, :-, :-, :-, :-, :-, :-, :C, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :U], 
  #         properties: [ []: []: []: []: []: []: []: []: []: []: []: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :D, :~, :~, :~, :C, :-, :-, :-, :-, :-, :-, :Definition, :Synonym] ] 
  #       },
  #       { name: "C71150_C62256", 
  #         result: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :D, :~, :~, :~, :C, :-, :-, :-, :-, :-, :-, :C, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :U], 
  #         properties: [[]: []: []: []: []: []: []: []: []: []: []: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :D, :~, :~, :~, :C, :-, :-, :-, :-, :-, :-, :Definition, :Synonym]] 
  #       },
  #       { name: "C120522_C102652", 
  #         result: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :D, :~, :~, :~, :C, :-, :-, :-, :-, :-, :-, :C, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :U], 
  #         properties: [[]: []: []: []: []: []: []: []: []: []: []: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :D, :~, :~, :~, :C, :-, :-, :-, :-, :-, :-, :Definition, :Synonym]] 
  #       },
  #       { name: "C120522_C62259", 
  #         result: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :D, :~, :~, :~, :C, :-, :-, :-, :-, :-, :-, :C, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :U], 
  #         properties: [[]: []: []: []: []: []: []: []: []: []: []: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :D, :~, :~, :~, :C, :-, :-, :-, :-, :-, :-, :Definition, :Synonym]] 
  #       },
  #       { name: "C74456_C102334", 
  #         result: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :D, :~, :~, :~, :C, :-, :-, :-, :-, :-, :-, :C, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :U], 
  #         properties: [[]: []: []: []: []: []: []: []: []: []: []: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :D, :~, :~, :~, :C, :-, :-, :-, :-, :-, :-, :Definition]] 
  #       },
  #       { name: "C120528_C128983", 
  #         result: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :D, :~, :~, :~, :C, :-, :-, :-, :-, :-, :-, :~, :~, :~, :~, :~, :~, :~, :~, :C, :U, :-, :-, :-, :U], 
  #         properties: [[]: []: []: []: []: []: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :D, :~, :~, :~, :C, :-, :-, :-, :-, :-, :-, :Notation, :Definition, :"Preferred Term", :Identifier, :Synonym]: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :D, :~, :~, :~, :C, :-, :-, :-, :-, :-, :-, :Synonym], 
  #           []: []: []: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :D, :~, :~, :~, :C, :-, :-, :-, :-, :-, :-, :Notation, :"Preferred Term", :Synonym]] 
  #       },
  #       { name: "C71620_C48491", 
  #         result: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :D, :~, :~, :~, :C, :-, :-, :-, :-, :-, :-, :~, :C, :-, :-, :-, :-, :-, :-, :-, :-, :-, :U], 
  #         properties: [[], all_properties: []: []: []: []: []: []: []: []: []: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :D, :~, :~, :~, :C, :-, :-, :-, :-, :-, :-, :Synonym]] 
  #       }
  #     ]
  #     cli_difference(checks)      
  #   end

  # end

end