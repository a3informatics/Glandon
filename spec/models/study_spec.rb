require 'rails_helper'

describe "Study" do

  include DataHelpers
  include PublicFileHelpers
  include SparqlHelpers
  include ThesauriHelpers
  include IsoManagedHelpers

  def sub_dir
    return "models/study"
  end

  describe "basic tests" do

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
    end

    after :each do
    end

    it "create an instance" do
      actual = Study.create(identifier: "XXX")
      expect(actual.scoped_identifier).to eq("XXX")
      expect(actual.version).to eq(1)
      expect(actual.semantic_version).to eq("0.1.0")
      expect(actual.implements).to eq(nil)
      actual = Study.find_minimum(actual.uri)
      expect(actual.scoped_identifier).to eq("XXX")
      expect(actual.version).to eq(1)
      expect(actual.semantic_version).to eq("0.1.0")
      expect(actual.implements).to eq(nil)
      check_dates(actual, sub_dir, "create_expected_1.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(actual.to_h, sub_dir, "create_expected_1.yaml", equate_method: :hash_equal)
    end

    it "simple update I" do
      actual = Study.create(identifier: "XXX")
      actual = Study.find_minimum(actual.uri)
      actual.description = "New description"
      actual.save
      actual = Study.find_minimum(actual.uri)
      check_dates(actual, sub_dir, "update_expected_1.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(actual.to_h, sub_dir, "update_expected_1.yaml", equate_method: :hash_equal)
      actual.description = "Really new description"
      actual.save
      actual = Study.find_with_properties(actual.uri)
      expect(actual.description).to eq("Really new description")
    end

    it "simple update II" do
      actual = Study.create(identifier: "XXX")
      actual = Study.find_minimum(actual.uri)
      actual.label = "New label"
      actual.save
      actual = Study.find_minimum(actual.uri)
      check_dates(actual, sub_dir, "update_expected_3.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(actual.to_h, sub_dir, "update_expected_3.yaml", equate_method: :hash_equal)
      actual.label = "Really new label"
      actual.save
      check_dates(actual, sub_dir, "update_expected_4.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(actual.to_h, sub_dir, "update_expected_4.yaml", equate_method: :hash_equal)
    end

    it "Study example" do
      p1 = Protocol.create(identifier: "XXX", title: "Protocol title")
      s1 = Study.create(identifier: "MY STUDY", label: "My Study", description: "Some def", implements: p1.uri)
      s1.implements = p1.uri
      s1.save
      actual = Study.find_minimum(s1.uri)
      protocol = actual.implements_links
      protocol = Protocol.find_minimum(actual.implements_links)
      expect(actual.scoped_identifier).to eq("MY STUDY")
      check_dates(actual, sub_dir, "study_expected_1.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(actual.to_h, sub_dir, "study_expected_1.yaml", equate_method: :hash_equal)
      actual = actual.protocol
      expect(actual.uri).to eq(p1.uri)
    end

  end

  describe "method tests" do

    before :all do
      load_files(schema_files, [])
      load_cdisc_term_versions(1..62)
      load_data_file_into_triple_store("mdr_transcelerate_identification.ttl")
      load_data_file_into_triple_store("hackathon_thesaurus.ttl")
      load_data_file_into_triple_store("hackathon_tas.ttl")
      load_data_file_into_triple_store("hackathon_indications.ttl")
      load_data_file_into_triple_store("hackathon_endpoints.ttl")
      load_data_file_into_triple_store("hackathon_parameters.ttl")
      load_data_file_into_triple_store("hackathon_protocols.ttl")
      load_data_file_into_triple_store("hackathon_bc_instances.ttl")
      load_data_file_into_triple_store("hackathon_bc_templates.ttl")
      load_data_file_into_triple_store("hackathon_form_cibic.ttl")
      load_data_file_into_triple_store("hackathon_form_dad.ttl")
      load_data_file_into_triple_store("hackathon_form_lab_samples.ttl")
      load_data_file_into_triple_store("hackathon_form_ecg.ttl")      
    end

    it "find protocol" do
      pr = Protocol.find_minimum(Uri.new(uri: "http://www.transceleratebiopharmainc.com/LY246708/V1#PR"))
      study = Study.create(identifier: "MY STUDY", label: "My Study", description: "Some def", implements: pr.uri)
      study = Study.find_minimum(study.uri)
      actual = study.protocol
      expect(actual.uri).to eq(pr.uri)
    end

    it "soa" do
      pr = Protocol.find_minimum(Uri.new(uri: "http://www.transceleratebiopharmainc.com/LY246708/V1#PR"))
      study = Study.create(identifier: "MY STUDY", label: "My Study", description: "Some def", implements: pr.uri)
      study = Study.find_minimum(study.uri)
      actual = study.soa
      check_file_actual_expected(actual, sub_dir, "soa_expected_1.yaml", equate_method: :hash_equal)
    end

    it "visits" do
      pr = Protocol.find_minimum(Uri.new(uri: "http://www.transceleratebiopharmainc.com/LY246708/V1#PR"))
      study = Study.create(identifier: "MY STUDY", label: "My Study", description: "Some def", implements: pr.uri)
      study = Study.find_minimum(study.uri)
      actual = study.visits
      check_file_actual_expected(actual, sub_dir, "visits_expected_1.yaml", equate_method: :hash_equal)
    end

  end

  
  describe "method tests" do

    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_transcelerate_identification.ttl")
    end

    it "create datatypes" do
      results = []
      s_1 = Study.new(label: "Study One", description: "A study into the effects of coding.")
      s_2 = Study.new(label: "Study Two", description: "A study into the effects of not coding.")
      s_3 = Study.new(label: "Study Three", description: "A study into the effects of coding late into the night.")
      s_1.set_initial("STUDY ONE")
      s_2.set_initial("STUDY TWO")
      s_3.set_initial("STUDY THREE")
      sparql = Sparql::Update.new
      sparql.default_namespace(s_1.uri.namespace)
      [s_1, s_2, s_3].each{|x| x.to_sparql(sparql, true)}
      full_path = sparql.to_file
    #Xcopy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "study_history.ttl")
    end

  end

end