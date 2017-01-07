require 'rails_helper'
require 'biomedical_concept_core/datatype'

describe BiomedicalConceptCore::Datatype do
  
  include DataHelpers

  def sub_dir
    return "models/biomedical_concept_core"
  end

  before :all do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Basic.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Data.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_schema_file_into_triple_store("BusinessOperational.ttl")
    load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")
    clear_iso_concept_object
  end

  it "validates a valid object" do
    result = BiomedicalConceptCore::Datatype.new
    result.iso21090_datatype = "PQ"
    expect(result.valid?).to eq(true)
  end

  it "validates a valid object - Children" do
    datatype = BiomedicalConceptCore::Datatype.new
    property = BiomedicalConceptCore::Property.new
    property.question_text = "Draft 123"
    property.prompt_text = "Draft"
    datatype.children[0] = property
    result = datatype.valid?
    expect(datatype.errors.full_messages.to_sentence).to eq("")
    expect(result).to eq(true)
  end

  it "validates an invalid object - Children question text" do
    datatype = BiomedicalConceptCore::Datatype.new
    property = BiomedicalConceptCore::Property.new
    property.question_text = "Draft 123±±±"
    datatype.children[0] = property
    expect(datatype.valid?).to eq(false)
    expect(datatype.errors.full_messages[0]).to eq("Property, ordinal=1, error: Question text contains invalid characters")
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
        :iso21090_datatype => "PQR",
        :children => [],
        :type => "http://www.assero.co.uk/CDISCBiomedicalConcept#Node"
      }
    triples = {}
    triples ["N_1"] = []
    triples ["N_1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#N_1", predicate: "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", object: "http://www.assero.co.uk/CDISCBiomedicalConcept#Node" }
    triples ["N_1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#N_1", predicate: "http://www.w3.org/2000/01/rdf-schema#label", object: "Text Label" }
    triples ["N_1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#N_1", predicate: "http://www.assero.co.uk/CDISCBiomedicalConcept#alias", object: "XXXXX" }
    triples ["N_1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#N_1", predicate: "http://www.assero.co.uk/CDISCBiomedicalConcept#ordinal", object: "1" }
    triples ["N_1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#N_1", predicate: "http://www.assero.co.uk/CDISCBiomedicalConcept#iso21090_datatype", object: "PQR" }
    item = BiomedicalConceptCore::Datatype.new(triples, "N_1")
    expect(item.to_json).to eq(result)    
  end

  it "allows the object to be found"

  it "allows the object to be exported as JSON" do
    result = 
      {
        :id => "123", 
        :namespace => "http://www.example.com/path", 
        :extension_properties => [],
        :label => "Test",
        :alias => "alias",
        :ordinal => 1,
        :iso21090_datatype => "PQR",
        :children => [],
        :type => "http://www.example.com/path#rdf_test_type"
      }
    item = BiomedicalConceptCore::Datatype.new
    item.id = "123"
    item.namespace = "http://www.example.com/path"
    item.label = "Test"
    item.alias = "alias"
    item.ordinal = 1
    item.iso21090_datatype = "PQR"
    item.rdf_type = "http://www.example.com/path#rdf_test_type"
    expect(item.to_json).to eq(result)
  end

  it "allows the object to be created from JSON, simple" do
    result = 
      {
        :id => "123", 
        :namespace => "http://www.example.com/path", 
        :extension_properties => [],
        :label => "Test",
        :alias => "alias",
        :ordinal => 1,
        :iso21090_datatype => "CD",
        :children => [],
        :type => "http://www.example.com/path#rdf_test_type"
      }
    expect(BiomedicalConceptCore::Datatype.from_json(result).to_json).to eq(result)
  end

  it "allows the object to be created from JSON, complex" do
    result = 
    {
      :type =>"http://www.assero.co.uk/CDISCBiomedicalConcept#Datatype",
      :id =>"BCT-Obs_PQR_PerformedObservation_dateRange_IVL_TS_DATETIME_low_TS_DATETIME",
      :namespace=>"http://www.assero.co.uk/MDRBCTs/V1",
      :label=>"",
      :extension_properties=>[],
      :ordinal=>1,
      :alias=>"",
      :iso21090_datatype=>"",
      :children=>[
        {
          :type=>"http://www.assero.co.uk/CDISCBiomedicalConcept#Property",
          :id=>"BCT-Obs_PQR_PerformedObservation_dateRange_IVL_TS_DATETIME_low_TS_DATETIME_value",
          :namespace=>"http://www.assero.co.uk/MDRBCTs/V1",
          :label=>"",
          :extension_properties=>[],
          :ordinal=>1,
          :alias=>"Date Time (--DTC)",
          :collect=>false,
          :enabled=>false,
          :question_text=>"",
          :prompt_text=>"",
          :simple_datatype=>"dateTime",
          :format=>"",
          :bridg_path=>"PerformedObservation.dateRange.IVL_TS_DATETIME.low.TS_DATETIME.value",
          :children=>[]
        }
      ]
    }
    expect(BiomedicalConceptCore::Datatype.from_json(result).to_json).to eq(result)
  end

  it "allows an object to be exported as SPARQL, simple" do
    sparql = SparqlUpdateV2.new
    item = BiomedicalConceptCore::Datatype.new
    item.id = "123"
    item.namespace = "http://www.example.com/path"
    item.rdf_type = "http://www.example.com/path#rdf_test_type"
    item.label = "test label"
    item.alias = "Note"
    item.iso21090_datatype = "CD"
    parent_uri = UriV2.new({:id => "XXX", :namespace => "http://www.example.com/path"})
    item.to_sparql_v2(parent_uri, sparql)
    #write_text_file_2(sparql.to_s, sub_dir, "datatype_sparql_simple.txt")
    expected = read_text_file_2(sub_dir, "datatype_sparql_simple.txt")
    expect(sparql.to_s).to eq(expected)
  end
  
  it "allows an object to be exported as SPARQL, complex" do
    sparql = SparqlUpdateV2.new
    result = 
    {
      :type =>"http://www.assero.co.uk/CDISCBiomedicalConcept#Datatype",
      :id =>"BCT-Obs_PQR_PerformedObservation_dateRange_IVL_TS_DATETIME_low_TS_DATETIME",
      :namespace=>"http://www.assero.co.uk/MDRBCTs/V1",
      :label=>"",
      :extension_properties=>[],
      :ordinal=>1,
      :alias=>"",
      :iso21090_datatype=>"",
      :children=>[
        {
          :type=>"http://www.assero.co.uk/CDISCBiomedicalConcept#Property",
          :id=>"BCT-Obs_PQR_PerformedObservation_dateRange_IVL_TS_DATETIME_low_TS_DATETIME_value",
          :namespace=>"http://www.assero.co.uk/MDRBCTs/V1",
          :label=>"",
          :extension_properties=>[],
          :ordinal=>1,
          :alias=>"Date Time (--DTC)",
          :collect=>false,
          :enabled=>false,
          :question_text=>"",
          :prompt_text=>"",
          :simple_datatype=>"dateTime",
          :format=>"",
          :bridg_path=>"PerformedObservation.dateRange.IVL_TS_DATETIME.low.TS_DATETIME.value",
          :children=>[]
        }
      ]
    }
    item = BiomedicalConceptCore::Datatype.from_json(result)
    parent_uri = UriV2.new({:id => "XXX", :namespace => "http://www.example.com/path"})
    item.to_sparql_v2(parent_uri, sparql)
    #write_text_file_2(sparql.to_s, sub_dir, "datatype_sparql_complex.txt")
    expected = read_text_file_2(sub_dir, "datatype_sparql_complex.txt")
    expect(sparql.to_s).to eq(expected)
  end

end
  