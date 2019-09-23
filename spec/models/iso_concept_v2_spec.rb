require 'rails_helper'

describe IsoConceptV2 do

	include DataHelpers
  include PauseHelpers
  include TimeHelpers
  include IsoHelpers

	def sub_dir
    return "models/iso_concept"
  end

	context "Main Tests" do

    before :all do
      IsoHelpers.clear_cache
    end

	  before :each do
      schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl"]
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "iso_concept_data_3.ttl"]
      load_files(schema_files, data_files)
      # clear_triple_store
      # load_schema_file_into_triple_store("ISO11179Types.ttl")
      # load_schema_file_into_triple_store("ISO11179Identification.ttl")
      # load_schema_file_into_triple_store("ISO11179Registration.ttl")
      # load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      # load_test_file_into_triple_store("iso_concept_data_3.ttl")
	  end

		it "validates a valid object" do
	    result = IsoConcept.new
	    result.label = "123456789"
	    expect(result.valid?).to eq(true)
	  end

	  it "does not validate an invalid object" do
	    result = IsoConcept.new
	    result.label = "123456789@£$%"
	    expect(result.valid?).to eq(false)
	  end

	  it "allows an concept to be found" do
      uri = Uri.new(uri: "http://www.assero.co.uk/Y/V1#F-T_G1")
			expected =     
				{ 
	      	:rdf_type => "http://www.assero.co.uk/ISO11179Concepts#Concept",
	      	:uri => uri.to_s, 
	      	:label => "A Concept",
          :id => uri.to_id
	    	}
      result = IsoConceptV2.find(uri)
			expect(result.to_h).to eq(expected)   
		end

		it "allows for the uri to be returned" do
			uri = Uri.new(uri: "http://www.assero.co.uk/Y/V1#F-T_G1")
      concept = IsoConceptV2.find(uri)
			expect(concept.uri.to_s).to eq("http://www.assero.co.uk/Y/V1#F-T_G1")   
		end

    it "raises exception if item not found" do
      expect{IsoConceptV2.find("")}.to raise_error(Errors::ReadError, "Failed to query the database. SPARQL query failed.")   
    end

		it "allows for the type fragment to be returned" do
			uri = Uri.new(uri: "http://www.assero.co.uk/Y/V1#F-T_G1")
      concept = IsoConceptV2.find(uri)
			expect(concept.uri.fragment).to eq("F-T_G1")   
		end
		
    it "find or create" do
      expect(IsoConceptV2.where(label: "X").empty?).to eq(true)
      concept = IsoConceptV2.where_only_or_create("X")
      object = IsoConceptV2.where(label: "X")
      expect(object.count).to eq(1)   
      expect(object.first.label).to eq("X")   
    end
    
  end

  describe "Utility Methods" do

    def check_count(ct, n) 
      query_string = %Q{
        SELECT ?o
        {
          #{ct.uri.to_ref} <http://www.assero.co.uk/Thesaurus#isTopConcept> ?o .
        }
      }
      query_results = Sparql::Query.new.query(query_string, "", [])
      expect(query_results.by_object(:o).count).to eq(n)
    end

    def check_uri(ct, set) 
      query_string = %Q{
        SELECT ?o
        {
          #{ct.uri.to_ref} <http://www.assero.co.uk/Thesaurus#isTopConcept> ?o .
        }
      }
      query_results = Sparql::Query.new.query(query_string, "", [])
      expect(query_results.by_object(:o)).to eq(set)
    end

    before :all  do
      IsoHelpers.clear_cache
    end

    before :each do
      schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl", "thesaurus.ttl", "BusinessOperational.ttl"]
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..5)
    end

    it "add link" do
      item = Thesaurus::ManagedConcept.new
      item.uri = Uri.new(uri: "http://www.assero.co.uk/XXX")
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.assero.co.uk/MDRThesaurus/ACME/V1#TH-SPONSOR_CT-1"))
      ct.add_link(:is_top_concept, item.uri)
      check_count(ct, 1)
      check_uri(ct, [item.uri])
    end

    it "delete link" do
      item1 = Thesaurus::ManagedConcept.new
      item1.uri = Uri.new(uri: "http://www.assero.co.uk/XXX1")
      item2 = Thesaurus::ManagedConcept.new
      item2.uri = Uri.new(uri: "http://www.assero.co.uk/XXX2")
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.assero.co.uk/MDRThesaurus/ACME/V1#TH-SPONSOR_CT-1"))
      update_query = %Q{
        INSERT  
        {
          #{ct.uri.to_ref} <http://www.assero.co.uk/Thesaurus#isTopConcept> #{item1.uri.to_ref} .
          #{ct.uri.to_ref} <http://www.assero.co.uk/Thesaurus#isTopConcept> #{item2.uri.to_ref} .
        } WHERE {}
      }
      ct.partial_update(update_query, [])
      check_count(ct, 2)
      check_uri(ct, [item1.uri, item2.uri])
      ct.delete_link(:is_top_concept, item1.uri)
      check_uri(ct, [item2.uri])
      ct.delete_link(:is_top_concept, item2.uri)
      check_uri(ct, [])
    end

  end

end