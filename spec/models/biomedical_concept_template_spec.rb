require 'rails_helper'

describe BiomedicalConceptTemplate do
  
  include DataHelpers

  def sub_dir
    return "models"
  end

  before :all do
    IsoHelpers.clear_cache
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "BCT.ttl"]
    load_files(schema_files, data_files)
    #load_cdisc_term_versions(1..43)
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
  end


  it "allows validity of the object to be checked - error" do
    result = BiomedicalConceptTemplate.new
    result.valid?
    expect(result.errors.count).to eq(3)
    expect(result.errors.full_messages[0]).to eq("Uri can't be blank")
    expect(result.errors.full_messages[1]).to eq("Has identifier empty object")
    expect(result.errors.full_messages[2]).to eq("Has state empty object")
    expect(result.valid?).to eq(false)
  end

  it "allows validity of the object to be checked" do
    result = BiomedicalConcept.new
    ra = IsoRegistrationAuthority.find(Uri.new(uri:"http://www.assero.co.uk/RA#DUNS123456789"))
    result.has_state = IsoRegistrationStateV2.new
    result.has_state.uri = "na"
    result.has_state.by_authority = ra
    result.has_identifier = IsoScopedIdentifierV2.new
    result.has_identifier.uri = "na"
    result.has_identifier.identifier = "HELLO WORLD"
    result.has_identifier.semantic_version = "0.1.0"
    result.uri = "xxx"
    valid = result.valid?
    expect(result.errors.count).to eq(0)
    expect(valid).to eq(true)
  end 

  it "allows a BCT to be found" do
    item = BiomedicalConceptTemplate.find(Uri.new(uri: "http://www.assero.co.uk/MDRBCTs/V1"))
    check_file_actual_expected(item.to_h, sub_dir, "find_bc_template_expected_1.yaml", equate_method: :hash_equal)
  end

  # it "finds all entries" do
  #   results = []
  #   results[0] = {:id => "BCT-Obs_PQR"}
  #   results[1] = {:id => "BCT-Obs_CD"}
  #   items = BiomedicalConceptTemplate.all
  #   items.each_with_index do |item, index|
  #     expect(items[index].id).to eq(results[index][:id])
  #   end
  # end

  # it "finds the history of an item" do
  #   results = []
  #   results[0] = {:id => "BCT-Obs_PQR", :scoped_identifier_version => 1}
  #   params = {:identifier => "Obs PQR", :scope => IsoRegistrationAuthority.owner.ra_namespace}
  #   items = BiomedicalConceptTemplate.history(params)
  #   expect(items.count).to eq(1)
  #   items.each {|x| results << x.to_h}
  #   check_file_actual_expected(results, sub_dir, "history_bc_template_expected_1.yaml", equate_method: :hash_equal, write_file: true)
  # end

  # it "finds list of all released entries" do
  #   results = []
  #   results[0] = {:id => "BCT-Obs_CD", :scoped_identifier_version => 1}
  #   results[1] = {:id => "BCT-Obs_PQR", :scoped_identifier_version => 1}
  #   items = BiomedicalConceptTemplate.list
  #   items.each_with_index do |item, index|
  #     expect(results[index][:id]).to eq(items[index].id)
  #     expect(results[index][:scoped_identifier_version]).to eq(items[index].scopedIdentifier.version)
  #   end
  # end

  # it "finds all unique entries"

  # it "allows the object to be exported as JSON"

  # it "allows the object to be created from JSON"

  # it "allows an object to be exported as SPARQL"

=begin
    sparql = SparqlUpdateV2.new
    result = 
      "PREFIX cbc: <http://www.assero.co.uk/CDISCBiomedicalConcept#>\n" +
      "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
      "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
      "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
      "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
      "INSERT DATA \n" +
      "{ \n" + 
      "<http://www.example.com/path#XXX_I1> rdf:type <http://www.example.com/path#rdf_test_type> . \n" +
      "<http://www.example.com/path#XXX_I1> rdfs:label \"test label\"^^xsd:string . \n" +
      "<http://www.example.com/path#XXX_I1> cbc:ordinal \"1\"^^xsd:positiveInteger . \n" +
      "<http://www.example.com/path#XXX_I1> cbc:alias \"Note\"^^xsd:string . \n" +
      "<http://www.example.com/path#XXX_I1> cbc:bridg_class \"Class\"^^xsd:string . \n" +
      "<http://www.example.com/path#XXX_I1> cbc:bridg_attribute \"Attribute\"^^xsd:string . \n" +
      "}"
    item = BiomedicalConceptTemplate.new
    item.id = "123"
    item.namespace = "http://www.example.com/path"
    item.rdf_type = "http://www.example.com/path#rdf_test_type"
    item.label = "test label"
    parent_uri = UriV2.new({:id => "XXX", :namespace => "http://www.example.com/path"})
    item.to_sparql_v2(parent_uri, sparql)
    expect(sparql.to_s).to eq(result)
  end
=end

end
  