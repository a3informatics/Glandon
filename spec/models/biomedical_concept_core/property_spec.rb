require 'rails_helper'

describe BiomedicalConceptCore::Property do
  
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
    load_test_file_into_triple_store("BCT.ttl")
    load_test_file_into_triple_store("BC.ttl")
  end

  it "validates a valid object" do
    result = BiomedicalConceptCore::Property.new
    result.valid?
    expect(result.valid?).to eq(true)
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
    result = BiomedicalConceptCore::Property.new
    result.complex_datatype = BiomedicalConceptCore::Datatype.new
    property = BiomedicalConceptCore::Property.new
    property.question_text = "Draft 123"
    result.complex_datatype.children[0] = property
    expect(result.valid?).to eq(true)
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
    expect(result.errors.full_messages[0]).to eq("Question text contains invalid characters")
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
    item = BiomedicalConceptCore::Property.new(triples, "N_1")
    expect(item.to_json).to eq(result)    
  end

  it "allows the object to be found - BCT" do
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
                  :children => []
                }
              ]
          }
      }
    property = BiomedicalConceptCore::Property.find("BCT-Obs_PQR_DefinedObservation_nameCode_CD_originalText", "http://www.assero.co.uk/MDRBCTs/V1")
    expect(property.to_json).to eq (result)
  end

  it "allows the object to be found - BC" do
    result = 
      {
        :id => "BC-ACME_BC_C25347_PerformedClinicalResult_value_PQR_code", 
        :namespace => "http://www.assero.co.uk/MDRBCs/V1", 
        :type => "http://www.assero.co.uk/CDISCBiomedicalConcept#Property",
        :extension_properties => [],
        :label => "",
        :alias => "Result Units (--ORRESU)",
        :ordinal => 2,
        :collect => true,
        :enabled => true,
        :format => "",
        :prompt_text => "Units",
        :question_text => "Result units?",
        :simple_datatype => "string",
        :children => 
        [ 
          {
            :type=>"http://www.assero.co.uk/BusinessOperational#TcReference",
            :id=>"BC-ACME_BC_C25347_PerformedClinicalResult_value_PQR_code_TR_1",
            :namespace=>"http://www.assero.co.uk/MDRBCs/V1",
            :label=>"Thesaurus Concept Reference",
            :extension_properties=>[],
            :enabled=>true,
            :optional=>true,
            :ordinal=>1,
            :local_label=>"",
            :subject_ref=>
            {
              :namespace=>"http://www.assero.co.uk/MDRThesaurus/CDISC/V42",
              :id=>"CLI-C66770_C49668"
            }
          },
          {
            :type=>"http://www.assero.co.uk/BusinessOperational#TcReference",
            :id=>"BC-ACME_BC_C25347_PerformedClinicalResult_value_PQR_code_TR_2",
            :namespace=>"http://www.assero.co.uk/MDRBCs/V1",
            :label=>"Thesaurus Concept Reference",
            :extension_properties=>[],
            :enabled=>true,
            :optional=>true,
            :ordinal=>2,
            :local_label=>"",
            :subject_ref=>
            {
              :namespace=>"http://www.assero.co.uk/MDRThesaurus/CDISC/V42",
              :id=>"CLI-C66770_C48500"
            }
          },
          {
            :type=>"http://www.assero.co.uk/BusinessOperational#TcReference",
            :id=>"BC-ACME_BC_C25347_PerformedClinicalResult_value_PQR_code_TR_3",
            :namespace=>"http://www.assero.co.uk/MDRBCs/V1",
            :label=>"Thesaurus Concept Reference",
            :extension_properties=>[],
            :enabled=>true,
            :optional=>true,
            :ordinal=>3,
            :local_label=>"",
            :subject_ref=>
            {
              :namespace=>"http://www.assero.co.uk/MDRThesaurus/CDISC/V42",
              :id=>"CLI-C71620_C41139"
            }
          },
          {
            :type=>"http://www.assero.co.uk/BusinessOperational#TcReference",
            :id=>"BC-ACME_BC_C25347_PerformedClinicalResult_value_PQR_code_TR_4",
            :namespace=>"http://www.assero.co.uk/MDRBCs/V1",
            :label=>"Thesaurus Concept Reference",
            :extension_properties=>[],
            :enabled=>true,
            :optional=>true,
            :ordinal=>4,
            :local_label=>"",
            :subject_ref=>
            {
              :namespace=>"http://www.assero.co.uk/MDRThesaurus/CDISC/V42",
              :id=>"CLI-C71620_C71253"
            }
          }
        ]
      }
    property = BiomedicalConceptCore::Property.find("BC-ACME_BC_C25347_PerformedClinicalResult_value_PQR_code", "http://www.assero.co.uk/MDRBCs/V1")
    expect(property.to_json).to eq (result)
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
    item.rdf_type = "http://www.example.com/path#rdf_test_type"
    expect(item.to_json).to eq(result)
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
        :type => "http://www.example.com/path#rdf_test_type"
      }
    expect(BiomedicalConceptCore::Property.from_json(result).to_json).to eq(result)
  end

  it "allows an object to be exported as SPARQL" do
    sparql = SparqlUpdateV2.new
    result = 
      "PREFIX cbc: <http://www.assero.co.uk/CDISCBiomedicalConcept#>\n" +
      "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
      "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
      "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
      "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
      "INSERT DATA \n" +
      "{ \n" + 
      "<http://www.example.com/path#XXX_P1> rdf:type <http://www.example.com/path#rdf_test_type> . \n" +
      "<http://www.example.com/path#XXX_P1> rdfs:label \"test label\"^^xsd:string . \n" +
      "<http://www.example.com/path#XXX_P1> cbc:ordinal \"1\"^^xsd:positiveInteger . \n" +
      "<http://www.example.com/path#XXX_P1> cbc:alias \"Note\"^^xsd:string . \n" +
      "<http://www.example.com/path#XXX_P1> cbc:question_text \"XXXX\"^^xsd:string . \n" +
      "<http://www.example.com/path#XXX_P1> cbc:prompt_text \"YYYY\"^^xsd:string . \n" +
      "<http://www.example.com/path#XXX_P1> cbc:format \"10.1\"^^xsd:string . \n" +
      "<http://www.example.com/path#XXX_P1> cbc:enabled \"false\"^^xsd:boolean . \n" +
      "<http://www.example.com/path#XXX_P1> cbc:collect \"false\"^^xsd:boolean . \n" +
      "<http://www.example.com/path#XXX_P1> cbc:bridg_path \"\"^^xsd:string . \n" +
      "<http://www.example.com/path#XXX_P1> cbc:simple_datatype \"float\"^^xsd:string . \n" +
      "}"
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
    parent_uri = UriV2.new({:id => "XXX", :namespace => "http://www.example.com/path"})
    item.to_sparql_v2(parent_uri, sparql)
    expect(sparql.to_s).to eq(result)
  end
  
end
  