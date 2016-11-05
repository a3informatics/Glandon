require 'rails_helper'

describe IsoConcept do

	include DataHelpers

	it "clears triple store and loads test data" do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Basic.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Data.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_schema_file_into_triple_store("BusinessForm.ttl")
    load_test_file_into_triple_store("iso_concept_extension.ttl")
    load_test_file_into_triple_store("iso_concept_data.ttl")
  end

	it "allows a blank concept to be created" do
		result =     
			{ 
      	:type => "",
      	:id => "", 
      	:namespace => "", 
      	:label => "",
      	:extension_properties => []
    	}
		expect(IsoConcept.new.to_json).to match(result)   
	end

	it "allows an concept to be found" do
		result =     
			{ 
      	:type => "http://www.assero.co.uk/BusinessForm#Question",
      	:id => "F-AE_G1_I2", 
      	:namespace => "http://www.assero.co.uk/X/V1", 
      	:label => "Adverse Event",
      	:extension_properties => 
      		[
      			{
      				:rdf_type=>"http://www.assero.co.uk/BusinessForm#Extension1",
           		:value=>"14",
           		:label=>"Extension 1"
           	},
          	{
          		:rdf_type=>"http://www.assero.co.uk/BusinessForm#Extension2",
           		:value=>"true",
           		:label=>"Extension 2"
           	}
          ]
    	}
		expect(IsoConcept.find("F-AE_G1_I2", "http://www.assero.co.uk/X/V1").to_json).to eq(result)   
	end

	it "allows for the uri to be returned" do
		concept = IsoConcept.find("F-AE_G1_I2", "http://www.assero.co.uk/X/V1")
		expect(concept.uri.to_s).to eq("http://www.assero.co.uk/X/V1#F-AE_G1_I2")   
	end

	it "allows for the type fragment to be returned" do
		concept = IsoConcept.find("F-AE_G1_I2", "http://www.assero.co.uk/X/V1")
		expect(concept.rdf_type_fragment).to eq("Question")   
	end
	
	it "allows the type of a concept to be found" do
		expect(IsoConcept.get_type("F-AE_G1_I2", "http://www.assero.co.uk/X/V1").to_s).to eq("http://www.assero.co.uk/BusinessForm#Question")   
	end
	
=begin
	it "allows the child links to be determined" do
		triples = {}
		triples["F-AE_G1"] = []
		triples["F-AE_G1_I2"] = []
		triples["F-AE_G1"] << { :subject => "http://www.assero.co.uk/X/V1#F-AE_G1", :predicate => "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", :object => "http://www.assero.co.uk/BusinessForm#NormalGroup" }
		triples["F-AE_G1"] << { :subject => "http://www.assero.co.uk/X/V1#F-AE_G1", :predicate => "http://www.w3.org/2000/01/rdf-schema#label", :object => "Question Group" }
		triples["F-AE_G1"] << { :subject => "http://www.assero.co.uk/X/V1#F-AE_G1", :predicate => "http://www.assero.co.uk/BusinessForm#isGroupOf", :object => "http://www.assero.co.uk/X/V1#F-AE" }
		triples["F-AE_G1"] << { :subject => "http://www.assero.co.uk/X/V1#F-AE_G1", :predicate => "http://www.assero.co.uk/BusinessForm#hasItem", :object => "http://www.assero.co.uk/X/V1#F-AE_G1_I1" }
		triples["F-AE_G1"] << { :subject => "http://www.assero.co.uk/X/V1#F-AE_G1", :predicate => "http://www.assero.co.uk/BusinessForm#hasItem", :object => "http://www.assero.co.uk/X/V1#F-AE_G1_I2" } 
		triples["F-AE_G1"] << { :subject => "http://www.assero.co.uk/X/V1#F-AE_G1", :predicate => "http://www.assero.co.uk/BusinessForm#hasItem", :object => "http://www.assero.co.uk/X/V1#F-AE_G1_I3" } 
		triples["F-AE_G1"] << { :subject => "http://www.assero.co.uk/X/V1#F-AE_G1", :predicate => "http://www.assero.co.uk/BusinessForm#hasItem", :object => "http://www.assero.co.uk/X/V1#F-AE_G1_I4" } 
		triples["F-AE_G1"] << { :subject => "http://www.assero.co.uk/X/V1#F-AE_G1", :predicate => "http://www.assero.co.uk/BusinessForm#hasItem", :object => "http://www.assero.co.uk/X/V1#F-AE_G1_I5" } 
		triples["F-AE_G1"] << { :subject => "http://www.assero.co.uk/X/V1#F-AE_G1", :predicate => "http://www.assero.co.uk/BusinessForm#hasItem", :object => "http://www.assero.co.uk/X/V1#F-AE_G1_I6" } 
		triples["F-AE_G1"] << { :subject => "http://www.assero.co.uk/X/V1#F-AE_G1", :predicate => "http://www.assero.co.uk/BusinessForm#hasItem", :object => "http://www.assero.co.uk/X/V1#F-AE_G1_I7" } 
		triples["F-AE_G1"] << { :subject => "http://www.assero.co.uk/X/V1#F-AE_G1", :predicate => "http://www.assero.co.uk/BusinessForm#completion", :object => "" }
		triples["F-AE_G1"] << { :subject => "http://www.assero.co.uk/X/V1#F-AE_G1", :predicate => "http://www.assero.co.uk/BusinessForm#note", :object => "" }
		triples["F-AE_G1"] << { :subject => "http://www.assero.co.uk/X/V1#F-AE_G1", :predicate => "http://www.assero.co.uk/BusinessForm#repeating", :object => "false" } 
		triples["F-AE_G1"] << { :subject => "http://www.assero.co.uk/X/V1#F-AE_G1", :predicate => "http://www.assero.co.uk/BusinessForm#optional", :object => "false" }
		triples["F-AE_G1"] << { :subject => "http://www.assero.co.uk/X/V1#F-AE_G1", :predicate => "http://www.assero.co.uk/BusinessForm#ordinal", :object => "1" }
		triples["F-AE_G1_I2"] << { :subject => "http://www.assero.co.uk/X/V1#F-AE_G1_I2", :predicate => "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", :object => "http://www.assero.co.uk/BusinessForm#Question" }
		triples["F-AE_G1_I2"] << { :subject => "http://www.assero.co.uk/X/V1#F-AE_G1_I2", :predicate => "http://www.w3.org/2000/01/rdf-schema#label", :object => "Adverse Event" }
		triples["F-AE_G1_I2"] << { :subject => "http://www.assero.co.uk/X/V1#F-AE_G1_I2", :predicate => "http://www.assero.co.uk/BusinessForm#completion", :object => "Completion" } 
		triples["F-AE_G1_I2"] << { :subject => "http://www.assero.co.uk/X/V1#F-AE_G1_I2", :predicate => "http://www.assero.co.uk/BusinessForm#note", :object => "" }
		triples["F-AE_G1_I2"] << { :subject => "http://www.assero.co.uk/X/V1#F-AE_G1_I2", :predicate => "http://www.assero.co.uk/BusinessForm#optional", :object => "false" } 
		triples["F-AE_G1_I2"] << { :subject => "http://www.assero.co.uk/X/V1#F-AE_G1_I2", :predicate => "http://www.assero.co.uk/BusinessForm#ordinal", :object => "2" }
		triples["F-AE_G1_I2"] << { :subject => "http://www.assero.co.uk/X/V1#F-AE_G1_I2", :predicate => "http://www.assero.co.uk/BusinessForm#datatype", :object => "S" } 
		triples["F-AE_G1_I2"] << { :subject => "http://www.assero.co.uk/X/V1#F-AE_G1_I2", :predicate => "http://www.assero.co.uk/BusinessForm#format", :object => "50" }
		triples["F-AE_G1_I2"] << { :subject => "http://www.assero.co.uk/X/V1#F-AE_G1_I2", :predicate => "http://www.assero.co.uk/BusinessForm#mapping", :object => "AETERM" } 
		triples["F-AE_G1_I2"] << { :subject => "http://www.assero.co.uk/X/V1#F-AE_G1_I2", :predicate => "http://www.assero.co.uk/BusinessForm#question_text", :object => "Adverse Event:" } 
		triples["F-AE_G1_I2"] << { :subject => "http://www.assero.co.uk/X/V1#F-AE_G1_I2", :predicate => "http://www.assero.co.uk/BusinessForm#Extension1", :object => "14" }
		triples["F-AE_G1_I2"] << { :subject => "http://www.assero.co.uk/X/V1#F-AE_G1_I2", :predicate => "http://www.assero.co.uk/BusinessForm#Extension2", :object => "true" } 
		links = []
		#links << { :rdf_type => "http://www.assero.co.uk/BusinessForm#isGroupOf", :value => "http://www.assero.co.uk/X/V1#F-AE" }
		#links << { :rdf_type => "http://www.assero.co.uk/BusinessForm#hasItem", :value => "http://www.assero.co.uk/X/V1#F-AE_G1_I1" }
		#links << { :rdf_type => "http://www.assero.co.uk/BusinessForm#hasItem", :value => "http://www.assero.co.uk/X/V1#F-AE_G1_I2" } 
		#links << { :rdf_type => "http://www.assero.co.uk/BusinessForm#hasItem", :value => "http://www.assero.co.uk/X/V1#F-AE_G1_I3" } 
		#links << { :rdf_type => "http://www.assero.co.uk/BusinessForm#hasItem", :value => "http://www.assero.co.uk/X/V1#F-AE_G1_I4" } 
		#links << { :rdf_type => "http://www.assero.co.uk/BusinessForm#hasItem", :value => "http://www.assero.co.uk/X/V1#F-AE_G1_I5" } 
		#links << { :rdf_type => "http://www.assero.co.uk/BusinessForm#hasItem", :value => "http://www.assero.co.uk/X/V1#F-AE_G1_I6" } 
		#links << { :rdf_type => "http://www.assero.co.uk/BusinessForm#hasItem", :value => "http://www.assero.co.uk/X/V1#F-AE_G1_I7" } 
		links << "http://www.assero.co.uk/X/V1#F-AE_G1_I1"
		links << "http://www.assero.co.uk/X/V1#F-AE_G1_I2" 
		links << "http://www.assero.co.uk/X/V1#F-AE_G1_I3" 
		links << "http://www.assero.co.uk/X/V1#F-AE_G1_I4"
		links << "http://www.assero.co.uk/X/V1#F-AE_G1_I5"
		links << "http://www.assero.co.uk/X/V1#F-AE_G1_I6"
		links << "http://www.assero.co.uk/X/V1#F-AE_G1_I7"
		expect(IsoConcept.find_for_parent(triples, links)).to eq()   
	end
=end

	it "allows an extension property to be added" do
		result = {}
		result["http://www.assero.co.uk/BusinessForm#Extension2"] = 
    	{
    		:uri=>"http://www.assero.co.uk/BusinessForm#Extension2", 
    		:label=>"Extension 2", 
    		:domain=>"http://www.assero.co.uk/BusinessForm#Question", 
    		:xsd_type=>"http://www.w3.org/2001/XMLSchema#boolean"
    	}
    result["http://www.assero.co.uk/BusinessForm#Extension1"] = 
			{
				:uri => "http://www.assero.co.uk/BusinessForm#Extension1", 
				:label => "Extension 1", 
				:domain => "http://www.assero.co.uk/BusinessForm#Question", 
				:xsd_type => "http://www.w3.org/2001/XMLSchema#integer" 
			}
    result["http://www.assero.co.uk/BusinessForm#XXX"] = 
    	{
    		:uri=>"http://www.assero.co.uk/BusinessForm#XXX", 
    		:label=>"A new extended property", 
    		:domain=>"http://www.assero.co.uk/BusinessForm#Question", 
    		:xsd_type=>"http://www.w3.org/2001/XMLSchema#string"
    	}
		concept = IsoConcept.find("F-AE_G1_I2", "http://www.assero.co.uk/X/V1")
		concept.add_extension_property("http://www.assero.co.uk/BusinessForm", { :identifier => "XXX", :datatype => "string", :label => "A new extended property", :definition => "A definition"})
		expect(concept.errors.count).to eq(0)
		expect(concept.extension_attributes).to eq(result)
	end

	it "prevents a duplicate extension property to be added" do
		result = {}
		result["http://www.assero.co.uk/BusinessForm#Extension2"] = 
    	{
    		:uri=>"http://www.assero.co.uk/BusinessForm#Extension2", 
    		:label=>"Extension 2", 
    		:domain=>"http://www.assero.co.uk/BusinessForm#Question", 
    		:xsd_type=>"http://www.w3.org/2001/XMLSchema#boolean"
    	}
    result["http://www.assero.co.uk/BusinessForm#Extension1"] = 
			{
				:uri => "http://www.assero.co.uk/BusinessForm#Extension1", 
				:label => "Extension 1", 
				:domain => "http://www.assero.co.uk/BusinessForm#Question", 
				:xsd_type => "http://www.w3.org/2001/XMLSchema#integer" 
			}
    result["http://www.assero.co.uk/BusinessForm#XXX"] = 
    	{
    		:uri=>"http://www.assero.co.uk/BusinessForm#XXX", 
    		:label=>"A new extended property", 
    		:domain=>"http://www.assero.co.uk/BusinessForm#Question", 
    		:xsd_type=>"http://www.w3.org/2001/XMLSchema#string"
    	}
		concept = IsoConcept.find("F-AE_G1_I2", "http://www.assero.co.uk/X/V1")
		concept.add_extension_property("http://www.assero.co.uk/BusinessForm", { :identifier => "XXX", :datatype => "string", :label => "A new extended property", :definition => "A definition"})
		expect(concept.errors.count).to eq(1)
		expect(concept.extension_attributes).to eq(result)
	end

	it "allows a concept to be output as SPARQL, with third extension" do
		result = "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
       "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
       "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
       "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
       "INSERT DATA \n" +
       "{ \n" +
       "<http://www.assero.co.uk/X/V1#F-AE_G1_I2> rdf:type <http://www.assero.co.uk/BusinessForm#Question> . \n" +
       "<http://www.assero.co.uk/X/V1#F-AE_G1_I2> rdfs:label \"Adverse Event\"^^xsd:string . \n" +
       "<http://www.assero.co.uk/X/V1#F-AE_G1_I2> <http://www.assero.co.uk/BusinessForm#Extension1> \"14\"^^xsd:integer . \n" +
       "<http://www.assero.co.uk/X/V1#F-AE_G1_I2> <http://www.assero.co.uk/BusinessForm#Extension2> \"true\"^^xsd:boolean . \n" +
       "<http://www.assero.co.uk/X/V1#F-AE_G1_I2> <http://www.assero.co.uk/BusinessForm#XXX> \"\"^^xsd:string . \n" +
       "}"
		concept = IsoConcept.find("F-AE_G1_I2", "http://www.assero.co.uk/X/V1")
		sparql = SparqlUpdateV2.new
		concept.to_sparql_v2(sparql, "bf")
		expect(sparql.to_s).to eq(result)
	end

	it "allows a concept to be output as JSON, with third extension" do
		result =     
			{ 
      	:type => "http://www.assero.co.uk/BusinessForm#Question",
      	:id => "F-AE_G1_I2", 
      	:namespace => "http://www.assero.co.uk/X/V1", 
      	:label => "Adverse Event",
      	:extension_properties => 
      		[
      			{
      				:rdf_type=>"http://www.assero.co.uk/BusinessForm#Extension1",
           		:value=>"14",
           		:label=>"Extension 1"
           	},
          	{
          		:rdf_type=>"http://www.assero.co.uk/BusinessForm#Extension2",
           		:value=>"true",
           		:label=>"Extension 2"
           	},
           	{
          		:rdf_type=>"http://www.assero.co.uk/BusinessForm#XXX",
           		:value=>"",
           		:label=>"A new extended property"
           	}
          ]
    	}
		concept = IsoConcept.find("F-AE_G1_I2", "http://www.assero.co.uk/X/V1")
		expect(concept.to_json).to eq(result)
	end

	it "allows extension properties to be updated" do
		result = "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
       "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
       "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
       "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
       "INSERT DATA \n" +
       "{ \n" +
       "<http://www.assero.co.uk/X/V1#F-AE_G1_I2> rdf:type <http://www.assero.co.uk/BusinessForm#Question> . \n" +
       "<http://www.assero.co.uk/X/V1#F-AE_G1_I2> rdfs:label \"Adverse Event\"^^xsd:string . \n" +
       "<http://www.assero.co.uk/X/V1#F-AE_G1_I2> <http://www.assero.co.uk/BusinessForm#Extension1> \"21\"^^xsd:integer . \n" +
       "<http://www.assero.co.uk/X/V1#F-AE_G1_I2> <http://www.assero.co.uk/BusinessForm#Extension2> \"false\"^^xsd:boolean . \n" +
       "<http://www.assero.co.uk/X/V1#F-AE_G1_I2> <http://www.assero.co.uk/BusinessForm#XXX> \"Hello World!\"^^xsd:string . \n" +
       "}"
		concept = IsoConcept.find("F-AE_G1_I2", "http://www.assero.co.uk/X/V1")
		json = concept.to_json
		json[:extension_properties][0][:value] = "21"
		json[:extension_properties][1][:value] = "false"
		json[:extension_properties][2][:value] = "Hello World!"
		new_concept = IsoConcept.from_json(json)
		sparql = SparqlUpdateV2.new
		new_concept.to_sparql_v2(sparql, "bf")
		expect(sparql.to_s).to eq(result)
	end

	it "allows an extension property to be deleted" do
		result = {}
		result["http://www.assero.co.uk/BusinessForm#Extension1"] = 
			{
				:uri => "http://www.assero.co.uk/BusinessForm#Extension1", 
				:label => "Extension 1", 
				:domain => "http://www.assero.co.uk/BusinessForm#Question", 
				:xsd_type => "http://www.w3.org/2001/XMLSchema#integer" 
			}
    result["http://www.assero.co.uk/BusinessForm#Extension2"] = 
    	{
    		:uri=>"http://www.assero.co.uk/BusinessForm#Extension2", 
    		:label=>"Extension 2", 
    		:domain=>"http://www.assero.co.uk/BusinessForm#Question", 
    		:xsd_type=>"http://www.w3.org/2001/XMLSchema#boolean"
    	}
    concept = IsoConcept.find("F-AE_G1_I2", "http://www.assero.co.uk/X/V1")
		concept.destroy_extension_property({:uri => "http://www.assero.co.uk/BusinessForm#XXX"})
		expect(concept.errors.count).to eq(0)
		expect(concept.extension_attributes).to eq(result)
	end

	it "allows a concept to be output as SPARQL, third extension property removed" do
		result = "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
       "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
       "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
       "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
       "INSERT DATA \n" +
       "{ \n" +
       "<http://www.assero.co.uk/X/V1#F-AE_G1_I2> rdf:type <http://www.assero.co.uk/BusinessForm#Question> . \n" +
       "<http://www.assero.co.uk/X/V1#F-AE_G1_I2> rdfs:label \"Adverse Event\"^^xsd:string . \n" +
       "<http://www.assero.co.uk/X/V1#F-AE_G1_I2> <http://www.assero.co.uk/BusinessForm#Extension1> \"14\"^^xsd:integer . \n" +
       "<http://www.assero.co.uk/X/V1#F-AE_G1_I2> <http://www.assero.co.uk/BusinessForm#Extension2> \"true\"^^xsd:boolean . \n" +
       "}"
		concept = IsoConcept.find("F-AE_G1_I2", "http://www.assero.co.uk/X/V1")
		sparql = SparqlUpdateV2.new
		concept.to_sparql_v2(sparql, "bf")
		expect(sparql.to_s).to eq(result)
	end
	
	it "allows a concept of to be deleted" do
		result =     
			{ 
      	:type => "",
      	:id => "", 
      	:namespace => "", 
      	:label => "",
      	:extension_properties => []
    	}
		concept = IsoConcept.find("F-AE_G1_I2", "http://www.assero.co.uk/X/V1")
		concept.destroy
		expect(IsoConcept.find("F-AE_G1_I2", "http://www.assero.co.uk/X/V1").to_json).to match(result)
	end

	it "allows all concepts of a given type to be found" do
		results = []
		results <<     
			{ 
      	:type => "http://www.assero.co.uk/BusinessForm#Question",
      	:id => "F-ACME_DM101_G1_I1", 
      	:namespace => "http://www.assero.co.uk/MDRForms/ACME/V1", 
      	:label => "CRF Number",
      	:extension_properties => []
    	}
    results <<     
			{ 
      	:type => "http://www.assero.co.uk/BusinessForm#Question",
      	:id => "F-ACME_DM101_G1_I2", 
      	:namespace => "http://www.assero.co.uk/MDRForms/ACME/V1", 
      	:label => "Date of Birth",
      	:extension_properties => []
    	}
    results <<     
			{ 
      	:type => "http://www.assero.co.uk/BusinessForm#Question",
      	:id => "F-ACME_DM101_G1_I3", 
      	:namespace => "http://www.assero.co.uk/MDRForms/ACME/V1", 
      	:label => "Sex",
      	:extension_properties => []
    	}
    results <<     
			{ 
      	:type => "http://www.assero.co.uk/BusinessForm#Question",
      	:id => "F-ACME_DM101_G1_I4", 
      	:namespace => "http://www.assero.co.uk/MDRForms/ACME/V1", 
      	:label => "Race",
      	:extension_properties => []
    	}
    results <<     
			{ 
      	:type => "http://www.assero.co.uk/BusinessForm#Question",
      	:id => "F-ACME_DM101_G1_I5", 
      	:namespace => "http://www.assero.co.uk/MDRForms/ACME/V1", 
      	:label => "Race Other",
      	:extension_properties => []
    	}
    results <<     
			{ 
      	:type => "http://www.assero.co.uk/BusinessForm#Question",
      	:id => "F-ACME_DM101_G1_I6", 
      	:namespace => "http://www.assero.co.uk/MDRForms/ACME/V1", 
      	:label => "Ethnicity",
      	:extension_properties => []
    	}
    results <<     
			{ 
      	:type => "http://www.assero.co.uk/BusinessForm#Question",
      	:id => "F-ACME_DM101_G1_I7", 
      	:namespace => "http://www.assero.co.uk/MDRForms/ACME/V1", 
      	:label => "Ethnic Subgroup",
      	:extension_properties => []
    	}
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Basic.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Data.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_schema_file_into_triple_store("BusinessForm.ttl")
    load_data_file_into_triple_store("ACME_DM1 01.ttl")
    concepts = IsoConcept.all("Question", "http://www.assero.co.uk/BusinessForm")
    concepts.each_with_index do |item, index|
    	results.should include(concepts[index].to_json)
    end
	end

	it "clears triple store" do
    clear_triple_store
  end

end