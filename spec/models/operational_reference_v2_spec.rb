require 'rails_helper'

describe OperationalReferenceV2 do

	include DataHelpers
    
	before :all do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_schema_file_into_triple_store("BusinessOperational.ttl")
    load_schema_file_into_triple_store("business_operational_extension.ttl")
    load_schema_file_into_triple_store("BusinessForm.ttl")
    load_test_file_into_triple_store("iso_registration_authority_real.ttl")
    load_test_file_into_triple_store("iso_namespace_real.ttl")
    load_test_file_into_triple_store("form_example_dm1.ttl")
    clear_iso_concept_object
  end
 
  it "validates a valid object" do
    result = OperationalReferenceV2.new
    result.local_label = "Draft 123"
    expect(result.valid?).to eq(true)
  end

  it "does not validate an invalid object, text label" do
    result = OperationalReferenceV2.new
    result.local_label = "Draft 123 more tesxt €"
    expect(result.valid?).to eq(false)
  end

  it "allows object to be initialized from triples" do
    result = 
      {
        :id => "F-ACME_OR_G1_I1", 
        :namespace => "http://www.assero.co.uk/X/V1", 
        :local_label => "sssssssssss",
        :extension_properties => [],
        :label => "BC Property Reference",
        :optional => false,
        :ordinal => 1,
        :enabled => true,
        :subject_ref => "null",
        :type => "http://www.assero.co.uk/BusinessOperational#PReference"
      }
    triples = {}
    triples ["F-ACME_OR_G1_I1"] = []
    triples ["F-ACME_OR_G1_I1"] << { subject: "http://www.assero.co.uk/X/V1#F-ACME_OR_G1_I1", predicate: "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", object: "http://www.assero.co.uk/BusinessOperational#PReference" }
    triples ["F-ACME_OR_G1_I1"] << { subject: "http://www.assero.co.uk/X/V1#F-ACME_OR_G1_I1", predicate: "http://www.w3.org/2000/01/rdf-schema#label", object: "BC Property Reference" }
    triples ["F-ACME_OR_G1_I1"] << { subject: "http://www.assero.co.uk/X/V1#F-ACME_OR_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#isItemOf", object: "<http://www.assero.co.uk/X/V1#F-ACME_OR_G1>" }
    triples ["F-ACME_OR_G1_I1"] << { subject: "http://www.assero.co.uk/X/V1#F-ACME_OR_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#enabled", object: "true" }
    triples ["F-ACME_OR_G1_I1"] << { subject: "http://www.assero.co.uk/X/V1#F-ACME_OR_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#optional", object: "false" }
    triples ["F-ACME_OR_G1_I1"] << { subject: "http://www.assero.co.uk/X/V1#F-ACME_OR_G1_I1", predicate: "http://www.assero.co.uk/BusinessOperational#local_label", object: "sssssssssss" }
    triples ["F-ACME_OR_G1_I1"] << { subject: "http://www.assero.co.uk/X/V1#F-ACME_OR_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#ordinal", object: "1" }
    expect(OperationalReferenceV2.new(triples, "F-ACME_OR_G1_I1").to_json).to eq(result)    
  end

  it "allows the object to be initialized from JSON" do
    result = 
      {
        :id => "F-ACME_OR_G1_I1", 
        :namespace => "http://www.assero.co.uk/X/V1", 
        :extension_properties => [],
        :label => "BC Property Reference",
        :subject_ref => UriV2.new({:id => "fragement", :namespace => "http://www.example.com/path"}).to_json,
        :optional => false,
        :ordinal => 1,
        :enabled => true,
        :local_label => "hello",
        :type => "http://www.assero.co.uk/BusinessForm#PReference"
      }
    item = OperationalReferenceV2.from_json(result)
    expect(item.to_json).to eq(result)
  end

  it "allows an object to be found from triples - Tc Reference" do
    id = "BC-ACME_BC_C25347_PerformedClinicalResult_value_PQR_code_TR_1"
    triples = {}
    triples [id] = []
    triples [id] = 
      [
        {
          :subject => "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25347_PerformedClinicalResult_value_PQR_code_TR_1",
          :predicate => "http://www.w3.org/2000/01/rdf-schema#label",
          :object => "Thesaurus Concept Reference"
        },
        {
          :subject => "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25347_PerformedClinicalResult_value_PQR_code_TR_1",
          :predicate => "http://www.w3.org/1999/02/22-rdf-syntax-ns#type",
          :object => "http://www.assero.co.uk/BusinessOperational#TcReference"
        },
        {
          :subject => "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25347_PerformedClinicalResult_value_PQR_code_TR_1",
          :predicate => "http://www.assero.co.uk/BusinessOperational#hasThesaurusConcept",
          :object => "http://www.assero.co.uk/MDRThesaurus/CDISC/V42#CLI-C66770_C49668"
        },
        {
          :subject => "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25347_PerformedClinicalResult_value_PQR_code_TR_1",
          :predicate => "http://www.assero.co.uk/BusinessOperational#ordinal",
          :object => "1"
        },
        {
          :subject => "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25347_PerformedClinicalResult_value_PQR_code_TR_1",
          :predicate => "http://www.assero.co.uk/BusinessOperational#enabled",
          :object => "true"
        },
        {
          :subject => "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25347_PerformedClinicalResult_value_PQR_code_TR_1",
          :predicate => "http://www.assero.co.uk/BusinessOperational#optional",
          :object => "true"
        },
        {
          :subject => "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25347_PerformedClinicalResult_value_PQR_code_TR_1",
          :predicate => "http://www.assero.co.uk/BusinessOperational#local_label",
          :object => ""
        }
      ]
    result = 
      {
        :id => "BC-ACME_BC_C25347_PerformedClinicalResult_value_PQR_code_TR_1", 
        :namespace => "http://www.assero.co.uk/MDRBCs/V1", 
        :label => "Thesaurus Concept Reference",
        :extension_properties => [],
        :subject_ref => UriV2.new({:id => "CLI-C66770_C49668", :namespace => "http://www.assero.co.uk/MDRThesaurus/CDISC/V42"}).to_json,
        :optional => true,
        :ordinal => 1,
        :local_label => "",
        :enabled => true,
        :type => "http://www.assero.co.uk/BusinessOperational#TcReference"
      }
    object = OperationalReferenceV2.find_from_triples(triples, id)
    expect(object.to_json).to eq(result)
  end

  it "allows an object to be found from triples - Bct Reference" do
    id = "BC-ACME_BC_C25347_TPR"
    triples = {}
    triples [id] = []
    triples [id] = 
      [
        {
          :subject => "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25347_TPR",
          :predicate => "http://www.w3.org/2000/01/rdf-schema#label",
          :object => "BCT Reference"
        },
        {
          :subject => "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25347_TPR",
          :predicate => "http://www.w3.org/1999/02/22-rdf-syntax-ns#type",
          :object => "http://www.assero.co.uk/BusinessOperational#BctReference"
        },
        {
          :subject => "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25347_TPR",
          :predicate => "http://www.assero.co.uk/BusinessOperational#basedOnTemplate",
          :object => "http://www.assero.co.uk/MDRBCTs/V1#BCT-Obs_PQR"
        },
        {
          :subject => "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25347_TPR",
          :predicate => "http://www.assero.co.uk/BusinessOperational#ordinal",
          :object => "1"
        },
        {
          :subject => "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25347_TPR",
          :predicate => "http://www.assero.co.uk/BusinessOperational#enabled",
          :object => "true"
        },
        {
          :subject => "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25347_TPR",
          :predicate => "http://www.assero.co.uk/BusinessOperational#optional",
          :object => "true"
        }
      ]
    result = 
      {
        :id => "BC-ACME_BC_C25347_TPR", 
        :namespace => "http://www.assero.co.uk/MDRBCs/V1", 
        :label => "BCT Reference",
        :extension_properties => [],
        :subject_ref => UriV2.new({:id => "BCT-Obs_PQR", :namespace => "http://www.assero.co.uk/MDRBCTs/V1"}).to_json,
        :optional => true,
        :ordinal => 1,
        :enabled => true,
        :local_label => "",
        :type => "http://www.assero.co.uk/BusinessOperational#BctReference"
      }
    object = OperationalReferenceV2.find_from_triples(triples, id)
    expect(object.to_json).to eq(result)
  end

  it "allows an object to be found from triples - Branch Reference" do
    id = "BC-ACME_BC_C25347_BRR"
    triples = {}
    triples [id] = []
    triples [id] = 
      [
        {
          :subject => "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25347_BRR",
          :predicate => "http://www.w3.org/2000/01/rdf-schema#label",
          :object => "BCT Reference"
        },
        {
          :subject => "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25347_BRR",
          :predicate => "http://www.w3.org/1999/02/22-rdf-syntax-ns#type",
          :object => "http://www.assero.co.uk/BusinessOperational#BReference"
        },
        {
          :subject => "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25347_BRR",
          :predicate => "http://www.assero.co.uk/BusinessOperational#branchedFrom",
          :object => "http://www.assero.co.uk/MDRBCTs/V1#BC-ACME_C123456"
        },
        {
          :subject => "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25347_BRR",
          :predicate => "http://www.assero.co.uk/BusinessOperational#ordinal",
          :object => "1"
        },
        {
          :subject => "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25347_BRR",
          :predicate => "http://www.assero.co.uk/BusinessOperational#enabled",
          :object => "true"
        },
        {
          :subject => "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25347_BRR",
          :predicate => "http://www.assero.co.uk/BusinessOperational#optional",
          :object => "true"
        }
      ]
    result = 
      {
        :id => "BC-ACME_BC_C25347_BRR", 
        :namespace => "http://www.assero.co.uk/MDRBCs/V1", 
        :label => "BCT Reference",
        :extension_properties => [],
        :subject_ref => UriV2.new({:id => "BC-ACME_C123456", :namespace => "http://www.assero.co.uk/MDRBCTs/V1"}).to_json,
        :optional => true,
        :ordinal => 1,
        :enabled => true,
        :local_label => "",
        :type => "http://www.assero.co.uk/BusinessOperational#BReference"
      }
    object = OperationalReferenceV2.find_from_triples(triples, id)
    expect(object.to_json).to eq(result)
  end

  it "allows an object to be found from triples - Old V Reference" do
    id = "F-ACME_VSBASELINE1_G1_G1_I2_I1_VR1"
    triples = {}
    triples [id] = []
    triples [id] = 
      [
        {
          :subject => "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_VSBASELINE1_G1_G1_I2_I1_VR1",
          :predicate => "http://www.w3.org/1999/02/22-rdf-syntax-ns#type",
          :object => "http://www.assero.co.uk/BusinessOperational#VReference" 
        },
        {
          :subject => "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_VSBASELINE1_G1_G1_I2_I1_VR1",
          :predicate => "http://www.w3.org/2000/01/rdf-schema#label",
          :object => "BC Property Value Reference"
        },
        {
          :subject => "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_VSBASELINE1_G1_G1_I2_I1_VR1",
          :predicate => "http://www.assero.co.uk/BusinessOperational#hasThesaurusConcept",
          :object => "http://www.assero.co.uk/MDRThesaurus/CDISC/V42#CLI-C71148_C62167"
        },
        {
          :subject => "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_VSBASELINE1_G1_G1_I2_I1_VR1",
          :predicate => "http://www.assero.co.uk/BusinessOperational#ordinal",
          :object => "3"
        },
        {
          :subject => "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_VSBASELINE1_G1_G1_I2_I1_VR1",
          :predicate => "http://www.assero.co.uk/BusinessOperational#enabled",
          :object => "true"
        },
        {
          :subject => "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_VSBASELINE1_G1_G1_I2_I1_VR1",
          :predicate => "http://www.assero.co.uk/BusinessOperational#optional",
          :object => "false" 
        },
        {
          :subject => "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_VSBASELINE1_G1_G1_I2_I1_VR1",
          :predicate => "http://www.assero.co.uk/BusinessOperational#local_label",
          :object => "Supine Position"
        }
      ]
    result = 
      {
        :id => "F-ACME_VSBASELINE1_G1_G1_I2_I1_VR1", 
        :namespace => "http://www.assero.co.uk/MDRForms/ACME/V1", 
        :label => "BC Property Value Reference",
        :extension_properties => [],
        :subject_ref => "null",
        :optional => false,
        :ordinal => 3,
        :local_label => "Supine Position",
        :enabled => true,
        :type => "http://www.assero.co.uk/BusinessOperational#VReference"
      }
    object = OperationalReferenceV2.find_from_triples(triples, id)
    expect(object.to_json).to eq(result)
  end

  it "allows an object to be found from triples - Invalid" do
    id = "F-ACME_VSBASELINE1_G1_G1_I2_I1_VR1"
    triples = {}
    triples [id] = []
    triples [id] = 
      [
        {
          :subject => "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_VSBASELINE1_G1_G1_I2_I1_VR1",
          :predicate => "http://www.w3.org/1999/02/22-rdf-syntax-ns#type",
          :object => "http://www.assero.co.uk/BusinessOperational#VxxxReference" 
        },
        {
          :subject => "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_VSBASELINE1_G1_G1_I2_I1_VR1",
          :predicate => "http://www.w3.org/2000/01/rdf-schema#label",
          :object => "BC Property Value Reference"
        },
        {
          :subject => "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_VSBASELINE1_G1_G1_I2_I1_VR1",
          :predicate => "http://www.assero.co.uk/BusinessOperational#hasThesaurusConcept",
          :object => "http://www.assero.co.uk/MDRThesaurus/CDISC/V42#CLI-C71148_C62167"
        },
        {
          :subject => "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_VSBASELINE1_G1_G1_I2_I1_VR1",
          :predicate => "http://www.assero.co.uk/BusinessOperational#ordinal",
          :object => "4"
        },
        {
          :subject => "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_VSBASELINE1_G1_G1_I2_I1_VR1",
          :predicate => "http://www.assero.co.uk/BusinessOperational#enabled",
          :object => "true"
        },
        {
          :subject => "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_VSBASELINE1_G1_G1_I2_I1_VR1",
          :predicate => "http://www.assero.co.uk/BusinessOperational#optional",
          :object => "false" 
        },
        {
          :subject => "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_VSBASELINE1_G1_G1_I2_I1_VR1",
          :predicate => "http://www.assero.co.uk/BusinessOperational#local_label",
          :object => "Supine Position"
        }
      ]
    result = 
      {
        :id => "F-ACME_VSBASELINE1_G1_G1_I2_I1_VR1", 
        :namespace => "http://www.assero.co.uk/MDRForms/ACME/V1", 
        :label => "BC Property Value Reference",
        :extension_properties => [],
        :subject_ref => "null",
        :optional => false,
        :ordinal => 4,
        :local_label => "Supine Position",
        :enabled => true,
        :type => "http://www.assero.co.uk/BusinessOperational#VxxxReference"
      }
    object = OperationalReferenceV2.find_from_triples(triples, id)
    expect(object.to_json).to eq(result)
  end

  it "allows an object to be exported as SPARQL, TcReference" do
    sparql = SparqlUpdateV2.new
    result = 
      "PREFIX bo: <http://www.assero.co.uk/BusinessOperational#>\n" +
      "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
      "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
      "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
      "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
      "INSERT DATA \n" +
      "{ \n" + 
      "<http://www.example.com/path#parent_XXX1> rdf:type <http://www.assero.co.uk/BusinessOperational#TcReference> . \n" +
      "<http://www.example.com/path#parent_XXX1> rdfs:label \"Thesaurus Concept Reference\"^^xsd:string . \n" +
      "<http://www.example.com/path#parent_XXX1> bo:hasThesaurusConcept <http://www.example.com/path#fragement> . \n" +
      "<http://www.example.com/path#parent_XXX1> bo:enabled \"true\"^^xsd:boolean . \n" +
      "<http://www.example.com/path#parent_XXX1> bo:optional \"false\"^^xsd:boolean . \n" +
      "<http://www.example.com/path#parent_XXX1> bo:ordinal \"1\"^^xsd:positiveInteger . \n" +
      "<http://www.example.com/path#parent_XXX1> bo:local_label \"****local****\"^^xsd:string . \n" + 
      "}"
    item = OperationalReferenceV2.new
    item.rdf_type = "http://www.example.com/path#rdf_test_type"
    item.label = "label"
    item.local_label = "****local****"
    item.subject_ref = UriV2.new({:id => "fragement", :namespace => "http://www.example.com/path"})
    item.to_sparql_v2(UriV2.new({:id => "parent", :namespace => "http://www.example.com/path"}), "hasThesaurusConcept", "XXX", 1, sparql)
    expect(sparql.to_s).to eq(result)
  end

  it "allows an object to be exported as SPARQL, BctReference" do
    sparql = SparqlUpdateV2.new
    result = 
      "PREFIX bo: <http://www.assero.co.uk/BusinessOperational#>\n" +
      "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
      "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
      "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
      "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
      "INSERT DATA \n" +
      "{ \n" + 
      "<http://www.example.com/path#parent_XXX1> rdf:type <http://www.assero.co.uk/BusinessOperational#BctReference> . \n" +
      "<http://www.example.com/path#parent_XXX1> rdfs:label \"Based on Template Reference\"^^xsd:string . \n" +
      "<http://www.example.com/path#parent_XXX1> bo:basedOnTemplate <http://www.example.com/path#fragement> . \n" +
      "<http://www.example.com/path#parent_XXX1> bo:enabled \"true\"^^xsd:boolean . \n" +
      "<http://www.example.com/path#parent_XXX1> bo:optional \"false\"^^xsd:boolean . \n" +
      "<http://www.example.com/path#parent_XXX1> bo:ordinal \"1\"^^xsd:positiveInteger . \n" +
      "<http://www.example.com/path#parent_XXX1> bo:local_label \"****local****\"^^xsd:string . \n" + 
      "}"
    item = OperationalReferenceV2.new
    item.rdf_type = "http://www.example.com/path#rdf_test_type"
    item.label = "label"
    item.local_label = "****local****"
    item.subject_ref = UriV2.new({:id => "fragement", :namespace => "http://www.example.com/path"})
    item.to_sparql_v2(UriV2.new({:id => "parent", :namespace => "http://www.example.com/path"}), "basedOnTemplate", "XXX", 1, sparql)
    expect(sparql.to_s).to eq(result)
  end

  it "allows an object to be exported as SPARQL, Branched From Reference" do
    sparql = SparqlUpdateV2.new
    result = 
      "PREFIX bo: <http://www.assero.co.uk/BusinessOperational#>\n" +
      "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
      "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
      "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
      "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
      "INSERT DATA \n" +
      "{ \n" + 
      "<http://www.example.com/path#parent_XXX1> rdf:type <http://www.assero.co.uk/BusinessOperational#BReference> . \n" +
      "<http://www.example.com/path#parent_XXX1> rdfs:label \"Branched From Reference\"^^xsd:string . \n" +
      "<http://www.example.com/path#parent_XXX1> bo:branchedFrom <http://www.example.com/path#fragement> . \n" +
      "<http://www.example.com/path#parent_XXX1> bo:enabled \"true\"^^xsd:boolean . \n" +
      "<http://www.example.com/path#parent_XXX1> bo:optional \"false\"^^xsd:boolean . \n" +
      "<http://www.example.com/path#parent_XXX1> bo:ordinal \"1\"^^xsd:positiveInteger . \n" +
      "<http://www.example.com/path#parent_XXX1> bo:local_label \"****local****\"^^xsd:string . \n" + 
      "}"
    item = OperationalReferenceV2.new
    item.rdf_type = "http://www.example.com/path#rdf_test_type"
    item.label = "label"
    item.local_label = "****local****"
    item.subject_ref = UriV2.new({:id => "fragement", :namespace => "http://www.example.com/path"})
    item.to_sparql_v2(UriV2.new({:id => "parent", :namespace => "http://www.example.com/path"}), "branchedFrom", "XXX", 1, sparql)
    expect(sparql.to_s).to eq(result)
  end

  it "allows an object to be exported as SPARQL, Branched From Reference, Optional True, Enabled False" do
    sparql = SparqlUpdateV2.new
    result = 
      "PREFIX bo: <http://www.assero.co.uk/BusinessOperational#>\n" +
      "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
      "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
      "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
      "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
      "INSERT DATA \n" +
      "{ \n" + 
      "<http://www.example.com/path#parent_XXX1> rdf:type <http://www.assero.co.uk/BusinessOperational#BReference> . \n" +
      "<http://www.example.com/path#parent_XXX1> rdfs:label \"Branched From Reference\"^^xsd:string . \n" +
      "<http://www.example.com/path#parent_XXX1> bo:branchedFrom <http://www.example.com/path#fragement> . \n" +
      "<http://www.example.com/path#parent_XXX1> bo:enabled \"false\"^^xsd:boolean . \n" +
      "<http://www.example.com/path#parent_XXX1> bo:optional \"true\"^^xsd:boolean . \n" +
      "<http://www.example.com/path#parent_XXX1> bo:ordinal \"1\"^^xsd:positiveInteger . \n" +
      "<http://www.example.com/path#parent_XXX1> bo:local_label \"****local****\"^^xsd:string . \n" + 
      "}"
    item = OperationalReferenceV2.new
    item.rdf_type = "http://www.example.com/path#rdf_test_type"
    item.label = "label"
    item.enabled = false
    item.optional = true
    item.local_label = "****local****"
    item.subject_ref = UriV2.new({:id => "fragement", :namespace => "http://www.example.com/path"})
    item.to_sparql_v2(UriV2.new({:id => "parent", :namespace => "http://www.example.com/path"}), "branchedFrom", "XXX", 1, sparql)
    expect(sparql.to_s).to eq(result)
  end

  it "allows an object to be exported as JSON" do
    result = 
      {
        :id => "fragment", 
        :namespace => "http://www.assero.co.uk/X/V1", 
        :local_label => "****local****",
        :extension_properties => [],
        :label => "BC Property Reference",
        :enabled => true,
        :optional => false,
        :ordinal => 1,
        :subject_ref => UriV2.new({:id => "fragement", :namespace => "http://www.example.com/path"}).to_json,
        :type => "http://www.assero.co.uk/BusinessForm#PReference"
      }
    item = OperationalReferenceV2.new
    item.id = "fragment"
    item.namespace = "http://www.assero.co.uk/X/V1"
    item.rdf_type = "http://www.assero.co.uk/BusinessForm#PReference"
    item.label = "BC Property Reference"
    item.local_label = "****local****"
    item.enabled = true
    item.optional = false  
    item.ordinal = 1
    item.subject_ref = UriV2.new({:id => "fragement", :namespace => "http://www.example.com/path"})
    expect(item.to_json).to eq(result)
  end

  it "allows an object to be found from triples, Cross Reference" do
  	id = "BC-ACME_BC_C25347_XR"
    triples = {}
    triples [id] = []
    triples [id] = 
      [
        {
          :subject => "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25347_XR",
          :predicate => "http://www.w3.org/2000/01/rdf-schema#label",
          :object => "Cross Reference"
        },
        {
          :subject => "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25347_XR",
          :predicate => "http://www.w3.org/1999/02/22-rdf-syntax-ns#type",
          :object => "http://www.assero.co.uk/BusinessOperational#XReference"
        },
        {
          :subject => "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25347_XR",
          :predicate => "http://www.assero.co.uk/BusinessOperational#hasCrossReference",
          :object => "http://www.assero.co.uk/MDRBCTs/V1#BC-ACME_C123456"
        },
        {
          :subject => "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25347_XR",
          :predicate => "http://www.assero.co.uk/BusinessOperational#ordinal",
          :object => "1"
        },
        {
          :subject => "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25347_XR",
          :predicate => "http://www.assero.co.uk/BusinessOperational#enabled",
          :object => "true"
        },
        {
          :subject => "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25347_XR",
          :predicate => "http://www.assero.co.uk/BusinessOperational#optional",
          :object => "true"
        },
        {
          :subject => "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25347_XR",
          :predicate => "http://www.assero.co.uk/BusinessOperational#local_label",
          :object => "Other Label Text"
        }        
      ]
    result = 
      {
        :id => "BC-ACME_BC_C25347_XR", 
        :namespace => "http://www.assero.co.uk/MDRBCs/V1", 
        :label => "Cross Reference",
        :extension_properties => [],
        :subject_ref => UriV2.new({:id => "BC-ACME_C123456", :namespace => "http://www.assero.co.uk/MDRBCTs/V1"}).to_json,
        :optional => true,
        :ordinal => 1,
        :enabled => true,
        :local_label => "Other Label Text",
        :type => "http://www.assero.co.uk/BusinessOperational#XReference"
      }
    object = OperationalReferenceV2.find_from_triples(triples, id)
    expect(object.to_json).to eq(result)
end

  it "allows an object to be exported as SPARQL, Cross Reference" do
    sparql = SparqlUpdateV2.new
    result = 
      "PREFIX bo: <http://www.assero.co.uk/BusinessOperational#>\n" +
      "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
      "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
      "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
      "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
      "INSERT DATA \n" +
      "{ \n" + 
      "<http://www.example.com/path#parent_XXX1> rdf:type <http://www.assero.co.uk/BusinessOperational#XReference> . \n" +
      "<http://www.example.com/path#parent_XXX1> rdfs:label \"Cross Reference\"^^xsd:string . \n" +
      "<http://www.example.com/path#parent_XXX1> bo:hasCrossReference <http://www.example.com/path#fragement> . \n" +
      "<http://www.example.com/path#parent_XXX1> bo:enabled \"true\"^^xsd:boolean . \n" +
      "<http://www.example.com/path#parent_XXX1> bo:optional \"false\"^^xsd:boolean . \n" +
      "<http://www.example.com/path#parent_XXX1> bo:ordinal \"1\"^^xsd:positiveInteger . \n" +
      "<http://www.example.com/path#parent_XXX1> bo:local_label \"****local****\"^^xsd:string . \n" + 
      "}"
    item = OperationalReferenceV2.new
    item.rdf_type = "http://www.example.com/path#rdf_test_type"
    item.label = "label"
    item.local_label = "****local****"
    item.subject_ref = UriV2.new({:id => "fragement", :namespace => "http://www.example.com/path"})
    item.to_sparql_v2(UriV2.new({:id => "parent", :namespace => "http://www.example.com/path"}), "hasCrossReference", "XXX", 1, sparql)
    expect(sparql.to_s).to eq(result)
  end

end