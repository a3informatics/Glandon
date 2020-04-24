require 'rails_helper'

describe Annotation::ChangeInstruction do
	
  include DataHelpers
  include SparqlHelpers

  def sub_dir
    return "models/annotation/cross_reference"
  end
    def load_versions(range)
      range.each {|n| load_data_file_into_triple_store("cdisc/ct/CT_V#{n}.ttl")}
    end

  before :all  do
    IsoHelpers.clear_cache
  end

  before :each do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_new_airports.ttl"]
    load_files(schema_files, data_files)
    load_versions(1..42)
  end

  it "will initialize an object" do
  	result = Annotation::ChangeInstruction.new
  	expect(result.description).to eq("")
  	expect(result.rdf_type.to_s).to eq("http://www.assero.co.uk/Annotations#ChangeInstruction")  	
  end

	it "will serialize as a hash" do
  	result = Annotation::ChangeInstruction.new
  	result.uri = Uri.new(uri: "http://www.assero.co.uk/Annotations#XXX")
  	result.description = "Comment Text"
  	result.label = "whatevs"
  	check_file_actual_expected(result.to_h, sub_dir, "to_h_expected.yaml", equate_method: :hash_equal)
  end

  it "will create an object from a hash" do
  	input = { id: "CI1", namespace: "http://www.example.com/XR", type: "http://www.assero.co.uk/Annotations#ChangeInstruction", label: "Change Instruction",
  		description: "The comments", ordinal: 1}
  	result = Annotation::ChangeInstruction.from_h(input)
    check_file_actual_expected(result.to_h, sub_dir, "from_h_expected.yaml", equate_method: :hash_equal)
  end

  it "will output as sparql" do
  	result = Annotation::ChangeInstruction.new
		result.description = "This is the comment"
    result.label = "Label"
    result.semantic = "A Relationship"
    allow(SecureRandom).to receive(:uuid).and_return("1234-5678-9012-3456")
		parent_uri = UriV2.new(uri: "http://example.com/A#base")
		sparql = Sparql::Update.new
    result.generate_uri(parent_uri)
		result.to_sparql(sparql)
  #Xwrite_text_file_2(sparql.to_create_sparql, sub_dir, "to_sparql_expected_1.txt")
    check_sparql_no_file(sparql.to_create_sparql, "to_sparql_expected_1.txt") 
	end

  it "creates a change instruction" do
    allow(SecureRandom).to receive(:uuid).and_return("1234-5678-9012-3456")
    item = Annotation::ChangeInstruction.create
    check_file_actual_expected(item.to_h, sub_dir, "create_expected_1.yaml")
  end

  it "updates a change instruction, fields" do
    allow(SecureRandom).to receive(:uuid).and_return("1234-5678-9012-3456")
    item = Annotation::ChangeInstruction.create
    item.update(description: "D", reference: "R", semantic: "S")
    check_file_actual_expected(item.to_h, sub_dir, "update_expected_1.yaml")
  end

  it "adds references I" do
    uri1 = Uri.new(uri: "http://www.cdisc.org/C96779/V26#C96779")
    uri2 = Uri.new(uri: "http://www.cdisc.org/C96779/V33#C96779")
    uri3 = Uri.new(uri: "http://www.cdisc.org/C96779/V37#C96779")
    allow(SecureRandom).to receive(:uuid).and_return("1234-5678-9012-3456")
    item = Annotation::ChangeInstruction.create
    item = Annotation::ChangeInstruction.find(item.id)
    item.add_references(previous: [uri1.to_id, uri2.to_id], current: [uri3.to_id])
    item = Annotation::ChangeInstruction.find(item.id)
    check_file_actual_expected(item.to_h, sub_dir, "add_references_expected_1.yaml")
  end

  it "adds references II" do
    uri1 = Uri.new(uri: "http://www.cdisc.org/C96779/V26#C96779")
    uri2 = Uri.new(uri: "http://www.cdisc.org/C96779/V33#C96779")
    uri3 = Uri.new(uri: "http://www.cdisc.org/C96779/V37#C96779")
    uri4 = Uri.new(uri: "http://www.cdisc.org/C96779/V40#C96779")
    allow(SecureRandom).to receive(:uuid).and_return("1234-5678-9012-3456")
    item = Annotation::ChangeInstruction.create
    item = Annotation::ChangeInstruction.find(item.id)
    item.add_references(previous: [uri1.to_id, uri2.to_id], current: [uri3.to_id, uri4.to_id])
    item = Annotation::ChangeInstruction.find(item.id)
    check_file_actual_expected(item.to_h, sub_dir, "add_references_expected_2.yaml")
  end

  it "adds references III" do
    uri1 = Uri.new(uri: "http://www.cdisc.org/C96779/V26#C96779")
    uri2 = Uri.new(uri: "http://www.cdisc.org/C96779/V33#C96779")
    uri3 = Uri.new(uri: "http://www.cdisc.org/C96779/V37#C96779")
    uri4 = Uri.new(uri: "http://www.cdisc.org/C96779/V40#C96779")
    allow(SecureRandom).to receive(:uuid).and_return("1234-5678-9012-3456")
    item = Annotation::ChangeInstruction.create
    item = Annotation::ChangeInstruction.find(item.id)
    item.add_references(previous: [uri1.to_id], current: [uri2.to_id])
    item = Annotation::ChangeInstruction.find(item.id)
    item.add_references(previous: [], current: [uri3.to_id, uri4.to_id])
    item = Annotation::ChangeInstruction.find(item.id)
    check_file_actual_expected(item.to_h, sub_dir, "add_references_expected_3.yaml")
  end

  it "adds references IV" do
    uri1 = Uri.new(uri: "http://www.cdisc.org/C96779/V26#C96779")
    uri2 = Uri.new(uri: "http://www.cdisc.org/C96779/V33#C96779")
    uri3 = Uri.new(uri: "http://www.cdisc.org/C96779/V37#C96779")
    uri4 = Uri.new(uri: "http://www.cdisc.org/C96779/V40#C96779")
    allow(SecureRandom).to receive(:uuid).and_return("1234-5678-9012-3456")
    item = Annotation::ChangeInstruction.create
    item = Annotation::ChangeInstruction.find(item.id)
    item.add_references(previous: [uri1.to_id, uri2.to_id, uri3.to_id, uri4.to_id], current: [])
    item = Annotation::ChangeInstruction.find(item.id)
    check_file_actual_expected(item.to_h, sub_dir, "add_references_expected_4.yaml")
  end       

  it "removes reference" do
    uri1 = Uri.new(uri: "http://www.cdisc.org/C96779/V26#C96779")
    uri2 = Uri.new(uri: "http://www.cdisc.org/C96779/V33#C96779")
    uri3 = Uri.new(uri: "http://www.cdisc.org/C96779/V37#C96779")
    uri4 = Uri.new(uri: "http://www.cdisc.org/C96779/V40#C96779")
    allow(SecureRandom).to receive(:uuid).and_return("1234-5678-9012-3456")
    item = Annotation::ChangeInstruction.create
    item = Annotation::ChangeInstruction.find(item.id)
    item.add_references(previous: [uri1.to_id, uri2.to_id], current: [uri3.to_id, uri4.to_id])
    item = Annotation::ChangeInstruction.find(item.id)
    op_ref2 = Uri.new(uri: "http://www.assero.co.uk/CHIN#1234-5678-9012-3456_R10001")
    op_ref2 = Annotation::ChangeInstruction.find(op_ref2.to_id)
    item.remove_reference(type: "current", concept_id: uri4.to_id)
    item = Annotation::ChangeInstruction.find(item.id)
    expect{Annotation::ChangeInstruction.find(op_ref2.uri.to_id)}.to raise_error(Errors::NotFoundError, "Failed to find http://www.assero.co.uk/CHIN#1234-5678-9012-3456_R10001 in Annotation::ChangeInstruction.")
    expect{OperationalReferenceV3.find(op_ref2.uri.to_id)}.to raise_error(Errors::NotFoundError, "Failed to find http://www.assero.co.uk/CHIN#1234-5678-9012-3456_R10001 in OperationalReferenceV3.")
  end

  it "adds and removes references" do
    uri1 = Uri.new(uri: "http://www.cdisc.org/C96779/V26#C96779")
    uri2 = Uri.new(uri: "http://www.cdisc.org/C96779/V33#C96779")
    uri3 = Uri.new(uri: "http://www.cdisc.org/C96779/V37#C96779")
    uri4 = Uri.new(uri: "http://www.cdisc.org/C96779/V40#C96779")
    allow(SecureRandom).to receive(:uuid).and_return("1234-5678-9012-3456")
    item = Annotation::ChangeInstruction.create
    item = Annotation::ChangeInstruction.find(item.id)
    item.add_references(previous: [uri1.to_id], current: [])
    item = Annotation::ChangeInstruction.find(item.id)
    op_ref = Uri.new(uri: "http://www.assero.co.uk/CHIN#1234-5678-9012-3456_R1")
    op_ref = Annotation::ChangeInstruction.find(op_ref.to_id)
    item.remove_reference(type: "previous", concept_id: uri1.to_id)
    item = Annotation::ChangeInstruction.find(item.id)
    expect{Annotation::ChangeInstruction.find(op_ref.uri.to_id)}.to raise_error(Errors::NotFoundError, "Failed to find http://www.assero.co.uk/CHIN#1234-5678-9012-3456_R1 in Annotation::ChangeInstruction.")
    expect{OperationalReferenceV3.find(op_ref.uri.to_id)}.to raise_error(Errors::NotFoundError, "Failed to find http://www.assero.co.uk/CHIN#1234-5678-9012-3456_R1 in OperationalReferenceV3.")
    item.add_references(previous: [uri2.to_id, uri3.to_id], current: [uri4.to_id, uri1.to_id])
    item = Annotation::ChangeInstruction.find(item.id)
    op_ref2 = Uri.new(uri: "http://www.assero.co.uk/CHIN#1234-5678-9012-3456_R10001")
    op_ref2 = Annotation::ChangeInstruction.find(op_ref2.to_id)
    item.remove_reference(type: "current", concept_id: uri1.to_id)
    item = Annotation::ChangeInstruction.find(item.id)
    expect{Annotation::ChangeInstruction.find(op_ref2.uri.to_id)}.to raise_error(Errors::NotFoundError, "Failed to find http://www.assero.co.uk/CHIN#1234-5678-9012-3456_R10001 in Annotation::ChangeInstruction.")
    expect{OperationalReferenceV3.find(op_ref2.uri.to_id)}.to raise_error(Errors::NotFoundError, "Failed to find http://www.assero.co.uk/CHIN#1234-5678-9012-3456_R10001 in OperationalReferenceV3.")
  end

  it "change instructions links I" do
    uri1 = Uri.new(uri: "http://www.cdisc.org/C96779/V26#C96779")
    uri2 = Uri.new(uri: "http://www.cdisc.org/C96779/V33#C96779")
    uri3 = Uri.new(uri: "http://www.cdisc.org/C96779/V37#C96779")
    uri4 = Uri.new(uri: "http://www.cdisc.org/C96779/V40#C96779")
    allow(SecureRandom).to receive(:uuid).and_return("1234-5678-9012-3456")
    item = Annotation::ChangeInstruction.create
    item.update(description: "D", reference: "R", semantic: "S")
    item = Annotation::ChangeInstruction.find(item.id)
    item.add_references(previous: [uri1.to_id, uri2.to_id], current: [uri3.to_id, uri4.to_id])
    item = Annotation::ChangeInstruction.find(item.id)
    results = item.get_data
    check_file_actual_expected(results, sub_dir, "change_instructions_links_expected_1.yaml", equate_method: :hash_equal)
  end

  it "change instructions links II" do
    uri1 = Uri.new(uri: "http://www.cdisc.org/C74456/V37#C74456_C32955")
    uri2 = Uri.new(uri: "http://www.cdisc.org/C96779/V33#C96779")
    allow(SecureRandom).to receive(:uuid).and_return("1234-5678-9012-3456")
    item = Annotation::ChangeInstruction.create
    item.update(description: "D", reference: "R", semantic: "S")
    item = Annotation::ChangeInstruction.find(item.id)
    item.add_references(previous: [uri1.to_id], current: [uri2.to_id])
    item = Annotation::ChangeInstruction.find(item.id)
    results = item.get_data
    check_file_actual_expected(results, sub_dir, "change_instructions_links_expected_2.yaml", equate_method: :hash_equal)
  end

  it "change instructions links III" do
    allow(SecureRandom).to receive(:uuid).and_return("1234-5678-9012-3456")
    item = Annotation::ChangeInstruction.create
    item.update(description: "D", reference: "R", semantic: "S")
    item = Annotation::ChangeInstruction.find(item.id)
    results = item.get_data
    check_file_actual_expected(results, sub_dir, "change_instructions_links_expected_3.yaml", equate_method: :hash_equal)
  end  

  it "change instructions links IV" do
    uri1 = Uri.new(uri: "http://www.cdisc.org/CT/V30#TH")
    uri2 = Uri.new(uri: "http://www.cdisc.org/CT/V37#TH")
    allow(SecureRandom).to receive(:uuid).and_return("1234-5678-9012-3456")
    item = Annotation::ChangeInstruction.create
    item.update(description: "D", reference: "R", semantic: "S")
    item = Annotation::ChangeInstruction.find(item.id)
    item.add_references(previous: [uri1.to_id], current: [uri2.to_id])
    item = Annotation::ChangeInstruction.find(item.id)
    results = item.get_data
    check_file_actual_expected(results, sub_dir, "change_instructions_links_expected_4.yaml", equate_method: :hash_equal)
  end       

  it "deletes a change instruction" do
    allow(SecureRandom).to receive(:uuid).and_return("1234-5678-9012-4567")
    ci_1 = Annotation::ChangeInstruction.create
    uri1 = Uri.new(uri: "http://www.cdisc.org/C96779/V26#C96779")
    uri2 = Uri.new(uri: "http://www.cdisc.org/C96779/V33#C96779")
    uri3 = Uri.new(uri: "http://www.cdisc.org/C96779/V37#C96779")
    item = Annotation::ChangeInstruction.find(ci_1.id)
    item.add_references(previous: [uri1.to_id], current: [uri2.to_id])
    item = Annotation::ChangeInstruction.find(item.id)
    item.add_references(previous: [uri3.to_id], current: [])
    item = Annotation::ChangeInstruction.find(item.id)
    or_1 = OperationalReferenceV3.find(Uri.new(uri: "http://www.assero.co.uk/CHIN#1234-5678-9012-4567_R10000"))
    item.delete
    expect{Annotation::ChangeInstruction.find(item.id)}.to raise_error(Errors::NotFoundError, "Failed to find http://www.assero.co.uk/CHIN#1234-5678-9012-4567 in Annotation::ChangeInstruction.")
    expect{Annotation::ChangeInstruction.find(or_1.id)}.to raise_error(Errors::NotFoundError, "Failed to find http://www.assero.co.uk/CHIN#1234-5678-9012-4567_R10000 in Annotation::ChangeInstruction.")
  end  
  
end