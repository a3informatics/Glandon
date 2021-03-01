require 'rails_helper'

describe Import::Crf do
	
	include DataHelpers
  include ImportHelpers
  include PublicFileHelpers
  include SparqlHelpers
  include SecureRandomHelpers
  
	def sub_dir
    return "models/import/data/cdisc/crf"
  end

  def simple_setup
    @object = Import::Crf.new
    @job = Background.new
    @job.save
    @object.background_id = @job.id
    @object.save
  end

	before :all do
    IsoHelpers.clear_cache
    load_files(schema_files, [])
    load_data_file_into_triple_store("mdr_identification.ttl")
    load_cdisc_term_versions(1..68)
    @th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V68#TH"))
    @th.has_state.make_current
  end

  before :each do
    Import.destroy_all
    delete_all_public_test_files
  end

  after :each do
    Import.destroy_all
    delete_all_public_test_files
  end

  it "CDISC aCRF Library - DM" do
    simple_setup
    full_path = test_file_path(sub_dir, "DM.xml")
    @object.import({identifier: "DM", files: [full_path], file_type: "1", job: @job})
    result = Import.find(@object.id)
    filename = File.basename(result.output_file)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "FORM_DM.ttl")
    copy_file_from_public_files("test", filename, sub_dir)
    check_ttl_fix(filename, "FORM_DM.ttl", {last_change_date: true, creation_date: true})
    delete_data_file(sub_dir, filename)
  end

  it "CDISC aCRF Library - VS" do
    simple_setup
    full_path = test_file_path(sub_dir, "VS.xml")
    @object.import({identifier: "VS_HORIZONTAL", files: [full_path], file_type: "1", job: @job})
    result = Import.find(@object.id)
    filename = File.basename(result.output_file)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "FORM_VS.ttl")
    copy_file_from_public_files("test", filename, sub_dir)
    check_ttl_fix(filename, "FORM_VS.ttl", {last_change_date: true, creation_date: true})
    delete_data_file(sub_dir, filename)
  end

  it "CDISC aCRF Library - PE" do
    simple_setup
    full_path = test_file_path(sub_dir, "PE.xml")
    @object.import({identifier: "PE", files: [full_path], file_type: "1", job: @job})
    result = Import.find(@object.id)
    filename = File.basename(result.output_file)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "FORM_PE.ttl")
    copy_file_from_public_files("test", filename, sub_dir)
    check_ttl_fix(filename, "FORM_PE.ttl", {last_change_date: true, creation_date: true})
    delete_data_file(sub_dir, filename)
  end

end