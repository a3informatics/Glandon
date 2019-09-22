require 'rails_helper'

describe CrossReference do
	
  include DataHelpers
  include SparqlHelpers

  def sub_dir
    return "models/cross_reference"
  end

  before :each do
    schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl", "BusinessOperational.ttl", "cross_reference.ttl"]
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
    # clear_triple_store
    # load_schema_file_into_triple_store("ISO11179Types.ttl")
    # load_schema_file_into_triple_store("ISO11179Identification.ttl")
    # load_schema_file_into_triple_store("ISO11179Registration.ttl")
    # load_schema_file_into_triple_store("ISO11179Concepts.ttl")
  	# load_schema_file_into_triple_store("BusinessOperational.ttl")
    # load_schema_file_into_triple_store("cross_reference.ttl")
  end

  it "will initialize an object" do
  	result = CrossReference.new
  	expect(result.description).to eq("")
  	expect(result.rdf_type.to_s).to eq("http://www.assero.co.uk/CrossReference#CrossReference")  	
  	expect(result.can_be_deleted).to eq(false)
    expect(result.can_be_modified).to eq(false)
  end

	it "will serialize as a hash" do
  	result = CrossReference.new
  	result.uri = Uri.new(uri: "http://www.assero.co.uk/CrossReference#XXX")
  	result.description = "Comment Text"
  	result.label = "whatevs"
  	check_file_actual_expected(result.to_h, sub_dir, "to_h_expected.yaml", equate_method: :hash_equal)
  end

  it "will create an object from a hash" do
  	input = { id: "CR1", namespace: "http://www.example.com/XR", type: "http://www.assero.co.uk/BusinessCrossReference#CrossReference", label: "Cross Reference",
  		description: "The comments", ordinal: 1}
  	result = CrossReference.from_h(input)
    check_file_actual_expected(result.to_h, sub_dir, "from_h_expected.yaml", equate_method: :hash_equal)
  end

  it "will output as sparql" do
  	result = CrossReference.new
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
  
end