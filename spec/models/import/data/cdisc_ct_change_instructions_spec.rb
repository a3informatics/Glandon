require 'rails_helper'

describe Import::ChangeInstruction do
	
	include DataHelpers
  include ImportHelpers
  include PublicFileHelpers
  include SparqlHelpers
  include CdiscCtHelpers

	def sub_dir
    return "models/import/data/cdisc/ct/changes"
  end

  def set_write_file
    true
  end

  def simple_setup
    @object = Import::ChangeInstruction.new
    @job = Background.new
    @job.save
    @object.background_id = @job.id
    @object.save
  end

  def load(filenames, ct_version, create_file)
    files = []
    simple_setup
    filenames.each_with_index {|f, index| files << db_load_file_path("cdisc/ct", filenames[index])}
    params = 
    {
      files: files, current_id: Uri.new(uri: "http://www.cdisc.org/CT/V#{ct_version}#TH").to_id, job: @job
    }
    result = @object.import(params)
    filename = "cdisc_change_instructions_#{@object.id}_errors.yml"
byebug
    expect(public_file_does_not_exist?("test", filename)).to eq(true)
    filename = "cdisc_change_instructions_#{@object.id}_load.ttl"
    expect(public_file_exists?("test", filename)).to eq(true)
    copy_file_from_public_files("test", filename, sub_dir)
    local_filename = "change_instructions_v#{ct_version}.ttl"
    copy_file_from_public_files_rename("test", filename, sub_dir, local_filename)
    check_ttl_fix(filename, local_filename, {last_change_date: true})
    expect(@job.status).to eq("Complete")
    delete_data_file(sub_dir, filename)
  end

  def execute_import(release_date, reqd_files, create_file=false)
    current_version = @date_to_version_map.index(release_date) + 1
    puts colourize("Version: #{current_version}", "green")
    files = []
    base_path = "changes/#{release_date}"
    file_pattern = 
    {
      adam: "#{base_path}/ADaM Terminology Changes #{release_date}",
      cdash: "#{base_path}/CDASH Terminology Changes #{release_date}", 
      coa: "#{base_path}/COA Terminology Changes #{release_date}", 
      sdtm: "#{base_path}/SDTM Terminology Changes #{release_date}", 
      qrs: "#{base_path}/QRS Terminology Changes #{release_date}", 
      qs: "#{base_path}/QS Terminology Changes #{release_date}",
      qsft: "#{base_path}/QS-FT Terminology Changes #{release_date}",
      send: "#{base_path}/SEND Terminology Changes #{release_date}",
      protocol: "#{base_path}/Protocol Terminology Changes #{release_date}"
    }
    reqd_files.each {|k, v| files << "#{file_pattern[k]}.xlsx" if reqd_files.key?(k)}
    results = load(files, current_version, create_file)
  end

	before :all do
    load_files(schema_files, [])
    load_data_file_into_triple_store("mdr_identification.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
    load_cdisc_term_versions(CdiscCtHelpers.version_range)
    Import.destroy_all
    delete_all_public_test_files
    @date_to_version_map = CdiscCtHelpers.date_version_map
  end

  after :all do
    Import.destroy_all
    delete_all_public_test_files
  end

  it "2016-03-25" do
    release_date = "2016-03-25"
    execute_import(release_date, {sdtm: true}, set_write_file)
  end

end