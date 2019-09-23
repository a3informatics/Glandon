require 'rails_helper'

describe OperationalReferenceV3::TcReference do

	include DataHelpers
  include SparqlHelpers
    
	def sub_dir
    return "models/operational_reference_v3/tc_reference"
  end

  before :all do
    IsoHelpers.clear_cache
  end

  before :each do
    schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl", "BusinessOperational.ttl", "thesaurus.ttl"]
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "iso_scoped_identifier.ttl"]
    load_files(schema_files, data_files)
  end
 
  it "validates a valid object" do
    result = OperationalReferenceV3::TcReference.new
    result.uri = Uri.new(uri: "http://www.assero.co.uk/X/V1#F-ACME_OR_G1_I1")
    result.local_label = "Hello"
    expect(result.valid?).to eq(true)
  end

  it "does not validate an invalid object, text label" do
    result = OperationalReferenceV3::TcReference.new
    result.local_label = "Draft 123 more tesxt €"
    expect(result.valid?).to eq(false)
    expect(result.errors.count).to eq(2)
    expect(result.errors.full_messages.to_sentence).to eq("Uri can't be blank and Local label contains invalid characters")
  end

  it "allows the object to be initialized from hash" do
    input = 
      {
        :uri => "http://www.assero.co.uk/X/V1#F-ACME_OR_G1_I1", 
        :label => "BC Property Reference",
        :optional => false,
        :ordinal => 1,
        :enabled => true,
        :local_label => "Changed",
        :reference => {},
        :rdf_type => "http://www.assero.co.uk/BusinessOperational#TcReference"
      }
    item = OperationalReferenceV3::TcReference.from_h(input)
    check_file_actual_expected(item.to_h, sub_dir, "from_h_expected.yaml", equate_method: :hash_equal)
  end

  it "allows an object to be exported as SPARQL" do
    sparql = Sparql::Update.new
    item = OperationalReferenceV3::TcReference.new
    item.label = "label"
    item.uri = Uri.new({:fragment => "parent", :namespace => "http://www.example.com/path"})
    item.reference = Uri.new(uri: "http://www.assero.co.uk/X/V1#REF")
    item.to_sparql(sparql)
  #Xwrite_text_file_2(sparql.to_create_sparql, sub_dir, "to_create_sparql_expected.txt")
    check_sparql_no_file(sparql.to_create_sparql, "to_create_sparql_expected.txt")
  end

  it "returns the referenced class" do
    expect(OperationalReferenceV3::TcReference.referenced_klass).to eq(Thesaurus::ManagedConcept)
  end

end