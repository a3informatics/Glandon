require 'rails_helper'

describe IsoConceptSystem::Node do

	include DataHelpers
  include PauseHelpers

	def sub_dir
    return "models/iso_concept_system/node"
  end

  before :each do
    schema_files = 
    [
      "ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl"
    ]
    data_files = 
    [
      "iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl", "iso_concept_system_generic_data.ttl"      
    ]
    load_files(schema_files, data_files)
  end

  it "allows a child object to be added" do
    cs = IsoConceptSystem::Node.find(Uri.new(uri: "http://www.assero.co.uk/MDRConcepts#GSC-C3"))
    child = cs.add({ :label => "Node 3_3", :description => "Node 3_3"})
    actual = child.add({ :label => "Node 3_3_1", :description => "Node 3_3_1"})
    check_file_actual_expected(actual.to_h, sub_dir, "create_expected_1.yaml", equate_method: :iso_concept_system_equal)
  end

  it "prevents a child object being added from invalid json" do
    cs = IsoConceptSystem::Node.find(Uri.new(uri: "http://www.assero.co.uk/MDRConcepts#GSC-C3"))
    child = cs.add({ :label => "Node 3_3", :description => "Node 3_3"})
    actual = child.add({ :label => "Node 3_3_1", :description => "Node 3_3_1±"})
    expect(actual.errors.count).to eq(1)
    expect(actual.errors.full_messages.to_sentence).to eq("Description contains invalid characters or is empty")
  end

  it "allows an object to be destroyed, no children" do
    node = IsoConceptSystem::Node.find(Uri.new(uri: "http://www.assero.co.uk/MDRConcepts#GSC-C2"))
    result = node.delete
    expect(result).to eq(1)
    expect{IsoConceptSystem::Node.find(Uri.new(uri: "http://www.assero.co.uk/MDRConcepts#GSC-C2"))}.to raise_error(Errors::NotFoundError, "Failed to find http://www.assero.co.uk/MDRConcepts#GSC-C2 in IsoConceptSystem::Node.")
  end

  it "prevents an object being destroyed, children" do
    cs = IsoConceptSystem::Node.find(Uri.new(uri: "http://www.assero.co.uk/MDRConcepts#GSC-C2"))
    child = cs.add(label: "Node 2_1", description: "Node 2_1")
    child = IsoConceptSystem::Node.find(child.uri)
    actual = child.add(label: "Node 2_1_1", description: "Node 2_1_1")
    actual = IsoConceptSystem::Node.find(actual.uri)
    child.delete
    expect(child.errors.count).to eq(1)
    expect(child.errors.full_messages.to_sentence).to eq("Cannot destroy tag as it has children tags or is currently in use.")
  end

  it "prevents an object being destroyed, linked" do
    cs = IsoConceptSystem::Node.find(Uri.new(uri: "http://www.assero.co.uk/MDRConcepts#GSC-C2"))
    child = cs.add(label: "Node 2_1", description: "Node 2_1")
    child = IsoConceptSystem::Node.find(child.uri)
    other = IsoConceptV2.create({uri: IsoConceptV2.create_uri(IsoConceptV2.base_uri), label: "Node X"})
    other = IsoConceptV2.find(other.uri)
    other.add_link(:tagged, child.uri)
    child.delete
    expect(child.errors.count).to eq(1)
    expect(child.errors.full_messages.to_sentence).to eq("Cannot destroy tag as it has children tags or is currently in use.")
  end

  it "returns the children property" do
    cs = IsoConceptSystem::Node.find(Uri.new(uri: "http://www.assero.co.uk/MDRConcepts#GSC-C2"))
    expect(cs.children_property).to eq(:narrower)
  end

  it "updates a node" do
    cs = IsoConceptSystem::Node.find(Uri.new(uri: "http://www.assero.co.uk/MDRConcepts#GSC-C2"))
    expect(cs.pref_label).to eq("Node 2")
    expect(cs.description).to eq("Description 2")
    cs.update(label: "Node AAA")    
    cs = IsoConceptSystem::Node.find(Uri.new(uri: "http://www.assero.co.uk/MDRConcepts#GSC-C2"))
    expect(cs.pref_label).to eq("Node AAA")
    expect(cs.description).to eq("Description 2")
    cs.update(label: "BBB", description: "ddd fff")    
    cs = IsoConceptSystem::Node.find(Uri.new(uri: "http://www.assero.co.uk/MDRConcepts#GSC-C2"))
    expect(cs.pref_label).to eq("BBB")
    expect(cs.description).to eq("ddd fff")
  end
end