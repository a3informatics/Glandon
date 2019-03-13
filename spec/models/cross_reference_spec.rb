require 'rails_helper'

describe CrossReference do
	
  include DataHelpers
  include SparqlHelpers

  def sub_dir
    return "models/cross_reference"
  end

  before :each do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
		load_schema_file_into_triple_store("business_operational_extension.ttl")
    load_schema_file_into_triple_store("business_cross_reference.ttl")
  end

  it "will initialize an object" do
  	result = CrossReference.new
  	expect(result.comments).to eq("")
  	expect(result.rdf_type).to eq("http://www.assero.co.uk/BusinessCrossReference#CrossReference")  	
  	expect(result.children).to match_array([])  	
  end

	it "will serialize as a hash" do
  	result = CrossReference.new
  	result.id = "id"
  	result.namespace = "namespace"
  	result.comments = "Comment Text"
  	result.label = "whatevs"
  	expected = {id: "id", namespace: "namespace", type: "http://www.assero.co.uk/BusinessCrossReference#CrossReference", label: "whatevs", 
  		comments: "Comment Text", children: [], ordinal: 1, extension_properties: []}
  	expect(result.to_hash).to eq(expected)
  end

  it "will create an object from a hash" do
  	xref_1 = OperationalReferenceV2.new
  	xref_2 = OperationalReferenceV2.new
  	xref_1.subject_ref = UriV2.new(uri: "http://example.com/A1")
  	xref_1.ordinal = 1
  	xref_2.subject_ref = UriV2.new(uri: "http://example.com/A2")
  	xref_2.ordinal = 2
  	input = { id: "CR1", namespace: "http://www.example.com/XR", type: "http://www.assero.co.uk/BusinessCrossReference#CrossReference", label: "Cross Reference",
  		comments: "The comments", children: [], ordinal: 1, extension_properties: []}
  	input[:children] << xref_1.to_json
  	input[:children] << xref_2.to_json
  	result = CrossReference.from_hash(input)
  	expect(result.to_hash).to eq(input)
  end

  it "will output as sparql" do
  	xref_1 = OperationalReferenceV2.new
  	xref_2 = OperationalReferenceV2.new
  	xref_1.ordinal = 1
  	xref_1.subject_ref = UriV2.new(uri: "http://example.com/A1")
  	xref_2.ordinal = 2
  	xref_2.subject_ref = UriV2.new(uri: "http://example.com/A2")
  	result = CrossReference.new
		result.comments = "This is the comment"
		result.children << xref_1
		result.children << xref_2
		parent_uri = UriV2.new(uri: "http://example.com/A#base")
		sparql = SparqlUpdateV2.new
		result.to_sparql_v2(parent_uri, sparql)
	#write_text_file_2(sparql.to_s, sub_dir, "to_sparql_1.txt")
    #expected = read_text_file_2(sub_dir, "to_sparql_1.txt")
		#expect(sparql.to_s).to eq(expected)
    check_sparql_no_file(sparql.to_s, "to_sparql_1.txt")
	end
  
end