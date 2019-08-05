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
	    clear_triple_store
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_test_file_into_triple_store("iso_concept_data_3.ttl")
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
          :uuid => uri.to_id
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
    
    it "find or create set, none present" do
      expect(IsoConceptV2.where(label: "X").empty?).to eq(true)
      expect(IsoConceptV2.where(label: "Y").empty?).to eq(true)
      concepts = IsoConceptV2.where_only_or_create_set(["X", "Y"])
      expect(concepts.count).to eq(2)
      object = IsoConceptV2.find(concepts[0])
      expect(object.label).to eq("X")   
      object = IsoConceptV2.find(concepts[1])
      expect(object.label).to eq("Y")   
    end
    
    it "find or create set, some present" do
      existing = IsoConceptV2.where_only_or_create("X")
      expect(IsoConceptV2.where(label: "Y").empty?).to eq(true)
      concepts = IsoConceptV2.where_only_or_create_set(["X", "Y"])
      expect(concepts.count).to eq(2)
      object = IsoConceptV2.find(concepts[0])
      expect(object.label).to eq("X")   
      expect(existing.uri).to eq(concepts[0])   
      object = IsoConceptV2.find(concepts[1])
      expect(object.label).to eq("Y")   
    end
    
  end

end