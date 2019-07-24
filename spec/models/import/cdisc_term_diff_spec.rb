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

  def check_count(version, expected)
    uri_sting = "http://www.cdisc.org/CT/V#{version}#TH"
    query_string = %Q{
SELECT DISTINCT (count(?uri) as ?count) WHERE {            
  #{Uri.new(uri: uri_sting).to_ref} th:isTopConceptReference/bo:reference ?mc .
  { 
    ?mc th:identifier ?i .
    BIND(?i as ?pi)
    BIND(?mc as ?uri)
  } UNION
  {
    ?mc th:narrower ?uc .
    ?mc th:identifier ?pi .
    ?uc th:identifier ?i .
    BIND(?uc as ?uri)
  }
}}
    query_results = Sparql::Query.new.query(query_string, "", [:bo, :th])
    count = query_results.by_object_set([:count]).first[:count].to_i
    expect(count).to eq(expected)
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
    puts colourize("***** ERRORS ON IMPORT - V#{version} for #{date} *****", "red")
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
      puts colourize("***** Warning! Copying result file. *****", "red")
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
      adam: "adam/ADaM Terminology",
      cdash: "cdash/CDASH Terminology", 
      coa: "coa/COA Terminology", 
      sdtm: "sdtm/SDTM Terminology", 
      qrs: "qrs/QRS Terminology", 
      qs: "qs/QS Terminology",
      qsft: "qs-ft/QS-FT Terminology"
    }
    load_versions(1..(current_version-1))
    reqd_files.each {|k,v| files << "#{file_pattern[k]} #{v}.xlsx" if reqd_files.key?(k)}
    results = process_load_and_compare(files, issue_date, current_version, create_file)
  end

  describe "2007" do

    it "Base create, version 1: 2007" do
      version = 1
      results = execute_import(version, "2007-03-06", {sdtm: "2007-03-06"}, set_write_file)
      expected = [
        {cl: :C16564, status: :created},
        {cl: :C20587, status: :created},
        {cl: :C49627, status: :created},
        {cl: :C49660, status: :created},
        {cl: :C49499, status: :created}
      ]
      check_cl_results(results, expected)
      check_count(version, 881)
    end

    it "Create version 2: 2007" do
      version = 2
      results = execute_import(version, "2007-04-20", {sdtm: "2007-04-20"}, set_write_file)
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
      check_count(version, 1003)
    end

    it "Create version 3: 2007" do
      version = 3
      results = execute_import(version, "2007-04-26", {sdtm: "2007-04-26"}, set_write_file)
      expected = [
        {cl: :C66785, status: :created},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67153, status: :no_change},
        {cl: :C66737, status: :updated}
      ]
      check_cl_results(results, expected)
      check_count(version, 1003)
    end

    it "Create version 4: 2007" do
      version = 4
      results = execute_import(version, "2007-05-31", {sdtm: "2007-05-31"}, set_write_file)
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
      version = 5
      results = execute_import(version, "2007-06-05", {sdtm: "2007-06-05"}, set_write_file)
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

  end

  describe "2008" do

    it "Create version 6: 2008" do
      version = 6
      results = execute_import(version, "2008-01-15", {sdtm: "2008-01-15"}, set_write_file)
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
      version = 7
      results = execute_import(version, "2008-01-25", {sdtm: "2008-01-25"}, set_write_file)
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
      version = 8
      results = execute_import(version, "2008-08-26", {sdtm: "2008-08-26"}, set_write_file)
      expected = [
        {cl: :C66737, status: :updated},
        {cl: :C66738, status: :no_change},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :no_change},
        {cl: :C67153, status: :no_change},
        {cl: :C71153, status: :no_change},
        {cl: :C71620, status: :no_change},
        {cl: :C74559, status: :created}
      ]
      check_cl_results(results, expected) 
    end

    it "Create version 9: 2008" do
      version = 9
      results = execute_import(version, "2008-09-22", {sdtm: "2008-09-22"}, set_write_file)
      expected = [
        {cl: :C66737, status: :updated},
        {cl: :C66738, status: :no_change},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :no_change},
        {cl: :C67153, status: :no_change},
        {cl: :C71153, status: :no_change},
        {cl: :C71620, status: :updated},
        {cl: :C74559, status: :no_change}
      ]
      check_cl_results(results, expected) 
    end

    it "Create version 10: 2008" do
      version = 10
      results = execute_import(version, "2008-09-24", {sdtm: "2008-09-24"}, set_write_file)
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
      version = 11
      results = execute_import(version, "2008-09-30", {sdtm: "2008-09-30"}, set_write_file)
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
      check_count(version, 2301)
    end

    it "Create version 12: 2008" do
      version = 12
      results = execute_import(version, "2008-10-09", {sdtm: "2008-10-09"}, set_write_file)
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
      version = 13
      results = execute_import(version, "2008-10-15", {sdtm: "2008-10-15"}, set_write_file)
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

  end

  describe "2009" do

    it "Create version 14: 2009" do
      version = 14
      results = execute_import(version, "2009-02-17", {sdtm: "2009-02-17"}, set_write_file)
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
      version = 15
      results = execute_import(version, "2009-02-18", {sdtm: "2009-02-18"}, set_write_file)
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
      version = 16
      results = execute_import(version, "2009-05-01", {sdtm: "2009-05-01"}, set_write_file)
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
      version = 17
      results = execute_import(version, "2009-07-06", {sdtm: "2009-07-06"}, set_write_file)
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
      version = 18
      results = execute_import(version, "2009-10-06", {sdtm: "2009-10-06"}, set_write_file)
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

  end

  describe "2010" do

    it "Create version 19: 2010" do
      version = 19
      results = execute_import(version, "2010-03-05", {sdtm: "2010-03-05", cdash: "2010-03-05", adam: "2010-03-05"}, set_write_file)
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
      version = 20
      results = execute_import(version, "2010-04-08", {sdtm: "2010-04-08", cdash: "2010-04-08", adam: "2010-04-08"}, set_write_file)
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
      version = 21
      results = execute_import(version, "2010-07-02", {sdtm: "2010-07-02", cdash: "2010-04-08", adam: "2010-04-08"}, set_write_file)
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
      check_count(version, 4190+134+26)
    end

    it "Create version 22: 2010" do
      version = 22
      results = execute_import(version, "2010-10-06", {sdtm: "2010-10-06", cdash: "2010-04-08", adam: "2010-10-06"}, set_write_file)
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
      version = 23
      results = execute_import(version, "2010-10-22", {sdtm: "2010-10-22", cdash: "2010-04-08", adam: "2010-10-06"}, set_write_file)
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

  end

  describe "2011" do

    it "Create version 24: 2011" do
      version = 24
      results = execute_import(version, "2011-01-07", {sdtm: "2011-01-07", adam: "2011-01-07", cdash: "2011-01-07"}, set_write_file)
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
      version = 25
      results = execute_import(version, "2011-04-08", {sdtm: "2011-04-08", adam: "2011-01-07", cdash: "2011-04-08"}, set_write_file)
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
      version = 26
      results = execute_import(version, "2011-06-10", {sdtm: "2011-06-10", adam: "2011-01-07", cdash: "2011-04-08"}, set_write_file)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :no_change},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :no_change},
        {cl: :C67153, status: :no_change},
        {cl: :C71153, status: :updated},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :updated},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :no_change}
      ]
      check_cl_results(results, expected) 
    end

    it "Create version 27: 2011" do
      version = 27
      results = execute_import(version, "2011-07-22", {sdtm: "2011-07-22", adam: "2011-07-22", cdash: "2011-07-22"}, set_write_file)
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
      version = 28
      results = execute_import(version, "2011-12-09", {sdtm: "2011-12-09", adam: "2011-07-22", cdash: "2011-12-09"}, set_write_file)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :updated},
        {cl: :C66785, status: :updated},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :updated},
        {cl: :C67153, status: :updated},
        {cl: :C71153, status: :no_change},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :updated},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :no_change},
        {cl: :C88025, status: :created}
      ]
      check_cl_results(results, expected) 
    end

  end

  describe "2012" do

    it "Create version 29: 2012" do
      version = 29
      results = execute_import(version, "2012-03-23", {sdtm: "2012-03-23", adam: "2011-07-22", cdash: "2011-12-09", qs: "2012-03-23"}, set_write_file)
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
        {cl: :C78735, status: :updated},
        {cl: :C88025, status: :no_change}
      ]
      check_cl_results(results, expected) 
    end

    it "Create version 30: 2012" do
      version = 30
      results = execute_import(version, "2012-06-29", {sdtm: "2012-06-29", adam: "2011-07-22", cdash: "2012-06-29", qs: "2012-06-29"}, set_write_file)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :no_change},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :no_change},
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

    it "Create version 31: 2012" do
      version = 31
      results = execute_import(version, "2012-08-03", {sdtm: "2012-08-03", adam: "2011-07-22", cdash: "2012-06-29", qs: "2012-08-03"}, set_write_file)
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
        {cl: :C74456, status: :updated},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :no_change},
        {cl: :C88025, status: :no_change}
      ]
      check_cl_results(results, expected)
      check_count(version, 6781+28+134+2305)
    end

    it "Create version 32: 2012" do
      version = 32
      results = execute_import(version, "2012-12-21", {sdtm: "2012-12-21", qs: "2012-12-21", cdash: "2012-12-21", adam: "2011-07-22"}, set_write_file)
      expected = [
        {cl: :C66737, status: :updated},
        {cl: :C66738, status: :updated},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :updated},
        {cl: :C67153, status: :updated},
        {cl: :C71153, status: :no_change},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :updated},
        {cl: :C76351, status: :updated},
        {cl: :C78735, status: :updated},
        {cl: :C88025, status: :updated}
      ]
      check_cl_results(results, expected) 
    end

  end

  describe "2013" do

    it "Create version 33: 2013" do
      version = 33
      results = execute_import(version, "2013-04-12", {sdtm: "2013-04-12", qs: "2013-04-12", cdash: "2012-12-21", adam: "2011-07-22"}, set_write_file)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :no_change},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :updated},
        {cl: :C67152, status: :updated},
        {cl: :C67153, status: :updated},
        {cl: :C71153, status: :updated},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :updated},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :updated},
        {cl: :C88025, status: :updated}
      ]
      check_cl_results(results, expected) 
    end

    it "Create version 34: 2013" do
      version = 34
      results = execute_import(version, "2013-06-28", {sdtm: "2013-06-28", qs: "2013-06-28", cdash: "2013-06-28", adam: "2011-07-22"}, set_write_file)
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
        {cl: :C78735, status: :updated},
        {cl: :C88025, status: :no_change} 
      ]
      check_cl_results(results, expected) 
      check_count(version, 7334+3689+134+28)
    end

    it "Create version 35: 2013" do
      version = 35
      results = execute_import(version, "2013-10-04", {sdtm: "2013-10-04", qs: "2013-10-04", cdash: "2013-10-04", adam: "2011-07-22"}, set_write_file)
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
        {cl: :C78735, status: :no_change},    
        {cl: :C88025, status: :updated}
      ]
      check_cl_results(results, expected) 
    end

    it "Create version 36: 2013" do
      version = 36
      results = execute_import(version, "2013-12-20", {sdtm: "2013-12-20", qs: "2013-12-20", cdash: "2013-12-20", adam: "2011-07-22"}, set_write_file)
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

  end

  describe "2014" do

    it "Create version 37: 2014" do
      version = 37
      results = execute_import(version, "2014-03-28", {sdtm: "2014-03-28", qs: "2014-03-28", cdash: "2014-03-28", adam: "2011-07-22"}, set_write_file)
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
        {cl: :C78735, status: :no_change},  
        {cl: :C88025, status: :updated}
      ]
      check_cl_results(results, expected) 
    end

    it "Create version 38: 2014" do
      version = 38
      results = execute_import(version, "2014-06-27", {sdtm: "2014-06-27", qsft: "2014-06-27", cdash: "2014-03-28", adam: "2011-07-22"}, set_write_file)
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
      version = 39
      results = execute_import(version, "2014-09-26", {sdtm: "2014-09-26", qsft: "2014-09-26", cdash: "2014-09-26", adam: "2014-09-26"}, set_write_file)
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
      version = 40
      results = execute_import(version, "2014-10-06", {sdtm: "2014-10-06", qsft: "2014-09-26", cdash: "2014-09-26", adam: "2014-09-26"}, set_write_file)
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
      version = 41
      results = execute_import(version, "2014-12-19", {sdtm: "2014-12-19", coa: "2014-12-19", cdash: "2014-09-26", adam: "2014-09-26"}, set_write_file)
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
      check_count(version, 9524+5921+134+37)
    end

  end

  describe "2015" do

    it "Create version 42: 2015" do
      version = 42
      results = execute_import(version, "2015-03-27", {sdtm: "2015-03-27", coa: "2015-03-27", cdash: "2015-03-27", adam: "2014-09-26"}, set_write_file)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :updated},
        {cl: :C66785, status: :updated},
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

    it "Create version 43: 2015" do
      version = 43
      results = execute_import(version, "2015-06-26", {sdtm: "2015-06-26", qrs: "2015-06-26", cdash: "2015-03-27", adam: "2014-09-26"}, set_write_file)
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
        {cl: :C76351, status: :updated},
        {cl: :C78735, status: :no_change},
        {cl: :C88025, status: :updated}
      ]
      check_cl_results(results, expected) 
    end

    it "Create version 44: 2015" do
      version = 44
      results = execute_import(version, "2015-09-25", {sdtm: "2015-09-25", qrs: "2015-09-25", cdash: "2015-03-27", adam: "2014-09-26"}, set_write_file)
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

    it "Create version 45: 2015" do
      version = 45
      results = execute_import(version, "2015-12-18", {sdtm: "2015-12-18", cdash: "2015-03-27", adam: "2015-12-18"}, set_write_file)
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
      check_count(version, 17356+134+40)
    end

  end

  describe "2016" do

    it "Create version 46: 2016" do
      version = 46
      results = execute_import(version, "2016-03-25", {sdtm: "2016-03-25", cdash: "2016-03-25", adam: "2016-03-25"}, set_write_file)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :updated},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :updated},
        {cl: :C67153, status: :updated},
        {cl: :C71153, status: :no_change},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :updated},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :no_change},
        {cl: :C88025, status: :updated}
      ]
      check_cl_results(results, expected) 
    end

    it "Create version 47: 2016" do
      version = 47
      results = execute_import(version, "2016-06-24", {sdtm: "2016-06-24", cdash: "2016-03-25", adam: "2016-03-25"}, set_write_file)
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
        {cl: :C78735, status: :no_change},
        {cl: :C88025, status: :updated}
      ]
      check_cl_results(results, expected) 
    end

    it "Create version 48: 2016" do
      version = 48
      results = execute_import(version, "2016-09-30", {sdtm: "2016-09-30", cdash: "2016-09-30", adam: "2016-09-30"}, set_write_file)
      expected = [
        {cl: :C66737, status: :updated},
        {cl: :C66738, status: :updated},
        {cl: :C66785, status: :updated},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :updated},
        {cl: :C67153, status: :updated},
        {cl: :C71153, status: :no_change},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :updated},
        {cl: :C76351, status: :updated},
        {cl: :C78735, status: :no_change},
        {cl: :C88025, status: :deleted}
      ]
      check_cl_results(results, expected) 
    end

    it "Create version 49: 2016" do
      version = 49
      results = execute_import(version, "2016-12-16", {sdtm: "2016-12-16", cdash: "2016-12-16", adam: "2016-12-16"}, set_write_file)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :updated},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :updated},
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

  end

  describe "2017" do

    it "Create version 50: 2017" do
      version = 50
      results = execute_import(version, "2017-03-31", {sdtm: "2017-03-31", cdash: "2016-12-16", adam: "2017-03-31"}, set_write_file)
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
        {cl: :C78735, status: :updated}
      ]
      check_cl_results(results, expected) 
    end

    it "Create version 51: 2017" do
      version = 51
      results = execute_import(version, "2017-06-30", {sdtm: "2017-06-30", cdash: "2016-12-16", adam: "2017-03-31"}, set_write_file)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :updated},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :updated},
        {cl: :C67153, status: :updated},
        {cl: :C71153, status: :no_change},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :no_change},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :no_change}
      ]
      check_cl_results(results, expected)
      check_count(version, 21977+223+45-87)
    end

    it "Create version 52: 2017" do
      version = 52
      results = execute_import(version, "2017-09-29", {sdtm: "2017-09-29", cdash: "2017-09-29", adam: "2017-09-29"}, set_write_file)
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
        {cl: :C78735, status: :no_change}
      ]
      check_cl_results(results, expected) 
    end

    it "Create version 53: 2017" do
      version = 53
      results = execute_import(version, "2017-12-22", {sdtm: "2017-12-22", cdash: "2017-09-29", adam: "2017-09-29"}, set_write_file)
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
        {cl: :C74456, status: :updated},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :no_change}
      ]
      check_cl_results(results, expected) 
    end

  end

  describe "2018" do

    it "Create version 54: 2018" do
      version = 54
      results = execute_import(version, "2018-03-30", {sdtm: "2018-03-30", cdash: "2018-03-30", adam: "2017-09-29"}, set_write_file)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :updated},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :updated},
        {cl: :C67153, status: :updated},
        {cl: :C71153, status: :no_change},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :updated},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :updated}
      ]
      check_cl_results(results, expected) 
    end

    it "Create version 55: 2018" do
      version = 55
      results = execute_import(version, "2018-06-29", {sdtm: "2018-06-29", cdash: "2018-06-29", adam: "2017-09-29"}, set_write_file)
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
        {cl: :C74456, status: :updated},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :updated}
      ]
      check_cl_results(results, expected) 
    end

    it "Create version 56: 2018" do
      version = 56
      results = execute_import(version, "2018-09-28", {sdtm: "2018-09-28", cdash: "2018-09-28", adam: "2017-09-29"}, set_write_file)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :updated},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :updated},
        {cl: :C67153, status: :updated},
        {cl: :C71153, status: :no_change},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :updated},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :updated}
      ]
      check_cl_results(results, expected) 
    end

    it "Create version 57: 2018" do
      version = 57
      results = execute_import(version, "2018-12-21", {sdtm: "2018-12-21", cdash: "2018-12-21", adam: "2018-12-21"}, set_write_file)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :updated},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :updated},
        {cl: :C67153, status: :updated},
        {cl: :C71153, status: :no_change},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :updated},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :no_change}
      ]
      check_cl_results(results, expected) 
    end

  end

  describe "2019" do

    it "Create version 58: 2019" do
      version = 58
      results = execute_import(version, "2019-03-29", {sdtm: "2019-03-29", cdash: "2019-03-29", adam: "2019-03-29"}, set_write_file)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :updated},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :no_change},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :updated},
        {cl: :C67153, status: :updated},
        {cl: :C71153, status: :no_change},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :updated},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :no_change}
      ]
      check_cl_results(results, expected)
      check_count(version, 28590+289+50-155) # Duplicates (155) in CDASH C128690, C128689 
    end

    it "Create version 59: 2019" do
      version = 59
      results = execute_import(version, "2019-06-28", {sdtm: "2019-06-28", cdash: "2019-06-28", adam: "2019-03-29"}, set_write_file)
      expected = [
        {cl: :C66737, status: :no_change},
        {cl: :C66738, status: :updated},
        {cl: :C66785, status: :no_change},
        {cl: :C66787, status: :deleted},
        {cl: :C66790, status: :no_change},
        {cl: :C67152, status: :updated},
        {cl: :C67153, status: :no_change},
        {cl: :C71153, status: :updated},
        {cl: :C71620, status: :updated},
        {cl: :C74456, status: :updated},
        {cl: :C76351, status: :no_change},
        {cl: :C78735, status: :no_change}
      ]
      check_cl_results(results, expected) 
      check_count(version, 29095+293+50-159) # Duplicates (159) in CDASH C128690, C128689 
    end

  end

end