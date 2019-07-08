require 'rails_helper'

describe CdiscTerm do

  include DataHelpers
  include PublicFileHelpers
  include SparqlHelpers

  def sub_dir
    return "models/import/cdisc_term"
  end

  def setup
    #@object = Import::CdiscTerm.new
    @object = Import.new(:type => "Import::CdiscTerm") # Use this rather than above.
    @job = Background.new
    @job.save
    @object.background_id = @job.id
    @object.save
  end

  before :each do
    schema_files = 
    [
      "ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", 
      "ISO11179Concepts.ttl", "BusinessOperational.ttl", "thesaurus.ttl"
    ]
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
    setup
  end

  after :each do
    Import.destroy_all
    delete_all_public_test_files
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

  def load_version(version)
    load_local_file_into_triple_store(sub_dir, "CT_V#{version}.ttl")
  end

  def set_params(version, date, files)
    { version: "#{version}", date: "#{date}", files: files, version_label: "#{date} Release", label: "Controlled Terminology", semantic_version: "#{version}.0.0", job: @job}
  end

	def check_cl_result(results, cl, status)
  	puts "***** Error checking CL Result: #{cl} for expected result #{status} *****" if results[:items][cl.to_sym][:status][0][:status] != status
    expect(results[:items][cl.to_sym][:status][0][:status]).to eq(status)
  end

  # def check_cli_result(old_version, new_version, cl, cli, *args)
		# created = args[0][:created].blank? ? false : args[0][:created]
  # 	deleted = args[0][:deleted].blank? ? false : args[0][:deleted]
  # 	updated = args[0][:updated].blank? ? [] : args[0][:updated]
  #   old_ct = find_term(old_version)
  #   new_ct = find_term(new_version)
  #   previous = CdiscCl.find_child(cl, cli, old_ct.namespace)
  #   current = CdiscCl.find_child(cl, cli, new_ct.namespace)
		# base = [:Definition, :"Preferred Term", :Notation, :Synonym, :Identifier]
	 #  no_change = base - updated
  #   result = CdiscTerm::Utility.compare_cli(new_ct, previous, current)
  # 	if created
  # 		base.each { |f| expect(result[:results][f][:status]).to eq(:created) }
  # 	elsif deleted
  # 		base.each { |f| expect(result[:results][f][:status]).to eq(:deleted) }
  # 	else
  # 		no_change.each { |f| expect(result[:results][f][:status]).to eq(:no_change) }
  # 		updated.each { |f| expect(result[:results][f][:status]).to eq(:updated) }
  # 	end
  # end

  def process_term(version, date, files, copy_file=false)
    params = set_params(version, date, files)
    result = @object.import(params)
    filename = "cdisc_term_#{@object.id}_errors.yml"
    expect(public_file_does_not_exist?("test", filename)).to eq(true)
    filename = "cdisc_term_#{@object.id}_load.ttl"
    expect(public_file_exists?("test", filename)).to eq(true)
    copy_file_from_public_files("test", filename, sub_dir)
    if copy_file
      puts "***** Warning! Copying result file. *****"
      copy_file_from_public_files_rename("test", filename, sub_dir, "CT_V#{version}.ttl") 
    end
    check_ttl_fix(filename, "CT_V#{version}.ttl", {last_change_date: true})
    expect(@job.status).to eq("Complete")
    delete_data_file(sub_dir, filename)
  end

  def check_cl_results(results, expected)
    expected.each {|e| check_cl_result(results, e[:cl], e[:status])}
  end

  def load_versions(range)
    range.each {|n| load_version(n)}
  end

  def process_load_and_compare(filenames, date, version, create_file=false)
    files = []
    filenames.each_with_index {|f, index| files << db_load_file_path("cdisc/ct/sdtm", filenames[index])}
    process_term(version, date, files, create_file)
    load_version(version)
    th = CdiscTerm.find(Uri.new(uri: "http://www.cdisc.org/CT/V#{version}#TH"))
    results = th.changes(2)
  end

  it "Base create, version 1 SDTM - 2007" do
    current_version = 1
    results = process_load_and_compare(["SDTM Terminology 2007-03-06.xlsx"], "2007-03-06", current_version, true)
    expected = [
      {cl: :C16564, status: :created},
      {cl: :C20587, status: :created},
      {cl: :C49627, status: :created},
      {cl: :C49660, status: :created},
      {cl: :C49499, status: :created}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 2 SDTM - 2007" do
    current_version = 2
    load_versions(1..(current_version-1))
    results = process_load_and_compare(["SDTM Terminology 2007-04-20.xlsx"], "2007-04-20", current_version, true)
    expected = [
      {cl: :C16564, status: :deleted},
      {cl: :C20587, status: :deleted},
      {cl: :C49627, status: :deleted},
      {cl: :C49660, status: :deleted},
      {cl: :C49499, status: :deleted},
      {cl: :C66787, status: :created},
      {cl: :C66790, status: :created},
      {cl: :C67153, status: :created},
      {cl: :C66737, status: :created}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 3 SDTM - 2007" do
    current_version = 3
    load_versions(1..(current_version-1))
    results = process_load_and_compare(["SDTM Terminology 2007-04-26.xlsx"], "2007-04-26", current_version, true)
    expected = [
      {cl: :C66785, status: :created},
      {cl: :C66787, status: :no_change},
      {cl: :C66790, status: :no_change},
      {cl: :C67153, status: :no_change},
      {cl: :C66737, status: :updated}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 4 SDTM - 2007" do
    current_version = 4
    load_versions(1..(current_version-1))
    results = process_load_and_compare(["SDTM Terminology 2007-05-31.xlsx"], "2007-05-31", current_version, true)
    expected = [
      {cl: :C66785, status: :updated},
      {cl: :C66787, status: :updated},
      {cl: :C66790, status: :updated},
      {cl: :C67153, status: :updated},
      {cl: :C66737, status: :updated},
      {cl: :C67152, status: :updated}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 5 SDTM - 2007" do
    current_version = 5
    load_versions(1..(current_version-1))
    results = process_load_and_compare(["SDTM Terminology 2007-06-05.xlsx"], "2007-06-05", current_version, true)
    expected = [
      {cl: :C66737, status: :no_change},
      {cl: :C66738, status: :updated},
      {cl: :C66785, status: :no_change},
      {cl: :C66787, status: :no_change},
      {cl: :C66790, status: :no_change},
      {cl: :C67152, status: :no_change},
      {cl: :C67153, status: :no_change}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 6 SDTM - 2008" do
    current_version = 6
    load_versions(1..(current_version-1))
    results = process_load_and_compare(["SDTM Terminology 2008-01-15.xlsx"], "2008-01-15", current_version, true)
    expected = [
      {cl: :C66737, status: :no_change},
      {cl: :C66738, status: :no_change},
      {cl: :C66785, status: :no_change},
      {cl: :C66787, status: :no_change},
      {cl: :C66790, status: :no_change},
      {cl: :C67152, status: :no_change},
      {cl: :C67153, status: :no_change},
      {cl: :C71153, status: :created},
      {cl: :C71620, status: :created}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 7 SDTM - 2008" do
    current_version = 7
    load_versions(1..(current_version-1))
    results = process_load_and_compare(["SDTM Terminology 2008-01-25.xlsx"], "2008-01-25", current_version, true)
    expected = [
      {cl: :C66737, status: :no_change},
      {cl: :C66738, status: :no_change},
      {cl: :C66785, status: :no_change},
      {cl: :C66787, status: :no_change},
      {cl: :C66790, status: :no_change},
      {cl: :C67152, status: :no_change},
      {cl: :C67153, status: :no_change},
      {cl: :C71153, status: :no_change},
      {cl: :C71620, status: :no_change}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 8 SDTM - 2008" do
    current_version = 8
    load_versions(1..(current_version-1))
    results = process_load_and_compare(["SDTM Terminology 2008-08-26.xlsx"], "2008-08-26", current_version, true)
    expected = [
      {cl: :C66737, status: :updated},
      {cl: :C66738, status: :no_change},
      {cl: :C66785, status: :no_change},
      {cl: :C66787, status: :no_change},
      {cl: :C66790, status: :no_change},
      {cl: :C67152, status: :no_change},
      {cl: :C67153, status: :no_change},
      {cl: :C71153, status: :updated},
      {cl: :C71620, status: :no_change},
      {cl: :C74559, status: :created}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 9 SDTM - 2008" do
    current_version = 9
    load_versions(1..(current_version-1))
    results = process_load_and_compare(["SDTM Terminology 2008-09-22.xlsx"], "2008-09-22", current_version, true)
    expected = [
      {cl: :C66737, status: :updated},
      {cl: :C66738, status: :no_change},
      {cl: :C66785, status: :no_change},
      {cl: :C66787, status: :no_change},
      {cl: :C66790, status: :no_change},
      {cl: :C67152, status: :no_change},
      {cl: :C67153, status: :no_change},
      {cl: :C71153, status: :updated},
      {cl: :C71620, status: :updated},
      {cl: :C74559, status: :no_change}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 10 SDTM - 2008" do
    current_version = 10
    load_versions(1..(current_version-1))
    results = process_load_and_compare(["SDTM Terminology 2008-09-24.xlsx"], "2008-09-24", current_version, true)
    expected = [
      {cl: :C66737, status: :no_change},
      {cl: :C66738, status: :no_change},
      {cl: :C66785, status: :no_change},
      {cl: :C66787, status: :no_change},
      {cl: :C66790, status: :no_change},
      {cl: :C67152, status: :no_change},
      {cl: :C67153, status: :no_change},
      {cl: :C71153, status: :no_change},
      {cl: :C71620, status: :no_change},
      {cl: :C74559, status: :updated},
      {cl: :C74456, status: :no_change},
      {cl: :C76351, status: :created},
      {cl: :C25188, status: :deleted}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 11 SDTM - 2008" do
    current_version = 11
    load_versions(1..(current_version-1))
    results = process_load_and_compare(["SDTM Terminology 2008-09-30.xlsx"], "2008-09-30", current_version, true)
    expected = [
      {cl: :C66737, status: :no_change},
      {cl: :C66738, status: :no_change},
      {cl: :C66785, status: :no_change},
      {cl: :C66787, status: :no_change},
      {cl: :C66790, status: :no_change},
      {cl: :C67152, status: :no_change},
      {cl: :C67153, status: :no_change},
      {cl: :C71153, status: :no_change},
      {cl: :C71620, status: :updated},
      {cl: :C74456, status: :no_change},
      {cl: :C76351, status: :no_change}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 12 SDTM - 2008" do
    current_version = 12
    load_versions(1..(current_version-1))
    results = process_load_and_compare(["SDTM Terminology 2008-10-09.xlsx"], "2008-10-09", current_version, true)
    expected = [
      {cl: :C66737, status: :no_change},
      {cl: :C66738, status: :no_change},
      {cl: :C66785, status: :no_change},
      {cl: :C66787, status: :no_change},
      {cl: :C66790, status: :no_change},
      {cl: :C67152, status: :no_change},
      {cl: :C67153, status: :no_change},
      {cl: :C71153, status: :no_change},
      {cl: :C71620, status: :no_change},
      {cl: :C74456, status: :no_change},
      {cl: :C76351, status: :no_change}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 13 SDTM - 2008" do
    current_version = 13
    load_versions(1..(current_version-1))
    results = process_load_and_compare(["SDTM Terminology 2008-10-15.xlsx"], "2008-10-15", current_version, true)
    expected = [
      {cl: :C66737, status: :no_change},
      {cl: :C66738, status: :no_change},
      {cl: :C66785, status: :no_change},
      {cl: :C66787, status: :no_change},
      {cl: :C66790, status: :updated},
      {cl: :C67152, status: :no_change},
      {cl: :C67153, status: :no_change},
      {cl: :C71153, status: :no_change},
      {cl: :C71620, status: :no_change},
      {cl: :C74456, status: :no_change},
      {cl: :C76351, status: :no_change}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 14 SDTM - 2009" do
    current_version = 14
    load_versions(1..(current_version-1))
    results = process_load_and_compare(["SDTM Terminology 2009-02-17.xlsx"], "2009-02-17", current_version, true)
    expected = [
      {cl: :C66737, status: :no_change},
      {cl: :C66738, status: :no_change},
      {cl: :C66785, status: :no_change},
      {cl: :C66787, status: :no_change},
      {cl: :C66790, status: :no_change},
      {cl: :C67152, status: :no_change},
      {cl: :C67153, status: :updated},
      {cl: :C71153, status: :no_change},
      {cl: :C71620, status: :updated},
      {cl: :C74456, status: :no_change},
      {cl: :C76351, status: :no_change}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 15 SDTM - 2009" do
    current_version = 15
    load_versions(1..(current_version-1))
    results = process_load_and_compare(["SDTM Terminology 2009-02-18.xlsx"], "2009-02-18", current_version, true)
    expected = [
      {cl: :C66737, status: :no_change},
      {cl: :C66738, status: :no_change},
      {cl: :C66785, status: :no_change},
      {cl: :C66787, status: :no_change},
      {cl: :C66790, status: :no_change},
      {cl: :C67152, status: :no_change},
      {cl: :C67153, status: :no_change},
      {cl: :C71153, status: :no_change},
      {cl: :C71620, status: :updated},
      {cl: :C74456, status: :no_change},
      {cl: :C76351, status: :no_change}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 16 SDTM - 2009" do
    current_version = 16
    load_versions(1..(current_version-1))
    results = process_load_and_compare(["SDTM Terminology 2009-05-01.xlsx"], "2009-05-01", current_version, true)
    expected = [
      {cl: :C66737, status: :updated},
      {cl: :C66738, status: :updated},
      {cl: :C66785, status: :no_change},
      {cl: :C66787, status: :updated},
      {cl: :C66790, status: :updated},
      {cl: :C67152, status: :updated},
      {cl: :C67153, status: :updated},
      {cl: :C71153, status: :no_change},
      {cl: :C71620, status: :updated},
      {cl: :C74456, status: :updated},
      {cl: :C76351, status: :updated}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 17 SDTM - 2009" do
    current_version = 17
    load_versions(1..(current_version-1))
    results = process_load_and_compare(["SDTM Terminology 2009-07-06.xlsx"], "2009-07-06", current_version, true)
    expected = [
      {cl: :C66737, status: :no_change},
      {cl: :C66738, status: :no_change},
      {cl: :C66785, status: :no_change},
      {cl: :C66787, status: :no_change},
      {cl: :C66790, status: :no_change},
      {cl: :C67152, status: :no_change},
      {cl: :C67153, status: :no_change},
      {cl: :C71153, status: :no_change},
      {cl: :C71620, status: :updated},
      {cl: :C74456, status: :no_change},
      {cl: :C76351, status: :no_change}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 18 SDTM - 2009" do
    current_version = 18
    load_versions(1..(current_version-1))
    results = process_load_and_compare(["SDTM Terminology 2009-10-06.xlsx"], "2009-10-06", current_version, true)
    expected = [
      {cl: :C66737, status: :no_change},
      {cl: :C66738, status: :updated},
      {cl: :C66785, status: :no_change},
      {cl: :C66787, status: :no_change},
      {cl: :C66790, status: :updated},
      {cl: :C67152, status: :updated},
      {cl: :C67153, status: :no_change},
      {cl: :C71153, status: :no_change},
      {cl: :C71620, status: :updated},
      {cl: :C74456, status: :no_change},
      {cl: :C76351, status: :no_change}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 19 SDTM - 2010" do
    current_version = 19
    load_versions(1..(current_version-1))
    results = process_load_and_compare(["SDTM Terminology 2010-03-05.xlsx", "ADaM Terminology 2010-03-05.xlsx", "CDASH Terminology 2010-03-05.xlsx"], "2010-03-05", current_version, true)
    expected = [
      {cl: :C66737, status: :no_change},
      {cl: :C66738, status: :no_change},
      {cl: :C66785, status: :no_change},
      {cl: :C66787, status: :no_change},
      {cl: :C66790, status: :no_change},
      {cl: :C67152, status: :no_change},
      {cl: :C67153, status: :no_change},
      {cl: :C71153, status: :no_change},
      {cl: :C71620, status: :no_change},
      {cl: :C74456, status: :no_change},
      {cl: :C76351, status: :no_change}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 20 SDTM - 2010" do
    current_version = 20
    load_versions(1..(current_version-1))
    results = process_load_and_compare(["SDTM Terminology 2010-04-08.xlsx"], "2010-04-08", current_version, true)
    expected = [
      {cl: :C66737, status: :no_change},
      {cl: :C66738, status: :no_change},
      {cl: :C66785, status: :no_change},
      {cl: :C66787, status: :no_change},
      {cl: :C66790, status: :no_change},
      {cl: :C67152, status: :no_change},
      {cl: :C67153, status: :no_change},
      {cl: :C71153, status: :no_change},
      {cl: :C71620, status: :no_change},
      {cl: :C74456, status: :no_change},
      {cl: :C76351, status: :no_change}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 21 SDTM - 2010" do
    current_version = 21
    load_versions(1..(current_version-1))
    results = process_load_and_compare(["SDTM Terminology 2010-07-02.xlsx"], "2010-07-02", current_version, true)
    expected = [
      {cl: :C66737, status: :no_change},
      {cl: :C66738, status: :no_change},
      {cl: :C66785, status: :no_change},
      {cl: :C66787, status: :no_change},
      {cl: :C66790, status: :no_change},
      {cl: :C67152, status: :no_change},
      {cl: :C67153, status: :no_change},
      {cl: :C71153, status: :no_change},
      {cl: :C71620, status: :no_change},
      {cl: :C74456, status: :no_change},
      {cl: :C76351, status: :no_change}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 22 SDTM - 2010" do
    current_version = 22
    load_versions(1..(current_version-1))
    results = process_load_and_compare(["SDTM Terminology 2010-10-06.xlsx", "ADaM Terminology 2010-10-06.xlsx"], "2010-10-06", current_version, true)
    expected = [
      {cl: :C66737, status: :no_change},
      {cl: :C66738, status: :no_change},
      {cl: :C66785, status: :no_change},
      {cl: :C66787, status: :no_change},
      {cl: :C66790, status: :no_change},
      {cl: :C67152, status: :no_change},
      {cl: :C67153, status: :no_change},
      {cl: :C71153, status: :no_change},
      {cl: :C71620, status: :no_change},
      {cl: :C74456, status: :no_change},
      {cl: :C76351, status: :no_change}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 23 SDTM - 2010" do
    current_version = 23
    load_versions(1..(current_version-1))
    results = process_load_and_compare(["SDTM Terminology 2010-10-22.xlsx"], "2010-10-22", current_version, true)
    expected = [
      {cl: :C66737, status: :no_change},
      {cl: :C66738, status: :no_change},
      {cl: :C66785, status: :no_change},
      {cl: :C66787, status: :no_change},
      {cl: :C66790, status: :no_change},
      {cl: :C67152, status: :no_change},
      {cl: :C67153, status: :no_change},
      {cl: :C71153, status: :no_change},
      {cl: :C71620, status: :no_change},
      {cl: :C74456, status: :no_change},
      {cl: :C76351, status: :no_change}
    ]
    check_cl_results(results, expected) 
  end

=begin
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
    check_cli_result(old_version, new_version, "C67153", "C41255", created: true)
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
=end

end