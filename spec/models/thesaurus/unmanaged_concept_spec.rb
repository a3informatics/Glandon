require 'rails_helper'

describe Thesaurus::UnmanagedConcept do

  include DataHelpers
  include ValidationHelpers
  include SparqlHelpers
  include PublicFileHelpers
  
  def sub_dir
    return "models/thesaurus/unmanaged_concept"
  end

  before :all  do
    IsoHelpers.clear_cache
  end

  before :each do
    schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl", "thesaurus.ttl", "BusinessOperational.ttl"]
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_concept_new_1.ttl"]
    load_files(schema_files, data_files)
  end

  it "allows validity of the object to be checked - error" do
    tc = Thesaurus::UnmanagedConcept.new
    expect(tc.valid?).to eq(false)
    expect(tc.errors.count).to eq(2)
    expect(tc.errors.full_messages.to_sentence).to eq("Uri can't be blank and Identifier is empty")
  end 

  it "allows validity of the object to be checked" do
    tc = Thesaurus::UnmanagedConcept.new
    tc.uri = Uri.new(uri:"http://www.assero.co.uk/MDRThesaurus/ACME/V1#THC-A00001")
    tc.identifier = "AAA"
    tc.notation = "A"
    valid = tc.valid?
    expect(valid).to eq(true)
  end 

  it "allows a TC to be found" do
    tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
    expect(tc.identifier).to eq("A000011")    
  end

  it "allows a TC to be found - error" do
    expect{Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011x"))}.to raise_error(Errors::NotFoundError, 
      "Failed to find http://www.acme-pharma.com/A00001/V1#A00001_A000011x in Thesaurus::UnmanagedConcept.")  
  end

  it "allows the existance of a TC to be determined" do
    expect(Thesaurus::UnmanagedConcept.exists?("A000011")).to eq(true)
  end

  it "allows the existance of a TC to be determined - not there" do
    expect(Thesaurus::UnmanagedConcept.exists?("A000011x")).to eq(false)
  end

  it "finds by properties, single" do
  	results = Thesaurus::UnmanagedConcept.where({identifier: "A000011"})
  	expect(results.count).to eq(1)
	end

  it "finds by properties, multiple" do
  	results = Thesaurus::UnmanagedConcept.where({notation: "T1", label: "Terminal 1"})
  	expect(results.count).to eq(1)
	end

  it "allows a new child TC to be added" do
    params = 
    {
      uri: Uri.new(uri: "http://www.assero.co.uk/TC#OWNER-A00004"),
      definition: "Other or mixed race",
      identifier: "A00004",
      label: "New",
      notation: "NEWNEW"
    }
    tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
    new_object = tc.add_child(params)
    expect(new_object.errors.count).to eq(0)
    tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
	#Xwrite_yaml_file(tc.to_h, sub_dir, "add_child_expected_1.yaml")
		expected = read_yaml_file(sub_dir, "add_child_expected_1.yaml")
    expect(tc.to_h).to eq(expected)
    tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.assero.co.uk/TC#OWNER-A00004"))
  #Xwrite_yaml_file(tc.to_h, sub_dir, "add_child_expected_2.yaml")
    expected = read_yaml_file(sub_dir, "add_child_expected_2.yaml")
    expect(tc.to_h).to eq(expected)
  end

  it "prevents a duplicate TC being added" do
    params = 
    {
      uri: Uri.new(uri: "http://www.assero.co.uk/TC#OWNER-A00004"),
      definition: "Other or mixed race",
      identifier: "A00004",
      label: "New",
      notation: "NEWNEW"
    }
    tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
    new_object = tc.add_child(params)
    expect(new_object.errors.count).to eq(0)
    tc = Thesaurus::UnmanagedConcept.find_children(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
    new_object = tc.add_child(params)
    expect(new_object.errors.count).to eq(1)
    expect(new_object.errors.full_messages[0]).to eq("An existing record exisits in the database")
  end

  it "prevents a TC being added with invalid identifier" do
    params = 
    {
      uri: Uri.new(uri: "http://www.assero.co.uk/TC#OWNER-A00004"),
      definition: "Other or mixed race",
      identifier: "?",
      label: "New",
      notation: "NEWNEW"
    }
    tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
    new_object = tc.add_child(params)
    expect(new_object.errors.count).to eq(1)
    expect(new_object.errors.full_messages[0]).to eq("Identifier contains a part with invalid characters")
  end

  it "prevents a TC being added with invalid data" do
    params = 
    {
      uri: Uri.new(uri: "http://www.assero.co.uk/TC#OWNER-A00004"),
      definition: "Other or mixed race!@£$%^&*(){}",
      identifier: "?",
      label: "New",
      notation: "NEWNEW"
    }
    tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
    new_object = tc.add_child(params)
    expect(new_object.errors.count).to eq(2)
    expect(new_object.errors.full_messages.to_sentence).to eq("Identifier contains a part with invalid characters and Definition contains invalid characters")
  end

  it "allows a TC to be updated" do
    tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
    params = 
    {
      uri: Uri.new(uri: "http://www.assero.co.uk/TC#OWNER-A00004"),
      definition: "Other or mixed race",
      identifier: "A00004",
      label: "New",
      notation: "NEWNEW"
    }
    new_object = tc.add_child(params)
    new_object.label = "New_XXX"
    new_object.notation = "NEWNEWXXX"
    new_object.update
    tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.assero.co.uk/TC#OWNER-A00004"))
  #Xwrite_yaml_file(tc.to_h, sub_dir, "update_expected_1.yaml")
    expected = read_yaml_file(sub_dir, "update_expected_1.yaml")
    expect(tc.to_h).to eq(expected)
  end

  it "allows a TC to be updated, quotes test" do
    tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
    params = 
    {
      uri: Uri.new(uri: "http://www.assero.co.uk/TC#OWNER-A00004"),
      definition: "Other or mixed race",
      identifier: "A00004",
      label: "New",
      notation: "NEWNEW"
    }
    new_object = tc.add_child(params)
    new_object.label = "New \"XXX\""
    new_object.update
    tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.assero.co.uk/TC#OWNER-A00004"))
  write_yaml_file(tc.to_h, sub_dir, "update_expected_2.yaml")
    expected = read_yaml_file(sub_dir, "update_expected_2.yaml")
    expect(tc.to_h).to eq(expected)
  end
  
  it "allows a TC to be updated, character test" do
    tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
    params = 
    {
      uri: Uri.new(uri: "http://www.assero.co.uk/TC#OWNER-A00004"),
      definition: "Other or mixed race",
      identifier: "A00004",
      label: "New",
      notation: "NEWNEW"
    }
    new_object = tc.add_child(params)
    new_object.label = vh_all_chars
    new_object.notation = vh_all_chars + "^"
    new_object.definition = vh_all_chars
    new_object.update
    tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.assero.co.uk/TC#OWNER-A00004"))
  write_yaml_file(tc.to_h, sub_dir, "update_expected_3.yaml")
    expected = read_yaml_file(sub_dir, "update_expected_3.yaml")
    expect(tc.to_h).to eq(expected)
  end
  
  it "allows to determine if TCs different" do
    tc1 = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
    tc2 = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000012"))
    results = tc1.diff?(tc2)
    expect(results).to eq(true)
  end

  it "allows to determine if TCs same" do
    tc1 = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
    tc2 = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
    results = tc1.diff?(tc2)
    expect(results).to eq(false)
  end

  it "allows to determine if TCs different - notation" do
    tc1 = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
    tc1.notation = "Tx5"
    tc2 = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
    results = tc1.diff?(tc2)
    expect(results).to eq(true)
  end

  it "allows the object to be exported as Hash" do
    tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
  #Xwrite_yaml_file(tc.to_h, sub_dir, "to_hash_expected.yaml")    
    expected = read_yaml_file(sub_dir, "to_hash_expected.yaml")
    expect(tc.to_h).to eq(expected)
  end

  it "allows a TC to be created from Hash" do
    input = read_yaml_file(sub_dir, "from_hash_input.yaml")
    tc = Thesaurus::UnmanagedConcept.from_h(input)
  #Xwrite_yaml_file(tc.to_h, sub_dir, "from_hash_expected.yaml")    
    expected = read_yaml_file(sub_dir, "from_hash_expected.yaml")
    expect(tc.to_h).to eq(expected)
  end

  it "allows a TC to be exported as SPARQL" do
    ra = IsoRegistrationAuthority.find_children(Uri.new(uri: "http://www.assero.co.uk/RA#DUNS123456789"))
    sparql = Sparql::Update.new
    th = Thesaurus.new
    #th.uri = Uri.new(uri: "http://www.assero.co.uk/TH#OWNER-TH")
    tc_1 = Thesaurus::UnmanagedConcept.from_h({
        uri: "http://www.assero.co.uk/TC#OWNER-A00022", 
        label: "Axe",
        identifier: "A00022",
        defintion: "A definiton",
        notation: "AXE",
        preferred_term: Uri.new(uri: "http://www.assero.co.uk/PT#1")
      })
    tc_2 = Thesaurus::UnmanagedConcept.new
    tc_2.uri = Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001_A000011")
    tc_2.identifier = "A000011"
    tc_2.definition = "The definition."
    tc_2.extensible = false
    tc_2.notation = "NOTATION1"
    tc_2.synonym << Thesaurus::Synonym.where_only_or_create("synonym 1")
    tc_2.synonym << Thesaurus::Synonym.where_only_or_create("synonym 2")
    tc_2.preferred_term = Thesaurus::PreferredTerm.where_only_or_create("Preferred Term 1")
    th.is_top_concept_reference << OperationalReferenceV3::TcReference.from_h({reference: tc_1.uri, local_label: "", enabled: true, ordinal: 1, optional: true})
    th.is_top_concept_reference << OperationalReferenceV3::TcReference.from_h({reference: tc_2.uri, local_label: "", enabled: true, ordinal: 2, optional: true})
    th.set_initial("NEW_TH", ra)
    sparql.default_namespace(th.uri.namespace)
    th.to_sparql(sparql, true)
    tc_1.to_sparql(sparql, true)
    tc_2.to_sparql(sparql, true)
    full_path = sparql.to_file
  #Xcopy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "unmanaged_concept.ttl")
  #Xwrite_yaml_file(tc.to_h, sub_dir, "from_hash_input.yaml")    
    #check_sparql_no_file(sparql.to_create_sparql, "to_sparql_expected.txt")  
  end
  
  it "allows a TC to be exported as SPARQL" do
    tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
    sparql = Sparql::Update.new
    tc.to_sparql(sparql, true)
  #Xwrite_text_file_2(sparql.to_create_sparql, sub_dir, "to_sparql_expected.txt")
    check_sparql_no_file(sparql.to_create_sparql, "to_sparql_expected.txt") 
  end
  
  it "allows a TC to be destroyed" do
    tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
    expect(Thesaurus::UnmanagedConcept.exists?("A000011")).to eq(true)
    result = tc.delete
    expect(result).to eq(1)
    expect{Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))}.to raise_error(Errors::NotFoundError, 
      "Failed to find http://www.acme-pharma.com/A00001/V1#A00001_A000011 in Thesaurus::UnmanagedConcept.")  
  end

  it "does not allow a TC to be destroyed if it has children" do
    tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
    params = 
    {
      uri: Uri.new(uri: "http://www.assero.co.uk/TC#OWNER-A00004"),
      definition: "Other or mixed race",
      identifier: "A00004",
      label: "New",
      notation: "NEWNEW"
    }
    new_object = tc.add_child(params)
    tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
    result = tc.delete
    expect(result).to eq(0)
    expect(tc.errors.count).to eq(1)
    expect(tc.errors.full_messages[0]).to eq("Cannot delete terminology concept with identifier A000011 due to the concept having children")
  end

  it "generates a CSV record with no header" do
    tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
    expected = 
    [ 
      "A00001", "Vital Sign Test Codes Extension", 
      "VSTEST", "", "A set of additional Vital Sign Test Codes to extend the CDISC set.", ""
    ]
    expect(tc.to_csv_no_header).to eq(expected)
  end

  it "returns the parent concept" do
    tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
    params = 
    {
      uri: Uri.new(uri: "http://www.assero.co.uk/TC#OWNER-A00004"),
      definition: "Other or mixed race",
      identifier: "A00004",
      label: "New",
      notation: "NEWNEW"
    }
    new_object = tc.add_child(params)
    tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.assero.co.uk/TC#OWNER-A00004"))
    expect(tc.parent).to eq("A000011")
  end

  it "returns the parent concept, none" do
    params = 
    {
      uri: Uri.new(uri: "http://www.assero.co.uk/TC#OWNER-A00004"),
      definition: "Other or mixed race",
      identifier: "A00004",
      label: "New",
      notation: "NEWNEW"
    }
    tc = Thesaurus::UnmanagedConcept.create(params)
    expect{tc.parent}.to raise_error(Errors::ApplicationLogicError, "Failed to find parent for A00004.")
  end

end