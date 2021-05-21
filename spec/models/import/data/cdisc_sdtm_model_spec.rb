require 'rails_helper'
require 'tabulation/column'

describe "Import CDISC SDTM Model Data" do

  include DataHelpers
  include PublicFileHelpers
  include SparqlHelpers
  include IsoHelpers

  def sub_dir
    return "models/import/data/cdisc/sdtm_model"
  end

  def load_version(version)
    load_local_file_into_triple_store(sub_dir, "SDTM_MODEL_V#{version}.ttl")
  end

  def load_versions(range)
    range.each {|n| load_version(n)}
  end

  describe "all versions" do

    before :all do
      create_maps
    end

    after :all do
      #
    end

    before :each do
      IsoHelpers.clear_cache
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_2.ttl")
      load_data_file_into_triple_store("canonical_references.ttl")
      load_data_file_into_triple_store("canonical_references_migration_1.ttl")
      load_data_file_into_triple_store("canonical_references_migration_2.ttl")
      setup
    end

    after :each do
      Import.destroy_all
      delete_all_public_test_files
    end

    # ---------- IMPORTANT SWITCHES ----------

    def set_write_file
      false
    end

    # ----------------------------------------

    def excel_filename(version)
      "SDTM_MODEL_V#{version}.ttl"
    end

    def setup
      @object = Import.new(:type => "Import::SdtmModel") # Use this rather than above.
      @job = Background.new
      @job.save
      @object.background_id = @job.id
      @object.save
    end

    def set_params(version, date, files)
      sv = @date_to_info_map[version-1][:semantic_version]
      file_type = !files.empty? ? "0" : "3"
      { version: "#{version}", date: "#{date}", files: files, version_label: "#{date} Release", label: "SDTM Model",
        semantic_version: "#{sv}", job: @job, file_type: file_type}
    end

    def dump_errors_if_present(filename, version, date)
      full_path = Rails.root.join "public/test/#{filename}"
      return if !File.exists?(full_path)
      errors = YAML.load_file(full_path)
      puts colourize("***** ERRORS ON IMPORT - V#{version} for #{date} *****", "red")
      puts errors
    end

    def process_model(version, date, files, copy_file=false)
      params = set_params(version, date, files)
      result = @object.import(params)
      filename = "cdisc_sdtm_model_#{@object.id}_errors.yml"
      dump_errors_if_present(filename, version, date)
      expect(public_file_does_not_exist?("test", filename)).to eq(true)
      filename = "cdisc_sdtm_model_#{@object.id}_load.ttl"
      expect(public_file_exists?("test", filename)).to eq(true)
      copy_file_from_public_files("test", filename, sub_dir)
      target_filename = excel_filename(version)
      if copy_file
        puts colourize("***** Warning! Copying result file to '#{target_filename}'. *****", "red")
        copy_file_from_public_files_rename("test", filename, sub_dir, target_filename)
      end
      check_ttl_fix(filename, target_filename, {last_change_date: true})
      expect(@job.status).to eq("Complete")
      delete_data_file(sub_dir, filename)
    end

    def process_load_and_compare(filenames, date, version, create_file=false)
      files = []
      filenames.each_with_index {|f, index| files << db_load_file_path("cdisc/sdtm_model", filenames[index])}
      puts colourize("File count: #{files.count}", "green")
      process_model(version, date, files, create_file)
    end

    def execute_import(issue_date, create_file=false)
      files = []
      version_index = @date_to_version_map.index(issue_date)
      current_version = version_index + 1
      puts colourize("Version: #{current_version}, Date: #{issue_date}", "green")
      load_versions(1..(current_version-1))
      files = [@date_to_filename_map[version_index]]
      @object.file_type = 0
      puts colourize("Loading from Excel", "green")
      @object.save
      results = process_load_and_compare(files, issue_date, current_version, create_file)
    end

    def create_maps
      @date_to_version_map = [
        "2008-11-12", "2012-07-16", "2013-11-26", "2016-07-05", "2017-11-16", "2018-11-20", "2019-09-17"
      ]

      @date_to_filename_map = [
        "sdtm_1-2.xlsx", "sdtm_1-3.xlsx", "sdtm_1-4.xlsx", "sdtm_1-5.xlsx", "sdtm_1-6.xlsx", "sdtm_1-7.xlsx", "sdtm_1-8.xlsx"
      ]

      @date_to_info_map = [
        {semantic_version: "1.2.0"},
        {semantic_version: "1.3.0"},
        {semantic_version: "1.4.0"},
        {semantic_version: "1.5.0"},
        {semantic_version: "1.6.0"},
        {semantic_version: "1.7.0"},
        {semantic_version: "1.8.0"}
      ]
    end

    it "Base create, 1-2", :import_data => 'slow' do
      release_date = "2008-11-12"
      results = execute_import(release_date, set_write_file)
    end

    it "1-3", :import_data => 'slow' do
      release_date = "2012-07-16"
      results = execute_import(release_date, set_write_file)
    end

    it "1-4", :import_data => 'slow' do
      release_date = "2013-11-26"
      results = execute_import(release_date, set_write_file)
    end

    it "1-5", :import_data => 'slow' do
      release_date = "2016-07-05"
      results = execute_import(release_date, set_write_file)
    end

    it "1-6", :import_data => 'slow' do
      release_date = "2017-11-16"
      results = execute_import(release_date, set_write_file)
    end

    it "1-7", :import_data => 'slow' do
      release_date = "2018-11-20"
      results = execute_import(release_date, set_write_file)
    end

    it "1-8", :import_data => 'slow' do
      release_date = "2019-09-17"
      results = execute_import(release_date, set_write_file)
    end

  end

  describe "Simple Statistics" do

    before :all do
      IsoHelpers.clear_cache
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_2.ttl")
      load_data_file_into_triple_store("canonical_references.ttl")
      load_versions(1..7)
    end

    it "check missing classified as references" do
      query_string = %Q{
        SELECT ?s ?l WHERE
        {
          ?s rdf:type bd:SdtmClassVariable  .
          ?s bd:name ?l .
          FILTER ( NOT EXISTS { ?s bd:classifiedAs ?o })
        } ORDER BY ?s
      }
      query_results = Sparql::Query.new.query(query_string, "", [:bd])
      result = query_results.by_object_set([:s, :l]).map{|x| {uri: x[:s].to_s, name: x[:l]}}
      check_file_actual_expected(result, sub_dir, "classified_as_check_1.yaml", equate_method: :hash_equal)
    end

    it "check classified as references" do
      query_string = %Q{
        SELECT ?s ?l ?c WHERE
        {
          ?s rdf:type bd:SdtmClassVariable  .
          ?s bd:name ?l .
          ?s bd:classifiedAs/isoC:prefLabel ?c .
        } ORDER BY ?s
      }
      query_results = Sparql::Query.new.query(query_string, "", [:bd, :isoC])
      result = query_results.by_object_set([:s, :l, :c]).map{|x| {uri: x[:s].to_s, name: x[:l], classified_as: x[:c]}}
      check_file_actual_expected(result, sub_dir, "classified_as_check_2.yaml", equate_method: :hash_equal)
    end

  end

end
