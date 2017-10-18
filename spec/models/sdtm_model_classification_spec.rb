require 'rails_helper'

describe SdtmModelClassification do
	
  include DataHelpers

  def sub_dir
    return "models"
  end

  before :all do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Basic.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Data.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_test_file_into_triple_store("sdtm_model_and_ig.ttl")
  end

  it "allows a new item to be created" do
    expected = 
    {
      :type => "http://www.assero.co.uk/BusinessDomain#VariableClassification", 
      :id => "", 
      :namespace => "", 
      :label => "", 
      :extension_properties => []
    }
    result = SdtmModelClassification.new
    expect(result.to_json).to eq(expected)
  end

  it "allows the object to be validated"

  it "allows the object to be created from JSON" do
    json = 
    {
      :type => "http://www.assero.co.uk/BusinessDomain#VariableClassification", 
      :id => "X", 
      :namespace => "http://www.example.com", 
      :label => "My Label", 
      :extension_properties => []
    }
    result = SdtmModelClassification.from_json(json)
    expect(result.to_json).to eq(json)
  end

  it "allows the object to be exported as JSON" do
    expected = 
    {
      :type => "http://www.assero.co.uk/BusinessDomain#VariableClassification", 
      :id => "", 
      :namespace => "", 
      :label => "NEW LABEL", 
      :extension_properties => []
    }
    result = SdtmModelClassification.new
    result.label = "NEW LABEL"
    expect(result.to_json).to eq(expected)
  end

  it "allows all leaf labels to be returned" do
    results = SdtmModelClassification.all_leaf("http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
    #write_yaml_file(results, sub_dir, "sdtm_model_classification_all_leaf.yaml")
    expected = read_yaml_file(sub_dir, "sdtm_model_classification_all_leaf.yaml")
    results.each do |result|
      found = expected.find { |x| x.id == result.id }
      expect(result.id).to eq(found.id)
    end
  end

  it "allows all parent labels to be returned" do
    results = SdtmModelClassification.all_parent("http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
    #write_yaml_file(results, sub_dir, "sdtm_model_classification_all_parent.yaml")
    expected = read_yaml_file(sub_dir, "sdtm_model_classification_all_parent.yaml")
    results.each do |result|
      found = expected.find { |x| x.id == result.id }
      expect(result.id).to eq(found.id)
    end
  end

  it "allows all child labels to be returned" do
    result = SdtmModelClassification.all_children("M-CDISC_SDTMMODEL_C_QUALIFIER", "http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
    json = []
    result.each {|tc| json << tc.to_json}
    #write_yaml_file(json, sub_dir, "sdtm_model_classification_all_child.yaml")
    expected = read_yaml_file(sub_dir, "sdtm_model_classification_all_child.yaml")
    expect(json).to eq(expected)
  end

  it "allows default parent label to be returned" do
    expected = 
    {
      :type => "http://www.assero.co.uk/BusinessDomain#VariableClassification", 
      :id => "M-CDISC_SDTMMODEL_C_QUALIFIER", 
      :namespace => "http://www.assero.co.uk/MDRSdtmM/CDISC/V3", 
      :label => "Qualifier", 
      :extension_properties => []
    }
    result = SdtmModelClassification.all_parent("http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
    default = SdtmModelClassification.default_parent(result)
    expect(default.to_json).to eq(expected)
  end

  it "allows default child label to be returned" do
    expected = 
    {
      :type => "http://www.assero.co.uk/BusinessDomain#VariableClassification", 
      :id => "M-CDISC_SDTMMODEL_SC_RECORDQUALIFIER", 
      :namespace => "http://www.assero.co.uk/MDRSdtmM/CDISC/V3", 
      :label => "Record Qualifier", 
      :extension_properties => []
    }
    result = SdtmModelClassification.all_children("M-CDISC_SDTMMODEL_C_QUALIFIER", "http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
    default = SdtmModelClassification.default_child(result)
    expect(default.to_json).to eq(expected)
  end

  it "allows addition of parent" do
  	parent_uri = UriV2.new(id: "MODEL", namespace: "http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
  	parent_classification_uri = UriV2.new(id: "MODEL_C_PARENT", namespace: "http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
		child_1_classification_uri = UriV2.new(id: "MODEL_SC_CHILD1", namespace: "http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
  	child_2_classification_uri = UriV2.new(id: "MODEL_SC_CHILD2", namespace: "http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
    item = SdtmModelClassification.new
    item.label = "CLASSIFICATION"
		item.set_parent
    expect(item.parent).to eq(true)
  end

  it "allows addition of children" do
  	parent_uri = UriV2.new(id: "MODEL", namespace: "http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
		child_1_classification = SdtmModelClassification.new
  	child_2_classification = SdtmModelClassification.new
  	child_3_classification = SdtmModelClassification.new
		child_1_classification.id = "1"
		child_2_classification.id = "2"
		child_3_classification.id = "3"
    item = SdtmModelClassification.new
    item.label = "CLASSIFICATION"
    expect(item.children.count).to eq(0)
		item.add_child(child_1_classification)
    expect(item.children.count).to eq(1)
    expect(item.children[0].id).to eq("1")
		item.add_child(child_2_classification)
    expect(item.children.count).to eq(2)
    expect(item.children[0].id).to eq("1")
    expect(item.children[1].id).to eq("2")
		item.add_child(child_3_classification)
    expect(item.children.count).to eq(3)
    expect(item.children[0].id).to eq("1")
    expect(item.children[1].id).to eq("2")
    expect(item.children[2].id).to eq("3")
  end

  it "allows object to be output as SPARQL, parent and no children" do
  	sparql = SparqlUpdateV2.new
  	parent_uri = UriV2.new(id: "MODEL", namespace: "http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
    item = SdtmModelClassification.new
    item.label = "CLASSIFICATION"
    item.set_parent
    result = item.to_sparql_v2(parent_uri, sparql)
  #write_text_file_2(sparql.to_s, sub_dir, "sdtm_model_classification_sparql.txt")
    expected = read_text_file_2(sub_dir, "sdtm_model_classification_sparql.txt")
    expect(sparql.to_s).to eq(expected)
  end

  it "allows object to be output as SPARQL, child" do
  	sparql = SparqlUpdateV2.new
  	parent_uri = UriV2.new(id: "MODEL", namespace: "http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
    item = SdtmModelClassification.new
    item.label = "CLASSIFICATION"
    result = item.to_sparql_v2(parent_uri, sparql)
  #write_text_file_2(sparql.to_s, sub_dir, "sdtm_model_classification_child_sparql.txt")
    expected = read_text_file_2(sub_dir, "sdtm_model_classification_child_sparql.txt")
    expect(sparql.to_s).to eq(expected)
  end

  it "allows object to be output as SPARQL, parent" do
  	sparql = SparqlUpdateV2.new
  	parent_uri = UriV2.new(id: "MODEL", namespace: "http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
  	child_1_classification = SdtmModelClassification.new
  	child_2_classification = SdtmModelClassification.new
  	child_1_classification.label = "Child 1"
		child_2_classification.label = "Child 2"
		item = SdtmModelClassification.new
    item.label = "CLASSIFICATION"
    item.set_parent
    item.add_child(child_1_classification)
		item.add_child(child_2_classification)
    result = item.to_sparql_v2(parent_uri, sparql)
  write_text_file_2(sparql.to_s, sub_dir, "sdtm_model_classification_parent_sparql.txt")
    expected = read_text_file_2(sub_dir, "sdtm_model_classification_parent_sparql.txt")
    expect(sparql.to_s).to eq(expected)
  end

end