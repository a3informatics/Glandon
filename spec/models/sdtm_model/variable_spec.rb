require 'rails_helper'

describe SdtmModel::Variable do

  include DataHelpers

  def sub_dir
    return "models/sdtm_model"
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
    load_schema_file_into_triple_store("BusinessDomain.ttl")
    load_test_file_into_triple_store("sdtm_model_and_ig.ttl")
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
  end

  it "validates a valid object" do
    item = SdtmModel::Variable.new
    item.ordinal = 1
    result = item.valid?
    expect(item.errors.full_messages.to_sentence).to eq("")
    expect(result).to eq(true)
  end

  it "does not validate an invalid object, name" do
    item = SdtmModel::Variable.new
    result = item.valid?
    expect(item.errors.full_messages.to_sentence).to eq("Ordinal contains an invalid positive integer value")
    expect(result).to eq(false)
  end

  it "returns the classification label" do
    variable = SdtmModel::Variable.find("M-CDISC_SDTMMODEL_xxTPTREF", "http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
    expect(variable.classification_label).to eq("Timing")
  end

  it "returns blank classification label if none present" do
    variable = SdtmModel::Variable.find("M-CDISC_SDTMMODEL_xxTPTREF", "http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
    variable.classification = nil
    expect(variable.classification_label).to eq("")
  end

  it "sub_classification_label" do
    variable = SdtmModel::Variable.find("M-CDISC_SDTMMODEL_xxTPTREF", "http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
    expect(variable.sub_classification_label).to eq("")
  end

  it "returns blank sub classification label if none present" do
    variable = SdtmModel::Variable.find("M-CDISC_SDTMMODEL_xxTPTREF", "http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
    variable.sub_classification = nil
    expect(variable.sub_classification_label).to eq("")
  end

  it "datatype_label" do
    variable = SdtmModel::Variable.find("M-CDISC_SDTMMODEL_xxTPTREF", "http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
    expect(variable.datatype_label).to eq("Char")
  end

  it "returns blank datatype label if none present" do
    variable = SdtmModel::Variable.find("M-CDISC_SDTMMODEL_xxTPTREF", "http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
    variable.datatype = nil
    expect(variable.datatype_label).to eq("")
  end

  it "allows object to be initialized from triples" do
    result = 
    {
      :extension_properties => [],
      :id => "M-CDISC_SDTMMODEL_xxTPTREF",
      :namespace => "http://www.assero.co.uk/MDRSdtmM/CDISC/V3",
      :type => "http://www.assero.co.uk/BusinessDomain#ModelVariable",
      :label => "Time Point Reference",
      :name => "--TPTREF",
      :description => "Description of the fixed reference point referred to by --ELTM, --TPTNUM, and --TPT. Examples: PREVIOUS DOSE, PREVIOUS MEAL.",
      :ordinal => 27,
      :prefixed => true,
      :rule => "",
      :classification => { :type=>"", :id=>"", :namespace=>"", :label=>"", :extension_properties=>[] },
      :datatype => { :type=>"http://www.assero.co.uk/BusinessDomain#VariableType", :id=>"", :namespace=>"", :label=>"", :extension_properties=>[] },
      :sub_classification => {:type=>"", :id=>"", :namespace=>"", :label=>"", :extension_properties=>[]},
    }
    triples = read_yaml_file(sub_dir, "variable_triples.yaml")
    expect(SdtmModel::Variable.new(triples, "M-CDISC_SDTMMODEL_xxTPTREF").to_json).to eq(result) 
  end 

  it "allows an object to be found" do
    variable = SdtmModel::Variable.find("M-CDISC_SDTMMODEL_xxTPTREF", "http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
  #write_yaml_file(variable.triples, sub_dir, "variable_triples.yaml")
  #write_yaml_file(variable.to_json, sub_dir, "variable.yaml")
    expected = read_yaml_file(sub_dir, "variable.yaml")
    expect(variable.to_json).to eq(expected)
  end

  it "allows an object to be exported as JSON" do
    variable = SdtmModel::Variable.find("M-CDISC_SDTMMODEL_xxTPTREF", "http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
  #write_yaml_file(variable.to_json, sub_dir, "variable_to_json.yaml")
    expected = read_yaml_file(sub_dir, "variable_to_json.yaml")
    expect(variable.to_json).to eq(expected)
  end

  it "allows the object to be created from JSON" do
  	json = read_yaml_file(sub_dir, "variable.yaml")
    item = SdtmModel::Variable.from_json(json)
    expected = read_yaml_file(sub_dir, "variable_to_json.yaml")
    expect(item.to_json).to eq(expected)
  end

  it "allows the object to be output as sparql" do
  	parent_uri = UriV2.new(id: "M-CDISC_SDTMMODEL", namespace: "http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
  	sparql = SparqlUpdateV2.new
  	json = read_yaml_file(sub_dir, "variable.yaml")
    item = SdtmModel::Variable.from_json(json)
    result = item.to_sparql_v2(parent_uri, sparql)
  #write_text_file_2(sparql.to_s, sub_dir, "variable_to_sparql.txt")
    expected = read_text_file_2(sub_dir, "variable_to_sparql.txt")
    expect(sparql.to_s).to eq(expected)
    expect(result.to_s).to eq("http://www.assero.co.uk/MDRSdtmM/CDISC/V3#M-CDISC_SDTMMODEL_xxTPTREF")
  end

  it "allows the datatype reference to be updated" do
  	variable = SdtmModel::Variable.find("M-CDISC_SDTMMODEL_xxTPTREF", "http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
  	datatype_1 = SdtmModelDatatype.new
  	datatype_1.id = "CHAR_NEW"
  	datatype_1.label = "Char"
  	datatype_2 = SdtmModelDatatype.new
  	datatype_2.id = "NUM_NEW"
  	datatype_2.label = "Num"
  	datatypes = {}
  	datatypes["Char"] = datatype_1
  	datatypes["Num"] = datatype_2
  	variable.update_datatype(datatypes)
  	expect(variable.datatype.id).to eq("CHAR_NEW")
  end

  it "allows the classification reference to be updated" do
  	variable = SdtmModel::Variable.find("M-CDISC_SDTMMODEL_xxTPTREF", "http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
  	classification_1 = SdtmModelClassification.new
  	classification_1.id = "CLASS_1"
  	classification_1.label = "Char"
  	classification_2 = SdtmModelClassification.new
  	classification_2.id = "CLASS_2"
  	classification_2.label = "Timing"
  	classification_3 = SdtmModelClassification.new
  	classification_3.id = "CLASS_3"
  	classification_3.label = "Qualifier"
  	classification_4 = SdtmModelClassification.new
  	classification_4.id = "CLASS_4"
  	classification_4.label = "Record Qualifier"
  	classifications = {}
  	classifications["Char"] = classification_1
  	classifications["Timing"] = classification_2
  	classifications["Qualifier"] = classification_3
  	classifications["Record Qualifier"] = classification_4
  	variable.update_classification(classifications)
  	expect(variable.classification.id).to eq("CLASS_2")
  	variable = SdtmModel::Variable.find("M-CDISC_SDTMMODEL_xxMETHOD", "http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
  	variable.update_classification(classifications)
  	expect(variable.classification.id).to eq("CLASS_3")
  	expect(variable.sub_classification.id).to eq("CLASS_4")
  end

end
  