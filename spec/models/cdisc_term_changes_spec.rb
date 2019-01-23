require 'rails_helper'

describe CdiscTerm do

  include DataHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/cdisc_term_changes"
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
    previous = CdiscCl.find_child(cl, cli, old_ct.namespace)
    current = CdiscCl.find_child(cl, cli, new_ct.namespace)
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

  it "compares V55 to V54" do
    old_version = 54
    new_version = 55
    load_term(old_version, new_version)

    # Compare versions
    results = compare_term(old_version, new_version)

    # Compare code lists
    check_cl_result(results, "C118971", :updated)
    check_cl_result(results, "C111111", :updated)
    check_cl_result(results, "C111112", :updated)
    check_cl_result(results, "C99079", :updated)
    check_cl_result(results, "C150780", :updated)
    check_cl_result(results, "C128681", :updated)
    check_cl_result(results, "C65047", :updated)
    check_cl_result(results, "C74456", :updated)
    check_cl_result(results, "C132263", :updated)
    check_cl_result(results, "C74457", :updated)

    # Compare code list items
    check_cli_result(old_version, new_version, "C66741", "C156606", created: true)
    check_cli_result(old_version, new_version, "C67154", "C41255", created: true)
    check_cli_result(old_version, new_version, "C67152", "C156604", created: true)
    check_cli_result(old_version, new_version, "C96778", "C147488", updated: [:Definition])
    check_cli_result(old_version, new_version, "C124298", "C126036", updated: [:Synonym])
    check_cli_result(old_version, new_version, "C127269", "C154909", updated: [:Synonym])
    check_cli_result(old_version, new_version, "C76348", "C51777", updated: [:"Preferred Term"])
    check_cli_result(old_version, new_version, "C74456", "C12810", created: true)
    check_cli_result(old_version, new_version, "C65047", "C156535", created: true)
    check_cli_result(old_version, new_version, "C65047", "C156515", created: true)
    check_cli_result(old_version, new_version, "C67154", "C156535", created: true)
    check_cli_result(old_version, new_version, "C67154", "C156515", created: true)
    check_cli_result(old_version, new_version, "C67154", "C81958", updated: [:Synonym, :Notation])

  end
    
end