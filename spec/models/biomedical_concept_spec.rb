require 'rails_helper'

describe BiomedicalConcept do
  
  include DataHelpers

  it "clears triple store and loads test data" do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Basic.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Data.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_schema_file_into_triple_store("BusinessOperational.ttl")
    load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")
    load_test_file_into_triple_store("MDRIdentificationACME.ttl")
    load_test_file_into_triple_store("BCT.ttl")
    load_test_file_into_triple_store("BC.ttl")
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
  end

  it "allows validity of the object to be checked - error" do
    result = BiomedicalConcept.new
    result.valid?
    expect(result.errors.count).to eq(2)
    expect(result.errors.full_messages[0]).to eq("Registration State error: Registration authority error: Namespace error: Short name contains invalid characters")
    expect(result.errors.full_messages[1]).to eq("Registration State error: Registration authority error: Number does not contains 9 digits")
    expect(result.valid?).to eq(false)
  end

    it "allows validity of the object to be checked" do
    result = BiomedicalConcept.new
    result.registrationState.registrationAuthority.namespace.shortName = "AAA"
    result.registrationState.registrationAuthority.namespace.name = "USER AAA"
    result.registrationState.registrationAuthority.number = "123456789"
    valid = result.valid?
    expect(result.errors.count).to eq(0)
    expect(valid).to eq(true)
  end 

it "allows a BC to be found" do
    item = BiomedicalConcept.find("BC-ACME_BC_C25206", "http://www.assero.co.uk/MDRBCs/V1")
    expect(item.identifier).to eq("BC_C25206")
  end

  it "handles a BCT not being found" do
    item = BiomedicalConcept.find("F-ACME_T2x", "http://www.assero.co.uk/MDRForms/ACME/V1")
    result = BiomedicalConcept.new
    result.rdf_type = ""
    result.template_ref = nil
    expect(item.to_json).to eq(result.to_json)
  end

  it "finds all entries" do
    results = []
    results[0] = {:id => "BC-ACME_BC_C25206"}
    results[1] = {:id => "BC-ACME_BC_C49677"}
    results[2] = {:id => "BC-ACME_BC_A00002"}
    results[3] = {:id => "BC-ACME_BC_C98793"}
    results[4] = {:id => "BC-ACME_BC_C49678"}
    results[5] = {:id => "BC-ACME_BC_C25298"}
    results[6] = {:id => "BC-ACME_BC_C25208"}
    results[7] = {:id => "BC-ACME_BC_A00003"}
    results[8] = {:id => "BC-ACME_BC_C25347"}
    results[9] = {:id => "BC-ACME_BC_C16358"}
    results[10] = {:id => "BC-ACME_BC_C81255"}
    results[11] = {:id => "BC-ACME_BC_C25299"}
    results[12] = {:id => "BC-ACME_BC_C98785"}
    results[13] = {:id => ""}
    results[14] = {:id => ""}
    results[15] = {:id => ""}
    results[15] = {:id => ""}
    items = BiomedicalConcept.all
    items.each_with_index do |item, index|
      expect(items[index].id).to eq(results[index][:id])
    end
  end

  it "finds the history of an item" do
    results = []
    results[0] = {:id => "BC-ACME_BC_C25347", :scoped_identifier_version => 1}
    params = {:identifier => "BC_C25347", :scope_id => IsoRegistrationAuthority.owner.namespace.id}
    items = BiomedicalConcept.history(params)
    expect(items.count).to eq(1)
    items.each_with_index do |item, index|
      expect(results[index][:id]).to eq(items[index].id)
      expect(results[index][:scoped_identifier_version]).to eq(items[index].scopedIdentifier.version)
    end
  end

  it "finds list of all released entries" do
    results = []
    results[0] = {:id => "BC-ACME_BC_A00002", :scoped_identifier_version => 1}
    results[1] = {:id => "BC-ACME_BC_A00003", :scoped_identifier_version => 1}
    results[2] = {:id => "BC-ACME_BC_C16358", :scoped_identifier_version => 1}
    results[3] = {:id => "BC-ACME_BC_C25206", :scoped_identifier_version => 1}
    results[4] = {:id => "BC-ACME_BC_C25208", :scoped_identifier_version => 1}
    results[5] = {:id => "BC-ACME_BC_C25298", :scoped_identifier_version => 1}
    results[6] = {:id => "BC-ACME_BC_C25299", :scoped_identifier_version => 1}
    results[7] = {:id => "BC-ACME_BC_C25347", :scoped_identifier_version => 1}
    results[8] = {:id => "BC-ACME_BC_C49677", :scoped_identifier_version => 1}
    results[9] = {:id => "BC-ACME_BC_C49678", :scoped_identifier_version => 1}
    results[10] = {:id => "BC-ACME_BC_C81255", :scoped_identifier_version => 1}
    results[11] = {:id => "BC-ACME_BC_C98785", :scoped_identifier_version => 1}
    results[12] = {:id => "BC-ACME_BC_C98793", :scoped_identifier_version => 1}
    results[13] = {:id => "", :scoped_identifier_version => 1}
    results[14] = {:id => "", :scoped_identifier_version => 1}
    results[15] = {:id => "", :scoped_identifier_version => 1}
    results[16] = {:id => "", :scoped_identifier_version => 1}
    results[17] = {:id => "", :scoped_identifier_version => 1}
    results[18] = {:id => "", :scoped_identifier_version => 1}
    results[19] = {:id => "", :scoped_identifier_version => 1}
    items = BiomedicalConcept.list
    items.each_with_index do |item, index|
      expect(items[index].id).to eq(results[index][:id])
      expect(items[index].scopedIdentifier.version).to eq(results[index][:scoped_identifier_version])
    end
  end

  it "finds all unique entries"

  it "allows the object to be exported as JSON"

  it "allows the object to be created from JSON"

  it "allows an object to be exported as SPARQL"

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
    item = BiomedicalConcept.new
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
  