require 'rails_helper'

describe "Thesaurus::Synonyms" do

	include DataHelpers
  include SparqlHelpers
    
	def sub_dir
    return "models/thesaurus/synonyms"
  end

  before :all do
    IsoHelpers.clear_cache
  end

  before :each do
    schema_files = 
    [
      "ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", 
      "ISO11179Concepts.ttl", "BusinessOperational.ttl", "thesaurus.ttl"
    ]
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "iso_scoped_identifier.ttl"]
    load_files(schema_files, data_files)
  end
 
  class TSTest < IsoConceptV2

    configure rdf_type: "http://www.assero.co.uk/Thesaurus#UnmanagedConcept",
              uri_property: :identifier,
              key_property: :identifier

    object_property :synonym, cardinality: :many, model_class: "Thesaurus::Synonym"
  
    include Thesaurus::Synonyms

  end

  it "merge synonyms" do
    object = TSTest.new
    object.synonym << Thesaurus::Synonym.where_only_or_create("X")
    object.synonym << Thesaurus::Synonym.where_only_or_create("Y")
    expect(object.synonyms_to_s).to eq("X; Y")
    object.synonym << Thesaurus::Synonym.where_only_or_create("A Third")
    expect(object.synonyms_to_s).to eq("A Third; X; Y")
  end

  it "creates a synonym set" do
    object = TSTest.new
    expect(Thesaurus::Synonym.where(label: "Syn 1").empty?).to eq(true)
    expect(Thesaurus::Synonym.where(label: "Syn 2").empty?).to eq(true)
    results = object.where_only_or_create_synonyms("Syn 1; Syn 2")
    s1 = Thesaurus::Synonym.where_only(label: "Syn 1")
    s2 = Thesaurus::Synonym.where_only(label: "Syn 2")
    expect(results.map{|x| x.uri}).to match_array([s1.uri, s2.uri])
    results = object.where_only_or_create_synonyms("Syn 1; Syn 2; Syn 3")
    s3 = Thesaurus::Synonym.where_only(label: "Syn 3")
    expect(results.map{|x| x.uri}).to match_array([s1.uri, s2.uri, s3.uri])
    results = object.where_only_or_create_synonyms("Syn 1; Syn 3")
    expect(results.map{|x| x.uri}).to match_array([s1.uri, s3.uri])
  end

end