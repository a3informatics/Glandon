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

  def find_term(version)
  	CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V#{version}")
  end

  def set_params(version, date, files)
    { version: "#{version}", date: "#{date}", files: files, version_label: "#{date} Release", label: "Controlled Terminology", semantic_version: "#{version}.0.0", job: @job}
  end

  def compare_term(old_version, new_version)
    old_ct = find_term(old_version) if !old_version.nil?
    new_ct = find_term(new_version)
    result = CdiscTerm.compare(old_ct, new_ct)
	end

	def check_cl_result(results, cl, status)
  	expect(results[:children][cl.to_sym][:status]).to eq(status)
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

  def process_term(version, date, files, copy_file=false)
    params = set_params(version, date, files)
    result = @object.import(params)
    filename = "cdisc_term_#{@object.id}_errors.yml"
byebug
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

  it "Base create, version 1 SDTM" do
    files = [db_load_file_path("cdisc/ct/sdtm", "SDTM Terminology 2007-03-06.xlsx")]
    process_term(1, "2007-03-06", files) #, true)
    # Load resulting file
    load_version(1)
    # Compare thesaurus
  	th = CdiscTerm.find(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"))
    results = th.changes(2)
    # Results
    check_cl_result(results[1], :C16564, :created)
  	check_cl_result(results[1], :C20587, :created)
  	check_cl_result(results[1], :C49627, :created)
  	check_cl_result(results[1], :C49660, :created)
    check_cl_result(results[1], :C49499, :created)
  end

  it "Create version 2 SDTM" do
    # Load previous versions
    load_version(1)
    # Process and load new
    files = [db_load_file_path("cdisc/ct/sdtm", "SDTM Terminology 2007-04-20.xlsx")]
    process_term(2, "2007-04-20", files) #, true)
    load_version(2)
    # Compare thesaurus
    th = CdiscTerm.find(Uri.new(uri: "http://www.cdisc.org/CT/V2#TH"))
    results = th.changes(2)
    # Results
    check_cl_result(results[2], :C16564, :deleted)
    check_cl_result(results[2], :C20587, :deleted)
    check_cl_result(results[2], :C49627, :deleted)
    check_cl_result(results[2], :C49660, :deleted)
    check_cl_result(results[2], :C49499, :deleted)
    check_cl_result(results[2], :C66785, :created)
    check_cl_result(results[2], :C66787, :created)
    check_cl_result(results[2], :C66790, :created)
    check_cl_result(results[2], :C67153, :created)
    check_cl_result(results[2], :C66737, :created)  
  end

  it "Create version 3 SDTM" do
    # Load previous versions
    load_version(1)
    load_version(2)
    # Process and load new
    files = [db_load_file_path("cdisc/ct/sdtm", "SDTM Terminology 2007-04-26.xlsx")]
    process_term(3, "2007-04-26", files) #, true)
    load_version(3)
    # Compare thesaurus
    th = CdiscTerm.find(Uri.new(uri: "http://www.cdisc.org/CT/V3#TH"))
    results = th.changes(2)
    # Results
    check_cl_result(results[3], :C66785, :created)
    check_cl_result(results[3], :C66787, :no_change)
    check_cl_result(results[3], :C66790, :no_change)
    check_cl_result(results[3], :C67153, :no_change)
    check_cl_result(results[3], :C66737, :updated)
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