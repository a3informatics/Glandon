require 'rails_helper'

describe CdiscTerm::Utility do

  include DataHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/cdisc_term"
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
    load_test_file_into_triple_store("CT_V41.ttl")
    load_test_file_into_triple_store("CT_V42.ttl")
    load_test_file_into_triple_store("CT_V43.ttl")
  end

  it "allows CLIs to be compared, same" do
    previous = CdiscCli.find("CLI-C101812_C102054", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42")
    current = CdiscCli.find("CLI-C101812_C102054", "http://www.assero.co.uk/MDRThesaurus/CDISC/V43")
    ct = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V43")
    results = CdiscTerm::Utility.compare_cli(ct, previous, current)
    #write_yaml_file(results, sub_dir, "cli_compare_same.yaml")
    expected = read_yaml_file(sub_dir, "cli_compare_same.yaml")
    expect(results).to eq(expected)
  end

  it "allows CLIs to be compared, different" do
    previous = CdiscCli.find("CLI-C101812_C102054", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42")
    previous.notation = "CDR01-Home and Hobbies NEW NEW"
    current = CdiscCli.find("CLI-C101812_C102054", "http://www.assero.co.uk/MDRThesaurus/CDISC/V43")
    ct = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V43")
    results = CdiscTerm::Utility.compare_cli(ct, previous, current)
    #write_yaml_file(results, sub_dir, "cli_compare_diff.yaml")
    expected = read_yaml_file(sub_dir, "cli_compare_diff.yaml")
    expect(results).to eq(expected)
  end

  it "allows CLIs to be compared, no previous" do
    previous = nil
    current = CdiscCli.find("CLI-C101812_C102054", "http://www.assero.co.uk/MDRThesaurus/CDISC/V43")
    ct = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V43")
    results = CdiscTerm::Utility.compare_cli(ct, previous, current)
    #write_yaml_file(results, sub_dir, "cli_compare_no_previous.yaml")
    expected = read_yaml_file(sub_dir, "cli_compare_no_previous.yaml")
    expect(results).to eq(expected)
  end

  it "allows CLIs to be compared, no current" do
    previous = CdiscCli.find("CLI-C101812_C102054", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42")
    current = nil
    ct = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V43")
    results = CdiscTerm::Utility.compare_cli(ct, previous, current)
    #write_yaml_file(results, sub_dir, "cli_compare_no_current.yaml")
    expected = read_yaml_file(sub_dir, "cli_compare_no_current.yaml")
    expect(results).to eq(expected)
  end

  it "allows CLs to be compared, same" do
    previous = CdiscCl.find("CL-C101812", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42")
    current = CdiscCl.find("CL-C101812", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42") # Note same release to ensure they are the same
    ct = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V43")
    results = CdiscTerm::Utility.compare_cl(ct, previous, current)
    #write_yaml_file(results, sub_dir, "cl_compare_same.yaml")
    expected = read_yaml_file(sub_dir, "cl_compare_same.yaml")
    expect(results).to eq(expected)
  end
  
  it "allows CLs to be compared, different" do
    previous = CdiscCl.find("CL-C101812", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42")
    current = CdiscCl.find("CL-C101812", "http://www.assero.co.uk/MDRThesaurus/CDISC/V43")
    ct = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V43")
    results = CdiscTerm::Utility.compare_cl(ct, previous, current)
    #write_yaml_file(results, sub_dir, "cl_compare_different.yaml")
    expected = read_yaml_file(sub_dir, "cl_compare_different.yaml")
    expect(results).to eq(expected)
  end

  it "allows CLs to be compared, no previous" do
    previous = nil
    current = CdiscCl.find("CL-C101812", "http://www.assero.co.uk/MDRThesaurus/CDISC/V43")
    ct = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V43")
    results = CdiscTerm::Utility.compare_cl(ct, previous, current)
    #write_yaml_file(results, sub_dir, "cl_compare_no_previous.yaml")
    expected = read_yaml_file(sub_dir, "cl_compare_no_previous.yaml")
    expect(results).to eq(expected)
  end

  it "allows CLs to be compared, no current" do
    previous = CdiscCl.find("CL-C101812", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42")
    current = nil
    ct = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V43")
    results = CdiscTerm::Utility.compare_cl(ct, previous, current)
    #write_yaml_file(results, sub_dir, "cl_compare_no_current.yaml")
    expected = read_yaml_file(sub_dir, "cl_compare_no_current.yaml")
    expect(results).to eq(expected)
  end

  it "determines the CLI changes" do
    results = CdiscTerm::Utility.cli_changes("CLI-C100129_C100775")
    #write_yaml_file(results, sub_dir, "cli_changes.yaml")
    expected = read_yaml_file(sub_dir, "cli_changes.yaml")
    expect(results).to eq(expected)
  end

  it "determines the CL changes" do
    results = CdiscTerm::Utility.cl_changes("CL-C100129")
    #write_yaml_file(results, sub_dir, "cl_changes.yaml")
    expected = read_yaml_file(sub_dir, "cl_changes.yaml")
    expect(results).to eq(expected)
  end

  it "transposes the results" do
    changes = CdiscTerm::Utility.cl_changes("CL-C100129")
    results = CdiscTerm::Utility.transpose_results(changes)
    #write_yaml_file(results, sub_dir, "cl_transpose.yaml")
    expected = read_yaml_file(sub_dir, "cl_transpose.yaml")
    expect(results).to eq(expected)
  end

end