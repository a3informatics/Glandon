require 'rails_helper'

describe Tabulation::Column do

  include DataHelpers

  def sub_dir
    return "models/tabulation/column"
  end

  before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
  end

  it "validates a valid object" do
    result = Tabulation::Column.new
    result.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
    expect(result.valid?).to eq(true)
  end

  it "does not validate an invalid object" do
    item = Tabulation::Column.new
    result = item.valid?
    expect(item.errors.full_messages.to_sentence).to eq("Uri can't be blank")
    expect(result).to eq(false)
  end

  # it "does not validate an invalid object, rule"

  # it "allows object to be initialized from triples" do
  #   result = 
  #     {
  #       :id => "D-ACME_VSDomain_V5", 
  #       :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1", 
  #       :extension_properties => [],
  #       :label => "Group ID",
  #       :ordinal => 5,
  #       :rule => "",
  #       :type => "http://www.assero.co.uk/BusinessDomain#UserVariable"
  #     }
  #   triples = read_yaml_file(sub_dir, "from_triples_input.yaml")
  #   expect(Tabulation::Column.new(triples, "D-ACME_VSDomain_V5").to_json).to eq(result) 
  # end  

  # it "allows an object to be found" do
  #   column = Tabulation::Column.find("D-ACME_VSDomain_V5", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1")
  # #write_yaml_file(column.to_json, sub_dir, "find_expected.yaml")
  #   expected = read_yaml_file(sub_dir, "find_expected.yaml")
  #   expect(column.to_json).to eq(expected)
  # end

  # it "allows an object to be created from JSON" do
  #   json = read_yaml_file(sub_dir, "from_json_input.yaml")
  #   item = Tabulation::Column.from_json(json)
  #   expect(item.to_json).to eq(json)
  # end
  
  # it "allows an object to be exported as JSON" do
  #   item = Tabulation::Column.new
  #   item.rdf_type = "http://www.example.com/path#rdf_test_type"
  #   item.label = "test label"
  #   item.ordinal = 12
  #   item.rule = ""
  # #write_yaml_file(item.to_json, sub_dir, "to_json_expected.yaml")
  #   expected = read_yaml_file(sub_dir, "to_json_expected.yaml")
  #   expect(item.to_json).to eq(expected)
  # end
  
  # it "allows an object to be exported as SPARQL" do
  #   sparql = SparqlUpdateV2.new
  #   item = Tabulation::Column.new
  #   item.id = "VS_V12"
  #   item.namespace = "http://www.example.com/path/V1"
  #   item.rdf_type = "http://www.example.com/schema#rdf_test_type"
  #   item.label = "test label"
  #   item.ordinal = 12
  #   item.rule = ""
  #   item.to_sparql_v2(sparql, "bd")
  # #write_text_file_2(sparql.to_s, sub_dir, "to_sparql_expected.txt")
  #   expected = read_text_file_2(sub_dir, "to_sparql_expected.txt")
  #   expect(sparql.to_s).to eq(expected)
  # end

end
  