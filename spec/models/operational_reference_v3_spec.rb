require 'rails_helper'

describe "OperationalReferenceV3" do

	include DataHelpers
  include SparqlHelpers
  include FusekiBaseHelpers
    
	def sub_dir
    return "models/operational_reference_v3"
  end

  before :all do
  end

  before :each do
    schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl", "BusinessOperational.ttl"]
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "iso_scoped_identifier.ttl"]
    load_files(schema_files, data_files)
    # FusekiBaseHelpers.clear
    # FusekiBaseHelpers.read_schema
  end
 
  it "validates a valid object" do
    result = OperationalReferenceV3.new
    result.uri = Uri.new(uri: "http://www.assero.co.uk/X/V1#F-ACME_OR_G1_I1")
    expect(result.valid?).to eq(true)
  end

  it "does not validate an invalid object, text label" do
    result = OperationalReferenceV3.new
    result.label = "Draft 123 more tesxt €"
    expect(result.valid?).to eq(false)
  end

  it "allows the object to be initialized from hash" do
    result = 
      {
        :uri => "http://www.assero.co.uk/X/V1#F-ACME_OR_G1_I1", 
        :label => "BC Property Reference",
        :optional => false,
        :ordinal => 1,
        :enabled => true,
        :reference => "http://www.assero.co.uk/A#ref",
        :context => "http://www.assero.co.uk/A#context",
        :rdf_type => "http://www.assero.co.uk/BusinessOperational#Reference"
      }
    item = OperationalReferenceV3.from_h(result)
    check_file_actual_expected(item.to_h, sub_dir, "from_h_expected.yaml")
  end

  it "allows an object to be exported as SPARQL" do
    sparql = Sparql::Update.new
    item = OperationalReferenceV3.new
    item.label = "label"
    item.uri = Uri.new({:fragment => "parent", :namespace => "http://www.example.com/path"})
    item.reference = Uri.new({:fragment => "ref", :namespace => "http://www.example.com/path"})
    item.to_sparql(sparql)
  #Xwrite_text_file_2(sparql.to_create_sparql, sub_dir, "to_create_sparql_expected.txt")
    check_sparql_no_file(sparql.to_create_sparql, "to_create_sparql_expected.txt")
  end

  it "returns the referenced class" do
    expect(OperationalReferenceV3.referenced_klass).to eq(IsoConceptV2)
  end

  it "create" do
    parent = IsoManagedV2.new
    parent.uri = Uri.new(uri: "http://www.assero.co.uk/A#ref")
    item = OperationalReferenceV3.create({label: "The Label", ordinal: 2}, parent)
    check_file_actual_expected(item.to_h, sub_dir, "created_expected.yaml")
  end

end