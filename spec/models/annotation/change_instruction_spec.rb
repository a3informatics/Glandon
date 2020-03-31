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
		parent_uri = UriV2.new(uri: "http://example.com/A#base")
		sparql = Sparql::Update.new
    result.generate_uri(parent_uri)
		result.to_sparql(sparql)
  #Xwrite_text_file_2(sparql.to_create_sparql, sub_dir, "to_sparql_expected_1.txt")
    check_sparql_no_file(sparql.to_create_sparql, "to_sparql_expected_1.txt") 
	end

  it "creates a change instruction" do
    uri1 = Uri.new(uri: "http://www.cdisc.org/C96779/V26#C96779")
    uri2 = Uri.new(uri: "http://www.cdisc.org/C96779/V33#C96779")
    uri3 = Uri.new(uri: "http://www.cdisc.org/C96779/V37#C96779")
    uri4 = Uri.new(uri: "http://www.cdisc.org/C96779/V40#C96779")
    item = Annotation::ChangeInstruction.create(description: "D", reference: "R", semantic: "S", previous: [uri1.to_id, uri2.to_id], current: [uri3.to_id, uri4.to_id])
    check_file_actual_expected(item.to_h, sub_dir, "create_expected_1.yaml", write_file:true)
  end

  it "creates a change instruction II" do
    uri1 = Uri.new(uri: "http://www.cdisc.org/C96779/V26#C96779")
    uri2 = Uri.new(uri: "http://www.cdisc.org/C96779/V33#C96779")
    uri3 = Uri.new(uri: "http://www.cdisc.org/C96779/V37#C96779")
    uri4 = Uri.new(uri: "http://www.cdisc.org/C96779/V40#C96779")
    item = Annotation::ChangeInstruction.create(description: "D", reference: "R", previous: [uri1.to_id, uri2.to_id], current: [uri3.to_id])
    check_file_actual_expected(item.to_h, sub_dir, "create_expected_2.yaml", write_file:true)
  end


  it "updates a change instruction" do
    uri1 = Uri.new(uri: "http://www.cdisc.org/C96779/V26#C96779")
    uri2 = Uri.new(uri: "http://www.cdisc.org/C96779/V33#C96779")
    uri3 = Uri.new(uri: "http://www.cdisc.org/C96779/V37#C96779")
    uri4 = Uri.new(uri: "http://www.cdisc.org/C96779/V40#C96779")
    item = Annotation::ChangeInstruction.create(description: "D", reference: "R", previous: [uri1.to_id, uri2.to_id], current: [uri3.to_id])
    item.update(description: "D1", reference: "R, R1")
    item = Annotation::ChangeInstruction.find(item.id)
    check_file_actual_expected(item.to_h, sub_dir, "update_expected_1.yaml", write_file: true)
  end 


  it "add references I" do
    uri1 = Uri.new(uri: "http://www.cdisc.org/C96779/V26#C96779")
    uri2 = Uri.new(uri: "http://www.cdisc.org/C96779/V33#C96779")
    uri3 = Uri.new(uri: "http://www.cdisc.org/C96779/V37#C96779")
    uri4 = Uri.new(uri: "http://www.cdisc.org/C96779/V40#C96779")
    item = Annotation::ChangeInstruction.create(description: "D", reference: "R", previous: [uri1.to_id, uri2.to_id], current: [uri3.to_id])
    #item.save
    item = Annotation::ChangeInstruction.find(item.id)
    item.add_references(previous: [], current: [uri4.to_id])
    check_file_actual_expected(item.to_h, sub_dir, "add_reference_expected_1.yaml", write_file: true)
  end

  it "add references II" do
    uri1 = Uri.new(uri: "http://www.cdisc.org/C96779/V26#C96779")
    uri2 = Uri.new(uri: "http://www.cdisc.org/C96779/V33#C96779")
    uri3 = Uri.new(uri: "http://www.cdisc.org/C96779/V37#C96779")
    uri4 = Uri.new(uri: "http://www.cdisc.org/C96779/V40#C96779")
    item = Annotation::ChangeInstruction.create(description: "D", reference: "R", previous: [uri1.to_id], current: [])
  byebug
    item.save
    item = Annotation::ChangeInstruction.find(item.id)
    item.add_references(previous: [uri2.to_id], current: [uri3.to_id, uri4.to_id])
     item.save
    item = Annotation::ChangeInstruction.find(item.id)
    check_file_actual_expected(item.to_h, sub_dir, "add_reference_expected_2.yaml", write_file: true)
  end   

  it "remove reference" do
    uri1 = Uri.new(uri: "http://www.cdisc.org/C96779/V26#C96779")
    uri2 = Uri.new(uri: "http://www.cdisc.org/C96779/V33#C96779")
    uri3 = Uri.new(uri: "http://www.cdisc.org/C96779/V37#C96779")
    uri4 = Uri.new(uri: "http://www.cdisc.org/C96779/V40#C96779")
    item = Annotation::ChangeInstruction.create(description: "D", reference: "R", previous: [uri1.to_id, uri2.to_id], current: [uri3.to_id])
    # item.save
    # item = Annotation::ChangeInstruction.find(item.id)
    item.remove_reference(uri3.to_id)
    check_file_actual_expected(item.to_h, sub_dir, "remove_reference_expected_1.yaml", write_file: true)
  end      

  # it "creates and reads a change instruction" do
  #   allow(Time).to receive(:now).and_return(Time.parse("Jan 1 12:00:00+01:00 2000"))
  #   allow(SecureRandom).to receive(:uuid).and_return(sid)
  #   item = Annotation::ChangeInstruction.create(description: description, reference: reference)
  #   allow(Time).to receive(:now).and_return(Time.parse("Jan 1 12:00:00+01:00 2000"))
  #   allow(SecureRandom).to receive(:uuid).and_return(sid)
  #   item = Annotation::ChangeInstruction.create(user_reference: user_reference, description: description, reference: reference)
  #   actual = Annotation::ChangeInstruction.find(item.uri)
  #   expect(item.to_h).to hash_equal(actual.to_h)
  # end    
  

  # it "deletes a change instruction" do
  #   allow(Time).to receive(:now).and_return(Time.parse("Jan 1 12:00:00 2000"))
  #   allow(SecureRandom).to receive(:uuid).and_return("1234-5678-9012-3456")
  #   ci_1 = Annotation::ChangeInstruction.create(description: "D2", reference: "R2")
  #   or_1 = OperationalReferenceV3.create({reference: nil, context: nil}, cn_1)
  #   ci_1.current_push(or_1)
  #   ci_1.save
  #   item = Annotation::ChangeInstruction.find(ci_1.id)
  #   item.delete
  #   expect{Annotation::ChangeInstruction.find(ci_1.id)}.to raise_error(Errors::NotFoundError, "Failed to find http://www.assero.co.uk/CN#1234-5678-9012-3456 in Annotation::ChangeInstruction.")
  #   expect{Annotation::ChangeInstruction.find(or_1.id)}.to raise_error(Errors::NotFoundError, "Failed to find http://www.assero.co.uk/CN#1234-5678-9012-3456_R1 in Annotation::ChangeInstruction.")
  # end  
  
end