require 'rails_helper'

describe Form do

	include DataHelpers

  def sub_dir
    return "models"
  end

  before :all do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Basic.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Data.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_schema_file_into_triple_store("BusinessOperational.ttl")
    load_schema_file_into_triple_store("BusinessForm.ttl")
    load_test_file_into_triple_store("iso_namespace_real.ttl")
    load_test_file_into_triple_store("form_example_dm1.ttl")
    load_test_file_into_triple_store("form_example_vs_baseline_new.ttl")
    load_test_file_into_triple_store("form_example_general.ttl")
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
  end

  it "validates a valid object" do
    result = Form.new
    ra = IsoRegistrationAuthority.new
    ra.number = "123456789"
    ra.scheme = "DUNS"
    ra.namespace = IsoNamespace.find("NS-ACME")
    result.registrationState.registrationAuthority = ra
    si = IsoScopedIdentifier.new
    si.identifier = "X FACTOR"
    result.scopedIdentifier = si
    result.valid?
    expect(result.valid?).to eq(true)
  end
  
  it "allows a form to be found" do
    item = Form.find("F-ACME_T2", "http://www.assero.co.uk/MDRForms/ACME/V1")
    expect(item.identifier).to eq("T2")
  end

  it "allows a form to be found, BC based" do
    result = Form.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
    #write_hash_to_yaml_file_2(result.to_json, sub_dir, "form_example_vs_baseline_new.yaml")
    expected = read_yaml_file_to_hash_2(sub_dir, "form_example_vs_baseline_new.yaml")
    expect(result.to_json).to eq(expected)
  end

  it "handles a form not being found" do
    item = Form.find("F-ACME_T2x", "http://www.assero.co.uk/MDRForms/ACME/V1")
    result = Form.new
    result.rdf_type = ""
    expect(item.to_json).to eq(result.to_json)
  end

  it "finds all entries" do
    expected = []
    expected[0] = {:id => "F-ACME_DM101"}
    expected[1] = {:id => "F-ACME_T2"}
    expected[2] = {:id => "F-ACME_VSBASELINE1"}
    results = Form.all
    expect(results.count).to eq(3)
    expected.each_with_index do |x, index|
      expect(results[index].id).to eq(expected[index][:id])
    end
  end

  it "finds all unique entries" do
    result = 
      [
        {
          :identifier=>"T2",
          :label=>"Test 2",
          :owner_id=>"NS-ACME",
          :owner=>"ACME"
        },
        {
          :identifier=>"DM1 01",
          :label=>"Demographics",
          :owner_id=>"NS-ACME",
          :owner=>"ACME"
        },
        {
          :identifier=>"VS BASELINE",
          :label=>"Vital Signs Baseline",
          :owner_id=>"NS-ACME",
          :owner=>"ACME"
        }
      ]
    expect(Form.unique).to eq (result)
  end

  it "finds list of all released entries" do
    expected = []
    expected[0] = {:id => "F-ACME_VSBASELINE1", :scoped_identifier_version => 1}
    results = Form.list
    expected.each_with_index do |x, index|
      expect(results[index].id).to eq(expected[index][:id])
      expect(results[index].scopedIdentifier.version).to eq(expected[index][:scoped_identifier_version])
    end
  end

  it "finds the history of an item" do
    results = []
    results[0] = {:id => "F-ACME_DM101", :scoped_identifier_version => 2}
    results[1] = {:id => "F-ACME_DM101", :scoped_identifier_version => 1}
    item = Form.find("F-ACME_DM101", "http://www.assero.co.uk/MDRForms/ACME/V1")
    item.registrationState.registrationStatus = "Standard"
    operation = item.to_operation
    new_item = Form.create(operation)
    expect(new_item.errors.count).to eq(0)
    params = {:identifier => "DM1 01", :scope_id => IsoRegistrationAuthority.owner.namespace.id}
    items = Form.history(params)
    expect(items.count).to eq(2)
    items.each_with_index do |item, index|
      expect(results[index][:id]).to eq(items[index].id)
      expect(results[index][:scoped_identifier_version]).to eq(items[index].scopedIdentifier.version)
    end   
  end
  
  it "allows a placeholder form to be created from parameters" do
    item = Form.create_placeholder({:identifier => "PLACE NEW", :label => "Placeholder New", :freeText => "Placeholder Test Form"})
    expect(item.errors.count).to eq(0)
  end

  it "allows a form to be created from operation JSON" do
    operation = read_yaml_file_to_hash_2(sub_dir, "form_example_simple_placeholder_with_operation.yaml")
    item = Form.create(operation)
    expect(item.errors.count).to eq(0)
  end

  it "allows a form to be created from operation JSON, base core form" do
    #text = read_text_file_2(sub_dir, "form_base_core.txt")
    #hash = JSON.parse(text)
    #write_hash_to_yaml_file_2(hash.deep_symbolize_keys, sub_dir, "form_base_core.yaml")
    parameters = read_yaml_file_to_hash_2(sub_dir, "form_base_core.yaml")
    item = Form.create(parameters[:form])
    #write_hash_to_yaml_file_2(item.to_json, sub_dir, "form_base_core_result.yaml")
    expected = read_yaml_file_to_hash_2(sub_dir, "form_base_core_result.yaml")
    expected[:last_changed_date] = date_check_now(item.lastChangeDate).iso8601
    expect(item.errors.count).to eq(0)
    expect(item.to_json).to eq(expected)
  end

  it "allows a form to be created from operation JSON, base BC form" do
    #text = read_text_file_2(sub_dir, "form_base_bc.txt")
    #hash = JSON.parse(text)
    #write_hash_to_yaml_file_2(hash.deep_symbolize_keys, sub_dir, "form_base_bc.yaml")
    parameters = read_yaml_file_to_hash_2(sub_dir, "form_base_bc.yaml")
    item = Form.create(parameters[:form])
    #write_hash_to_yaml_file_2(item.to_json, sub_dir, "form_base_bc_result.yaml")
    expected = read_yaml_file_to_hash_2(sub_dir, "form_base_bc_result.yaml")
    expected[:last_changed_date] = date_check_now(item.lastChangeDate).iso8601
    expect(item.errors.count).to eq(0)
    expect(item.to_json).to eq(expected)
  end

  it "allows a form to be updated" do
    item = Form.find("F-ACME_PLACENEW", "http://www.assero.co.uk/MDRForms/ACME/V1")
    item.label = "New Label"
    Form.update(item.to_operation)
  end

  it "allows a form to be destroyed" do
    item = Form.find("F-ACME_PLACENEW", "http://www.assero.co.uk/MDRForms/ACME/V1")
    item.destroy
    expect{Form.find("F-ACME_PLACENEW", "http://www.assero.co.uk/MDRForms/ACME/V1")}.to raise_error(Exceptions::NotFoundError)
  end

  it "allows a form to be destroyed" do
    item = Form.find("F-ACME_PLACENEW", "http://www.assero.co.uk/MDRForms/ACME/V1")
    expect{item.destroy}.to raise_error(Exceptions::DestroyError)
  end
    
  it "can serialize as json, core form" do
    item = Form.find("F-ACME_TEST1", "http://www.assero.co.uk/MDRForms/ACME/V1")
    expected = read_yaml_file_to_hash_2(sub_dir, "form_base_core_result.yaml")
    expected[:last_changed_date] = date_check_now(item.lastChangeDate).iso8601
    expect(item.to_json).to eq(expected)
  end

  it "can serialize as json, BC form" do
    item = Form.find("F-ACME_TEST2", "http://www.assero.co.uk/MDRForms/ACME/V1")
    #write_hash_to_yaml_file_2(item.to_json, sub_dir, "form_base_bc_json.yaml")
    expected = read_yaml_file_to_hash_2(sub_dir, "form_base_bc_json.yaml")
    expected[:last_changed_date] = date_check_now(item.lastChangeDate).iso8601
    expect(item.to_json).to eq(expected)
  end

  it "can create the sparql for core form" do
    item = Form.find("F-ACME_TEST2", "http://www.assero.co.uk/MDRForms/ACME/V1")
    write_text_file_2(item.to_sparql_v2.to_s, sub_dir, "form_base_core_sparql.txt")
    expected = read_text_file_2(sub_dir, "form_base_core_sparql.txt")
    expect(item.to_sparql_v2.to_s).to eq(expected)
  end

  it "can create the sparql for BC form" do
    item = Form.find("F-ACME_TEST2", "http://www.assero.co.uk/MDRForms/ACME/V1")
    write_text_file_2(item.to_sparql_v2.to_s, sub_dir, "form_base_bc_sparql.txt")
    expected = read_text_file_2(sub_dir, "form_base_bc_sparql.txt")
    expect(item.to_sparql_v2.to_s).to eq(expected)
  end

  it "to_xml"
  
  it "checks if the form is valid?" do
    item = Form.find("F-ACME_TEST2", "http://www.assero.co.uk/MDRForms/ACME/V1")
    result = item.valid?
    expect(result).to eq(true)
    item.label = "@@@@@@@"
    result = item.valid?
    expect(result).to eq(false)
    expect(item.errors.full_messages.to_sentence).to eq("Label contains invalid characters")
    item.label = "addd"
    result = item.valid?
    expect(result).to eq(true)
    item.completion = ">>>>"
    result = item.valid?
    expect(result).to eq(false)
    expect(item.errors.full_messages.to_sentence).to eq("Completion contains invalid markdown")
    item.completion = ""
    result = item.valid?
    expect(result).to eq(true)
    item.note = "<<<<<<"
    result = item.valid?
    expect(result).to eq(false)
    expect(item.errors.full_messages.to_sentence).to eq("Note contains invalid markdown")
    item.note = ""
    result = item.valid?
    expect(result).to eq(true)
  end
  
  it "generates the form annotations"

end