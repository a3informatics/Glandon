require 'rails_helper'

describe BiomedicalConceptInstance do

  include DataHelpers
  include SparqlHelpers
  include IsoManagedHelpers

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
      load_cdisc_term_versions(1..20)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_test_bc_template_and_instances
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
      load_test_bc_template_and_instances
      load_data_file_into_triple_store("complex_datatypes.ttl")
    end

    it "creates from a template, no errors" do
      template = BiomedicalConceptTemplate.find_full(Uri.new(uri: "http://www.s-cubed.dk/BASIC_OBS_PQR/V1#BCT"))
      item = BiomedicalConceptInstance.create_from_template({label: "New BC", identifier: "XXX"}, template)
      check_dates(item, sub_dir, "create_from_template_expected_1.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(item.to_h, sub_dir, "create_from_template_expected_1.yaml", equate_method: :hash_equal)
    end

    it "creates from a template, label error" do
      template = BiomedicalConceptTemplate.find_full(Uri.new(uri: "http://www.s-cubed.dk/BASIC_OBS_PQR/V1#BCT"))
      item = BiomedicalConceptInstance.create_from_template({label: "New BC±", identifier: "XXX1"}, template)
      expect(item.errors.count).to eq(1)
      expect(item.errors.full_messages.to_sentence).to eq("Label contains invalid characters")
    end

    it "creates from a template, identifier error" do
      template = BiomedicalConceptTemplate.find_full(Uri.new(uri: "http://www.s-cubed.dk/BASIC_OBS_PQR/V1#BCT"))
      item = BiomedicalConceptInstance.create_from_template({label: "New BC", identifier: "XXX%"}, template)
      expect(item.errors.count).to eq(1)
      expect(item.errors.full_messages.to_sentence).to eq("Has identifier - identifier - contains invalid characters")
    end

  end

  describe "Update Tests" do

    before :each do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_test_bc_template_and_instances
    end

    it "update, no clone, no errors" do
      instance = BiomedicalConceptInstance.find_full(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      uri = Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI_BCI1_BCCDTCD_BCPcode")
      property = BiomedicalConcept::PropertyX.find(uri)
      expect(property.prompt_text).to eq("")
      property = instance.update_property({property_id: property.id, prompt_text: "XXX"})
      expect(property.errors.count).to eq(0)
      property = BiomedicalConcept::PropertyX.find(uri)
      check_file_actual_expected(property.to_h, sub_dir, "update_property_expected_1.yaml", equate_method: :hash_equal)
    end

    it "update, clone, no errors" do
      bc = BiomedicalConceptInstance.create(label: "this is XXX", identifier: "XXX")
      bc.has_item_push(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI_BCI1"))
      bc.save
      bc = BiomedicalConceptInstance.find_full(bc.uri)
      instance = BiomedicalConceptInstance.find_full(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      uri = Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI_BCI1_BCCDTCD_BCPcode")
      property = BiomedicalConcept::PropertyX.find(uri)
      expect(property.prompt_text).to eq("")
      property = bc.update_property({property_id: property.id, prompt_text: "New object and updated text"})
      expect(bc.errors.count).to eq(0)
      property = BiomedicalConcept::PropertyX.find(property.uri)
      check_file_actual_expected(property.to_h, sub_dir, "update_property_expected_5.yaml", equate_method: :hash_equal)
    end

    it "update multiple fields, no clone, no errors" do
      instance = BiomedicalConceptInstance.find_full(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      uri = Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI_BCI1_BCCDTCD_BCPcode")
      property = BiomedicalConcept::PropertyX.find(uri)
      property = instance.update_property({property_id: property.id, prompt_text: "XXX", question_text: "YYY", format: "12"})
      expect(property.errors.count).to eq(0)
      property = BiomedicalConcept::PropertyX.find(uri)
      check_file_actual_expected(property.to_h, sub_dir, "update_property_expected_2.yaml", equate_method: :hash_equal)
    end

    it "update, errors, field disallowed" do
      instance = BiomedicalConceptInstance.find_full(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      uri = Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI_BCI1_BCCDTCD_BCPcode")
      property = BiomedicalConcept::PropertyX.find(uri)
      expect{instance.update_property({property_id: property.id, label: "ZZZ"})}.to raise_error(Errors::ApplicationLogicError, "No matching property for 'label' found.")
    end

    it "update multiple fields, item, no clone, no errors" do
      instance = BiomedicalConceptInstance.find_full(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      uri_p = Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI_BCI1_BCCDTCD_BCPcode")
      uri_i = Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI_BCI1")
      property = BiomedicalConcept::PropertyX.find(uri_p)
      instance.update_property({property_id: property.id, enabled: true, collect: false})
      item = BiomedicalConcept::Item.find(uri_i)
      check_file_actual_expected(item.to_h, sub_dir, "update_property_expected_3.yaml", equate_method: :hash_equal)      
    end

    it "update multiple fields, item, no clone, no errors" do
      instance = BiomedicalConceptInstance.find_full(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      uri_p = Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI_BCI1_BCCDTCD_BCPcode")
      uri_i = Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI_BCI1")
      property = BiomedicalConcept::PropertyX.find(uri_p)
      instance.update_property({property_id: property.id, enabled: true, collect: true})
      item = BiomedicalConcept::Item.find(uri_i)
      check_file_actual_expected(item.to_h, sub_dir, "update_property_expected_4.yaml", equate_method: :hash_equal)      
    end

    it "update property, validation errors" do
      instance = BiomedicalConceptInstance.find_full(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      uri = Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI_BCI1_BCCDTCD_BCPcode")
      property = BiomedicalConcept::PropertyX.find(uri)
      property = instance.update_property({property_id: property.id, question_text: "ZZZ±"})
      expect(property.errors.count).to eq(1)
      expect(property.errors.full_messages.to_sentence).to eq("Question text contains invalid characters")
    end

    it "update item, validation errors" do
      instance = BiomedicalConceptInstance.find_full(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      uri = Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI_BCI1_BCCDTCD_BCPcode")
      uri_i = Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI_BCI1")
      property = BiomedicalConcept::PropertyX.find(uri)
      property = instance.update_property({property_id: property.id, enabled: "ZZZ±"})
      expect(property.errors.count).to eq(1)
      expect(property.errors.full_messages.to_sentence).to eq("Enabled contains an invalid boolean value")
    end

    it "update multiple, errors" do
      instance = BiomedicalConceptInstance.find_full(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      uri_p = Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI_BCI1_BCCDTCD_BCPcode")
      uri_i = Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI_BCI1")
      property = BiomedicalConcept::PropertyX.find(uri_p)
      expect{instance.update_property({property_id: property.id, enabled: true, question_text: "something nice"})}.to raise_error(Errors::ApplicationLogicError, "Attempting to update multiple children '{:item=>{:enabled=>true}, :property=>{:question_text=>\"something nice\"}}'.")
    end

    it "update, empty parameters, errors" do
      instance = BiomedicalConceptInstance.find_full(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      uri_p = Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI_BCI1_BCCDTCD_BCPcode")
      uri_i = Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI_BCI1")
      property = BiomedicalConcept::PropertyX.find(uri_p)
      expect(ConsoleLogger).to receive(:info).with("BiomedicalConceptInstance", "update_property", "Attempt to update property with empty parameters.")
      result = instance.update_property({property_id: property.id})
    end

  end

  describe "Update Tests, Coded" do

    before :each do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_test_bc_template_and_instances
      load_cdisc_term_versions(1..20)
    end

    it "update, no clone, no errors, 3 updates" do
      cl = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C74457/V10#C74457"))
      cli_1 = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C74457/V10#C74457_C41259"))
      cli_2 = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C74457/V10#C74457_C41260"))
      cli_3 = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C74457/V10#C74457_C41219"))
      instance = BiomedicalConceptInstance.find_full(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      uri = Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI_BCI11_BCCDTPQR_BCPcode")
      property = BiomedicalConcept::PropertyX.find(uri)
      property = instance.update_property({property_id: property.id, has_coded_value: [{id: cli_1.id, context_id: cl.id}]})
      expect(property.errors.count).to eq(0)
      instance = BiomedicalConceptInstance.find_full(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      check_file_actual_expected(instance.to_h, sub_dir, "update_property_coded_expected_1.yaml", equate_method: :hash_equal)
      property = BiomedicalConcept::PropertyX.find(uri)
      property = instance.update_property({property_id: property.id, has_coded_value: [{id: cli_1.id, context_id: cl.id}, {id: cli_2.id, context_id: cl.id}]})
      expect(property.errors.count).to eq(0)
      instance = BiomedicalConceptInstance.find_full(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      check_file_actual_expected(instance.to_h, sub_dir, "update_property_coded_expected_2.yaml", equate_method: :hash_equal)
      property = BiomedicalConcept::PropertyX.find(uri)
      property = instance.update_property({property_id: property.id, has_coded_value: [{id: cli_3.id, context_id: cl.id}, {id: cli_2.id, context_id: cl.id}, {id: cli_1.id, context_id: cl.id}]})
      expect(property.errors.count).to eq(0)
      instance = BiomedicalConceptInstance.find_full(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      check_file_actual_expected(instance.to_h, sub_dir, "update_property_coded_expected_3.yaml", equate_method: :hash_equal)
    end

  end

  describe "Clone Tests" do

    before :each do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_test_bc_template_and_instances
    end

    it "clone" do
      instance = BiomedicalConceptInstance.find_with_properties(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      result = instance.clone
      check_file_actual_expected(result.to_h, sub_dir, "clone_expected_1.yaml", equate_method: :hash_equal)
    end

  end 

  describe "Other Tests" do

    before :all do
      load_files(schema_files, [])
      load_cdisc_term_versions(1..20)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_test_bc_template_and_instances
    end

    it "allows an object to be exported as SPARQL" do
      item = BiomedicalConceptInstance.find_full(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      sparql = Sparql::Update.new
      item.to_sparql(sparql, true)
    #Xwrite_text_file_2(sparql.to_create_sparql, sub_dir, "to_sparql_expected_1.txt")
      check_sparql_no_file(sparql.to_create_sparql, "to_sparql_expected_1.txt")
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

  describe "Dependency Tests" do

    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_test_bc_template_and_instances
    end

    it "dependency paths" do
      paths = BiomedicalConceptInstance.dependency_paths
      check_file_actual_expected(paths, sub_dir, "dependency_paths_expected_1.yaml", equate_method: :hash_equal)
    end

    it "dependencies" do
      expect(Form).to receive(:dependency_paths).and_return([])
      item = BiomedicalConceptInstance.find_full(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      results = item.dependency_required_by
      expect(results).to eq([])
    end

  end

end
