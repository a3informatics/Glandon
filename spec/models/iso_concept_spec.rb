require 'rails_helper'

describe IsoConcept do

	include DataHelpers
  include PauseHelpers
  include TimeHelpers

	def sub_dir
    return "models/iso_concept"
  end

  def compare_link_to_results(results, expected)
		expect(results.length).to eq(expected.length)
		results.each do |r|
			found = false
			expected.each do |e|
				found = true if e.to_json == r.to_json
			end
			expect(r.to_json).to eq(expected.to_json) if !found
		end
	end

  def compare_cross_references(result, expected)
    expect(result.count).to eq(expected.count)
    result.each do |r|
      item = expected.find { |e| e[:uri].to_s == r[:uri].to_s }
      expect(item).to_not be_nil
    #puts "#{item[:uri].to_s} == #{r[:uri].to_s}"
      expect(item[:rdf_type]).to eq(r[:rdf_type])
    #puts "#{item[:rdf_type]} == #{r[:rdf_type].to_s}"
    end
  end

  def compare_cross_reference_details(result, expected)
    expect(result.count).to eq(expected.count)
    result.each do |r|
      item = expected.find { |e| e[:uri].to_s == r[:uri].to_s }
      expect(item).to_not be_nil
    #puts "#{item[:uri].to_s} == #{r[:uri].to_s}"
      expect(item[:comments]).to eq(r[:comments])
    #puts "#{item[:comments]} == #{r[:comments].to_s}"
      expect(item[:cross_references].map { |m| m.to_s }).to match_array(r[:cross_references].map { |m| m.to_s })
    end
  end

	context "Main Tests" do

	  before :all do
	    clear_triple_store
	    load_schema_file_into_triple_store("ISO11179Types.ttl")
	    load_schema_file_into_triple_store("ISO11179Basic.ttl")
	    load_schema_file_into_triple_store("ISO11179Identification.ttl")
	    load_schema_file_into_triple_store("ISO11179Registration.ttl")
	    load_schema_file_into_triple_store("ISO11179Data.ttl")
	    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
	    load_schema_file_into_triple_store("ISO25964.ttl")
	    load_schema_file_into_triple_store("BusinessOperational.ttl")
	    load_schema_file_into_triple_store("BusinessForm.ttl")
	    load_schema_file_into_triple_store("business_operational_extension.ttl")
	    load_schema_file_into_triple_store("business_cross_reference.ttl")
	    load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")    
	    load_test_file_into_triple_store("iso_concept_extension.ttl")
	    load_test_file_into_triple_store("iso_concept_data.ttl")
	    load_test_file_into_triple_store("iso_concept_data_2.ttl")
	    load_test_file_into_triple_store("CT_V42.ttl")
	    load_test_file_into_triple_store("CT_V46.ttl")
	    load_test_file_into_triple_store("CT_V47.ttl")
	    load_test_file_into_triple_store("BC.ttl")
	    load_test_file_into_triple_store("form_example_vs_baseline_new.ttl")
	    clear_iso_concept_object
	    clear_iso_namespace_object
	    clear_iso_registration_authority_object
	    clear_iso_registration_state_object
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

	  it "allows an object to be created from triples" do
	    expected = 
	    {
	      :extension_properties => 
	      [
	        {
	          :rdf_type => "http://www.assero.co.uk/BusinessForm#Extension1", 
	          :instance_variable=>"Extension1", 
	          :label=>"Extension 1"
	        }, 
	        {
	          :rdf_type=>"http://www.assero.co.uk/BusinessForm#Extension2", 
	          :instance_variable=>"Extension2", 
	          :label=>"Extension 2"
	        }
	      ],
	      :id => "F-AE_G1_I2",
	      :label => "Adverse Event",
	      :namespace => "http://www.assero.co.uk/X/V1",
	      :type => "http://www.assero.co.uk/BusinessForm#Question",
	    }
	    triples = read_yaml_file(sub_dir, "new_input.yaml")
	    result = IsoConcept.new(triples, "F-AE_G1_I2")
	    expect(result.to_json).to eq(expected)
	  end

	  it "allows an object to be created from triples, none present" do
	    expected = 
	    {
	      :extension_properties => [],
	      :id => "",
	      :label => "",
	      :namespace => "",
	      :type => "",
	    }
	    triples = read_yaml_file(sub_dir, "new_input.yaml")
	    result = IsoConcept.new(triples, "F-AE_G7_I10")
	    expect(result.to_json).to eq(expected)
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

		it "allows a blank concept to be created, missing extension_properties" do
	    input =     
	      { 
	        :type => "http://www.assero.co.uk/BusinessForm#Question",
	        :id => "F-AE_G1_I22", 
	        :namespace => "http://www.assero.co.uk/X/V1", 
	        :label => "Adverse Event"
	      }
	    result =     
	      { 
	        :type => "http://www.assero.co.uk/BusinessForm#Question",
	        :id => "F-AE_G1_I22", 
	        :namespace => "http://www.assero.co.uk/X/V1", 
	        :label => "Adverse Event",
	        :extension_properties => []
	      }
	    expect(IsoConcept.from_json(input).to_json).to eq(result)   
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
	      				rdf_type: "http://www.assero.co.uk/BusinessForm#Extension1",
	              :instance_variable => "Extension1",
	           		:label=>"Extension 1"
	           	},
	          	{
	          		rdf_type: "http://www.assero.co.uk/BusinessForm#Extension2",
	           		:instance_variable => "Extension2",
	              :label=>"Extension 2"
	           	}
	          ]
	    	}
			expect(IsoConcept.find("F-AE_G1_I2", "http://www.assero.co.uk/X/V1").to_json).to eq(result)   
		end

	  it "allows an concept to be found, get extension value" do
	    result =     
	      { 
	        :type => "http://www.assero.co.uk/BusinessForm#Question",
	        :id => "F-AE_G1_I2", 
	        :namespace => "http://www.assero.co.uk/X/V1", 
	        :label => "Adverse Event",
	        :extension_properties => 
	          [
	            {
	              rdf_type: "http://www.assero.co.uk/BusinessForm#Extension1",
	              :instance_variable => "Extension1",
	              :label=>"Extension 1"
	            },
	            {
	              rdf_type: "http://www.assero.co.uk/BusinessForm#Extension2",
	              :instance_variable => "Extension2",
	              :label=>"Extension 2"
	            }
	          ]
	      }
	    concept = IsoConcept.find("F-AE_G1_I2", "http://www.assero.co.uk/X/V1")
	    value = concept.get_extension_value("Extension1") 
	    expect(value).to eq(14)
	    #expect(concept.Extension1).to eq(14)
	    value = concept.get_extension_value("Extension2") 
	    expect(value).to eq(true)
	    #expect(concept.Extension2).to eq(true)
	  end

	  it "allows an concept to be found, get extension value, no extension" do
	    result =     
	      { 
	        :type => "http://www.assero.co.uk/BusinessForm#Question",
	        :id => "F-AE_G1_I2", 
	        :namespace => "http://www.assero.co.uk/X/V1", 
	        :label => "Adverse Event",
	        :extension_properties => 
	          [
	            {
	              rdf_type: "http://www.assero.co.uk/BusinessForm#Extension1",
	              :instance_variable => "Extension1",
	              :label=>"Extension 1"
	            },
	            {
	              rdf_type: "http://www.assero.co.uk/BusinessForm#Extension2",
	              :instance_variable => "Extension2",
	              :label=>"Extension 2"
	            }
	          ]
	      }
	    concept = IsoConcept.find("F-AE_G1_I2", "http://www.assero.co.uk/X/V1")
	    value = concept.get_extension_value("Extension11") 
	    expect(value).to eq("")
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

	  it "permits existance of an object to be determined" do
	    form = Form.find("F-AE_G1", "http://www.assero.co.uk/X/V1")
	    result = IsoConcept.exists?("completion", "IDENT", "NormalGroup", "http://www.assero.co.uk/BusinessForm", form.namespace)
	    expect(result).to eq(true)  
	  end

		it "permits existance of an object to be determined - fail" do
	    form = Form.find("F-AE_G1", "http://www.assero.co.uk/X/V1")
	    result = IsoConcept.exists?("completion", "IDENTx", "NormalGroup", "http://www.assero.co.uk/BusinessForm", form.namespace)
	    expect(result).to eq(false)  
	  end

		it "find by properties, ThesaurusConcept identifier" do
      concept = IsoConcept.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42", false)
	    results = concept.find_by_property({identifier: "C62122"}, ["hasConcept", "hasChild"], "ThesaurusConcept", "http://www.assero.co.uk/ISO25964")
			expect(results[0].to_s).to eq("http://www.assero.co.uk/MDRThesaurus/CDISC/V42#CLI-C71148_C62122")  
	  end

		it "find by properties, ThesaurusConcept, notation" do
      concept = IsoConcept.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42", false)
      results = concept.find_by_property({notation: "BPI125"}, ["hasConcept", "hasChild"], "ThesaurusConcept", "http://www.assero.co.uk/ISO25964")
      expect(results[0].to_s).to eq("http://www.assero.co.uk/MDRThesaurus/CDISC/V42#CLI-C100162_C100339")  
	  end

		it "find by properties, ThesaurusConcept, notation and identifier" do
      concept = IsoConcept.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42", false)
      results = concept.find_by_property({notation: "BPI125", identifier: "C100339"}, ["hasConcept", "hasChild"], "ThesaurusConcept", "http://www.assero.co.uk/ISO25964")
      expect(results[0].to_s).to eq("http://www.assero.co.uk/MDRThesaurus/CDISC/V42#CLI-C100162_C100339")  
	  end

		it "find by properties, ThesaurusConcept, notation and identifier, fail" do
      concept = IsoConcept.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42", false)
      results = concept.find_by_property({notation: "BPI125", identifier: "C100339x"}, ["hasConcept", "hasChild"], "ThesaurusConcept", "http://www.assero.co.uk/ISO25964")
      expect(results.length).to eq(0)  
	  end

	  it "allows the child links to be determined" do
	    expected = 
	      [ 
	        UriV2.new({:id => "F-AE_G1_I2", :namespace => "http://www.assero.co.uk/X/V1"}),
	        UriV2.new({:id => "F-AE_G1_I3", :namespace => "http://www.assero.co.uk/X/V1"}),
	        UriV2.new({:id => "F-AE_G1_I4", :namespace => "http://www.assero.co.uk/X/V1"}),
	        UriV2.new({:id => "F-AE_G1_I1", :namespace => "http://www.assero.co.uk/X/V1"})
	      ]
	    concept = IsoConcept.find("F-AE_G1", "http://www.assero.co.uk/X/V1")
	    links = concept.get_links_v2("bf", "hasItem")
	    links.each_with_index do |link|
	      found = expected.find { |x| x.id == link.id }
	      expect(link.id).to eq(found.id)
	    end
	  end

	  it "allows the child links to be determined when none present" do
	    concept = IsoConcept.find("F-AE_G1", "http://www.assero.co.uk/X/V1")
	    links = concept.get_links_v2("bf", "hasGroup")
	    expect(links).to eq([])
	  end

	  it "allows the children to be found for a parent object" do
	    concept = IsoConcept.find("F-AE_G1", "http://www.assero.co.uk/X/V1")
	    form = Form.find("F-AE_G1", "http://www.assero.co.uk/X/V1")
	    links = form.get_links_v2("bf", "hasItem")
	    children = Form::Group.find_for_parent(concept.triples, links)
	    expect(children.length).to eq(4)
	    expected = 
	      [ 
	        UriV2.new({:id => "F-AE_G1_I2", :namespace => "http://www.assero.co.uk/X/V1"}),
	        UriV2.new({:id => "F-AE_G1_I3", :namespace => "http://www.assero.co.uk/X/V1"}),
	        UriV2.new({:id => "F-AE_G1_I4", :namespace => "http://www.assero.co.uk/X/V1"}),
	        UriV2.new({:id => "F-AE_G1_I1", :namespace => "http://www.assero.co.uk/X/V1"})
	      ]
	    children.each_with_index do |child|
	      found = expected.find { |x| x.id == child.id }
	      expect(child.id).to eq(found.id)
	    end
	  end

	  it "allows a concept to be created" do
	    input =     
	      { 
	        :type => "http://www.assero.co.uk/BusinessForm#Question",
	        :id => "F-T_G1_I5", 
	        :namespace => "http://www.assero.co.uk/Y/V1", 
	        :label => "NEW NEW NEW"
	      }
	    concept = IsoConcept.from_json(input)
	    sparql = SparqlUpdateV2.new
	    sparql.default_namespace(concept.namespace)
	    concept.to_sparql_v2(sparql, "bf") 
	    concept.create(sparql)
	    all = IsoConcept.find("F-T_G1_I5", "http://www.assero.co.uk/Y/V1", true)
	  #write_yaml_file(all.triples, sub_dir, "create_expected.yaml")
	    expected = read_yaml_file(sub_dir, "create_expected.yaml")
	    all.triples["F-T_G1_I5"].each do |triple|
	      found = expected["F-T_G1_I5"].find { |x| x[:subject] == triple[:subject] && x[:predicate] == triple[:predicate] }
	      expect(triple).to eq(found)
	    end
	  end

	  it "handles failed response when a concept is being created" do
	    input =     
	      { 
	        :type => "http://www.assero.co.uk/BusinessForm#Question",
	        :id => "F-T_G1_I5", 
	        :namespace => "http://www.assero.co.uk/Y/V1", 
	        :label => "NEW NEW NEW"
	      }
	    concept = IsoConcept.from_json(input)
	    sparql = SparqlUpdateV2.new
	    sparql.default_namespace(concept.namespace)
	    concept.to_sparql_v2(sparql, "bf") 
	    response = Typhoeus::Response.new(code: 200, body: "") # Beware of odering og these next three lines. Should be just before test call.
	    expect(Rest).to receive(:sendRequest).and_return(response)
	    expect(response).to receive(:success?).and_return(false)
	    expect{concept.create(sparql)}.to raise_error(Exceptions::CreateError)
	  end

	  it "handles failed response when a concept is being destroyed" do
	    # Do this befoe next test or else object is not there
	    concept = IsoConcept.find("F-T_G1_I3", "http://www.assero.co.uk/Y/V1")
	    response = Typhoeus::Response.new(code: 200, body: "") # Beware of odering og these next three lines. Should be just before test call.
	    expect(Rest).to receive(:sendRequest).and_return(response)
	    expect(response).to receive(:success?).and_return(false)
	    expect{concept.destroy}.to raise_error(Exceptions::DestroyError)
	  end

	  it "allows an concept to be destroyed" do
	    concept = IsoConcept.find("F-T_G1_I3", "http://www.assero.co.uk/Y/V1")
	    concept.destroy
	    all = IsoConcept.find("F-T_G1", "http://www.assero.co.uk/Y/V1", true)
	  #write_yaml_file(all.triples, sub_dir, "destroy_expected.yaml")
	    expected = read_yaml_file(sub_dir, "destroy_expected.yaml")
	    all.triples["F-T_G1"].each do |triple|
	      found = expected["F-T_G1"].find { |x| x[:subject] == triple[:subject] && x[:predicate] == triple[:predicate] && x[:object] == triple[:object] }
	      expect(triple).to eq(found)
	    end
	  end

	  it "allows a child concept to be created" do
	    input =     
	      { 
	        :type => "http://www.assero.co.uk/BusinessForm#Question",
	        :id => "F-T_G1_I2_I1", 
	        :namespace => "http://www.assero.co.uk/Y/V1", 
	        :label => "CHILD"
	      }
	    child = IsoConcept.from_json(input)
	    parent = IsoConcept.find("F-T_G1_I2", "http://www.assero.co.uk/Y/V1")
	    sparql = SparqlUpdateV2.new
	    sparql.default_namespace(parent.namespace)
	    child.to_sparql_v2(sparql, "bf") 
	    parent.create_child(child, sparql, "bf", "test_link")    
	    all = IsoConcept.find("F-T_G1", "http://www.assero.co.uk/Y/V1", true)
	  #write_yaml_file(all.triples, sub_dir, "create_child_expected.yaml")
	    expected = read_yaml_file(sub_dir, "create_child_expected.yaml")
	    all.triples["F-T_G1"].each do |triple|
	      found = expected["F-T_G1"].find { |x| x[:subject] == triple[:subject] && x[:predicate] == triple[:predicate] && x[:object] == triple[:object] }
	      expect(triple).to eq(found)
	    end
	  end

	  it "handles failed response when a child concept is being created" do
	    input =     
	      { 
	        :type => "http://www.assero.co.uk/BusinessForm#Question",
	        :id => "F-T_G1_I2_I1", 
	        :namespace => "http://www.assero.co.uk/Y/V1", 
	        :label => "CHILD"
	      }
	    child = IsoConcept.from_json(input)
	    parent = IsoConcept.find("F-T_G1_I2", "http://www.assero.co.uk/Y/V1")
	    sparql = SparqlUpdateV2.new
	    sparql.default_namespace(parent.namespace)
	    child.to_sparql_v2(sparql, "bf") 
	    response = Typhoeus::Response.new(code: 200, body: "")
	    expect(Rest).to receive(:sendRequest).and_return(response) # Beware of odering og these next three lines. Should be just before test call.
	    expect(response).to receive(:success?).and_return(false)
	    expect{parent.create_child(child, sparql, "bf", "test_link")  }.to raise_error(Exceptions::CreateError)
	  end

	  it "handles failed response when a concept with associated links is being destroyed" do
	    child = IsoConcept.find("F-T_G1_I2_I1", "http://www.assero.co.uk/Y/V1")
	    response = Typhoeus::Response.new(code: 200, body: "") # Beware of odering og these next three lines. Should be just before test call.
	    expect(Rest).to receive(:sendRequest).and_return(response)
	    expect(response).to receive(:success?).and_return(false)
	    expect{child.destroy_with_links}.to raise_error(Exceptions::DestroyError)
	  end

	  it "allows a concept to be destroyed with associated links" do
	    child = IsoConcept.find("F-T_G1_I2_I1", "http://www.assero.co.uk/Y/V1")
	    child.destroy_with_links
	    all = IsoConcept.find("F-T_G1", "http://www.assero.co.uk/Y/V1", true)
	  #write_yaml_file(all.triples, sub_dir, "destroy_with_links_expected.yaml")
	    expected = read_yaml_file(sub_dir, "destroy_with_links_expected.yaml")
	    all.triples["F-T_G1"].each do |triple|
	      found = expected["F-T_G1"].find { |x| x[:subject] == triple[:subject] && x[:predicate] == triple[:predicate] && x[:object] == triple[:object] }
	      expect(triple).to eq(found)
	    end
	  end

	  it "allows a concept to be updated" do
	    child = IsoConcept.find("F-T_G1_I2", "http://www.assero.co.uk/Y/V1")
	    child.label = "Very new label"
	    sparql = SparqlUpdateV2.new
	    sparql.default_namespace(child.namespace)
	    child.to_sparql_v2(sparql, "bf")
	    child.update(sparql)
	    all = IsoConcept.find("F-T_G1", "http://www.assero.co.uk/Y/V1", true)
	  #write_yaml_file(all.triples, sub_dir, "update_expected.yaml")
	    expected = read_yaml_file(sub_dir, "update_expected.yaml")
	    all.triples["F-T_G1"].each do |triple|
	      found = expected["F-T_G1"].find { |x| x[:subject] == triple[:subject] && x[:predicate] == triple[:predicate] && x[:object] == triple[:object] }
	      expect(triple).to eq(found)
	    end
	  end

		it "handles failed response when a concept is being updated" do
	    child = IsoConcept.find("F-T_G1_I2", "http://www.assero.co.uk/Y/V1")
	    child.label = "Very very very new label"
	    sparql = SparqlUpdateV2.new
	    sparql.default_namespace(child.namespace)
	    child.to_sparql_v2(sparql, "bf")
	    response = Typhoeus::Response.new(code: 200, body: "") # Beware of odering og these next three lines. Should be just before test call.
	    expect(Rest).to receive(:sendRequest).and_return(response) 
	    expect(response).to receive(:success?).and_return(false)
	    expect{child.update(sparql)}.to raise_error(Exceptions::UpdateError)
	  end

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
			concept.add_extension_property("http://www.assero.co.uk/BusinessForm", 
	      { :identifier => "XXX", :datatype => "string", :label => "A new extended property", :definition => "A definition"})
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
			concept.add_extension_property("http://www.assero.co.uk/BusinessForm", 
	      { :identifier => "XXX", :datatype => "string", :label => "A new extended property", :definition => "A definition"})
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
	      				rdf_type: "http://www.assero.co.uk/BusinessForm#Extension1",
	              :instance_variable => "Extension1",
	           		:label=>"Extension 1"
	           	},
	          	{
	          		rdf_type: "http://www.assero.co.uk/BusinessForm#Extension2",
	              :instance_variable => "Extension2",
	           		:label=>"Extension 2"
	           	},
	           	{
	          		rdf_type: "http://www.assero.co.uk/BusinessForm#XXX",
	              :instance_variable => "XXX",
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
			concept.set_extension_value("Extension1", 21)
			concept.set_extension_value("Extension2", false)
	    concept.set_extension_value("XXX", "Hello World!")
	    sparql = SparqlUpdateV2.new
			concept.to_sparql_v2(sparql, "bf")
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

	  it "allows the links from a concept to be determined, BC Property Ref" do
	    results = IsoConcept.links_from("F-ACME_VSBASELINE1_G1_G2_I1","http://www.assero.co.uk/MDRForms/ACME/V1")
	    expected = 
	    [ 
	      { 
	        uri: UriV2.new({uri: "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25347_PerformedObservation_dateRange_IVL_TS_DATETIME_low_TS_DATETIME_value"}), 
	        rdf_type: "http://www.assero.co.uk/CDISCBiomedicalConcept#Property",
          label: "",
	        local: false 
	      }
	    ]
      #expect(results).to eq(expected)
	    expect(results.to_json).to eq(expected.to_json)
	  end

	  it "allows the links to a concept to be determined, BC Property Ref" do
	    results = IsoConcept.links_to("BC-ACME_BC_C25347_PerformedObservation_dateRange_IVL_TS_DATETIME_low_TS_DATETIME_value","http://www.assero.co.uk/MDRBCs/V1")
	    expected = 
	    [ 
	      { 
	        uri: UriV2.new({uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_VSBASELINE1_G1_G2_I1"}), 
	        rdf_type: "http://www.assero.co.uk/BusinessForm#BcProperty",
          label: "Date and Time (--DTC)",
	        local: false  
	      },
	      { 
	        uri: UriV2.new({uri: "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25347_PerformedObservation_dateRange_IVL_TS_DATETIME_low_TS_DATETIME"}), 
	        rdf_type: "http://www.assero.co.uk/CDISCBiomedicalConcept#Datatype",
          label: "",
	        local: true
	      }
	    ]
	    expect(results.to_json).to eq(expected.to_json)
	  end

	  it "allows the links from a concept to be determined, internal to managed item hierarchy" do
	    results = IsoConcept.links_from("F-ACME_VSBASELINE1_G1_G1","http://www.assero.co.uk/MDRForms/ACME/V1")
	    expected = 
	    [ 
	      { 
	        uri: UriV2.new({uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_VSBASELINE1_G1_G1_I2"}), 
	        rdf_type: "http://www.assero.co.uk/BusinessForm#CommonItem",
          label: "Common Item",
	        local: true
	      },
	      { 
	        uri: UriV2.new({uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_VSBASELINE1_G1_G1_I1"}), 
	        rdf_type: "http://www.assero.co.uk/BusinessForm#CommonItem",
          label: "Common Item",
	        local: true 
	      }
	    ]
	    expect(results.to_json).to eq(expected.to_json)
	  end

	  it "allows the links to a concept to be determined, BC Property Ref" do
	    results = IsoConcept.links_to("F-ACME_VSBASELINE1_G1","http://www.assero.co.uk/MDRForms/ACME/V1")
	    expected = 
	    [
	      {
	        uri: UriV2.new({uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_VSBASELINE1"}),
	        rdf_type: "http://www.assero.co.uk/BusinessForm#Form",
          label: "Vital Signs Baseline",
	        local: true
	      }
	    ]
	    expect(results.to_json).to eq(expected.to_json)
	  end

	  it "allows the links from a concept to be determined, TC Ref" do
	    results = IsoConcept.links_from("F-ACME_VSBASELINE1_G1_G4_I4","http://www.assero.co.uk/MDRForms/ACME/V1")
	    expected = 
	    [ 
	      { 
	        uri: UriV2.new({uri: "http://www.assero.co.uk/MDRThesaurus/CDISC/V42#CLI-C71148_C62122"}), 
	        rdf_type: "http://www.assero.co.uk/ISO25964#ThesaurusConcept",
          label: "Sitting",
	        local: false  
	      },
	      { 
	        uri: UriV2.new({uri: "http://www.assero.co.uk/MDRThesaurus/CDISC/V42#CLI-C71148_C62166"}), 
	        rdf_type: "http://www.assero.co.uk/ISO25964#ThesaurusConcept",
          label: "Standing",
	        local: false 
	      },
	      { 
	        uri: UriV2.new({uri: "http://www.assero.co.uk/MDRThesaurus/CDISC/V42#CLI-C71148_C62167"}), 
	        rdf_type: "http://www.assero.co.uk/ISO25964#ThesaurusConcept",
          label: "Supine Position",
	        local: false  
	      },
	      {
	        uri: UriV2.new({uri: "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25298_PerformedObservation_bodyPositionCode_CD_code"}),
	        rdf_type: "http://www.assero.co.uk/CDISCBiomedicalConcept#Property",
          label: "",
	        local: false 
	      }
	    ]
	    expect(results.to_json).to eq(expected.to_json)
	  end

		it "allows the links to a concept to be determined, BC Property Ref" do
	    results = IsoConcept.links_to("CLI-C71148_C62122","http://www.assero.co.uk/MDRThesaurus/CDISC/V42")
	    expected = 
	    [ 
	      {
          uri: UriV2.new({uri: "http://www.assero.co.uk/MDRThesaurus/CDISC/V42#CL-C71148"}),
          rdf_type: "http://www.assero.co.uk/ISO25964#ThesaurusConcept",
          label: "Position",
          local: true
        },
        { 
	        uri: UriV2.new({uri: "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C49677_PerformedObservation_bodyPositionCode_CD_code"}),
	        rdf_type: "http://www.assero.co.uk/CDISCBiomedicalConcept#Property",
          label: "",
	        local: false 
	      },
	      { 
	        uri: UriV2.new({uri: "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_A00003_PerformedObservation_bodyPositionCode_CD_code"}),
	        rdf_type: "http://www.assero.co.uk/CDISCBiomedicalConcept#Property",
          label: "",
	        local: false 
	      },
	      {
	        uri: UriV2.new({uri: "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25299_PerformedObservation_bodyPositionCode_CD_code"}),
	        rdf_type: "http://www.assero.co.uk/CDISCBiomedicalConcept#Property",
          label: "",
	        local: false 
	      },
	      {
	        uri: UriV2.new({uri: "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25298_PerformedObservation_bodyPositionCode_CD_code"}),
	        rdf_type: "http://www.assero.co.uk/CDISCBiomedicalConcept#Property",
          label: "",
	        local: false 
	      },
	      { 
	        uri: UriV2.new({uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_VSBASELINE1_G1_G5_I4"}), 
	        rdf_type: "http://www.assero.co.uk/BusinessForm#BcProperty",
          label: "Body Position (--POS)",
	        local: false  
	      },
	      { 
	        uri: UriV2.new({uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_VSBASELINE1_G1_G4_I4"}), 
	        rdf_type: "http://www.assero.co.uk/BusinessForm#BcProperty",
          label: "Body Position (--POS)",
	        local: false  
	      }
	    ]
	    compare_link_to_results(results, expected)
	  end

	  it "allows the parent object to be determined, concept -> concept" do
	    uri1 = UriV2.new({uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_VSBASELINE1_G1_G1"})
	    uri2 = UriV2.new({uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_VSBASELINE1_G1"})
	    result = IsoConcept.find_parent(uri1)
	    expect(result[:uri].to_s).to eq(uri2.to_s)
	    expect(result[:rdf_type]).to eq("http://www.assero.co.uk/BusinessForm#NormalGroup")
	  end

	  it "allows the parent object to be determined, managed_item -> concept " do
	    uri1 = UriV2.new({uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_VSBASELINE1_G1"})
	    uri2 = UriV2.new({uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_VSBASELINE1"})
	    result = IsoConcept.find_parent(uri1)
	    expect(result[:uri].to_s).to eq(uri2.to_s)
	    expect(result[:rdf_type]).to eq("http://www.assero.co.uk/BusinessForm#Form")
	  end

	  it "allows the parent object to be determined, no parent" do
	    uri1 = UriV2.new({uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_VSBASELINE1"})
	    expect(IsoConcept.find_parent(uri1)).to eq(nil)
	  end

	  it "detects trying to find a missing object" do
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
			expect{IsoConcept.find("F-AE_G1_I2", "http://www.assero.co.uk/X/V1")}.to raise_error(Exceptions::NotFoundError)
		end

	end

	context "Find Tests" do

		before :each do
			clear_triple_store
	    load_schema_file_into_triple_store("ISO11179Types.ttl")
	    load_schema_file_into_triple_store("ISO11179Basic.ttl")
	    load_schema_file_into_triple_store("ISO11179Identification.ttl")
	    load_schema_file_into_triple_store("ISO11179Registration.ttl")
	    load_schema_file_into_triple_store("ISO11179Data.ttl")
	    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
	    load_schema_file_into_triple_store("BusinessForm.ttl")
	    load_data_file_into_triple_store("ACME_DM1 01.ttl")
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
	    concepts = IsoConcept.all("Question", "http://www.assero.co.uk/BusinessForm")
	    concepts.each_with_index do |item, index|
	    	expect(results).to include(concepts[index].to_json)
	    end
		end

	end

	context "Error Handling Tests" do

		it "allows other errors to be copied" do
			object_1 = IsoConcept.new
			object_1.label = "!@£$%^&**"
			object_1.valid?
			object_2 = IsoConcept.new
			object_2.copy_errors(object_1, "Child errors:")
			expect(object_2.errors.full_messages[0]).to eq("Child errors: Label contains invalid characters")
		end

	end

	context "Cross Reference Tests" do

		before :each do
			clear_triple_store
	    load_schema_file_into_triple_store("ISO11179Types.ttl")
	    load_schema_file_into_triple_store("ISO11179Basic.ttl")
	    load_schema_file_into_triple_store("ISO11179Identification.ttl")
	    load_schema_file_into_triple_store("ISO11179Registration.ttl")
	    load_schema_file_into_triple_store("ISO11179Data.ttl")
	    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
	    load_schema_file_into_triple_store("ISO25964.ttl")
	    load_schema_file_into_triple_store("BusinessOperational.ttl")
	    load_schema_file_into_triple_store("BusinessForm.ttl")
	    load_schema_file_into_triple_store("business_operational_extension.ttl")
	    load_schema_file_into_triple_store("business_cross_reference.ttl")
	    load_test_file_into_triple_store("CT_V42.ttl")
	    load_test_file_into_triple_store("CT_V46.ttl")
			# Set up references
		  object_1 = IsoConcept.find("CLI-C71148_C62122", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42")
	    object_2 = IsoConcept.find("CLI-C100144_C103635", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42")
	    object_3 = IsoConcept.find("CL-C100129", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42")
	    object_4 = IsoConcept.find("CLI-C74456_C114198", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42")
			object_new_1 = IsoConcept.find("CLI-C71148_C62122", "http://www.assero.co.uk/MDRThesaurus/CDISC/V46")
	    object_new_2 = IsoConcept.find("CLI-C128685_C119517", "http://www.assero.co.uk/MDRThesaurus/CDISC/V46")
			or_1 = OperationalReferenceV2.new
			or_1.ordinal = 1
			or_1.subject_ref = object_1.uri
			or_2 = OperationalReferenceV2.new
			or_2.ordinal = 1
			or_2.subject_ref = object_2.uri
			or_3 = OperationalReferenceV2.new
			or_3.ordinal = 1
			or_3.subject_ref = object_3.uri
			or_4 = OperationalReferenceV2.new
			or_4.ordinal = 1
			or_4.subject_ref = object_4.uri
			cr_1 = CrossReference.new
			cr_1.comments = "Linking v46 to v42 for some reason" 
			cr_1.ordinal = 1
			cr_1.children << or_1
			cr_1.children << or_2
			cr_2 = CrossReference.new
			cr_2.comments = "Linking v46 to v42 for some reason" 
			cr_2.ordinal = 1
			cr_2.children << or_3
			cr_3 = CrossReference.new
			cr_3.comments = "Linking v46 to v42 for some reason" 
			cr_3.ordinal = 1
			cr_3.children << or_4
			sparql = SparqlUpdateV2.new
			uri = cr_1.to_sparql_v2(object_new_1.uri, sparql)
			sparql.triple({uri: object_new_1.uri}, {:prefix => UriManagement::C_BCR, :id => "crossReference"}, {:uri => uri})
			uri = cr_2.to_sparql_v2(object_new_1.uri, sparql)
			sparql.triple({uri: object_new_1.uri}, {:prefix => UriManagement::C_BCR, :id => "crossReference"}, {:uri => uri})
			uri = cr_3.to_sparql_v2(object_new_2.uri, sparql)
			sparql.triple({uri: object_new_2.uri}, {:prefix => UriManagement::C_BCR, :id => "crossReference"}, {:uri => uri})
			response = CRUD.update(sparql.to_s)
	    expect(response.success?).to eq(true)
	  end

		it "allows the cross references from the object and children to be determined" do
	    result = IsoConcept.cross_references("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V46", :from)
	  #write_yaml_file(result, sub_dir, "cross_references_from_expected.yaml")
	    expected = read_yaml_file(sub_dir, "cross_references_from_expected.yaml")
	    compare_cross_references(result, expected)
		end
	    
		it "allows the cross references to the object and children to be determined" do
	  	result = IsoConcept.cross_references("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42", :to)
	  #write_yaml_file(result, sub_dir, "cross_references_to_expected.yaml")
	    expected = read_yaml_file(sub_dir, "cross_references_to_expected.yaml")
      compare_cross_references(result, expected)
	  end

		it "allows the cross references from the object to be determined" do
			ic = IsoConcept.find("CLI-C71148_C62122", "http://www.assero.co.uk/MDRThesaurus/CDISC/V46")
			result = ic.cross_reference_details(:from)
	  #write_yaml_file(result, sub_dir, "cross_references_details_from_expected.yaml")
	    expected = read_yaml_file(sub_dir, "cross_references_details_from_expected.yaml")
      compare_cross_reference_details(result, expected)
		end

		it "allows the cross references to the object to be determined" do
			ic = IsoConcept.find("CLI-C100144_C103635", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42")
			result = ic.cross_reference_details(:to)
	  #write_yaml_file(result, sub_dir, "cross_reference_details_to_expected.yaml")
	    expected = read_yaml_file(sub_dir, "cross_reference_details_to_expected.yaml")
	    compare_cross_reference_details(result, expected)
		end

	end

  context "Terminology Tests" do

    before :all do
      clear_triple_store
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Basic.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Data.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("ISO25964.ttl")
      load_schema_file_into_triple_store("CDISCTerm.ttl")
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      load_test_file_into_triple_store("CT_V39.ttl")
      load_test_file_into_triple_store("CT_V40.ttl")
      load_test_file_into_triple_store("CT_V41.ttl")
      load_test_file_into_triple_store("CT_V42.ttl")
      load_test_file_into_triple_store("CT_V43.ttl")
      load_test_file_into_triple_store("CT_V44.ttl")
      load_test_file_into_triple_store("CT_V45.ttl")
      load_test_file_into_triple_store("CT_V46.ttl")
      load_test_file_into_triple_store("CT_V47.ttl")
      clear_iso_concept_object
    end

    it "detects two different objects" do
      previous = IsoConcept.find("CLI-C105134_C105261", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42")
      current = IsoConcept.find("CLI-C105134_C105262", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42")
      result = IsoConcept.diff?(previous, current)
      expect(result).to eq(true)
    end

    it "detects if two objects are the same" do
      previous = IsoConcept.find("CLI-C105134_C105261", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42")
      current = IsoConcept.find("CLI-C105134_C105261", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42")
      result = IsoConcept.diff?(previous, current)
      expect(result).to eq(false)
    end

    it "shows differences between two different objects" do
      previous = IsoConcept.find("CLI-C105134_C105261", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42")
      current = IsoConcept.find("CLI-C105134_C105262", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42")
      result = IsoConcept.difference(previous, current)
    #write_yaml_file(result, sub_dir, "difference_expected_1.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_1.yaml")
      expect(result).to eq(expected)
    end

    it "shows differences between two different objects, no previous" do
      previous = nil
      current = IsoConcept.find("CLI-C105134_C105262", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42")
      result = IsoConcept.difference(previous, current)
    #write_yaml_file(result, sub_dir, "difference_expected_2.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_2.yaml")
      expect(result).to eq(expected)
    end
    
    it "shows differences between two different objects, no current" do
      current = nil
      previous = IsoConcept.find("CLI-C105134_C105262", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42")
      result = IsoConcept.difference(previous, current)
    #write_yaml_file(result, sub_dir, "difference_expected_3.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_3.yaml")
      expect(result).to eq(expected)
    end
    
    it "shows differences between same objects" do
      previous = IsoConcept.find("CLI-C105134_C105262", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42")
      current = IsoConcept.find("CLI-C105134_C105262", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42")
      result = IsoConcept.difference(previous, current)
    #write_yaml_file(result, sub_dir, "difference_expected_4.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_4.yaml")
      expect(result).to eq(expected)
    end
   
    it "shows differences between two different objects, no previous or current" do
      current = nil
      previous = nil
      result = IsoConcept.difference(previous, current)
    #write_yaml_file(result, sub_dir, "difference_expected_5.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_5.yaml")
      expect(result).to eq(expected)
    end  

    it "checks if the children are the same for two objects, 1" do
      current = ThesaurusConcept.find("CL-C101865", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42")
      previous = ThesaurusConcept.find("CL-C101865", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42")
      result = current.child_match?(previous, "children", "identifier")
      expect(result).to eq(true)
    end

    it "checks if the children are different for two objects, 2" do
      current = ThesaurusConcept.find("CL-C101865", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42")
      previous = ThesaurusConcept.find("CL-C102577", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42")
      result = current.child_match?(previous, "children", "identifier")
      expect(result).to eq(false)
    end

    it "checks if the children are different for two objects, 3" do
      current = ThesaurusConcept.find("CL-C100129", "http://www.assero.co.uk/MDRThesaurus/CDISC/V47")
      previous = ThesaurusConcept.find("CL-C100129", "http://www.assero.co.uk/MDRThesaurus/CDISC/V46")
      result = current.child_match?(previous, "children", "identifier")
      expect(result).to eq(false)
    end

    it "determines the items deleted from the previous objects, same" do
      current = ThesaurusConcept.find("CL-C101865", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42")
      previous = ThesaurusConcept.find("CL-C101865", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42")
      result = current.deleted_set(previous, "children", "identifier")
      expect(result).to eq([])
    end

    it "determines the items deleted from the previous objects, different" do
      current = ThesaurusConcept.find("CL-C101865", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42")
      previous = ThesaurusConcept.find("CL-C102577", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42")
      result = current.deleted_set(previous, "children", "identifier")
      expect(result).to eq(["C85563", "C102633", "C17745"])
    end

    it "CLs different object, different" do
      cl_1 = CdiscCl.find("CL-C66741", "http://www.assero.co.uk/MDRThesaurus/CDISC/V40")
      cl_2 = CdiscCl.find("CL-C66741", "http://www.assero.co.uk/MDRThesaurus/CDISC/V41")
      result = IsoConcept.diff?(cl_1, cl_2)
      expect(result).to eq(true)    
    end

    it "CLs different object, same" do
      cl_1 = CdiscCli.find("CLI-C66741_C84372", "http://www.assero.co.uk/MDRThesaurus/CDISC/V40")
      cl_2 = CdiscCli.find("CLI-C66741_C84372", "http://www.assero.co.uk/MDRThesaurus/CDISC/V41")
      result = IsoConcept.difference(cl_1, cl_2, {ignore: [:synonym]})
    #write_yaml_file(result, sub_dir, "difference_expected_6.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_6.yaml")
      expect(result).to eq(expected)
    end
    
    it "CLs different object, same" do
      cl_1 = CdiscCli.find("CLI-C66741_C84372", "http://www.assero.co.uk/MDRThesaurus/CDISC/V40")
      cl_2 = CdiscCli.find("CLI-C66741_C84372", "http://www.assero.co.uk/MDRThesaurus/CDISC/V41")
      result = IsoConcept.difference(cl_1, cl_2, {ignore: [:synonym]})
    #write_yaml_file(result, sub_dir, "difference_expected_7.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_7.yaml")
      expect(result).to eq(expected)
    end

    it "CLs different object with children, same" do
      cl_1 = CdiscCl.find("CL-C101843", "http://www.assero.co.uk/MDRThesaurus/CDISC/V39")
      cl_2 = CdiscCl.find("CL-C101843", "http://www.assero.co.uk/MDRThesaurus/CDISC/V39")
      result = IsoConcept.diff_with_children?(cl_1, cl_2, "identifier")
      expect(result).to eq(false)    
    end
    
    it "CL difference object, same" do
      cl_1 = CdiscCl.find("CL-C101843", "http://www.assero.co.uk/MDRThesaurus/CDISC/V39")
      cl_2 = CdiscCl.find("CL-C101843", "http://www.assero.co.uk/MDRThesaurus/CDISC/V39")
      result = IsoConcept.difference(cl_1, cl_2)
    #write_yaml_file(result, sub_dir, "difference_expected_8.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_8.yaml")
      expect(result).to eq(expected)
    end
    
    it "CL difference object with children, same" do
      cl_1 = CdiscCl.find("CL-C101843", "http://www.assero.co.uk/MDRThesaurus/CDISC/V39")
      cl_2 = CdiscCl.find("CL-C101843", "http://www.assero.co.uk/MDRThesaurus/CDISC/V39")
      result = IsoConcept.difference_with_children(cl_1, cl_2, "identifier")
    #write_yaml_file(result, sub_dir, "difference_expected_9.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_9.yaml")
      expect(result).to eq(expected)
    end

    it "CLs different object, different" do
      cl_1 = CdiscCl.find("CL-C66741", "http://www.assero.co.uk/MDRThesaurus/CDISC/V40")
      cl_2 = CdiscCl.find("CL-C66741", "http://www.assero.co.uk/MDRThesaurus/CDISC/V41")
      result = IsoConcept.difference_with_children(cl_1, cl_2, "identifier")
    #write_yaml_file(result, sub_dir, "difference_expected_10.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_10.yaml")
      expect(result).to eq(expected)
    end

    it "CLs different object with children, different" do
      cl_1 = CdiscCl.find("CL-C65047", "http://www.assero.co.uk/MDRThesaurus/CDISC/V40")
      cl_2 = CdiscCl.find("CL-C65047", "http://www.assero.co.uk/MDRThesaurus/CDISC/V41")
      result = IsoConcept.diff_with_children?(cl_1, cl_2, "identifier")
      expect(result).to eq(true)    
    end
    
    it "CL difference object, different" do
      cl_1 = CdiscCl.find("CL-C65047", "http://www.assero.co.uk/MDRThesaurus/CDISC/V40")
      cl_2 = CdiscCl.find("CL-C65047", "http://www.assero.co.uk/MDRThesaurus/CDISC/V41")
      result = IsoConcept.difference(cl_1, cl_2)
    #write_yaml_file(result, sub_dir, "difference_expected_11.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_11.yaml")
      expect(result).to eq(expected)
    end
    
    it "CL difference object with children, different" do
      cl_1 = CdiscCl.find("CL-C65047", "http://www.assero.co.uk/MDRThesaurus/CDISC/V40")
      cl_2 = CdiscCl.find("CL-C65047", "http://www.assero.co.uk/MDRThesaurus/CDISC/V41")
      result = IsoConcept.difference_with_children(cl_1, cl_2, "identifier")
    write_yaml_file(result, sub_dir, "difference_expected_12.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_12.yaml")
      expect(result).to eq(expected)
    end

    it "CL difference object, different" do
      cl_1 = CdiscCl.find("CL-65047", "http://www.assero.co.uk/MDRThesaurus/CDISC/V40")
      cl_2 = CdiscCl.find("CL-65047", "http://www.assero.co.uk/MDRThesaurus/CDISC/V41")
      result = IsoConcept.difference(cl_1, cl_2)
    #write_yaml_file(result, sub_dir, "difference_expected_14.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_14.yaml")
      expect(result).to eq(expected)
    end

    it "CL difference object with children, different" do
      cl_1 = CdiscCl.find("CL-C65047", "http://www.assero.co.uk/MDRThesaurus/CDISC/V40")
      cl_2 = CdiscCl.find("CL-C65047", "http://www.assero.co.uk/MDRThesaurus/CDISC/V41")
      result = IsoConcept.difference_with_children(cl_1, cl_2, "identifier")
    #write_yaml_file(result, sub_dir, "difference_expected_15.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_15.yaml")
      expect(result).to eq(expected)
    end

  end

  context "SDTM Difference Tests" do
  
    before :all do
      clear_triple_store
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Basic.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Data.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("BusinessOperational.ttl")
      load_schema_file_into_triple_store("BusinessDomain.ttl")
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      load_data_file_into_triple_store("SDTM_Model_1-2.ttl")
      load_data_file_into_triple_store("SDTM_Model_1-3.ttl")
      load_data_file_into_triple_store("SDTM_Model_1-4.ttl")
      load_data_file_into_triple_store("SDTM_IG_3-1-2.ttl")
      load_data_file_into_triple_store("SDTM_IG_3-1-3.ttl")
      load_data_file_into_triple_store("SDTM_IG_3-2.ttl")
      clear_iso_concept_object
      @uri_link = UriV2.new(uri: "http://www.assero.co.uk/BusinessDomain#includesVariable")
      @uri_identifier = UriV2.new(uri: "http://www.assero.co.uk/BusinessDomain#name")
    end

    it "Model Variable diff?, no change" do
      i_1 = SdtmModel::Variable.find("M-CDISC_SDTMMODEL_STUDYID", "http://www.assero.co.uk/MDRSdtmM/CDISC/V1")
      i_2 = SdtmModel::Variable.find("M-CDISC_SDTMMODEL_STUDYID", "http://www.assero.co.uk/MDRSdtmM/CDISC/V2")
      result = IsoConcept.diff?(i_1, i_2)
      expect(result).to eq(false)
    end

    it "Model Variable difference, no change" do
      i_1 = SdtmModel::Variable.find("M-CDISC_SDTMMODEL_STUDYID", "http://www.assero.co.uk/MDRSdtmM/CDISC/V1")
      i_2 = SdtmModel::Variable.find("M-CDISC_SDTMMODEL_STUDYID", "http://www.assero.co.uk/MDRSdtmM/CDISC/V2")
      result = IsoConcept.difference(i_1, i_2)
    #write_yaml_file(result, sub_dir, "difference_expected_16.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_16.yaml")
      expect(result).to eq(expected)
    end

    it "SDTM IG Variable diff?, change" do
      i_1 = SdtmIgDomain::Variable.find("IG-CDISC_SDTMIGAE_AEDECOD", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V1")
      i_2 = SdtmIgDomain::Variable.find("IG-CDISC_SDTMIGAE_AEDECOD", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V2")
      result = IsoConcept.diff?(i_1, i_2)
      expect(result).to eq(true)
    end

    it "SDTM IG Variable difference, change" do
      i_1 = SdtmIgDomain::Variable.find("IG-CDISC_SDTMIGAE_AEDECOD", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V1")
      i_2 = SdtmIgDomain::Variable.find("IG-CDISC_SDTMIGAE_AEDECOD", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V2")
      result = IsoConcept.difference(i_1, i_2)
    #write_yaml_file(result, sub_dir, "difference_expected_17.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_17.yaml")
      expect(result).to eq(expected)
    end

    it "SDTM IG Variable difference, no change" do
      i_1 = SdtmIgDomain::Variable.find("IG-CDISC_SDTMIGAE_AEDECOD", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V1")
      i_2 = SdtmIgDomain::Variable.find("IG-CDISC_SDTMIGAE_AEDECOD", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V2")
      result = IsoConcept.difference(i_1, i_2, {ignore: [:ordinal]})
    #write_yaml_file(result, sub_dir, "difference_expected_18.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_18.yaml")
      expect(result).to eq(expected)
    end

    it "SDTM IG Variable difference, change" do
      i_1 = SdtmIgDomain::Variable.find("IG-CDISC_SDTMIGAE_AEDECOD", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V2")
      i_2 = SdtmIgDomain::Variable.find("IG-CDISC_SDTMIGAE_AEDECOD", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3")
      result = IsoConcept.difference(i_1, i_2, {ignore: [:ordinal]})
    #write_yaml_file(result, sub_dir, "difference_expected_19.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_19.yaml")
      expect(result).to eq(expected)
    end

    it "SDTM IG Variable difference, change" do
      i_1 = SdtmIgDomain::Variable.find("IG-CDISC_SDTMIGQS_QSCAT", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V2")
      i_2 = SdtmIgDomain::Variable.find("IG-CDISC_SDTMIGQS_QSCAT", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3")
      result = IsoConcept.difference(i_1, i_2, {ignore: [:ordinal]})
    #write_yaml_file(result, sub_dir, "difference_expected_20.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_20.yaml")
      expect(result).to eq(expected)
    end

    it "Model difference with children, different" do
      i_1 = SdtmModel.find("M-CDISC_SDTMMODEL", "http://www.assero.co.uk/MDRSdtmM/CDISC/V1")
      i_2 = SdtmModel.find("M-CDISC_SDTMMODEL", "http://www.assero.co.uk/MDRSdtmM/CDISC/V2")
      timer_start
      result = IsoConcept.difference_with_children(i_1, i_2, "name")
      timer_stop("SDTM Model 1.2 to 1.3 difference, no options")
    #write_yaml_file(result, sub_dir, "difference_expected_21.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_21.yaml")
      expect(result).to eq(expected)
    end

    it "Model difference with children, different" do
      i_1 = SdtmModel.find("M-CDISC_SDTMMODEL", "http://www.assero.co.uk/MDRSdtmM/CDISC/V2")
      i_2 = SdtmModel.find("M-CDISC_SDTMMODEL", "http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
      timer_start
      result = IsoConcept.difference_with_children(i_1, i_2, "name")
      timer_stop("SDTM Model 1.3 to 1.4 difference, no options")
    #write_yaml_file(result, sub_dir, "difference_expected_22.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_22.yaml")
      expect(result).to eq(expected)
    end

    it "Model difference with children, different, ignore ordinal" do
      i_1 = SdtmModel.find("M-CDISC_SDTMMODEL", "http://www.assero.co.uk/MDRSdtmM/CDISC/V1")
      i_2 = SdtmModel.find("M-CDISC_SDTMMODEL", "http://www.assero.co.uk/MDRSdtmM/CDISC/V2")
      timer_start
      result = IsoConcept.difference_with_children(i_1, i_2, "name", {ignore: [:ordinal]})
      timer_stop("SDTM Model 1.2 to 1.3 difference, ignore ordinal")
    #write_yaml_file(result, sub_dir, "difference_expected_23.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_23.yaml")
      expect(result).to eq(expected)
    end

    it "Model difference with children, different, ignore ordinal" do
      i_1 = SdtmModel.find("M-CDISC_SDTMMODEL", "http://www.assero.co.uk/MDRSdtmM/CDISC/V2")
      i_2 = SdtmModel.find("M-CDISC_SDTMMODEL", "http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
      timer_start
      result = IsoConcept.difference_with_children(i_1, i_2, "name", {ignore: [:ordinal]})
      timer_stop("SDTM Model 1.3 to 1.4 difference, ignore ordinal")
    #write_yaml_file(result, sub_dir, "difference_expected_24.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_24.yaml")
      expect(result).to eq(expected)
    end

    it "SDTM Model Variable difference, change" do
      i_1 = SdtmModel::Variable.find("M-CDISC_SDTMMODEL_xxDOSRGM", "http://www.assero.co.uk/MDRSdtmM/CDISC/V2")
      i_2 = SdtmModel::Variable.find("M-CDISC_SDTMMODEL_xxDOSRGM", "http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
      result = IsoConcept.difference(i_1, i_2, {ignore: [:ordinal]})
    #write_yaml_file(result, sub_dir, "difference_expected_25.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_25.yaml")
      expect(result).to eq(expected)
    end

    it "SDTM Model Variable difference, change" do
      i_1 = SdtmModel::Variable.find("M-CDISC_SDTMMODEL_xxLOC", "http://www.assero.co.uk/MDRSdtmM/CDISC/V1")
      i_2 = SdtmModel::Variable.find("M-CDISC_SDTMMODEL_xxLOC", "http://www.assero.co.uk/MDRSdtmM/CDISC/V2")
      result = IsoConcept.difference(i_1, i_2, {ignore: [:ordinal]})
    #write_yaml_file(result, sub_dir, "difference_expected_26.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_26.yaml")
      expect(result).to eq(expected)
    end

    it "SDTM Model Class difference with children, different" do
      i_1 = SdtmModelDomain.find("M-CDISC_SDTMMODELEVENTS", "http://www.assero.co.uk/MDRSdtmMd/CDISC/V1")
      i_2 = SdtmModelDomain.find("M-CDISC_SDTMMODELEVENTS", "http://www.assero.co.uk/MDRSdtmMd/CDISC/V2")
      timer_start
      result = IsoConcept.difference_with_children(i_1, i_2, "name", {ignore: [:ordinal]})
      timer_stop("SDTM Model Events 1.2 to 1.3 difference, ignore ordinal")
    #write_yaml_file(result, sub_dir, "difference_expected_27.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_27.yaml")
      expect(result).to eq(expected)
    end

    it "SDTM Model Class difference with children, different" do
      i_1 = SdtmModelDomain.find("M-CDISC_SDTMMODELEVENTS", "http://www.assero.co.uk/MDRSdtmMd/CDISC/V2")
      i_2 = SdtmModelDomain.find("M-CDISC_SDTMMODELEVENTS", "http://www.assero.co.uk/MDRSdtmMd/CDISC/V3")
      timer_start
      result = IsoConcept.difference_with_children(i_1, i_2, "name", {ignore: [:ordinal]})
      timer_stop("SDTM Model Events 1.3 to 1.4 difference, ignore ordinal")
    #write_yaml_file(result, sub_dir, "difference_expected_28.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_28.yaml")
      expect(result).to eq(expected)
    end

    it "SDTM Model Class Variable difference, no change" do
      i_1 = SdtmModelDomain::Variable.find("M-CDISC_SDTMMODELEVENTS_xxDECOD", "http://www.assero.co.uk/MDRSdtmMd/CDISC/V1")
      i_2 = SdtmModelDomain::Variable.find("M-CDISC_SDTMMODELEVENTS_xxDECOD", "http://www.assero.co.uk/MDRSdtmMd/CDISC/V2")
      result = IsoConcept.difference(i_1, i_2, {ignore: [:ordinal]})
    #write_yaml_file(result, sub_dir, "difference_expected_29.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_29.yaml")
      expect(result).to eq(expected)
    end

    it "SDTM Model Class Variable difference, change" do
      i_1 = SdtmModelDomain::Variable.find("M-CDISC_SDTMMODELEVENTS_xxSTTPT", "http://www.assero.co.uk/MDRSdtmMd/CDISC/V2")
      i_2 = SdtmModelDomain::Variable.find("M-CDISC_SDTMMODELEVENTS_xxSTTPT", "http://www.assero.co.uk/MDRSdtmMd/CDISC/V3")
      result = IsoConcept.difference(i_1, i_2, {ignore: [:ordinal]})
    #write_yaml_file(result, sub_dir, "difference_expected_30.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_30.yaml")
      expect(result).to eq(expected)
    end

    it "IG Domain difference with children, different" do
      i_1 = SdtmIgDomain.find("IG-CDISC_SDTMIGDM", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V1")
      i_2 = SdtmIgDomain.find("IG-CDISC_SDTMIGDM", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V2")
      result = IsoConcept.difference_with_children(i_1, i_2, "name")
    #write_yaml_file(result, sub_dir, "difference_expected_31.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_31.yaml")
      expect(result).to eq(expected)
    end

    it "IG Domain difference with children, different, ignore ordinal" do
      i_1 = SdtmIgDomain.find("IG-CDISC_SDTMIGDM", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V1")
      i_2 = SdtmIgDomain.find("IG-CDISC_SDTMIGDM", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V2")
      result = IsoConcept.difference_with_children(i_1, i_2, "name", {ignore: [:ordinal]})
    #write_yaml_file(result, sub_dir, "difference_expected_32.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_32.yaml")
      expect(result).to eq(expected)
    end

    it "IG Domain difference with children, different, ignore ordinal" do
      i_1 = SdtmIgDomain.find("IG-CDISC_SDTMIGDM", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V2")
      i_2 = SdtmIgDomain.find("IG-CDISC_SDTMIGDM", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3")
      timer_start
      result = IsoConcept.difference_with_children(i_1, i_2, "name", {ignore: [:ordinal]})
    #write_yaml_file(result, sub_dir, "difference_expected_33.yaml")
      timer_stop("SDTM IG DM Domain 3.1.3 to 3.2 difference, ignore ordinal")
      expected = read_yaml_file(sub_dir, "difference_expected_33.yaml")
      expect(result).to eq(expected)
    end

  end

  context "Form Difference Tests" do
  
    before :all do
      clear_triple_store
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Basic.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Data.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("BusinessOperational.ttl")
      load_schema_file_into_triple_store("BusinessForm.ttl")
      load_schema_file_into_triple_store("ISO25964.ttl")
      load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      load_test_file_into_triple_store("form_example_dm1.ttl")
      load_test_file_into_triple_store("form_example_vs_baseline_new.ttl")
      load_test_file_into_triple_store("form_example_general.ttl")
      load_test_file_into_triple_store("CT_V42.ttl")
      load_test_file_into_triple_store("CT_V43.ttl")
      load_test_file_into_triple_store("CT_ACME_V1.ttl")
      load_test_file_into_triple_store("BCT.ttl")
      load_test_file_into_triple_store("BC.ttl")
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
    end

    it "Form diff?, no change" do
      i_1 = Form.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
      i_2 = Form.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
      result = IsoConcept.diff?(i_1, i_2)
      expect(result).to eq(false)
    end

    it "Form difference, no change" do
      i_1 = Form.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
      i_2 = Form.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
      result = IsoConcept.difference(i_1, i_2)
    #write_yaml_file(result, sub_dir, "difference_expected_34.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_34.yaml")
      expect(result).to eq(expected)
    end

    it "Form diff?, change" do
      i_1 = Form.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
      i_2 = Form.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
      i_2.note = "Updated ha ha!"
      result = IsoConcept.diff?(i_1, i_2)
      expect(result).to eq(true)
    end

    it "Form difference, change" do
      i_1 = Form.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
      i_2 = Form.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
      i_2.note = "Updated ha ha!"
      result = IsoConcept.difference(i_1, i_2)
    #write_yaml_file(result, sub_dir, "difference_expected_35.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_35.yaml")
      expect(result).to eq(expected)
    end

    it "Form difference with children, no difference" do
      i_1 = Form.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
      i_2 = Form.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
      result = IsoConcept.difference_with_children(i_1, i_2, "ordinal")
    #write_yaml_file(result, sub_dir, "difference_expected_36.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_36.yaml")
      expect(result).to eq(expected)
    end

    it "Form difference with children, different" do
      i_1 = Form.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
      i_2 = Form.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
      i_2.note = "Updated ha ha once more!"
      i_2.children[0].note = "Group updated ha ha!"
      result = IsoConcept.difference_with_children(i_1, i_2, "ordinal")
    #write_yaml_file(result, sub_dir, "difference_expected_37.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_37.yaml")
      expect(result).to eq(expected)
    end

=begin
    it "Model difference with children, different, ignore ordinal" do
      i_1 = SdtmModel.find("M-CDISC_SDTMMODEL", "http://www.assero.co.uk/MDRSdtmM/CDISC/V1")
      i_2 = SdtmModel.find("M-CDISC_SDTMMODEL", "http://www.assero.co.uk/MDRSdtmM/CDISC/V2")
      timer_start
      result = IsoConcept.difference_with_children(i_1, i_2, "name", {ignore: [:ordinal]})
      timer_stop("SDTM Model 1.2 to 1.3 difference, ignore ordinal")
    #write_yaml_file(result, sub_dir, "difference_expected_23.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_23.yaml")
      expect(result).to eq(expected)
    end

    it "Model difference with children, different, ignore ordinal" do
      i_1 = SdtmModel.find("M-CDISC_SDTMMODEL", "http://www.assero.co.uk/MDRSdtmM/CDISC/V2")
      i_2 = SdtmModel.find("M-CDISC_SDTMMODEL", "http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
      timer_start
      result = IsoConcept.difference_with_children(i_1, i_2, "name", {ignore: [:ordinal]})
      timer_stop("SDTM Model 1.3 to 1.4 difference, ignore ordinal")
    #write_yaml_file(result, sub_dir, "difference_expected_24.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_24.yaml")
      expect(result).to eq(expected)
    end

    it "SDTM Model Variable difference, change" do
      i_1 = SdtmModel::Variable.find("M-CDISC_SDTMMODEL_xxDOSRGM", "http://www.assero.co.uk/MDRSdtmM/CDISC/V2")
      i_2 = SdtmModel::Variable.find("M-CDISC_SDTMMODEL_xxDOSRGM", "http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
      result = IsoConcept.difference(i_1, i_2, {ignore: [:ordinal]})
    #write_yaml_file(result, sub_dir, "difference_expected_25.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_25.yaml")
      expect(result).to eq(expected)
    end

    it "SDTM Model Variable difference, change" do
      i_1 = SdtmModel::Variable.find("M-CDISC_SDTMMODEL_xxLOC", "http://www.assero.co.uk/MDRSdtmM/CDISC/V1")
      i_2 = SdtmModel::Variable.find("M-CDISC_SDTMMODEL_xxLOC", "http://www.assero.co.uk/MDRSdtmM/CDISC/V2")
      result = IsoConcept.difference(i_1, i_2, {ignore: [:ordinal]})
    #write_yaml_file(result, sub_dir, "difference_expected_26.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_26.yaml")
      expect(result).to eq(expected)
    end

    it "SDTM Model Class difference with children, different" do
      i_1 = SdtmModelDomain.find("M-CDISC_SDTMMODELEVENTS", "http://www.assero.co.uk/MDRSdtmMd/CDISC/V1")
      i_2 = SdtmModelDomain.find("M-CDISC_SDTMMODELEVENTS", "http://www.assero.co.uk/MDRSdtmMd/CDISC/V2")
      timer_start
      result = IsoConcept.difference_with_children(i_1, i_2, "name", {ignore: [:ordinal]})
      timer_stop("SDTM Model Events 1.2 to 1.3 difference, ignore ordinal")
    #write_yaml_file(result, sub_dir, "difference_expected_27.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_27.yaml")
      expect(result).to eq(expected)
    end

    it "SDTM Model Class difference with children, different" do
      i_1 = SdtmModelDomain.find("M-CDISC_SDTMMODELEVENTS", "http://www.assero.co.uk/MDRSdtmMd/CDISC/V2")
      i_2 = SdtmModelDomain.find("M-CDISC_SDTMMODELEVENTS", "http://www.assero.co.uk/MDRSdtmMd/CDISC/V3")
      timer_start
      result = IsoConcept.difference_with_children(i_1, i_2, "name", {ignore: [:ordinal]})
      timer_stop("SDTM Model Events 1.3 to 1.4 difference, ignore ordinal")
    #write_yaml_file(result, sub_dir, "difference_expected_28.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_28.yaml")
      expect(result).to eq(expected)
    end

    it "SDTM Model Class Variable difference, no change" do
      i_1 = SdtmModelDomain::Variable.find("M-CDISC_SDTMMODELEVENTS_xxDECOD", "http://www.assero.co.uk/MDRSdtmMd/CDISC/V1")
      i_2 = SdtmModelDomain::Variable.find("M-CDISC_SDTMMODELEVENTS_xxDECOD", "http://www.assero.co.uk/MDRSdtmMd/CDISC/V2")
      result = IsoConcept.difference(i_1, i_2, {ignore: [:ordinal]})
    #write_yaml_file(result, sub_dir, "difference_expected_29.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_29.yaml")
      expect(result).to eq(expected)
    end

    it "SDTM Model Class Variable difference, change" do
      i_1 = SdtmModelDomain::Variable.find("M-CDISC_SDTMMODELEVENTS_xxSTTPT", "http://www.assero.co.uk/MDRSdtmMd/CDISC/V2")
      i_2 = SdtmModelDomain::Variable.find("M-CDISC_SDTMMODELEVENTS_xxSTTPT", "http://www.assero.co.uk/MDRSdtmMd/CDISC/V3")
      result = IsoConcept.difference(i_1, i_2, {ignore: [:ordinal]})
    #write_yaml_file(result, sub_dir, "difference_expected_30.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_30.yaml")
      expect(result).to eq(expected)
    end

    it "IG Domain difference with children, different" do
      i_1 = SdtmIgDomain.find("IG-CDISC_SDTMIGDM", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V1")
      i_2 = SdtmIgDomain.find("IG-CDISC_SDTMIGDM", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V2")
      result = IsoConcept.difference_with_children(i_1, i_2, "name")
    #write_yaml_file(result, sub_dir, "difference_expected_31.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_31.yaml")
      expect(result).to eq(expected)
    end

    it "IG Domain difference with children, different, ignore ordinal" do
      i_1 = SdtmIgDomain.find("IG-CDISC_SDTMIGDM", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V1")
      i_2 = SdtmIgDomain.find("IG-CDISC_SDTMIGDM", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V2")
      result = IsoConcept.difference_with_children(i_1, i_2, "name", {ignore: [:ordinal]})
    #write_yaml_file(result, sub_dir, "difference_expected_32.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_32.yaml")
      expect(result).to eq(expected)
    end

    it "IG Domain difference with children, different, ignore ordinal" do
      i_1 = SdtmIgDomain.find("IG-CDISC_SDTMIGDM", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V2")
      i_2 = SdtmIgDomain.find("IG-CDISC_SDTMIGDM", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3")
      timer_start
      result = IsoConcept.difference_with_children(i_1, i_2, "name", {ignore: [:ordinal]})
    #write_yaml_file(result, sub_dir, "difference_expected_33.yaml")
      timer_stop("SDTM IG DM Domain 3.1.3 to 3.2 difference, ignore ordinal")
      expected = read_yaml_file(sub_dir, "difference_expected_33.yaml")
      expect(result).to eq(expected)
    end
=end

  end

  context "Sponsor Terminology Difference Tests" do
  
    before :all do
      clear_triple_store
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Basic.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Data.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("BusinessOperational.ttl")
      load_schema_file_into_triple_store("ISO25964.ttl")
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      load_test_file_into_triple_store("ACME_AE_V1.ttl")
      load_test_file_into_triple_store("ACME_AE_V1-1.ttl")
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
    end

    it "Thesaurus diff?, no change" do
      i_1 = Thesaurus.find("TH-ACME_SANOFIAE", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
      i_2 = Thesaurus.find("TH-ACME_SANOFIAE", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
      result = IsoConcept.diff?(i_1, i_2)
      expect(result).to eq(false)
    end

    it "Thesaurus difference, no previous" do
      i_1 = nil
      i_2 = Thesaurus.find("TH-ACME_SANOFIAE", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
      result = IsoConcept.difference(i_1, i_2)
    write_yaml_file(result, sub_dir, "difference_expected_100.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_100.yaml")
      expect(result).to eq(expected)
    end

    it "Thesaurus difference, no change" do
      i_1 = Thesaurus.find("TH-ACME_SANOFIAE", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
      i_2 = Thesaurus.find("TH-ACME_SANOFIAE", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
      result = IsoConcept.difference(i_1, i_2)
    write_yaml_file(result, sub_dir, "difference_expected_101.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_101.yaml")
      expect(result).to eq(expected)
    end

=begin
    it "Form diff?, change" do
      i_1 = Form.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
      i_2 = Form.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
      i_2.note = "Updated ha ha!"
      result = IsoConcept.diff?(i_1, i_2)
      expect(result).to eq(true)
    end

    it "Form difference, change" do
      i_1 = Form.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
      i_2 = Form.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
      i_2.note = "Updated ha ha!"
      result = IsoConcept.difference(i_1, i_2)
    #write_yaml_file(result, sub_dir, "difference_expected_35.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_35.yaml")
      expect(result).to eq(expected)
    end

    it "Form difference with children, no difference" do
      i_1 = Form.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
      i_2 = Form.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
      result = IsoConcept.difference_with_children(i_1, i_2, "ordinal")
    #write_yaml_file(result, sub_dir, "difference_expected_36.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_36.yaml")
      expect(result).to eq(expected)
    end

    it "Form difference with children, different" do
      i_1 = Form.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
      i_2 = Form.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
      i_2.note = "Updated ha ha once more!"
      i_2.children[0].note = "Group updated ha ha!"
      result = IsoConcept.difference_with_children(i_1, i_2, "ordinal")
    #write_yaml_file(result, sub_dir, "difference_expected_37.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_37.yaml")
      expect(result).to eq(expected)
    end

=begin
    it "Model difference with children, different, ignore ordinal" do
      i_1 = SdtmModel.find("M-CDISC_SDTMMODEL", "http://www.assero.co.uk/MDRSdtmM/CDISC/V1")
      i_2 = SdtmModel.find("M-CDISC_SDTMMODEL", "http://www.assero.co.uk/MDRSdtmM/CDISC/V2")
      timer_start
      result = IsoConcept.difference_with_children(i_1, i_2, "name", {ignore: [:ordinal]})
      timer_stop("SDTM Model 1.2 to 1.3 difference, ignore ordinal")
    #write_yaml_file(result, sub_dir, "difference_expected_23.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_23.yaml")
      expect(result).to eq(expected)
    end

    it "Model difference with children, different, ignore ordinal" do
      i_1 = SdtmModel.find("M-CDISC_SDTMMODEL", "http://www.assero.co.uk/MDRSdtmM/CDISC/V2")
      i_2 = SdtmModel.find("M-CDISC_SDTMMODEL", "http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
      timer_start
      result = IsoConcept.difference_with_children(i_1, i_2, "name", {ignore: [:ordinal]})
      timer_stop("SDTM Model 1.3 to 1.4 difference, ignore ordinal")
    #write_yaml_file(result, sub_dir, "difference_expected_24.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_24.yaml")
      expect(result).to eq(expected)
    end

    it "SDTM Model Variable difference, change" do
      i_1 = SdtmModel::Variable.find("M-CDISC_SDTMMODEL_xxDOSRGM", "http://www.assero.co.uk/MDRSdtmM/CDISC/V2")
      i_2 = SdtmModel::Variable.find("M-CDISC_SDTMMODEL_xxDOSRGM", "http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
      result = IsoConcept.difference(i_1, i_2, {ignore: [:ordinal]})
    #write_yaml_file(result, sub_dir, "difference_expected_25.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_25.yaml")
      expect(result).to eq(expected)
    end

    it "SDTM Model Variable difference, change" do
      i_1 = SdtmModel::Variable.find("M-CDISC_SDTMMODEL_xxLOC", "http://www.assero.co.uk/MDRSdtmM/CDISC/V1")
      i_2 = SdtmModel::Variable.find("M-CDISC_SDTMMODEL_xxLOC", "http://www.assero.co.uk/MDRSdtmM/CDISC/V2")
      result = IsoConcept.difference(i_1, i_2, {ignore: [:ordinal]})
    #write_yaml_file(result, sub_dir, "difference_expected_26.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_26.yaml")
      expect(result).to eq(expected)
    end

    it "SDTM Model Class difference with children, different" do
      i_1 = SdtmModelDomain.find("M-CDISC_SDTMMODELEVENTS", "http://www.assero.co.uk/MDRSdtmMd/CDISC/V1")
      i_2 = SdtmModelDomain.find("M-CDISC_SDTMMODELEVENTS", "http://www.assero.co.uk/MDRSdtmMd/CDISC/V2")
      timer_start
      result = IsoConcept.difference_with_children(i_1, i_2, "name", {ignore: [:ordinal]})
      timer_stop("SDTM Model Events 1.2 to 1.3 difference, ignore ordinal")
    #write_yaml_file(result, sub_dir, "difference_expected_27.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_27.yaml")
      expect(result).to eq(expected)
    end

    it "SDTM Model Class difference with children, different" do
      i_1 = SdtmModelDomain.find("M-CDISC_SDTMMODELEVENTS", "http://www.assero.co.uk/MDRSdtmMd/CDISC/V2")
      i_2 = SdtmModelDomain.find("M-CDISC_SDTMMODELEVENTS", "http://www.assero.co.uk/MDRSdtmMd/CDISC/V3")
      timer_start
      result = IsoConcept.difference_with_children(i_1, i_2, "name", {ignore: [:ordinal]})
      timer_stop("SDTM Model Events 1.3 to 1.4 difference, ignore ordinal")
    #write_yaml_file(result, sub_dir, "difference_expected_28.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_28.yaml")
      expect(result).to eq(expected)
    end

    it "SDTM Model Class Variable difference, no change" do
      i_1 = SdtmModelDomain::Variable.find("M-CDISC_SDTMMODELEVENTS_xxDECOD", "http://www.assero.co.uk/MDRSdtmMd/CDISC/V1")
      i_2 = SdtmModelDomain::Variable.find("M-CDISC_SDTMMODELEVENTS_xxDECOD", "http://www.assero.co.uk/MDRSdtmMd/CDISC/V2")
      result = IsoConcept.difference(i_1, i_2, {ignore: [:ordinal]})
    #write_yaml_file(result, sub_dir, "difference_expected_29.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_29.yaml")
      expect(result).to eq(expected)
    end

    it "SDTM Model Class Variable difference, change" do
      i_1 = SdtmModelDomain::Variable.find("M-CDISC_SDTMMODELEVENTS_xxSTTPT", "http://www.assero.co.uk/MDRSdtmMd/CDISC/V2")
      i_2 = SdtmModelDomain::Variable.find("M-CDISC_SDTMMODELEVENTS_xxSTTPT", "http://www.assero.co.uk/MDRSdtmMd/CDISC/V3")
      result = IsoConcept.difference(i_1, i_2, {ignore: [:ordinal]})
    #write_yaml_file(result, sub_dir, "difference_expected_30.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_30.yaml")
      expect(result).to eq(expected)
    end

    it "IG Domain difference with children, different" do
      i_1 = SdtmIgDomain.find("IG-CDISC_SDTMIGDM", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V1")
      i_2 = SdtmIgDomain.find("IG-CDISC_SDTMIGDM", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V2")
      result = IsoConcept.difference_with_children(i_1, i_2, "name")
    #write_yaml_file(result, sub_dir, "difference_expected_31.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_31.yaml")
      expect(result).to eq(expected)
    end

    it "IG Domain difference with children, different, ignore ordinal" do
      i_1 = SdtmIgDomain.find("IG-CDISC_SDTMIGDM", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V1")
      i_2 = SdtmIgDomain.find("IG-CDISC_SDTMIGDM", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V2")
      result = IsoConcept.difference_with_children(i_1, i_2, "name", {ignore: [:ordinal]})
    #write_yaml_file(result, sub_dir, "difference_expected_32.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_32.yaml")
      expect(result).to eq(expected)
    end

    it "IG Domain difference with children, different, ignore ordinal" do
      i_1 = SdtmIgDomain.find("IG-CDISC_SDTMIGDM", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V2")
      i_2 = SdtmIgDomain.find("IG-CDISC_SDTMIGDM", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3")
      timer_start
      result = IsoConcept.difference_with_children(i_1, i_2, "name", {ignore: [:ordinal]})
    #write_yaml_file(result, sub_dir, "difference_expected_33.yaml")
      timer_stop("SDTM IG DM Domain 3.1.3 to 3.2 difference, ignore ordinal")
      expected = read_yaml_file(sub_dir, "difference_expected_33.yaml")
      expect(result).to eq(expected)
    end
=end

  end
end