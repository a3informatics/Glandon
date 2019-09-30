require 'rails_helper'

describe "IsoScopedIdentifierV2" do
  
  include DataHelpers
  include SparqlHelpers

  def sub_dir
    return "models/iso_scoped_identifier_v2"
  end

  before :all do
    IsoHelpers.clear_cache
  end

  before :each do
    schema_files = ["ISO11179Identification.ttl", "ISO11179Registration.ttl"]
    data_files = ["iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl", "iso_scoped_identifier.ttl"]
    load_files(schema_files, data_files)
  end

  it "validates a valid object" do
    org = IsoNamespace.find_by_short_name("BBB")
    result = IsoScopedIdentifierV2.new
    result.has_scope = org
    result.uri = "http://www.example.com"
    result.identifier = "ABC"
    result.version = 123
    result.version_label = "Draft 123"
    result.semantic_version = "1.2.3"
    expect(result.valid?).to eq(true)
  end

  it "does not validate an invalid version" do
    org = IsoNamespace.find_by_short_name("BBB")
    result = IsoScopedIdentifierV2.new
    result.has_scope = org
    result.uri = "http://www.example.com"
    result.identifier = "ABC"
    result.version = "123s"
    result.version_label = "Draft 123s"
    result.semantic_version = "1.2.3"
    expect(result.valid?).to eq(false)
  end

  it "does not validate an invalid version label" do
    org = IsoNamespace.find_by_short_name("BBB")
    result = IsoScopedIdentifierV2.new
    result.has_scope = org
    result.uri = "http://www.example.com"
    result.identifier = "ABC"
    result.version = 123
    result.version_label = "Draft 123£"
    result.semantic_version = "1.2.3"
    expect(result.valid?).to eq(false)
  end

  it "does not validate an invalid identifier" do
    org = IsoNamespace.find_by_short_name("BBB")
    result = IsoScopedIdentifierV2.new
    result.has_scope = org
    result.uri = "http://www.example.com"
    result.identifier = "ABC@"
    result.version = 123
    result.version_label = "Draft 123"
    result.semantic_version = "1.2.3"
    expect(result.valid?).to eq(false)
  end

  it "does not validate an invalid semantic version" do
    org = IsoNamespace.find_by_short_name("BBB")
    result = IsoScopedIdentifierV2.new
    result.has_scope = org
    result.uri = "http://www.example.com"
    result.identifier = "ABC@"
    result.version = 123
    result.version_label = "Draft 123"
    result.semantic_version = "1.2.3WWW"
    expect(result.valid?).to eq(false)
  end

  it "allows the next version to be retrieved" do
    result = IsoScopedIdentifierV2.find(Uri.new(uri: "http://www.assero.co.uk/MDRItems#SI-TEST_1-1"))
    expect(result.next_version).to eq(2)
  end

  it "allows the next semantic version to be retrieved" do
    result = IsoScopedIdentifierV2.find(Uri.new(uri: "http://www.assero.co.uk/MDRItems#SI-TEST_SV2-5"))
    expect(result.next_semantic_version.to_s).to eq("3.2.0")
  end

  it "allows a check against a later version" do
    result = IsoScopedIdentifierV2.find(Uri.new(uri: "http://www.assero.co.uk/MDRItems#SI-TEST_3-3"))
    expect(result.later_version?(2)).to eq(true)
  end

  it "allows a check against a later version" do
    result = IsoScopedIdentifierV2.find(Uri.new(uri: "http://www.assero.co.uk/MDRItems#SI-TEST_3-3"))
    expect(result.later_version?(3)).to eq(false)
  end

  it "allows a check against a earlier version" do
    result = IsoScopedIdentifierV2.find(Uri.new(uri: "http://www.assero.co.uk/MDRItems#SI-TEST_3-3"))
    expect(result.earlier_version?(4)).to eq(true)
  end

  it "allows a check against a earlier version" do
    result = IsoScopedIdentifierV2.find(Uri.new(uri: "http://www.assero.co.uk/MDRItems#SI-TEST_3-3"))
    expect(result.earlier_version?(3)).to eq(false)
  end

  it "allows a check against a same version" do
    result = IsoScopedIdentifierV2.find(Uri.new(uri: "http://www.assero.co.uk/MDRItems#SI-TEST_1-1"))
    expect(result.same_version?(2)).to eq(false)
  end

  it "allows a check against a same version" do
    result = IsoScopedIdentifierV2.find(Uri.new(uri: "http://www.assero.co.uk/MDRItems#SI-TEST_1-1"))
    expect(result.same_version?(1)).to eq(true)
  end

  it "allows the first version to be found" do
    expect(IsoScopedIdentifierV2.first_version).to eq(1)
  end

  it "detects if a identifier exists" do
    org = IsoNamespace.find_by_short_name("BBB")
    expect(IsoScopedIdentifierV2.exists?("TEST3", org)).to eq(true)
  end

  it "detects if a identifier does not exist" do
    org = IsoNamespace.find_by_short_name("BBB")
    expect(IsoScopedIdentifierV2.exists?("TEST3x", org)).to eq(false)
  end

  it "detects if a identifier with version exists" do
    org = IsoNamespace.find_by_short_name("BBB")
    expect(IsoScopedIdentifierV2.version_exists?("TEST3", 3, org)).to eq(true)
  end

  it "detects if a identifier with version does not exist" do
    org = IsoNamespace.find_by_short_name("BBB")
    expect(IsoScopedIdentifierV2.version_exists?("TEST3", 2, org)).to eq(false)
  end

  it "finds a given uri" do
    result = 
    {
      :uri => "http://www.assero.co.uk/MDRItems#SI-TEST_1-1", 
      :id => Uri.new(uri: "http://www.assero.co.uk/MDRItems#SI-TEST_1-1").to_id,
      :identifier => "TEST1", 
      :version => 1, 
      :version_label => "0.1", 
      :semantic_version => "", 
      has_scope: "http://www.assero.co.uk/NS#BBB",
      rdf_type: "http://www.assero.co.uk/ISO11179Identification#ScopedIdentifier"
    }
    expect(IsoScopedIdentifierV2.find(Uri.new(uri: "http://www.assero.co.uk/MDRItems#SI-TEST_1-1")).to_h).to eq(result)
  end

  it "finds a given uri, semantic version" do
    iso_namespace = IsoNamespace.find_by_short_name("BBB")
    result = 
    {
      :uri => "http://www.assero.co.uk/MDRItems#SI-TEST_SV1-5", 
      :id => Uri.new(uri: "http://www.assero.co.uk/MDRItems#SI-TEST_SV1-5").to_id,
      :identifier => "TESTSV 1", 
      :version => 7, 
      :version_label => "0.7", 
      :semantic_version => "0.0.7", 
      has_scope: "http://www.assero.co.uk/NS#BBB",
      rdf_type: "http://www.assero.co.uk/ISO11179Identification#ScopedIdentifier"
    }
    expect(IsoScopedIdentifierV2.find(Uri.new(uri: "http://www.assero.co.uk/MDRItems#SI-TEST_SV1-5")).to_h).to eq(result)
  end

  it "finds a given id, semantic version, with child" do
    iso_namespace = IsoNamespace.find_by_short_name("BBB")
    result = 
    {
      :uri => "http://www.assero.co.uk/MDRItems#SI-TEST_SV1-5", 
      :id => Uri.new(uri: "http://www.assero.co.uk/MDRItems#SI-TEST_SV1-5").to_id,
      :identifier => "TESTSV 1", 
      :version => 7, 
      :version_label => "0.7", 
      :semantic_version => "0.0.7", 
      has_scope: 
      {
        :authority=>"www.bbb.com", :name=>"BBB Pharma", :short_name=>"BBB", :uri=>"http://www.assero.co.uk/NS#BBB",
        :id => Uri.new(uri: "http://www.assero.co.uk/NS#BBB").to_id,
        :rdf_type=>"http://www.assero.co.uk/ISO11179Identification#Namespace"
      },
      rdf_type: "http://www.assero.co.uk/ISO11179Identification#ScopedIdentifier"
    }
    expect(IsoScopedIdentifierV2.find_children(Uri.new(uri: "http://www.assero.co.uk/MDRItems#SI-TEST_SV1-5")).to_h).to eq(result)
  end

  it "does not find an unknown id" do
    expect{IsoScopedIdentifierV2.find(Uri.new(uri: "http://www.assero.co.uk/MDRItems#SI-TEST_1-1x")).id}.to raise_error(Errors::NotFoundError, "Failed to find http://www.assero.co.uk/MDRItems#SI-TEST_1-1x in IsoScopedIdentifierV2.")
  end

  it "allows all records to be returned" do
    expected = 
    [
      {
        uri: "http://www.assero.co.uk/MDRItems#SI-TEST_1-1", 
        id: Uri.new(uri: "http://www.assero.co.uk/MDRItems#SI-TEST_1-1").to_id, 
        :identifier => "TEST1", :version => 1, :version_label => "0.1", 
        :semantic_version => "", has_scope: "http://www.assero.co.uk/NS#BBB",
        rdf_type: "http://www.assero.co.uk/ISO11179Identification#ScopedIdentifier"
      },
      {
        uri: "http://www.assero.co.uk/MDRItems#SI-TEST_3-3", 
        id: Uri.new(uri: "http://www.assero.co.uk/MDRItems#SI-TEST_3-3").to_id, 
        :identifier => "TEST3", :version => 3, :version_label => "0.3", 
        :semantic_version => "", has_scope: "http://www.assero.co.uk/NS#BBB",
        rdf_type: "http://www.assero.co.uk/ISO11179Identification#ScopedIdentifier"
      },
      {
        uri: "http://www.assero.co.uk/MDRItems#SI-TEST_2-2", 
        id: Uri.new(uri: "http://www.assero.co.uk/MDRItems#SI-TEST_2-2").to_id, 
        :identifier => "TEST2", :version => 2, :version_label => "0.2", 
        :semantic_version => "", has_scope: "http://www.assero.co.uk/NS#BBB",
        rdf_type: "http://www.assero.co.uk/ISO11179Identification#ScopedIdentifier"
      },
      {
        uri: "http://www.assero.co.uk/MDRItems#SI-TEST_3-4", 
        id: Uri.new(uri: "http://www.assero.co.uk/MDRItems#SI-TEST_3-4").to_id, 
        :identifier => "TEST3", :version => 4, :version_label => "0.4", 
        :semantic_version => "", has_scope: "http://www.assero.co.uk/NS#BBB",
        rdf_type: "http://www.assero.co.uk/ISO11179Identification#ScopedIdentifier"
      },
      {
        uri: "http://www.assero.co.uk/MDRItems#SI-TEST_3-5", 
        id: Uri.new(uri: "http://www.assero.co.uk/MDRItems#SI-TEST_3-5").to_id, 
        :identifier => "TEST3", :version => 5, :version_label => "0.5", 
        :semantic_version => "", has_scope: "http://www.assero.co.uk/NS#BBB",
        rdf_type: "http://www.assero.co.uk/ISO11179Identification#ScopedIdentifier"
      },
      {
        uri: "http://www.assero.co.uk/MDRItems#SI-TEST_SV1-5", 
        id: Uri.new(uri: "http://www.assero.co.uk/MDRItems#SI-TEST_SV1-5").to_id, 
        :identifier => "TESTSV 1", :version => 7, :version_label => "0.7", 
        :semantic_version => "0.0.7", has_scope: "http://www.assero.co.uk/NS#BBB",
        rdf_type: "http://www.assero.co.uk/ISO11179Identification#ScopedIdentifier"
      },
      {
        uri: "http://www.assero.co.uk/MDRItems#SI-TEST_SV2-5", 
        id: Uri.new(uri: "http://www.assero.co.uk/MDRItems#SI-TEST_SV2-5").to_id, 
        :identifier => "TESTSV 2", :version => 6, :version_label => "0.6", 
        :semantic_version => "3.1.6", has_scope: "http://www.assero.co.uk/NS#BBB",
        rdf_type: "http://www.assero.co.uk/ISO11179Identification#ScopedIdentifier"
      }
    ]
    results = IsoScopedIdentifierV2.all
    expect(results.count).to eq(7)
    results.each do |result|
      compare = expected.find{|x| x[:uri] == result.uri.to_s}
      expect(result.to_h).to eq(compare)
    end
  end

  it "allows an object to be created" do
    org = IsoNamespace.find_by_short_name("BBB")
    result = 
    {
      uri: "http://www.assero.co.uk/SI/BBB/NEW-1", 
      id: Uri.new(uri: "http://www.assero.co.uk/SI/BBB/NEW-1").to_id,
      :identifier => "NEW 1", :version => 1, :version_label => "0.1", :semantic_version => "1.2.3", has_scope: org.to_h,
      rdf_type: "http://www.assero.co.uk/ISO11179Identification#ScopedIdentifier"}
    si = IsoScopedIdentifierV2.create(identifier: "NEW 1", version: 1, version_label: "0.1", semantic_version: "1.2.3", has_scope: org)
    expect(si.to_h).to eq(result)
    expect(si.errors.count).to eq(0)
    item = IsoScopedIdentifierV2.find_children(Uri.new(uri: "http://www.assero.co.uk/SI/BBB/NEW-1"))
    expect(item.to_h).to eq(result)
  end

  it "does not allow a duplicate object to be created" do
    org = IsoNamespace.find_by_short_name("BBB")
    si1 = IsoScopedIdentifierV2.create(identifier: "NEW 1", version: 1, version_label: "0.1", semantic_version: "1.2.3", has_scope: org)
    item = IsoScopedIdentifierV2.find_children(Uri.new(uri: "http://www.assero.co.uk/SI/BBB/NEW-1"))
    si2 = IsoScopedIdentifierV2.create(identifier: "NEW 1", version: 1, version_label: "0.1", semantic_version: "4.5.6", has_scope: org)
    expect(si2.errors.count).to eq(1)
    expect(si2.errors.full_messages.to_sentence).to eq("The scoped identifier is already in use")
  end

  it "does not allow an invalid object to be created" do
    org = IsoNamespace.find_by_short_name("BBB")
    result = {:id=>"SI-BBB_NEW_1-1", :identifier => "NEW@@@@ 1", :version => 1, :version_label => "0.1", has_scope: org.to_h}
    si = IsoScopedIdentifierV2.create(identifier: "NEW@@@@ 1", version: 1, version_label: "0.1", semantic_version: "4.5.6", has_scope: org)
    expect(si.errors.count).to eq(1)
    expect(si.errors.full_messages.to_sentence).to eq("Identifier contains invalid characters")
  end

  it "does not allow an invalid object to be created" do
    org = IsoNamespace.find_by_short_name("BBB")
    si = IsoScopedIdentifierV2.create(identifier: "NEW_1", version: 1, version_label: "0.1", semantic_version: "4.5.6", has_scope: org)
    expect(si.errors.count).to eq(1)
    expect(si.errors.full_messages.to_sentence).to eq("Identifier contains invalid characters")
  end

  it "does not allow an invalid object to be created" do
    org = IsoNamespace.find_by_short_name("BBB")
    si = IsoScopedIdentifierV2.create(identifier: "NEW-1", version: 1, version_label: "0.1", semantic_version: "4.5.6", has_scope: org)
    expect(si.errors.count).to eq(1)
    expect(si.errors.full_messages.to_sentence).to eq("Identifier contains invalid characters")
  end
  
  it "allows an object to be created from JSON" do
    org = IsoNamespace.find_by_short_name("BBB")
    result = {uri: "http://www.assero.co.uk/SI/BBB/NEW_1", id: Uri.new(uri: "http://www.assero.co.uk/SI/BBB/NEW_1").to_id, :identifier => "NEW_1", :version => 1, :version_label => "0.1", :semantic_version => "1.2.3", has_scope: org.to_h,
      rdf_type: "http://www.assero.co.uk/ISO11179Identification#ScopedIdentifier"}
    json = {uri: "http://www.assero.co.uk/SI/BBB/NEW_1", identifier: "NEW_1", semantic_version: "1.2.3", version_label: "0.1", version: 1, has_scope: org.to_h }
    expect(IsoScopedIdentifierV2.from_h(json).to_h).to eq(result)
  end
  
  it "allows an object to be exported as JSON" do
    org = IsoNamespace.find_by_short_name("BBB")
    result = 
    {
      :uri=>"http://www.assero.co.uk/MDRItems#SI-TEST_3-4", 
      :id=>Uri.new(uri: "http://www.assero.co.uk/MDRItems#SI-TEST_3-4").to_id,
      :identifier => "TEST3", 
      :version => 4, 
      :version_label => "0.4", 
      :semantic_version => "", 
      has_scope: org.to_h,
      rdf_type: "http://www.assero.co.uk/ISO11179Identification#ScopedIdentifier"
    }
    expect(IsoScopedIdentifierV2.find_children(Uri.new(uri: "http://www.assero.co.uk/MDRItems#SI-TEST_3-4")).to_h).to eq(result)
  end

  it "allows an object to be exported as SPARQL" do
    sparql = Sparql::Update.new
    IsoScopedIdentifierV2.find(Uri.new(uri: "http://www.assero.co.uk/MDRItems#SI-TEST_3-4")).to_sparql(sparql)
  #Xwrite_text_file_2(sparql.to_create_sparql, sub_dir, "to_create_sparql_expected.txt")
    check_sparql_no_file(sparql.to_create_sparql, "to_create_sparql_expected.txt")
  end
  
  it "allows for an object to be updated, version label" do
    object = IsoScopedIdentifierV2.find_children(Uri.new(uri: "http://www.assero.co.uk/MDRItems#SI-TEST_3-4"))
    object.version_label = "0.10"
    object.semantic_version = "1.1.1"
    object.update
    expect(object.errors.count).to eq(0)
    object = IsoScopedIdentifierV2.find(Uri.new(uri: "http://www.assero.co.uk/MDRItems#SI-TEST_3-4"))
    expect(object.version_label).to eq("0.10")
  end
  
  it "allows for an object to be updated, semantic version" do
    object = IsoScopedIdentifierV2.find_children(Uri.new(uri: "http://www.assero.co.uk/MDRItems#SI-TEST_3-4"))
    object.semantic_version = "1.2.3"
    object.update
    expect(object.errors.count).to eq(0)
    object = IsoScopedIdentifierV2.find(Uri.new(uri: "http://www.assero.co.uk/MDRItems#SI-TEST_3-4"))
    expect(object.semantic_version.to_s).to eq("1.2.3")
  end
  
  it "prevents an object to be updated if invalid version label" do
    object = IsoScopedIdentifierV2.find_children(Uri.new(uri: "http://www.assero.co.uk/MDRItems#SI-TEST_3-4"))
    object.semantic_version = "1.2.3"
    object.version_label = "0.10±"
    object.update
    expect(object.errors.count).to eq(1)
  end
  
  it "allows for an object to be destroyed" do
    object = IsoScopedIdentifierV2.find(Uri.new(uri: "http://www.assero.co.uk/MDRItems#SI-TEST_3-4"))
    object.delete
  end

  it "handles a bad response error - destroy" do
    object = IsoScopedIdentifierV2.find(Uri.new(uri: "http://www.assero.co.uk/MDRItems#SI-TEST_3-4"))
    response = Typhoeus::Response.new(code: 200, body: "")
    expect(Rest).to receive(:sendRequest).and_return(response)
    expect(response).to receive(:success?).and_return(false)
    expect{object.delete}.to raise_error(Errors::DestroyError, "Failed to delete an item in the database. SPARQL delete failed.")
  end

  it "obtains the next version, does not exist" do
  	org = IsoNamespace.find_by_short_name("BBB")
  	version = IsoScopedIdentifierV2.next_version("XXXXXTEST1", org)
  	expect(version).to eq(1)
  end

  it "obtains the next version, exists" do
  	org = IsoNamespace.find_by_short_name("BBB")
  	version = IsoScopedIdentifierV2.next_version("TEST1", org)
  	expect(version).to eq(2)
  	version = IsoScopedIdentifierV2.next_version("TEST2", org)
  	expect(version).to eq(3)
  	version = IsoScopedIdentifierV2.next_version("TEST3", org)
  	expect(version).to eq(6)
  end

  it "generates a URI" do
    si = IsoScopedIdentifierV2.new
    si.generate_uri(Uri.new(uri: "http://www.assero.co.uk/ID/1"))
    expect(si.uri.to_s).to eq("http://www.assero.co.uk/ID/1#SI")
  end

end
  