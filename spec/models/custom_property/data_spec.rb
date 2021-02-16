require 'rails_helper'

describe CustomPropertyDefinition do
	
	include DataHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/custom_property/data"
  end

  before :each do
    load_files(schema_files, [])
  end

  def definitions
    uri = Uri.new(uri: "http://www.assero.co.uk/Thesaurus#UnmanagedConcept")
    [
      {
        datatype: "boolean", 
        label: "DC Stage", 
        description: "Indicates that the codelist is used in the Data Collection Metadata or not.", 
        default: "false",
        custom_property_of: uri
      },
      {
        datatype: "boolean", 
        label: "SDTM Stage", 
        description: "Indicates that the codelist is used in the Global Standard SDTM Metadata or not.", 
        default: "false",
        custom_property_of: uri
      },
      {
        datatype: "boolean", 
        label: "ADaM Stage", 
        description: "Indicates that the codelist is used in the Global Standard ADAM Metadata or not.", 
        default: "false",
        custom_property_of: uri
      },
      {
        datatype: "boolean", 
        label: "ED Use", 
        description: "Indicates that the codelist is used in the Global Standard External Data Workflows or not.", 
        default: "false",
        custom_property_of: uri
      },
      {
        datatype: "string", 
        label: "CRF Display Value", 
        description: "This is for data collection purposes only. This is the text to appear on the CRF. As specified internally.", 
        default: "",
        custom_property_of: uri
      }
    ]
  end

  def migration_one
    uri = Uri.new(uri: "http://www.assero.co.uk/Thesaurus#UnmanagedConcept")
    [
      {
        datatype: "string", 
        label: "Synonym Sponsor", 
        description: "Additional synonyms created by the sponsor", 
        default: "",
        custom_property_of: uri
      }
    ]
  end

  def migration_two
    uri = Uri.new(uri: "http://www.assero.co.uk/Thesaurus#UnmanagedConcept")
    [
      {
        datatype: "string", 
        label: "Display Order", 
        description: "The desired display order.", 
        default: "",
        custom_property_of: uri
      }
    ]
  end

  it "create custom property" do
    results = []
    definitions.each do |definition|
      item = CustomPropertyDefinition.new(definition)
      item.uri = item.create_uri(item.class.base_uri)
      results << item
    end
    sparql = Sparql::Update.new
    sparql.default_namespace(results.first.uri.namespace)
    results.each{|x| x.to_sparql(sparql, true)}
    full_path = sparql.to_file
  #Xcopy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "custom_properties.ttl")
	end

  it "create custom property, migration one" do
    results = []
    migration_one.each do |definition|
      item = CustomPropertyDefinition.new(definition)
      item.uri = item.create_uri(item.class.base_uri)
      results << item
    end
    sparql = Sparql::Update.new
    sparql.default_namespace(results.first.uri.namespace)
    results.each{|x| x.to_sparql(sparql, true)}
    full_path = sparql.to_file
  #Xcopy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "custom_properties_migration_one.ttl")
  end

  it "create custom property, migration two" do
    results = []
    migration_two.each do |definition|
      item = CustomPropertyDefinition.new(definition)
      item.uri = item.create_uri(item.class.base_uri)
      results << item
    end
    sparql = Sparql::Update.new
    sparql.default_namespace(results.first.uri.namespace)
    results.each{|x| x.to_sparql(sparql, true)}
    full_path = sparql.to_file
  #Xcopy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "custom_properties_migration_two.ttl")
  end

end