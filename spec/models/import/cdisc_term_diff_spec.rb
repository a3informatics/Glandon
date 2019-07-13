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

  def set_write_file
    true
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

  def dump_errors_if_present(filename, version, date)
    full_path = Rails.root.join "public/test/#{filename}"
    return if !File.exists?(full_path)
    errors = YAML.load_file(full_path)
    puts "***** ERRORS ON IMPORT - V#{version} for #{date} *****"
    puts errors
  end

  def process_term(version, date, files, copy_file=false)
    params = set_params(version, date, files)
    result = @object.import(params)
    filename = "cdisc_term_#{@object.id}_errors.yml"
    dump_errors_if_present(filename, version, date)
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
    filenames.each_with_index {|f, index| files << db_load_file_path("cdisc/ct/", filenames[index])}
    process_term(version, date, files, create_file)
    load_version(version)
    th = CdiscTerm.find(Uri.new(uri: "http://www.cdisc.org/CT/V#{version}#TH"))
    results = th.changes(2)
  end

  def execute_import(current_version, issue_date, reqd_files, create_file=false)
    files = []
    file_pattern = 
    {
      adam: "adam/ADaM Terminology #{issue_date}.xlsx",
      cdash: "cdash/CDASH Terminology #{issue_date}.xlsx", 
      coa: "coa/COA Terminology #{issue_date}.xlsx", 
      sdtm: "sdtm/SDTM Terminology #{issue_date}.xlsx", 
      qrs: "qrs/QRS Terminology #{issue_date}.xlsx", 
      qs: "qs/QS Terminology #{issue_date}.xlsx",
      qsft: "qs-ft/QS-FT Terminology #{issue_date}.xlsx"
    }
    load_versions(1..(current_version-1))
    reqd_files.each {|k,v| files << file_pattern[k] if v}
    results = process_load_and_compare(files, issue_date, current_version, create_file: create_file)
  end

  it "Base create, version 1: 2007" do
    current_version = 1
    results = process_load_and_compare(["sdtm/SDTM Terminology 2007-03-06.xlsx"], "2007-03-06", current_version, set_write_file)
    expected = [
      {cl: :C16564, status: :created},
      {cl: :C20587, status: :created},
      {cl: :C49627, status: :created},
      {cl: :C49660, status: :created},
      {cl: :C49499, status: :created}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 2: 2007" do
    current_version = 2
    load_versions(1..(current_version-1))
    results = process_load_and_compare(["sdtm/SDTM Terminology 2007-04-20.xlsx"], "2007-04-20", current_version, set_write_file)
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

  it "Create version 3: 2007" do
    current_version = 3
    load_versions(1..(current_version-1))
    results = process_load_and_compare(["sdtm/SDTM Terminology 2007-04-26.xlsx"], "2007-04-26", current_version, set_write_file)
    expected = [
      {cl: :C66785, status: :created},
      {cl: :C66787, status: :no_change},
      {cl: :C66790, status: :no_change},
      {cl: :C67153, status: :no_change},
      {cl: :C66737, status: :updated}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 4: 2007" do
    current_version = 4
    load_versions(1..(current_version-1))
    results = process_load_and_compare(["sdtm/SDTM Terminology 2007-05-31.xlsx"], "2007-05-31", current_version, set_write_file)
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

  it "Create version 5: 2007" do
    current_version = 5
    load_versions(1..(current_version-1))
    results = process_load_and_compare(["sdtm/SDTM Terminology 2007-06-05.xlsx"], "2007-06-05", current_version, set_write_file)
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

  it "Create version 6: 2008" do
    current_version = 6
    load_versions(1..(current_version-1))
    results = process_load_and_compare(["sdtm/SDTM Terminology 2008-01-15.xlsx"], "2008-01-15", current_version, set_write_file)
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

  it "Create version 7: 2008" do
    current_version = 7
    load_versions(1..(current_version-1))
    results = process_load_and_compare(["sdtm/SDTM Terminology 2008-01-25.xlsx"], "2008-01-25", current_version, set_write_file)
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

  it "Create version 8: 2008" do
    current_version = 8
    load_versions(1..(current_version-1))
    results = process_load_and_compare(["sdtm/SDTM Terminology 2008-08-26.xlsx"], "2008-08-26", current_version, set_write_file)
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

  it "Create version 9: 2008" do
    current_version = 9
    load_versions(1..(current_version-1))
    results = process_load_and_compare(["sdtm/SDTM Terminology 2008-09-22.xlsx"], "2008-09-22", current_version, set_write_file)
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

  it "Create version 10: 2008" do
    current_version = 10
    load_versions(1..(current_version-1))
    results = process_load_and_compare(["sdtm/SDTM Terminology 2008-09-24.xlsx"], "2008-09-24", current_version, set_write_file)
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

  it "Create version 11: 2008" do
    current_version = 11
    load_versions(1..(current_version-1))
    results = process_load_and_compare(["sdtm/SDTM Terminology 2008-09-30.xlsx"], "2008-09-30", current_version, set_write_file)
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

  it "Create version 12: 2008" do
    current_version = 12
    load_versions(1..(current_version-1))
    results = process_load_and_compare(["sdtm/SDTM Terminology 2008-10-09.xlsx"], "2008-10-09", current_version, set_write_file)
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

  it "Create version 13: 2008" do
    current_version = 13
    load_versions(1..(current_version-1))
    results = process_load_and_compare(["sdtm/SDTM Terminology 2008-10-15.xlsx"], "2008-10-15", current_version, set_write_file)
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

  it "Create version 14: 2009" do
    current_version = 14
    load_versions(1..(current_version-1))
    results = process_load_and_compare(["sdtm/SDTM Terminology 2009-02-17.xlsx"], "2009-02-17", current_version, set_write_file)
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

  it "Create version 15: 2009" do
    current_version = 15
    load_versions(1..(current_version-1))
    results = process_load_and_compare(["sdtm/SDTM Terminology 2009-02-18.xlsx"], "2009-02-18", current_version, set_write_file)
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

  it "Create version 16: 2009" do
    current_version = 16
    load_versions(1..(current_version-1))
    results = process_load_and_compare(["sdtm/SDTM Terminology 2009-05-01.xlsx"], "2009-05-01", current_version, set_write_file)
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

  it "Create version 17: 2009" do
    current_version = 17
    load_versions(1..(current_version-1))
    results = process_load_and_compare(["sdtm/SDTM Terminology 2009-07-06.xlsx"], "2009-07-06", current_version, set_write_file)
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

  it "Create version 18: 2009" do
    current_version = 18
    load_versions(1..(current_version-1))
    results = process_load_and_compare(["sdtm/SDTM Terminology 2009-10-06.xlsx"], "2009-10-06", current_version, set_write_file)
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

  it "Create version 19: 2010" do
    current_version = 19
    load_versions(1..(current_version-1))
    files = ["sdtm/SDTM Terminology 2010-03-05.xlsx", "adam/ADaM Terminology 2010-03-05.xlsx", "cdash/CDASH Terminology 2010-03-05.xlsx"]
    results = process_load_and_compare(files, "2010-03-05", current_version, set_write_file)
    expected = [
      {cl: :C66737, status: :no_change},
      {cl: :C66738, status: :updated},
      {cl: :C66785, status: :no_change},
      {cl: :C66787, status: :no_change},
      {cl: :C66790, status: :updated},
      {cl: :C67152, status: :updated},
      {cl: :C67153, status: :updated},
      {cl: :C71153, status: :no_change},
      {cl: :C71620, status: :updated},
      {cl: :C74456, status: :no_change},
      {cl: :C76351, status: :no_change},
      {cl: :C78735, status: :updated}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 20: 2010" do
    current_version = 20
    load_versions(1..(current_version-1))
    results = process_load_and_compare(["sdtm/SDTM Terminology 2010-04-08.xlsx"], "2010-04-08", current_version, set_write_file)
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
      {cl: :C74456, status: :updated},
      {cl: :C76351, status: :no_change},
      {cl: :C78735, status: :no_change}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 21: 2010" do
    current_version = 21
    load_versions(1..(current_version-1))
    results = process_load_and_compare(["sdtm/SDTM Terminology 2010-07-02.xlsx"], "2010-07-02", current_version, set_write_file)
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
      {cl: :C76351, status: :updated},
      {cl: :C78735, status: :no_change}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 22: 2010" do
    current_version = 22
    load_versions(1..(current_version-1))
    results = process_load_and_compare(["sdtm/SDTM Terminology 2010-10-06.xlsx", "adam/ADaM Terminology 2010-10-06.xlsx"], "2010-10-06", current_version, set_write_file)
    expected = [
      {cl: :C66737, status: :no_change},
      {cl: :C66738, status: :updated},
      {cl: :C66785, status: :no_change},
      {cl: :C66787, status: :no_change},
      {cl: :C66790, status: :no_change},
      {cl: :C67152, status: :updated},
      {cl: :C67153, status: :no_change},
      {cl: :C71153, status: :no_change},
      {cl: :C71620, status: :no_change},
      {cl: :C74456, status: :updated},
      {cl: :C76351, status: :no_change},
      {cl: :C78735, status: :no_change}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 23: 2010" do
    current_version = 23
    load_versions(1..(current_version-1))
    results = process_load_and_compare(["sdtm/SDTM Terminology 2010-10-22.xlsx"], "2010-10-22", current_version, set_write_file)
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
      {cl: :C76351, status: :no_change},
      {cl: :C78735, status: :no_change}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 24: 2011" do
    results = execute_import(24, "2011-01-07", {sdtm: true, adam: true, cdash: true}, set_write_file)
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
      {cl: :C76351, status: :no_change},
      {cl: :C78735, status: :no_change}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 25: 2011" do
    results = execute_import(25, "2011-04-08", {sdtm: true, adam: false, cdash: true}, set_write_file)
    expected = [
      {cl: :C66737, status: :no_change},
      {cl: :C66738, status: :no_change},
      {cl: :C66785, status: :no_change},
      {cl: :C66787, status: :no_change},
      {cl: :C66790, status: :no_change},
      {cl: :C67152, status: :updated},
      {cl: :C67153, status: :no_change},
      {cl: :C71153, status: :no_change},
      {cl: :C71620, status: :no_change},
      {cl: :C74456, status: :no_change},
      {cl: :C76351, status: :no_change},
      {cl: :C78735, status: :no_change}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 26: 2011" do
    results = execute_import(26, "2011-06-10", {sdtm: true, adam: false, cdash: false}, set_write_file)
    expected = [
      {cl: :C66737, status: :no_change},
      {cl: :C66738, status: :no_change},
      {cl: :C66785, status: :no_change},
      {cl: :C66787, status: :no_change},
      {cl: :C66790, status: :no_change},
      {cl: :C67152, status: :no_change},
      {cl: :C67153, status: :no_change},
      {cl: :C71153, status: :updated},
      {cl: :C71620, status: :no_change},
      {cl: :C74456, status: :updated},
      {cl: :C76351, status: :no_change},
      {cl: :C78735, status: :no_change}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 27: 2011" do
    results = execute_import(27, "2011-07-22", {sdtm: true, adam: true, cdash: true}, set_write_file)
    expected = [
      {cl: :C66737, status: :no_change},
      {cl: :C66738, status: :updated},
      {cl: :C66785, status: :no_change},
      {cl: :C66787, status: :no_change},
      {cl: :C66790, status: :no_change},
      {cl: :C67152, status: :updated},
      {cl: :C67153, status: :no_change},
      {cl: :C71153, status: :no_change},
      {cl: :C71620, status: :updated},
      {cl: :C74456, status: :updated},
      {cl: :C76351, status: :no_change},
      {cl: :C78735, status: :no_change}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 28: 2011" do
    results = execute_import(28, "2011-12-09", {sdtm: true, adam: false, cdash: true}, set_write_file)
    expected = [
      {cl: :C66737, status: :no_change},
      {cl: :C66738, status: :updated},
      {cl: :C66785, status: :no_change},
      {cl: :C66787, status: :no_change},
      {cl: :C66790, status: :no_change},
      {cl: :C67152, status: :updated},
      {cl: :C67153, status: :updated},
      {cl: :C71153, status: :no_change},
      {cl: :C71620, status: :no_change},
      {cl: :C74456, status: :updated},
      {cl: :C76351, status: :no_change},
      {cl: :C78735, status: :no_change},
      {cl: :C88025, status: :created}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 29: 2012" do
    results = execute_import(29, "2012-03-23", {sdtm: true, adam: false, cdash: false, qs: true}, set_write_file)
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
      {cl: :C76351, status: :no_change},
      {cl: :C78735, status: :no_change},
      {cl: :C88025, status: :no_change}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 30: 2012" do
    results = execute_import(30, "2012-06-29", {sdtm: true, adam: false, cdash: true, qs: true}, set_write_file)
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
      {cl: :C76351, status: :no_change},
      {cl: :C78735, status: :no_change},
      {cl: :C88025, status: :no_change}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 31: 2012" do
    results = execute_import(31, "2012-08-03", {sdtm: true, adam: false, cdash: false, qs: true}, set_write_file)
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
      {cl: :C76351, status: :no_change},
      {cl: :C78735, status: :no_change},
      {cl: :C88025, status: :no_change}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 32: 2012" do
    results = execute_import(32, "2012-12-21", {sdtm: true, adam: false, cdash: true, qs: true}, set_write_file)
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
      {cl: :C76351, status: :no_change},
      {cl: :C78735, status: :no_change},
      {cl: :C88025, status: :no_change}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 33: 2013" do
    results = execute_import(33, "2013-04-12", {sdtm: true, qs: true}, set_write_file)
    expected = [
      {cl: :C66737, status: :no_change},
      {cl: :C66738, status: :no_change},
      {cl: :C66785, status: :no_change},
      {cl: :C66787, status: :no_change},
      {cl: :C66790, status: :no_change},
      {cl: :C67152, status: :no_change},
      {cl: :C67153, status: :updated},
      {cl: :C71153, status: :updated},
      {cl: :C71620, status: :updated},
      {cl: :C74456, status: :no_change},
      {cl: :C76351, status: :no_change},
      {cl: :C78735, status: :updated},
      {cl: :C88025, status: :updated}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 34: 2013" do
    results = execute_import(34, "2013-06-28", {sdtm: true, cdash: true, qs: true}, set_write_file)
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
      {cl: :C76351, status: :no_change},
      {cl: :C78735, status: :no_change},
      {cl: :C88025, status: :no_change}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 35: 2013" do
    results = execute_import(35, "2013-10-04", {sdtm: true, cdash: true, qs: true}, set_write_file)
    expected = [
      {cl: :C66737, status: :updated},
      {cl: :C66738, status: :updated},
      {cl: :C66785, status: :no_change},
      {cl: :C66787, status: :no_change},
      {cl: :C66790, status: :no_change},
      {cl: :C67152, status: :updated},
      {cl: :C67153, status: :no_change},
      {cl: :C71153, status: :updated},
      {cl: :C71620, status: :updated},
      {cl: :C74456, status: :updated},
      {cl: :C76351, status: :no_change},
      {cl: :C78735, status: :updated},
      {cl: :C88025, status: :updated}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 36: 2013" do
    results = execute_import(36, "2013-12-20", {sdtm: true, cdash: true, qs: true}, set_write_file)
    expected = [
      {cl: :C66737, status: :no_change},
      {cl: :C66738, status: :updated},
      {cl: :C66785, status: :no_change},
      {cl: :C66787, status: :no_change},
      {cl: :C66790, status: :no_change},
      {cl: :C67152, status: :updated},
      {cl: :C67153, status: :updated},
      {cl: :C71153, status: :updated},
      {cl: :C71620, status: :updated},
      {cl: :C74456, status: :no_change},
      {cl: :C76351, status: :no_change},
      {cl: :C78735, status: :no_change},
      {cl: :C88025, status: :updated}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 37: 2014" do
    results = execute_import(37, "2014-03-28", {sdtm: true, cdash: true, qs: true}, set_write_file)
    expected = [
      {cl: :C66737, status: :updated},
      {cl: :C66738, status: :updated},
      {cl: :C66785, status: :no_change},
      {cl: :C66787, status: :no_change},
      {cl: :C66790, status: :no_change},
      {cl: :C67152, status: :updated},
      {cl: :C67153, status: :no_change},
      {cl: :C71153, status: :no_change},
      {cl: :C71620, status: :updated},
      {cl: :C74456, status: :updated},
      {cl: :C76351, status: :no_change},
      {cl: :C78735, status: :updated},
      {cl: :C88025, status: :updated}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 38: 2014" do
    results = execute_import(38, "2014-06-27", {sdtm: true, qsft: true}, set_write_file)
    expected = [
      {cl: :C66737, status: :no_change},
      {cl: :C66738, status: :updated},
      {cl: :C66785, status: :no_change},
      {cl: :C66787, status: :no_change},
      {cl: :C66790, status: :no_change},
      {cl: :C67152, status: :updated},
      {cl: :C67153, status: :no_change},
      {cl: :C71153, status: :updated},
      {cl: :C71620, status: :updated},
      {cl: :C74456, status: :updated},
      {cl: :C76351, status: :no_change},
      {cl: :C78735, status: :no_change},
      {cl: :C88025, status: :updated}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 39: 2014" do
    results = execute_import(39, "2014-09-26", {sdtm: true, qsft: true, cdash: true, adam: true}, set_write_file)
    expected = [
      {cl: :C66737, status: :no_change},
      {cl: :C66738, status: :updated},
      {cl: :C66785, status: :no_change},
      {cl: :C66787, status: :no_change},
      {cl: :C66790, status: :no_change},
      {cl: :C67152, status: :updated},
      {cl: :C67153, status: :updated},
      {cl: :C71153, status: :updated},
      {cl: :C71620, status: :updated},
      {cl: :C74456, status: :updated},
      {cl: :C76351, status: :no_change},
      {cl: :C78735, status: :no_change},
      {cl: :C88025, status: :updated}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 40: 2014" do
    results = execute_import(40, "2014-10-06", {sdtm: true}, set_write_file)
    expected = [
      {cl: :C66737, status: :no_change},
      {cl: :C66738, status: :updated},
      {cl: :C66785, status: :no_change},
      {cl: :C66787, status: :no_change},
      {cl: :C66790, status: :no_change},
      {cl: :C67152, status: :updated},
      {cl: :C67153, status: :no_change},
      {cl: :C71153, status: :no_change},
      {cl: :C71620, status: :no_change},
      {cl: :C74456, status: :no_change},
      {cl: :C76351, status: :no_change},
      {cl: :C78735, status: :no_change},
      {cl: :C88025, status: :no_change}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 41: 2014" do
    results = execute_import(41, "2014-12-19", {sdtm: true, coa: true}, set_write_file)
    expected = [
      {cl: :C66737, status: :updated},
      {cl: :C66738, status: :updated},
      {cl: :C66785, status: :no_change},
      {cl: :C66787, status: :no_change},
      {cl: :C66790, status: :no_change},
      {cl: :C67152, status: :updated},
      {cl: :C67153, status: :no_change},
      {cl: :C71153, status: :updated},
      {cl: :C71620, status: :updated},
      {cl: :C74456, status: :updated},
      {cl: :C76351, status: :no_change},
      {cl: :C78735, status: :updated},
      {cl: :C88025, status: :updated}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 42: 2015" do
    results = execute_import(42, "2015-03-27", {sdtm: true, coa: true, cdash: true}, set_write_file)
    expected = [
      {cl: :C66737, status: :no_change},
      {cl: :C66738, status: :updated},
      {cl: :C66785, status: :no_change},
      {cl: :C66787, status: :no_change},
      {cl: :C66790, status: :no_change},
      {cl: :C67152, status: :no_change},
      {cl: :C67153, status: :no_change},
      {cl: :C71153, status: :updated},
      {cl: :C71620, status: :no_change},
      {cl: :C74456, status: :updated},
      {cl: :C76351, status: :no_change},
      {cl: :C78735, status: :no_change},
      {cl: :C88025, status: :updated}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 43: 2015" do
    results = execute_import(43, "2015-06-26", {sdtm: true, qrs: true}, set_write_file)
    expected = [
      {cl: :C66737, status: :no_change},
      {cl: :C66738, status: :updated},
      {cl: :C66785, status: :no_change},
      {cl: :C66787, status: :no_change},
      {cl: :C66790, status: :no_change},
      {cl: :C67152, status: :no_change},
      {cl: :C67153, status: :no_change},
      {cl: :C71153, status: :no_change},
      {cl: :C71620, status: :no_change},
      {cl: :C74456, status: :no_change},
      {cl: :C76351, status: :no_change},
      {cl: :C78735, status: :no_change},
      {cl: :C88025, status: :no_change}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 44: 2015" do
    results = execute_import(44, "2015-09-25", {sdtm: true, qrs: true}, set_write_file)
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
      {cl: :C76351, status: :no_change},
      {cl: :C78735, status: :no_change},
      {cl: :C88025, status: :no_change}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 45: 2015" do
    results = execute_import(45, "2015-12-18", {sdtm: true, adam: true}, set_write_file)
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
      {cl: :C76351, status: :no_change},
      {cl: :C78735, status: :no_change},
      {cl: :C88025, status: :no_change}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 46: 2016" do
    results = execute_import(46, "2016-03-25", {sdtm: true, cdash: true, adam: true}, set_write_file)
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
      {cl: :C76351, status: :no_change},
      {cl: :C78735, status: :no_change},
      {cl: :C88025, status: :no_change}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 47: 2016" do
    results = execute_import(47, "2016-06-24", {sdtm: true}, set_write_file)
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
      {cl: :C76351, status: :no_change},
      {cl: :C78735, status: :no_change},
      {cl: :C88025, status: :no_change}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 48: 2016" do
    results = execute_import(48, "2016-09-30", {sdtm: true, cdash: true, adam: true}, set_write_file)
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
      {cl: :C76351, status: :no_change},
      {cl: :C78735, status: :no_change},
      {cl: :C88025, status: :no_change}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 49: 2016" do
    results = execute_import(49, "2016-12-16", {sdtm: true, cdash: true, adam: true}, set_write_file)
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
      {cl: :C76351, status: :no_change},
      {cl: :C78735, status: :no_change},
      {cl: :C88025, status: :no_change}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 50: 2017" do
    results = execute_import(50, "2017-03-31", {sdtm: true, adam: true}, set_write_file)
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
      {cl: :C76351, status: :no_change},
      {cl: :C78735, status: :no_change},
      {cl: :C88025, status: :no_change}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 51: 2017" do
    results = execute_import(51, "2017-06-30", {sdtm: true}, set_write_file)
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
      {cl: :C76351, status: :no_change},
      {cl: :C78735, status: :no_change},
      {cl: :C88025, status: :no_change}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 52: 2017" do
    results = execute_import(52, "2017-09-29", {sdtm: true, cdash: true, adam: true}, set_write_file)
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
      {cl: :C76351, status: :no_change},
      {cl: :C78735, status: :no_change},
      {cl: :C88025, status: :no_change}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 53: 2017" do
    results = execute_import(53, "2017-12-22", {sdtm: true}, set_write_file)
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
      {cl: :C76351, status: :no_change},
      {cl: :C78735, status: :no_change},
      {cl: :C88025, status: :no_change}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 54: 2018" do
    results = execute_import(54, "2018-03-30", {sdtm: true, cdash: true}, set_write_file)
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
      {cl: :C76351, status: :no_change},
      {cl: :C78735, status: :no_change},
      {cl: :C88025, status: :no_change}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 55: 2018" do
    results = execute_import(55, "2018-06-29", {sdtm: true, cdash: true}, set_write_file)
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
      {cl: :C76351, status: :no_change},
      {cl: :C78735, status: :no_change},
      {cl: :C88025, status: :no_change}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 56: 2018" do
    results = execute_import(56, "2018-09-28", {sdtm: true, cdash: true}, set_write_file)
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
      {cl: :C76351, status: :no_change},
      {cl: :C78735, status: :no_change},
      {cl: :C88025, status: :no_change}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 57: 2018" do
    results = execute_import(57, "2018-12-21", {sdtm: true, cdash: true, adam: true}, set_write_file)
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
      {cl: :C76351, status: :no_change},
      {cl: :C78735, status: :no_change},
      {cl: :C88025, status: :no_change}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 58: 2019" do
    results = execute_import(58, "2019-03-29", {sdtm: true, cdash: true, adam: true}, set_write_file)
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
      {cl: :C76351, status: :no_change},
      {cl: :C78735, status: :no_change},
      {cl: :C88025, status: :no_change}
    ]
    check_cl_results(results, expected) 
  end

  it "Create version 59: 2019" do
    results = execute_import(59, "2019-06-28", {sdtm: true, cdash: true}, set_write_file)
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
      {cl: :C76351, status: :no_change},
      {cl: :C78735, status: :no_change},
      {cl: :C88025, status: :no_change}
    ]
    check_cl_results(results, expected) 
  end

end