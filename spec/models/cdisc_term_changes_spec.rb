require 'rails_helper'

describe CdiscTerm do

  include DataHelpers
  include PublicFileHelpers

  def sub_dir
    return "models"
  end

  def check_term_differences(results, expected)
    expect(results[:status]).to eq(expected[:status])
    expect(results[:result]).to eq(expected[:result])
    expect(results[:children].count).to eq(expected[:children].count)
    results[:children].each do |key, result|
      found = expected[:children][key]
      expect(result).to eq(found)
    end
  end

  def load_term(old_version, new_version)
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
    load_test_file_into_triple_store("CT_V#{old_version}.ttl")
    load_test_file_into_triple_store("CT_V#{new_version}.ttl")
  end

  def find_term(version)
  	CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V#{version}")
  end

  def compare_term(old_version, new_version)
    old_ct = find_term(old_version)
    new_ct = find_term(new_version)
    result = CdiscTerm.compare(old_ct, new_ct)
  	results = CdiscCtChanges.read(CdiscCtChanges::C_TWO_CT, {old_version: old_version, new_version: new_version})
  	return results
	end

	def check_cl_result(results, cl, status)
  	expect(results[1][:children][cl.to_sym][:status]).to eq(status)
  end

  def check_cli_result(old_version, new_version, cl, cli, *args)
		created = args[0][:created].blank? ? false : args[0][:created]
  	deleted = args[0][:deleted].blank? ? false : args[0][:deleted]
  	updated = args[0][:updated].blank? ? [] : args[0][:updated]
    old_ct = find_term(old_version)
    new_ct = find_term(new_version)
    id = "CLI-#{cl}_#{cli}"
    previous = CdiscCli.find(id, old_ct.namespace)
    current = CdiscCli.find(id, new_ct.namespace)
		base = [:Definition, :"Preferred Term", :Notation, :Synonym, :Identifier]
	  no_change = base - updated
    result = CdiscTerm::Utility.compare_cli(new_ct, previous, current)
  	if created
  		base.each { |f| expect(result[:results][f][:status]).to eq(:created) }
  	elsif deleted
  		base.each { |f| expect(result[:results][f][:status]).to eq(:deleted) }
  	else
  		no_change.each { |f| expect(result[:results][f][:status]).to eq(:no_change) }
  		updated.each { |f| expect(result[:results][f][:status]).to eq(:updated) }
  	end
  end

  it "compares V49 to V48" do
  	old_version = 48
  	new_version = 49
  	load_term(old_version, new_version)
  	# Compare code lists
  	results = compare_term(old_version, new_version)
  	check_cl_result(results, "C127265", :no_change)
  	check_cl_result(results, "C132262", :updated)
  	check_cl_result(results, "C66738", :updated)
  	# Compare code list items
  	check_cli_result(old_version, new_version, "C100129", "C100763", updated: [:"Preferred Term", :Notation, :Synonym])
  	check_cli_result(old_version, new_version, "C100129", "C119093", updated: [:Definition])
  	check_cli_result(old_version, new_version, "C101846", "C99524", updated: [:Definition])
  	check_cli_result(old_version, new_version, "C101846", "C127576", updated: [:Definition])
  end

  it "compares V50 to V49" do
  	old_version = 49
  	new_version = 50
  	load_term(old_version, new_version)
  	# Compare code lists
  	results = compare_term(old_version, new_version)
  	check_cl_result(results, "C101846", :updated)
  	check_cl_result(results, "C101847", :updated)
  	check_cl_result(results, "C138221", :created)
  	check_cl_result(results, "C138225", :created)
  	check_cl_result(results, "C67154", :updated)
  	check_cl_result(results, "C65047", :updated) 
  	check_cl_result(results, "C74456", :updated)
  	check_cl_result(results, "C120528", :updated)
  	check_cl_result(results, "C101848", :updated)
  	check_cl_result(results, "C96782", :updated)
  	# Compare code list items
  	check_cli_result(old_version, new_version, "C101846", "C127573", updated: [:Definition])
  	check_cli_result(old_version, new_version, "C101847", "C127575", updated: [:Definition])
  	check_cli_result(old_version, new_version, "C101847", "C139051", created: true)
  	check_cli_result(old_version, new_version, "C138221", "C138436", created: true)
  	check_cli_result(old_version, new_version, "C138225", "C138462", created: true)
  	check_cli_result(old_version, new_version, "C67154", "C139090", created: true)
  	check_cli_result(old_version, new_version, "C65047", "C64606", updated: [:Definition, :Synonym])
  	check_cli_result(old_version, new_version, "C65047", "C114218", deleted: true)
  	check_cli_result(old_version, new_version, "C74456", "C12774", updated: [:Notation])
  	check_cli_result(old_version, new_version, "C120528", "C128982", updated: [:Notation, :Definition, :Synonym])
	end

  it "compares V50 to V49" do
    old_version = 49
    new_version = 50
    load_term(old_version, new_version)
    # Compare code lists
    results = compare_term(old_version, new_version)
    check_cl_result(results, "C101846", :updated)
    check_cl_result(results, "C101847", :updated)
    check_cl_result(results, "C138221", :created)
    check_cl_result(results, "C138225", :created)
    check_cl_result(results, "C67154", :updated)
    check_cl_result(results, "C65047", :updated) 
    check_cl_result(results, "C74456", :updated)
    check_cl_result(results, "C120528", :updated)
    check_cl_result(results, "C101848", :updated)
    check_cl_result(results, "C96782", :updated)
    # Compare code list items
    check_cli_result(old_version, new_version, "C101846", "C127573", updated: [:Definition])
    check_cli_result(old_version, new_version, "C101847", "C127575", updated: [:Definition])
    check_cli_result(old_version, new_version, "C101847", "C139051", created: true)
    check_cli_result(old_version, new_version, "C138221", "C138436", created: true)
    check_cli_result(old_version, new_version, "C138225", "C138462", created: true)
    check_cli_result(old_version, new_version, "C67154", "C139090", created: true)
    check_cli_result(old_version, new_version, "C65047", "C64606", updated: [:Definition, :Synonym])
    check_cli_result(old_version, new_version, "C65047", "C114218", deleted: true)
    check_cli_result(old_version, new_version, "C74456", "C12774", updated: [:Notation])
    check_cli_result(old_version, new_version, "C120528", "C128982", updated: [:Notation, :Definition, :Synonym])
  end

  it "compares V55 to V54" do
    v1 = 53
    v2 = 54
    v3 = 55
    load_term(v1, v2)
    load_test_file_into_triple_store("CT_V#{v3}.ttl")

    v1_cl = CdiscCl.find("CL-C74457", "http://www.assero.co.uk/MDRThesaurus/CDISC/V53")
    v2_cl = CdiscCl.find("CL-C74457", "http://www.assero.co.uk/MDRThesaurus/CDISC/V54")
    v3_cl = CdiscCl.find("TH-CDISC_CDISCTerminology_C74457", "http://www.assero.co.uk/MDRThesaurus/CDISC/V55")
    result = CdiscCl.difference(v1_cl, v2_cl)
byebug
    result = CdiscCl.difference(v2_cl, v3_cl)
byebug

    # Compare code lists
    results = compare_term(old_version, new_version)
    check_cl_result(results, "C65047", :updated)
    check_cl_result(results, "C67154", :updated)

    # Compare code list items
    check_cli_result(old_version, new_version, "C65047", "C81958", updated: [:Notation])
    check_cli_result(old_version, new_version, "C67154", "C81958", updated: [:Notation])
  end
    
end