require 'rails_helper'

describe Form do

	include DataHelpers

  def date_check_now(item)
    expect(item).to be_within(1.second).of Time.now
    return item
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
  
  it "allows a form to be created from operation JSON" do
    operation = read_yaml_file_to_hash("form_example_simple_placeholder_with_operation.yaml")
    item = Form.create(operation)
    expect(item.errors.count).to eq(0)
  end

  it "allows a placeholder form to be created from parameters" do
    item = Form.create_placeholder({:identifier => "PLACE NEW", :label => "Placeholder New", :freeText => "Placeholder Test Form"})
    expect(item.errors.count).to eq(0)
  end

  it "allows a form to be found" do
    item = Form.find("F-ACME_T2", "http://www.assero.co.uk/MDRForms/ACME/V1")
    expect(item.identifier).to eq("T2")
  end

  it "allows a form to be found, BC based" do
    result = Form.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
    write_hash_to_yaml_file(result.to_json, "form_example_vs_baseline_new.yaml")
    expected = read_yaml_file_to_hash("form_example_vs_baseline_new.yaml")
    expect(result.to_json).to eq(expected)
  end

  it "handles a form not being found" do
    item = Form.find("F-ACME_T2x", "http://www.assero.co.uk/MDRForms/ACME/V1")
    result = Form.new
    result.rdf_type = ""
    expect(item.to_json).to eq(result.to_json)
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

  it "finds all entries" do
    expected = []
    expected[0] = {:id => "F-ACME_DM101"}
    expected[1] = {:id => "F-ACME_P1"}
    expected[2] = {:id => "F-ACME_T2"}
    expected[3] = {:id => "F-ACME_DM101"}
    results = Form.all
    expected.each_with_index do |x, index|
      expect(results[index].id).to eq(expected[index][:id])
    end
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

  it "finds all unique entries" do
    result = 
      [
        {
          :identifier=>"DM1 01",
          :label=>"Demographics",
          :owner_id=>"NS-ACME",
          :owner=>"ACME"
        },
        {
          :identifier=>"P1",
          :label=>"Placeholder 1",
          :owner_id=>"NS-ACME",
          :owner=>"ACME"
        },
        {
          :identifier=>"PLACE NEW",
          :label=>"Placeholder New",
          :owner_id=>"NS-ACME",
          :owner=>"ACME"
        },
        {
          :identifier=>"T2",
          :label=>"Test 2",
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

end