require 'rails_helper'
require 'biomedical_concept_core/property'

describe BiomedicalConceptCore::Property do
  
  include DataHelpers
  include SparqlHelpers

  def sub_dir
    return "models/biomedical_concept_core/property"
  end

  before :all do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_schema_file_into_triple_store("BusinessOperational.ttl")
    load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")
    load_test_file_into_triple_store("BCT.ttl")
    load_test_file_into_triple_store("BC.ttl")
    clear_iso_concept_object
  end

  it "validates a valid object" do
    item = BiomedicalConceptCore::Property.new
    item.question_text = "Draft 123"
    item.prompt_text = "Draft 123"
    result = item.valid?
    expect(item.errors.full_messages.to_sentence).to eq("")
    expect(result).to eq(true)
  end

  it "validates a valid object - Set" do
    result = BiomedicalConceptCore::Property.new
    result.question_text = "Draft 123"
    result.prompt_text = "Draft 123"
    result.enabled = false
    result.collect = true
    result.format = "5.2"
    result.bridg_path = "path"
    result.simple_datatype = "string"
    expect(result.valid?).to eq(true)
  end

  it "validates a valid object - Complex" do
    item = BiomedicalConceptCore::Property.new
    item.complex_datatype = BiomedicalConceptCore::Datatype.new
    item.complex_datatype.iso21090_datatype = "PQ"
    property = BiomedicalConceptCore::Property.new
    property.question_text = "Draft 123"
    property.prompt_text = "Draft 123"
    item.complex_datatype.children[0] = property
    result = item.valid?
    expect(item.errors.full_messages.to_sentence).to eq("")
    expect(result).to eq(true)
  end

  it "does not validate an invalid object - Complex" do
    item = BiomedicalConceptCore::Property.new
    item.complex_datatype = BiomedicalConceptCore::Datatype.new
    property = BiomedicalConceptCore::Property.new
    item.complex_datatype.children[0] = property
    property.question_text = "€"
    result = item.valid?
    expect(item.errors.full_messages.to_sentence).to eq("Complex datatype, error: Property, ordinal=1, error: Question text contains invalid characters")
    expect(result).to eq(false)
  end

  it "does not validate an invalid object - Question Text" do
    result = BiomedicalConceptCore::Property.new
    result.question_text = "Draft 123^^^"
    result.prompt_text = "Draft 123"
    result.enabled = false
    result.collect = true
    result.format = "5.2"
    result.bridg_path = "path"
    result.simple_datatype = "string"
    expect(result.valid?).to eq(false)
    expect(result.errors.full_messages.to_sentence).to eq("Question text contains invalid characters")
  end

  it "does not validate an invalid object - Prompt Text" do
    result = BiomedicalConceptCore::Property.new
    result.question_text = "Draft 123"
    result.prompt_text = "Draft 123^^^"
    result.enabled = false
    result.collect = true
    result.format = "5.2"
    result.bridg_path = "path"
    result.simple_datatype = "string"
    expect(result.valid?).to eq(false)
  end

  it "does not validate an invalid object - Format" do
    result = BiomedicalConceptCore::Property.new
    result.question_text = "Draft 123"
    result.prompt_text = "Draft 123"
    result.enabled = false
    result.collect = true
    result.format = "5.2s"
    result.bridg_path = "path"
    result.simple_datatype = "string"
    expect(result.valid?).to eq(false)
  end

  it "does not validate an invalid object - Datatype" do
    result = BiomedicalConceptCore::Property.new
    result.question_text = "Draft 123"
    result.prompt_text = "Draft 123"
    result.enabled = false
    result.collect = true
    result.format = "5.2"
    result.bridg_path = "path"
    result.simple_datatype = "stringX"
    expect(result.valid?).to eq(false)
  end

  it "allows object to be initialized from triples" do
    result = 
      {
        :id => "N_1", 
        :namespace => "http://www.assero.co.uk/MDRForms/ACME/V1", 
        :extension_properties => [],
        :label => "Text Label",
        :alias => "XXXXX",
        :ordinal => 1,
        :question_text => "qText",
        :prompt_text => "pText",
        :children => [],
        :collect => true,
        :enabled => false,
        :format => "5.2",
        :simple_datatype => "string",
        :bridg_path => "a.b.c",
        :coded => false,
        :type => "http://www.assero.co.uk/CDISCBiomedicalConcept#Node"
      }
    triples = {}
    triples ["N_1"] = []
    triples ["N_1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#N_1", predicate: "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", object: "http://www.assero.co.uk/CDISCBiomedicalConcept#Node" }
    triples ["N_1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#N_1", predicate: "http://www.w3.org/2000/01/rdf-schema#label", object: "Text Label" }
    triples ["N_1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#N_1", predicate: "http://www.assero.co.uk/CDISCBiomedicalConcept#alias", object: "XXXXX" }
    triples ["N_1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#N_1", predicate: "http://www.assero.co.uk/CDISCBiomedicalConcept#ordinal", object: "1" }
    triples ["N_1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#N_1", predicate: "http://www.assero.co.uk/CDISCBiomedicalConcept#question_text", object: "qText" }
    triples ["N_1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#N_1", predicate: "http://www.assero.co.uk/CDISCBiomedicalConcept#prompt_text", object: "pText" }
    triples ["N_1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#N_1", predicate: "http://www.assero.co.uk/CDISCBiomedicalConcept#collect", object: "true" }
    triples ["N_1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#N_1", predicate: "http://www.assero.co.uk/CDISCBiomedicalConcept#enabled", object: "false" }
    triples ["N_1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#N_1", predicate: "http://www.assero.co.uk/CDISCBiomedicalConcept#format", object: "5.2" }
    triples ["N_1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#N_1", predicate: "http://www.assero.co.uk/CDISCBiomedicalConcept#simple_datatype", object: "string" }
    triples ["N_1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#N_1", predicate: "http://www.assero.co.uk/CDISCBiomedicalConcept#bridg_path", object: "a.b.c" }
    item = BiomedicalConceptCore::Property.new(triples, "N_1")
    expect(item.to_json).to eq(result)    
  end

  it "detects complex property" do
    property = BiomedicalConceptCore::Property.find("BCT-Obs_PQR_DefinedObservation_nameCode_CD_originalText", "http://www.assero.co.uk/MDRBCTs/V1")
    expect(property.is_complex?).to eq(true)
  end

  it "allows coded to be set" do
    property = BiomedicalConceptCore::Property.find("BC-ACME_BC_C25347_PerformedClinicalResult_value_PQR_code", "http://www.assero.co.uk/MDRBCs/V1")
    property.set_coded
    expect(property.coded?).to eq (true)
  end

  it "prevents coded being set on complex property" do
    property = BiomedicalConceptCore::Property.find("BCT-Obs_PQR_DefinedObservation_nameCode_CD_originalText", "http://www.assero.co.uk/MDRBCTs/V1")
    property.set_coded
    expect(property.coded?).to eq (false)
  end

  it "allows coded to be determined" do
    property = BiomedicalConceptCore::Property.find("BC-ACME_BC_C25347_PerformedClinicalResult_value_PQR_code", "http://www.assero.co.uk/MDRBCs/V1")
    property.set_coded
    expect(property.coded?).to eq (true)
  end

  it "allows the object to be found - Complex datatype" do
    result = 
      {
        :id => "BCT-Obs_PQR_DefinedObservation_nameCode_CD_originalText", 
        :namespace => "http://www.assero.co.uk/MDRBCTs/V1", 
        :type => "http://www.assero.co.uk/CDISCBiomedicalConcept#Property",
        :extension_properties => [],
        :label => "",
        :alias => "Name",
        :ordinal => 2,
        :complex_datatype => 
          {
            :type =>"http://www.assero.co.uk/CDISCBiomedicalConcept#Datatype", 
            :id =>"BCT-Obs_PQR_DefinedObservation_nameCode_CD_originalText_ED", 
            :namespace =>"http://www.assero.co.uk/MDRBCTs/V1", 
            :label =>"", :extension_properties=>[], 
            :ordinal =>1, 
            :alias =>"", 
            :iso21090_datatype =>"ED", 
            :children =>
              [
                { 
                  :type=>"http://www.assero.co.uk/CDISCBiomedicalConcept#Property",
                  :id=>"BCT-Obs_PQR_DefinedObservation_nameCode_CD_originalText_ED_value",
                  :namespace=>"http://www.assero.co.uk/MDRBCTs/V1",
                  :label=>"",
                  :extension_properties=>[],    
                  :alias => "Test Name (--TEST)",
                  :question_text => "",
                  :prompt_text => "",
                  :ordinal => 1,
                  :collect => false,
                  :enabled => false,
                  :format => "",
                  :coded => true,
                  :simple_datatype => "string",
                  :bridg_path=>"DefinedObservation.nameCode.CD.originalText.ED.value",
                  :children => []
                }
              ]
          }
      }
    property = BiomedicalConceptCore::Property.find("BCT-Obs_PQR_DefinedObservation_nameCode_CD_originalText", "http://www.assero.co.uk/MDRBCTs/V1")
    expect(property.to_json).to eq(result)
  end

  it "allows the object to be found - TC Refs" do
    property = BiomedicalConceptCore::Property.find("BC-ACME_BC_C25347_PerformedClinicalResult_value_PQR_code", "http://www.assero.co.uk/MDRBCs/V1")
    check_file_actual_expected(property.to_json, sub_dir, "find_expected_1.yaml", eq_method: hash_equal)
  end

  it "allows the object to be exported as JSON" do
    result = 
      {
        :id => "123", 
        :namespace => "http://www.example.com/path", 
        :extension_properties => [],
        :label => "Test",
        :alias => "alias",
        :ordinal => 1,
        :question_text => "XXXX",
        :prompt_text => "YYYY",
        :children => [],
        :collect => false,
        :enabled => false,
        :format => "10.1",
        :simple_datatype => "float",
        :bridg_path => "x.y.z",
        :coded => false,
        :type => "http://www.example.com/path#rdf_test_type"
      }
    item = BiomedicalConceptCore::Property.new
    item.id = "123"
    item.namespace = "http://www.example.com/path"
    item.label = "Test"
    item.alias = "alias"
    item.ordinal = 1
    item.question_text = "XXXX"
    item.prompt_text = "YYYY"
    item.enabled = false
    item.collect = false
    item.format = "10.1"
    item.simple_datatype = "float"
    item.bridg_path = "x.y.z"
    item.rdf_type = "http://www.example.com/path#rdf_test_type"
    expect(item.to_json).to eq(result)
  end

  it "allows the object to be created from JSON, complex datatype" do
    result = 
      {
        :id => "BCT-Obs_PQR_DefinedObservation_nameCode_CD_originalText", 
        :namespace => "http://www.assero.co.uk/MDRBCTs/V1", 
        :type => "http://www.assero.co.uk/CDISCBiomedicalConcept#Property",
        :extension_properties => [],
        :label => "",
        :alias => "Name",
        :ordinal => 1,
        :complex_datatype => 
        {
          :type =>"http://www.assero.co.uk/CDISCBiomedicalConcept#Datatype", 
          :id =>"BCT-Obs_PQR_DefinedObservation_nameCode_CD_originalText_ED", 
          :namespace =>"http://www.assero.co.uk/MDRBCTs/V1", 
          :label =>"", :extension_properties=>[], 
          :ordinal =>1, 
          :alias =>"", 
          :iso21090_datatype =>"ED", 
          :children =>
            [
              { 
                :type=>"http://www.assero.co.uk/CDISCBiomedicalConcept#Property",
                :id=>"BCT-Obs_PQR_DefinedObservation_nameCode_CD_originalText_ED_value",
                :namespace=>"http://www.assero.co.uk/MDRBCTs/V1",
                :label=>"",
                :extension_properties=>[],    
                :alias => "Test Name (--TEST)",
                :question_text => "",
                :prompt_text => "",
                :ordinal => 1,
                :collect => false,
                :enabled => false,
                :format => "",
                :simple_datatype => "string",
                :coded => false,
                :bridg_path=>"DefinedObservation.nameCode.CD.originalText.ED.value",
                :children => []
              }
            ]
        }
      }
    expect(BiomedicalConceptCore::Property.from_json(result).to_json).to eq(result)
  end

  it "allows the object to be created from JSON" do
    result = 
      {
        :id => "123", 
        :namespace => "http://www.example.com/path", 
        :extension_properties => [],
        :label => "Test",
        :alias => "alias",
        :ordinal => 1,
        :question_text => "XXXX",
        :prompt_text => "YYYY",
        :children => [],
        :collect => false,
        :enabled => false,
        :format => "10.1",
        :simple_datatype => "float",
        :bridg_path => "ddd.eee.fff",
        :coded => false,
        :type => "http://www.example.com/path#rdf_test_type"
      }
    expect(BiomedicalConceptCore::Property.from_json(result).to_json).to eq(result)
  end

  it "allows an object to be exported as SPARQL" do
    sparql = SparqlUpdateV2.new
    item = BiomedicalConceptCore::Property.new
    item.id = "123"
    item.namespace = "http://www.example.com/path"
    item.rdf_type = "http://www.example.com/path#rdf_test_type"
    item.label = "test label"
    item.alias = "Note"
    item.question_text = "XXXX"
    item.prompt_text = "YYYY"
    item.enabled = false
    item.collect = false
    item.format = "10.1"
    item.simple_datatype = "float"
    item.bridg_path = "ddd.eee.fff"
    parent_uri = UriV2.new({:id => "XXX", :namespace => "http://www.example.com/path"})
    item.to_sparql_v2(parent_uri, sparql)
  #Xwrite_text_file_2(sparql.to_s, sub_dir, "sparql_simple.txt")
    #expected = read_text_file_2(sub_dir, "sparql_simple.txt")
    #expect(sparql.to_s).to eq(expected)
    check_sparql_no_file(sparql.to_s, "sparql_simple.txt")
  end
  
  it "allows an object to be exported as SPARQL, complex datatype" do
    sparql = SparqlUpdateV2.new
    result = 
      {
        :id => "BCT-Obs_PQR_DefinedObservation_nameCode_CD_originalText", 
        :namespace => "http://www.assero.co.uk/MDRBCTs/V1", 
        :type => "http://www.assero.co.uk/CDISCBiomedicalConcept#Property",
        :extension_properties => [],
        :label => "",
        :alias => "Name",
        :ordinal => 1,
        :complex_datatype => 
        {
          :type =>"http://www.assero.co.uk/CDISCBiomedicalConcept#Datatype", 
          :id =>"BCT-Obs_PQR_DefinedObservation_nameCode_CD_originalText_ED", 
          :namespace =>"http://www.assero.co.uk/MDRBCTs/V1", 
          :label =>"", :extension_properties=>[], 
          :ordinal =>1, 
          :alias =>"", 
          :iso21090_datatype =>"", 
          :children =>
            [
              { 
                :type=>"http://www.assero.co.uk/CDISCBiomedicalConcept#Property",
                :id=>"BCT-Obs_PQR_DefinedObservation_nameCode_CD_originalText_ED_value",
                :namespace=>"http://www.assero.co.uk/MDRBCTs/V1",
                :label=>"",
                :extension_properties=>[],    
                :alias => "Test Name (--TEST)",
                :question_text => "",
                :prompt_text => "",
                :ordinal => 1,
                :collect => false,
                :enabled => false,
                :format => "",
                :simple_datatype => "string",
                :bridg_path=>"DefinedObservation.nameCode.CD.originalText.ED.value",
                :children => []
              }
            ]
        }
      }
    item = BiomedicalConceptCore::Property.from_json(result)
    parent_uri = UriV2.new({:id => "XXX", :namespace => "http://www.example.com/path"})
    item.to_sparql_v2(parent_uri, sparql)
  #Xwrite_text_file_2(sparql.to_s, sub_dir, "sparql_complex.txt")
    #expected = read_text_file_2(sub_dir, "sparql_complex.txt")
    #expect(sparql.to_s).to eq(expected)
    check_sparql_no_file(sparql.to_s, "sparql_complex.txt")
  end

  it "allows the property to be updated" do
    property = BiomedicalConceptCore::Property.find("BC-ACME_BC_C25347_PerformedClinicalResult_baselineIndicator_BL_value", "http://www.assero.co.uk/MDRBCs/V1")
    params = {}
    params[:question_text] = "New Q"
    params[:prompt_text] = "New P"
    params[:enabled] = "true"
    params[:collect]= "true"
    params[:format] = "10.1"
    property.update(params)
    expect(property.errors.count).to eq(0)
    property = BiomedicalConceptCore::Property.find("BC-ACME_BC_C25347_PerformedClinicalResult_value_PQR_code", "http://www.assero.co.uk/MDRBCs/V1")
  #write_yaml_file(property.to_json, sub_dir, "update.yaml")
    expected = read_yaml_file(sub_dir, "update.yaml")
    expect(property.to_json).to eq(expected)
  end

  it "prevents a property being updated with invalid data" do
    property = BiomedicalConceptCore::Property.find("BC-ACME_BC_C25347_PerformedClinicalResult_baselineIndicator_BL_value", "http://www.assero.co.uk/MDRBCs/V1")
    params = {}
    params[:question_text] = "£££££££"
    params[:prompt_text] = "New P"
    params[:enabled] = "true"
    params[:collect]= "true"
    params[:format] = "10.1"
    property.update(params)
    expect(property.errors.full_messages.to_sentence).to eq("Question text contains invalid characters")
    expect(property.errors.count).to eq(1)
  end

  it "handles errors during an update" do
    property = BiomedicalConceptCore::Property.find("BC-ACME_BC_C25347_PerformedClinicalResult_baselineIndicator_BL_value", "http://www.assero.co.uk/MDRBCs/V1")
    params = {}
    params[:question_text] = "New Q"
    params[:prompt_text] = "New P"
    params[:enabled] = "true"
    params[:collect]= "true"
    params[:format] = "10.1"
    response = Typhoeus::Response.new(code: 200, body: "")
    expect(Rest).to receive(:sendRequest).and_return(response)
    expect(response).to receive(:success?).and_return(false)
    expect(ConsoleLogger).to receive(:info)
    expect{property.update(params)}.to raise_error(Exceptions::UpdateError)
  end

  it "allows term references to be added" do
    property = BiomedicalConceptCore::Property.find("BC-ACME_BC_C25347_PerformedClinicalResult_value_PQR_code", "http://www.assero.co.uk/MDRBCs/V1")
    refs = []
    refs << { :subject_ref => {id: "new_1", namespace: "http://example.com/term" }, ordinal: 5}
    refs << { :subject_ref => {id: "new_2", namespace: "http://example.com/term" }, ordinal: 6}
    property.add({ tc_refs: refs })
    property = BiomedicalConceptCore::Property.find("BC-ACME_BC_C25347_PerformedClinicalResult_value_PQR_code", "http://www.assero.co.uk/MDRBCs/V1")
  #Xwrite_yaml_file(property.to_json, sub_dir, "add_term.yaml")
    expected = read_yaml_file(sub_dir, "add_term.yaml")
    expect(property.tc_refs.count).to eq(6)
    expect(property.to_json).to eq(expected)
  end

  it "handles error adding term references" do
    property = BiomedicalConceptCore::Property.find("BC-ACME_BC_C25347_PerformedClinicalResult_value_PQR_code", "http://www.assero.co.uk/MDRBCs/V1")
    refs = []
    refs << { :subject_ref => {id: "new_3", namespace: "http://example.com/term" }, ordinal: 7}
    response = Typhoeus::Response.new(code: 200, body: "")
    expect(Rest).to receive(:sendRequest).and_return(response)
    expect(response).to receive(:success?).and_return(false)
    expect(ConsoleLogger).to receive(:info)
    expect{property.add({ tc_refs: refs })}.to raise_error(Exceptions::UpdateError)
  end

  it "allows term refs to be removed" do
    property = BiomedicalConceptCore::Property.find("BC-ACME_BC_C25347_PerformedClinicalResult_value_PQR_code", "http://www.assero.co.uk/MDRBCs/V1")
    property.remove
    property = BiomedicalConceptCore::Property.find("BC-ACME_BC_C25347_PerformedClinicalResult_value_PQR_code", "http://www.assero.co.uk/MDRBCs/V1")
  #Xwrite_yaml_file(property.to_json, sub_dir, "remove_term.yaml")
    expected = read_yaml_file(sub_dir, "remove_term.yaml")
    expect(property.tc_refs.count).to eq(0)
    expect(property.to_json).to eq(expected)
  end

  it "handles error removing term references" do
    property = BiomedicalConceptCore::Property.find("BC-ACME_BC_C25347_PerformedClinicalResult_value_PQR_code", "http://www.assero.co.uk/MDRBCs/V1")
    response = Typhoeus::Response.new(code: 200, body: "")
    expect(Rest).to receive(:sendRequest).and_return(response)
    expect(response).to receive(:success?).and_return(false)
    expect(ConsoleLogger).to receive(:info)
    expect{property.remove}.to raise_error(Exceptions::UpdateError)
  end

end
  