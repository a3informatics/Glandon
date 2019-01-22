require 'rails_helper'

describe CdiscTerm::Utility do

  include DataHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/cdisc_term"
  end

  def trim_initial
  	results = 
  		[
  			{version: 1, data: "Array Index 1"}, 
  			{version: 2, data: "Array Index 2"}, 
  			{version: 3, data: "Array Index 3"}, 
  			{version: 4, data: "Array Index 4"},
  			{version: 5, data: "Array Index 5"},
  			{version: 6, data: "Array Index 6"},
  			{version: 7, data: "Array Index 7"},
  			{version: 8, data: "Array Index 8"},
  			{version: 9, data: "Array Index 9"},
  			{version: 10, data: "Array Index 10"},
  			{version: 11, data: "Array Index 11"},
  			{version: 12, data: "Array Index 12"},
  			{version: 13, data: "Array Index 13"},
  			{version: 14, data: "Array Index 14"},
  			{version: 15, data: "Array Index 15"},
  			{version: 16, data: "Array Index 16"},
  			{version: 17, data: "Array Index 17"}
  		]
  	return results
  end

  def trim_submission_initial
  	results = {}
  	results[:versions] = 
  		[
  			{version: 1, version_label: "V1"}, 
  			{version: 2, version_label: "V2"}, 
  			{version: 3, version_label: "V3"}, 
  			{version: 4, version_label: "V4"}, 
  			{version: 5, version_label: "V5"}, 
  			{version: 6, version_label: "V6"}, 
  			{version: 7, version_label: "V7"}, 
  			{version: 8, version_label: "V8"}, 
  			{version: 9, version_label: "V9"}, 
  			{version: 10, version_label: "V10"}, 
  			{version: 11, version_label: "V11"}, 
  			{version: 12, version_label: "V12"}, 
  			{version: 13, version_label: "V13"}, 
  			{version: 14, version_label: "V14"}, 
  			{version: 15, version_label: "V15"}, 
  			{version: 16, version_label: "V16"}, 
  			{version: 17, version_label: "V17"} 
  		]
  	results[:children] = {}
  	results[:children][:item_1] = { label: "Item 1", result: Array.new(17) { |i| { status: :no_change, item_index: "#{i}" }}}
  	results[:children][:item_2] = { label: "Item 2", result: Array.new(17) { |i| { status: :no_change, item_index: "#{i}" }}}
  	results[:children][:item_3] = { label: "Item 3", result: Array.new(17) { |i| { status: :no_change, item_index: "#{i}" }}}
  	results[:children][:item_4] = { label: "Item 4", result: Array.new(17) { |i| { status: :no_change, item_index: "#{i}" }}}
  	results[:children][:item_5] = { label: "Item 5", result: Array.new(17) { |i| { status: :no_change, item_index: "#{i}" }}}
  	results[:children][:item_6] = { label: "Item 6", result: Array.new(17) { |i| { status: :no_change, item_index: "#{i}" }}}
  	results[:children][:item_7] = { label: "Item 7", result: Array.new(17) { |i| { status: :no_change, item_index: "#{i}" }}}
  	results[:children][:item_8] = { label: "Item 8", result: Array.new(17) { |i| { status: :no_change, item_index: "#{i}" }}}
  	results[:children][:item_9] = { label: "Item 9", result: Array.new(17) { |i| { status: :no_change, item_index: "#{i}" }}}
  	results[:children][:item_10] = { label: "Item 10", result: Array.new(17) { |i| { status: :no_change, item_index: "#{i}" }}}
  	# Now add in the changes
  	results[:children][:item_1][:result][0][:status] = :updated
  	results[:children][:item_2][:result][1][:status] = :updated
  	results[:children][:item_3][:result][2][:status] = :updated
  	results[:children][:item_4][:result][3][:status] = :updated
  	results[:children][:item_5][:result][4][:status] = :updated
  	results[:children][:item_6][:result][5][:status] = :updated
  	results[:children][:item_7][:result][6][:status] = :updated
  	results[:children][:item_8][:result][7][:status] = :updated
  	results[:children][:item_9][:result][8][:status] = :updated
  	results[:children][:item_10][:result][9][:status] = :updated
  	results[:children][:item_10][:result][10][:status] = :updated  	
  	results[:children][:item_10][:result][11][:status] = :updated  	
  	results[:children][:item_10][:result][12][:status] = :updated  	
  	results[:children][:item_10][:result][13][:status] = :updated  	
  	results[:children][:item_10][:result][14][:status] = :updated  	
  	results[:children][:item_10][:result][15][:status] = :updated  	
  	results[:children][:item_10][:result][16][:status] = :updated
  	return results
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
    load_schema_file_into_triple_store("CDISCTerm.ttl")
    load_test_file_into_triple_store("iso_namespace_real.ttl")
    load_test_file_into_triple_store("CT_V39.ttl")
    load_test_file_into_triple_store("CT_V40.ttl")
    load_test_file_into_triple_store("CT_V41.ttl")
    load_test_file_into_triple_store("CT_V42.ttl")
    load_test_file_into_triple_store("CT_V43.ttl")
  end

  it "allows CLIs to be compared, same" do
    previous = CdiscCli.find("CLI-C101812_C102054", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42")
    current = CdiscCli.find("CLI-C101812_C102054", "http://www.assero.co.uk/MDRThesaurus/CDISC/V43")
    ct = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V43")
    results = CdiscTerm::Utility.compare_cli(ct, previous, current)
  #Xwrite_yaml_file(results, sub_dir, "cli_compare_same.yaml")
    expected = read_yaml_file(sub_dir, "cli_compare_same.yaml")
    expect(results).to eq(expected)
  end

  it "allows CLIs to be compared, different" do
    previous = CdiscCli.find("CLI-C101812_C102054", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42")
    previous.notation = "CDR01-Home and Hobbies NEW NEW"
    current = CdiscCli.find("CLI-C101812_C102054", "http://www.assero.co.uk/MDRThesaurus/CDISC/V43")
    ct = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V43")
    results = CdiscTerm::Utility.compare_cli(ct, previous, current)
  #Xwrite_yaml_file(results, sub_dir, "cli_compare_diff.yaml")
    expected = read_yaml_file(sub_dir, "cli_compare_diff.yaml")
    expect(results).to eq(expected)
  end

  it "allows CLIs to be compared, no previous" do
    previous = nil
    current = CdiscCli.find("CLI-C101812_C102054", "http://www.assero.co.uk/MDRThesaurus/CDISC/V43")
    ct = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V43")
    results = CdiscTerm::Utility.compare_cli(ct, previous, current)
  #Xwrite_yaml_file(results, sub_dir, "cli_compare_no_previous.yaml")
    expected = read_yaml_file(sub_dir, "cli_compare_no_previous.yaml")
    expect(results).to eq(expected)
  end

  it "allows CLIs to be compared, no current" do
    previous = CdiscCli.find("CLI-C101812_C102054", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42")
    current = nil
    ct = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V43")
    results = CdiscTerm::Utility.compare_cli(ct, previous, current)
  #Xwrite_yaml_file(results, sub_dir, "cli_compare_no_current.yaml")
    expected = read_yaml_file(sub_dir, "cli_compare_no_current.yaml")
    expect(results).to eq(expected)
  end

  it "allows CLs to be compared, same" do
    previous = CdiscCl.find("CL-C101812", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42")
    current = CdiscCl.find("CL-C101812", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42") # Note same release to ensure they are the same
    ct = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V43")
    results = CdiscTerm::Utility.compare_cl(ct, previous, current)
  #Xwrite_yaml_file(results, sub_dir, "cl_compare_same.yaml")
    expected = read_yaml_file(sub_dir, "cl_compare_same.yaml")
    expect(results).to eq(expected)
  end
  
  it "allows CLs to be compared, different" do
    previous = CdiscCl.find("CL-C101812", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42")
    current = CdiscCl.find("CL-C101812", "http://www.assero.co.uk/MDRThesaurus/CDISC/V43")
    ct = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V43")
    results = CdiscTerm::Utility.compare_cl(ct, previous, current)
  #Xwrite_yaml_file(results, sub_dir, "cl_compare_different.yaml")
    expected = read_yaml_file(sub_dir, "cl_compare_different.yaml")
    expect(results).to eq(expected)
  end

  it "allows CLs to be compared, no previous" do
    previous = nil
    current = CdiscCl.find("CL-C101812", "http://www.assero.co.uk/MDRThesaurus/CDISC/V43")
    ct = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V43")
    results = CdiscTerm::Utility.compare_cl(ct, previous, current)
  #Xwrite_yaml_file(results, sub_dir, "cl_compare_no_previous.yaml")
    expected = read_yaml_file(sub_dir, "cl_compare_no_previous.yaml")
    expect(results).to eq(expected)
  end

  it "allows CLs to be compared, no current" do
    previous = CdiscCl.find("CL-C101812", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42")
    current = nil
    ct = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V43")
    results = CdiscTerm::Utility.compare_cl(ct, previous, current)
  #Xwrite_yaml_file(results, sub_dir, "cl_compare_no_current.yaml")
    expected = read_yaml_file(sub_dir, "cl_compare_no_current.yaml")
    expect(results).to eq(expected)
  end

  it "determines the CLI changes 1" do
    uri = UriV3.new(fragment: "CLI-C100129_C100775", namespace: "http://www.assero.co.uk/MDRThesaurus/CDISC/V42")
    results = CdiscTerm::Utility.cli_changes(uri)
  #Xwrite_yaml_file(results, sub_dir, "cli_changes_1.yaml")
    expected = read_yaml_file(sub_dir, "cli_changes_1.yaml")
    expect(results).to eq(expected)
  end

  it "determines the CLI changes 2" do
    uri = UriV3.new(fragment: "CLI-C120521_C120601", namespace: "http://www.assero.co.uk/MDRThesaurus/CDISC/V42")
    results = CdiscTerm::Utility.cli_changes(uri)
  #Xwrite_yaml_file(results, sub_dir, "cli_changes_2.yaml")
    expected = read_yaml_file(sub_dir, "cli_changes_2.yaml")
    expect(results).to eq(expected)
  end

  it "determines the CLI changes 3" do
    uri = UriV3.new(fragment: "CLI-C100145_C120601", namespace: "http://www.assero.co.uk/MDRThesaurus/CDISC/V43")
    results = CdiscTerm::Utility.cli_changes(uri)
  #Xwrite_yaml_file(results, sub_dir, "cli_changes_3.yaml")
    expected = read_yaml_file(sub_dir, "cli_changes_3.yaml")
    expect(results).to eq(expected)
  end

  it "determines the CLI changes 4" do
    uri = UriV3.new(fragment: "CLI-C122006_C94596", namespace: "http://www.assero.co.uk/MDRThesaurus/CDISC/V42")
    results = CdiscTerm::Utility.cli_changes(uri)
  #Xwrite_yaml_file(results, sub_dir, "cli_changes_4.yaml")
    expected = read_yaml_file(sub_dir, "cli_changes_4.yaml")
    expect(results).to eq(expected)
  end

  it "determines the CL changes 1" do
    uri = UriV3.new(fragment: "CL-C100129", namespace: "http://www.assero.co.uk/MDRThesaurus/CDISC/V42")
    results = CdiscTerm::Utility.cl_changes(uri)
  #Xwrite_yaml_file(results, sub_dir, "cl_changes_1.yaml")
    expected = read_yaml_file(sub_dir, "cl_changes_1.yaml")
    expect(results).to eq(expected)
  end

  it "determines the CL changes 2" do
    uri = UriV3.new(fragment: "CL-C120521", namespace: "http://www.assero.co.uk/MDRThesaurus/CDISC/V42")
    results = CdiscTerm::Utility.cl_changes(uri)
  #Xwrite_yaml_file(results, sub_dir, "cl_changes_2.yaml")
    expected = read_yaml_file(sub_dir, "cl_changes_2.yaml")
    expect(results).to eq(expected)
  end

  it "determines the CL changes 3" do
    uri = UriV3.new(fragment: "CL-C100145", namespace: "http://www.assero.co.uk/MDRThesaurus/CDISC/V39") # URI needs to exist
    results = CdiscTerm::Utility.cl_changes(uri)
  #Xwrite_yaml_file(results, sub_dir, "cl_changes_3.yaml")
    expected = read_yaml_file(sub_dir, "cl_changes_3.yaml")
    expect(results).to eq(expected)
  end

  it "determines the CL changes 4" do
    uri = UriV3.new(fragment: "CL-C122006", namespace: "http://www.assero.co.uk/MDRThesaurus/CDISC/V42")
    results = CdiscTerm::Utility.cl_changes(uri)
  #Xwrite_yaml_file(results, sub_dir, "cl_changes_4.yaml")
    expected = read_yaml_file(sub_dir, "cl_changes_4.yaml")
    expect(results).to eq(expected)
  end

  it "transposes the results" do
    uri = UriV3.new(fragment: "CL-C100129", namespace: "http://www.assero.co.uk/MDRThesaurus/CDISC/V42")
    changes = CdiscTerm::Utility.cl_changes(uri)
    results = CdiscTerm::Utility.transpose_results(changes[:results])
  #Xwrite_yaml_file(results, sub_dir, "cl_transpose.yaml")
    expected = read_yaml_file(sub_dir, "cl_transpose.yaml")
    expect(results).to eq(expected)
  end

  it "trims the result, 1" do
  	results = trim_initial
  	expected = trim_initial[3 .. 7]
  	results = CdiscTerm::Utility.trim_results(results, 4, 5)
    expect(results).to eq(expected)    	
  end

  it "trims the result, 2" do
  	results = trim_initial
  	expected = trim_initial
  	results = CdiscTerm::Utility.trim_results(results, 0, 5)
    expect(results).to eq(expected)    	
  end

  it "trims the result, 3" do
  	results = trim_initial
  	expected = trim_initial[14 .. 16]
  	results = CdiscTerm::Utility.trim_results(results, 15, 5)
    expect(results).to eq(expected)    	
  end

  it "trims the result, 4" do
  	results = trim_initial
  	expected = trim_initial[13 .. 16]
  	results = CdiscTerm::Utility.trim_results(results, nil, 4)
    expect(results).to eq(expected)    	
  end

  it "trims the submission result, 1" do
  	initial = trim_submission_initial
  	results = CdiscTerm::Utility.trim_submission_results(initial, 4, 5)
  #write_yaml_file(results, sub_dir, "submission_changes_1.yaml")
    expected = read_yaml_file(sub_dir, "submission_changes_1.yaml")
    expect(results).to eq(expected)    	
  end

  it "trims the submission result, 2" do
  	initial = trim_submission_initial
  	results = CdiscTerm::Utility.trim_submission_results(initial, 0, 5)
  #write_yaml_file(results, sub_dir, "submission_changes_2.yaml")
    expected = read_yaml_file(sub_dir, "submission_changes_2.yaml")
    expect(results).to eq(expected)    	
  end

  it "trims the submission result, 3" do
  	initial = trim_submission_initial
  	results = CdiscTerm::Utility.trim_submission_results(initial, 15, 5)
  #write_yaml_file(results, sub_dir, "submission_changes_3.yaml")
    expected = read_yaml_file(sub_dir, "submission_changes_3.yaml")
    expect(results).to eq(expected)    	
  end

  it "trims the submission result, 4" do
  	initial = trim_submission_initial
  	results = CdiscTerm::Utility.trim_submission_results(initial, nil, 4)
  #write_yaml_file(results, sub_dir, "submission_changes_4.yaml")
    expected = read_yaml_file(sub_dir, "submission_changes_4.yaml")
    expect(results).to eq(expected)    	
  end

  it "previous and next versions, 1" do
  	full = trim_initial
  	results = CdiscTerm::Utility.trim_results(full, 6, 4)
  	previous_version = CdiscTerm::Utility.previous_version(full, results.first[:version])
  	next_version = CdiscTerm::Utility.next_version(full, results.first[:version], 4, full.length)
    expect(previous_version).to eq(5)    	
    expect(next_version).to eq(7)    	
  end

  it "previous and next versions, 2" do
  	full = trim_initial
  	results = CdiscTerm::Utility.trim_results(full, 1, 4)
  	previous_version = CdiscTerm::Utility.previous_version(full, results.first[:version])
  	next_version = CdiscTerm::Utility.next_version(full, results.first[:version], 4, full.length)
    expect(previous_version).to eq(nil)    	
    expect(next_version).to eq(2)    	
  end

  it "previous and next versions, 3" do
  	full = trim_initial
  	results = CdiscTerm::Utility.trim_results(full, 14, 4)
  	previous_version = CdiscTerm::Utility.previous_version(full, results.first[:version])
  	next_version = CdiscTerm::Utility.next_version(full, results.first[:version], 4, full.length)
    expect(previous_version).to eq(13)    	
    expect(next_version).to eq(nil)    	
  end

  it "previous and next versions, 4" do
  	initial = trim_submission_initial
  	results = CdiscTerm::Utility.trim_submission_results(initial, 4, 5)
    previous_version = CdiscTerm::Utility.previous_version(initial[:versions], results[:versions].first[:version])
  	next_version = CdiscTerm::Utility.next_version(initial[:versions], results[:versions].first[:version], 4, initial[:versions].length)
    expect(previous_version).to eq(3)    	
    expect(next_version).to eq(5)    	
  end

end