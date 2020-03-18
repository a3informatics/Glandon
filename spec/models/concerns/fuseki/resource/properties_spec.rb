require 'rails_helper'

describe Fuseki::Resource::Properties do
  
  include DataHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/concerns/fuseki/resource/properties"
  end

  before :all do
    IsoHelpers.clear_cache
  end

  def property_metadata(property)
    result = {}
    property.each {|key, value| result[key] = value.respond_to?(:to_h) ? value.to_h : value}
    result
  end

  def all_metadata(metadata)
    result = {}
    metadata.each {|key, property| result[key] = property_metadata(property)}
    result
  end

  before :each do
    data_files = ["iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl"]
    load_files(schema_files, data_files)
  end

  it "setup properties" do
    metadata = FusekiBaseHelpers::TestRegistrationAuthorities.resources
    item = FusekiBaseHelpers::TestRegistrationAuthorities.new
    properties = Fuseki::Resource::Properties.new(item, metadata)
    expect(properties.parent.class).to eq(FusekiBaseHelpers::TestRegistrationAuthorities)
    check_file_actual_expected(all_metadata(properties.metadata), sub_dir, "properties_new_expected_1.yaml")
  end
  
  it "ignore property" do
    metadata = FusekiBaseHelpers::TestRegistrationAuthorities.resources
    item = FusekiBaseHelpers::TestRegistrationAuthorities.new
    properties = Fuseki::Resource::Properties.new(item, metadata)
    expect(properties.ignore?(:fred)).to eq(true)
    expect(properties.ignore?(:owner)).to eq(false)
    expect(properties.ignore?(:ra_namespace)).to eq(false)
  end  

  it "property" do
    metadata = FusekiBaseHelpers::TestRegistrationAuthorities.resources
    item = FusekiBaseHelpers::TestRegistrationAuthorities.new
    properties = Fuseki::Resource::Properties.new(item, metadata)
    result = properties.property(:owner)
    check_file_actual_expected(property_metadata(result.metadata), sub_dir, "property_expected_1.yaml")
  end  

  it "assign" do
    metadata = FusekiBaseHelpers::TestRegistrationAuthorities.resources
    item = FusekiBaseHelpers::TestRegistrationAuthorities.new
    item.properties.assign(organization_identifier: "NEW", owner: true)
    expect(item.owner).to eq(true)
    expect(item.organization_identifier).to eq("NEW")
  end  

  it "sets property from triple" do
    metadata = FusekiBaseHelpers::TestRegistrationAuthorities.resources
    item = FusekiBaseHelpers::TestRegistrationAuthorities.new
    properties = Fuseki::Resource::Properties.new(item, metadata)
    result = properties.property_from_triple({subject: "", predicate: Uri.new(uri: "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"), object: ""})
    expect(result).to eq(nil)
    result = properties.property_from_triple({subject: "", predicate: Uri.new(uri: "http://www.assero.co.uk/ISO11179Registration#internationalCodeDesignator"), object: "EEEEE"})
    expect(result.name).to eq(:international_code_designator)
    expect(result.get).to eq("EEEEE")
    result = properties.property_from_triple({subject: "", predicate: Uri.new(uri: "http://www.assero.co.uk/ISO11179Registration#raNamespace"), object: Uri.new(uri: "http://www.assero.co.uk/A#A")})
    expect(result.name).to eq(:ra_namespace)
    expect(result.get.to_s).to eq("http://www.assero.co.uk/A#A")
  end

  it "same property" do
    metadata = FusekiBaseHelpers::TestRegistrationAuthorities.resources
    item = FusekiBaseHelpers::TestRegistrationAuthorities.new
    properties = Fuseki::Resource::Properties.new(item, metadata)
    result = properties.property_from_triple({subject: "", predicate: Uri.new(uri: "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"), object: ""})
    expect(result).to eq(nil)
    result = properties.property_from_triple({subject: "", predicate: Uri.new(uri: "http://www.assero.co.uk/ISO11179Registration#internationalCodeDesignator"), object: "EEEEE"})
    expect(result.name).to eq(:international_code_designator)
    expect(result.get).to eq("EEEEE")
    item.properties.assign(international_code_designator: "NEW E")
    item.properties.assign(owner: true)
    expect(item.properties.property(:international_code_designator).get).to eq("NEW E")
    results = []
    item.properties.each {|x| results << "#{x.get}"}  
    expect(results).to match_array(["", "", "<Not Set>", "NEW E", "true"])
    item.properties.property(:organization_identifier).set_raw("ORG")
    results = []
    item.properties.each {|x| results << "#{x.get}"}  
    expect(results).to match_array(["", "", "ORG", "NEW E", "true"])
    results = []
    item.properties.each {|x| results << x.to_be_saved?}  
    expect(results).to match_array([true, true, true, true, true])
  end

  it "persisted" do
    metadata = FusekiBaseHelpers::TestRegistrationAuthorities.resources
    item = FusekiBaseHelpers::TestRegistrationAuthorities.new
    expect(item.properties.property(:organization_identifier).to_be_saved?).to eq(true)
    item.properties.saved
    expect(item.properties.property(:organization_identifier).to_be_saved?).to eq(false)
  end

end