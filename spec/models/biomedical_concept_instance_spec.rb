require 'rails_helper'

describe BiomedicalConceptInstance do

  include DataHelpers
  include SparqlHelpers

  def sub_dir
    return "models/biomedical_concept_instance"
  end

  describe "Validity Tests" do

    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    it "allows validity of the object to be checked - error" do
      result = BiomedicalConceptInstance.new
      result.valid?
      expect(result.errors.count).to eq(3)
      expect(result.errors.full_messages[0]).to eq("Uri can't be blank")
      expect(result.errors.full_messages[1]).to eq("Has identifier empty object")
      expect(result.errors.full_messages[2]).to eq("Has state empty object")
      expect(result.valid?).to eq(false)
    end

    it "allows validity of the object to be checked" do
      result = BiomedicalConceptInstance.new
      ra = IsoRegistrationAuthority.find(Uri.new(uri:"http://www.assero.co.uk/RA#DUNS123456789"))
      result.has_state = IsoRegistrationStateV2.new
      result.has_state.uri = "na"
      result.has_state.by_authority = ra
      result.has_identifier = IsoScopedIdentifierV2.new
      result.has_identifier.uri = "na"
      result.has_identifier.identifier = "HELLO WORLD"
      result.has_identifier.semantic_version = "0.1.0"
      result.uri = "xxx"
      valid = result.valid?
      expect(result.errors.count).to eq(0)
      expect(valid).to eq(true)
    end

  end

  describe "Find Tests" do

    before :all do
      load_files(schema_files, [])
      load_cdisc_term_versions(1..62)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("biomedical_concept_templates.ttl")
      load_data_file_into_triple_store("biomedical_concept_instances.ttl")
    end

    it "allows a BC to be found" do
      item = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      check_file_actual_expected(item.to_h, sub_dir, "find_expected_1.yaml", equate_method: :hash_equal)
    end

    it "allows a BC to be found, full" do
      item = BiomedicalConceptInstance.find_full(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      check_file_actual_expected(item.to_h, sub_dir, "find_full_expected_1.yaml", equate_method: :hash_equal)
    end

    it "allows a BC to be found, minimum" do
      item = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      check_file_actual_expected(item.to_h, sub_dir, "find_minimum_expected_1.yaml", equate_method: :hash_equal)
    end

    it "get the properties, with references" do
      instance = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      check_file_actual_expected(instance.get_properties(true), sub_dir, "get_properties_with_references_expected.yaml", equate_method: :hash_equal)
    end

    it "get the properties, without references" do
      instance = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      check_file_actual_expected(instance.get_properties, sub_dir, "get_properties_with_no_references_expected.yaml", equate_method: :hash_equal)
    end

  end

  describe "Create Tests" do

    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("biomedical_concept_templates.ttl")
    end

    it "creates from a template, no errors" do
      template = BiomedicalConceptTemplate.find_full(Uri.new(uri: "http://www.s-cubed.dk/BASIC_OBS/V1#BCT"))
      item = BiomedicalConceptInstance.create_from_template({label: "New BC", identifier: "XXX"}, template)
      check_file_actual_expected(item.to_h, sub_dir, "create_from_template_expected_1.yaml", equate_method: :hash_equal)
    end

    it "creates from a template, label error" do
      template = BiomedicalConceptTemplate.find_full(Uri.new(uri: "http://www.s-cubed.dk/BASIC_OBS/V1#BCT"))
      item = BiomedicalConceptInstance.create_from_template({label: "New BC±", identifier: "XXX1"}, template)
      expect(item.errors.count).to eq(1)
      expect(item.errors.full_messages.to_sentence).to eq("Label contains invalid characters")
    end

    it "creates from a template, identifier error" do
      template = BiomedicalConceptTemplate.find_full(Uri.new(uri: "http://www.s-cubed.dk/BASIC_OBS/V1#BCT"))
      item = BiomedicalConceptInstance.create_from_template({label: "New BC", identifier: "XXX%"}, template)
      expect(item.errors.count).to eq(1)
      expect(item.errors.full_messages.to_sentence).to eq("Has identifier - identifier - contains invalid characters")
    end

  end

  describe "Other Tests" do

    before :all do
      load_files(schema_files, [])
      load_cdisc_term_versions(1..62)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("biomedical_concept_templates.ttl")
      load_data_file_into_triple_store("biomedical_concept_instances.ttl")
    end

    it "allows an object to be exported as SPARQL" do
      item = BiomedicalConceptInstance.find_full(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      sparql = Sparql::Update.new
      item.to_sparql(sparql, true)
    #Xwrite_text_file_2(sparql.to_create_sparql, sub_dir, "to_sparql_expected_1.txt")
      check_sparql_no_file(sparql.to_create_sparql, "to_sparql_expected_1.txt")
  describe "Main Tests" do

    before :all do
      load_files(schema_files, [])
      load_cdisc_term_versions(1..62)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("biomedical_concept_templates.ttl")
      load_data_file_into_triple_store("biomedical_concept_instances.ttl")
    end

    it "allows a BC to be found" do
      item = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      check_file_actual_expected(item.to_h, sub_dir, "find_expected_1.yaml", equate_method: :hash_equal)
    end

    it "allows a BC to be found, full" do
      item = BiomedicalConceptInstance.find_full(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      check_file_actual_expected(item.to_h, sub_dir, "find_full_expected_1.yaml", equate_method: :hash_equal)
    end

    it "allows a BC to be found, minimum" do
      item = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      check_file_actual_expected(item.to_h, sub_dir, "find_minimum_expected_1.yaml", equate_method: :hash_equal)
    end

    it "allows an object to be exported as SPARQL" do
      item = BiomedicalConceptInstance.find_full(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      sparql = Sparql::Update.new
      item.to_sparql(sparql, true)
    #Xwrite_text_file_2(sparql.to_create_sparql, sub_dir, "to_sparql_expected_1.txt")
      check_sparql_no_file(sparql.to_create_sparql, "to_sparql_expected_1.txt")
    end

    it "get the properties, with references" do
      instance = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      check_file_actual_expected(instance.get_properties(true), sub_dir, "get_properties_with_references_expected.yaml", equate_method: :hash_equal)
    end

    it "get the properties, without references" do
      instance = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      check_file_actual_expected(instance.get_properties, sub_dir, "get_properties_with_no_references_expected.yaml", equate_method: :hash_equal)
    end

  end

  describe "Path Tests" do

    it "returns read path" do
      check_file_actual_expected(BiomedicalConceptInstance.read_paths, sub_dir, "read_paths_expected.yaml", equate_method: :hash_equal)
    end

    it "returns export path" do
      check_file_actual_expected(BiomedicalConceptInstance.export_paths, sub_dir, "export_paths_expected.yaml", equate_method: :hash_equal)
    end

    it "returns delete path" do
      check_file_actual_expected(BiomedicalConceptInstance.delete_paths, sub_dir, "delete_paths_expected.yaml", equate_method: :hash_equal)
    end

  end
end
