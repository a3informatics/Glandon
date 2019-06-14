require 'rails_helper'

describe Thesaurus::ManagedConcept do

  include DataHelpers
  include ValidationHelpers
  include SparqlHelpers
  include PublicFileHelpers
  
  def sub_dir
    return "models/thesaurus/managed_concept"
  end

  def simple_thesaurus_1
    @ra = IsoRegistrationAuthority.find_children(Uri.new(uri: "http://www.assero.co.uk/RA#DUNS123456789"))
    @th_1 = Thesaurus.new
    @tc_1 = Thesaurus::ManagedConcept.from_h({
        label: "London Heathrow",
        identifier: "A00001",
        definition: "A definition",
        notation: "LHR"
      })
    @tc_1.synonym << Thesaurus::Synonym.where_only_or_create("Heathrow")
    @tc_1.synonym << Thesaurus::Synonym.where_only_or_create("LHR")
    @tc_1.preferred_term = Thesaurus::PreferredTerm.where_only_or_create("London Heathrow")
    @tc_1a = Thesaurus::UnmanagedConcept.from_h({
        label: "Terminal 5",
        identifier: "A000011",
        definition: "The 5th LHR Terminal",
        notation: "T5"
      })
    @tc_1a.synonym << Thesaurus::Synonym.where_only_or_create("T5")
    @tc_1a.synonym << Thesaurus::Synonym.where_only_or_create("Terminal Five")
    @tc_1a.synonym << Thesaurus::Synonym.where_only_or_create("BA Terminal")
    @tc_1a.synonym << Thesaurus::Synonym.where_only_or_create("British Airways Terminal")
    @tc_1a.preferred_term = Thesaurus::PreferredTerm.where_only_or_create("Terminal 5")
    @tc_1b = Thesaurus::UnmanagedConcept.from_h({
        label: "Terminal 1",
        identifier: "A000012",
        definition: "The oldest LHR Terminal",
        notation: "T1"
      })
    @tc_1b.preferred_term = Thesaurus::PreferredTerm.where_only_or_create("Terminal 1")
    @tc_1.narrower << @tc_1a
    @tc_1.narrower << @tc_1b
    @tc_2 = Thesaurus::ManagedConcept.new
    @tc_2.identifier = "A00002"
    @tc_2.definition = "Copenhagen"
    @tc_2.extensible = false
    @tc_2.notation = "CPH"
    @th_1.is_top_concept_reference << OperationalReferenceV3::TcReference.from_h({reference: @tc_1.uri, local_label: "", enabled: true, ordinal: 1, optional: true})
    @th_1.is_top_concept_reference << OperationalReferenceV3::TcReference.from_h({reference: @tc_2.uri, local_label: "", enabled: true, ordinal: 2, optional: true})
  end

  def simple_thesaurus_2
    @th_2 = Thesaurus.new
    @tc_3 = Thesaurus::ManagedConcept.from_h(@tc_1.to_h)
    @tc_3.synonym << Thesaurus::Synonym.where_only_or_create("Heathrow")
    @tc_3.synonym << Thesaurus::Synonym.where_only_or_create("LHR")
    @tc_3.preferred_term = Thesaurus::PreferredTerm.where_only_or_create("London Heathrow")
    @tc_3a = Thesaurus::UnmanagedConcept.from_h(@tc_1a.to_h)
    @tc_3a.synonym << Thesaurus::Synonym.where_only_or_create("T5")
    @tc_3a.synonym << Thesaurus::Synonym.where_only_or_create("Terminal Five")
    @tc_3a.synonym << Thesaurus::Synonym.where_only_or_create("BA Terminal")
    @tc_3a.synonym << Thesaurus::Synonym.where_only_or_create("British Airways Terminal")
    @tc_3a.preferred_term = Thesaurus::PreferredTerm.where_only_or_create("Terminal 5")
    params = @tc_1b.to_h
    params[:definition] = "The oldest LHR Terminal. A real mess",
    @tc_3b = Thesaurus::UnmanagedConcept.from_h(params)
    @tc_3b.preferred_term = Thesaurus::PreferredTerm.where_only_or_create("Terminal 1")
    @tc_3.narrower << @tc_3a
    @tc_3.narrower << @tc_3b
    @tc_4 = Thesaurus::ManagedConcept.from_h(@tc_2.to_h)
    @th_2.is_top_concept_reference << OperationalReferenceV3::TcReference.from_h({reference: @tc_3.uri, local_label: "", enabled: true, ordinal: 1, optional: true})
    @th_2.is_top_concept_reference << OperationalReferenceV3::TcReference.from_h({reference: @tc_4.uri, local_label: "", enabled: true, ordinal: 2, optional: true})
  end

  def simple_thesaurus_3
    @th_3 = Thesaurus.new
    @tc_5 = Thesaurus::ManagedConcept.from_h(@tc_1.to_h)
    @tc_5.synonym << Thesaurus::Synonym.where_only_or_create("Heathrow")
    @tc_5.synonym << Thesaurus::Synonym.where_only_or_create("LHR")
    @tc_5.preferred_term = Thesaurus::PreferredTerm.where_only_or_create("London Heathrow")
    @tc_5c = Thesaurus::UnmanagedConcept.from_h({
        label: "Terminal X",
        identifier: "A000014",
        definition: "The new new LHR Terminal. Never going to happen",
        notation: "TX"
      })
    @tc_5c.preferred_term = Thesaurus::PreferredTerm.where_only_or_create("Terminal X")
    @tc_5a = Thesaurus::UnmanagedConcept.from_h(@tc_1a.to_h)
    @tc_5a.synonym << Thesaurus::Synonym.where_only_or_create("T5")
    @tc_5a.synonym << Thesaurus::Synonym.where_only_or_create("Terminal Five")
    @tc_5a.synonym << Thesaurus::Synonym.where_only_or_create("BA Terminal")
    @tc_5a.synonym << Thesaurus::Synonym.where_only_or_create("British Airways Terminal")
    @tc_5a.preferred_term = Thesaurus::PreferredTerm.where_only_or_create("Terminal 5")
    @tc_5b = Thesaurus::UnmanagedConcept.from_h(@tc_1b.to_h)
    @tc_5b.preferred_term = Thesaurus::PreferredTerm.where_only_or_create("Terminal 1")
    @tc_5.narrower << @tc_5a
    @tc_5.narrower << @tc_5b
    @tc_5.narrower << @tc_5c
    @tc_6 = Thesaurus::ManagedConcept.from_h(@tc_2.to_h)
    @th_3.is_top_concept_reference << OperationalReferenceV3::TcReference.from_h({reference: @tc_5.uri, local_label: "", enabled: true, ordinal: 1, optional: true})
    @th_3.is_top_concept_reference << OperationalReferenceV3::TcReference.from_h({reference: @tc_6.uri, local_label: "", enabled: true, ordinal: 2, optional: true})
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
    tc = Thesaurus::ManagedConcept.new
    expect(tc.valid?).to eq(false)
    expect(tc.errors.count).to eq(2)
    expect(tc.errors.full_messages.to_sentence).to eq("Uri can't be blank and Identifier is empty")
  end 

  it "allows validity of the object to be checked" do
    tc = Thesaurus::ManagedConcept.new
    tc.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
    tc.identifier = "AAA"
    tc.notation = "A"
    valid = tc.valid?
    expect(valid).to eq(true)
  end 

  it "allows a TC to be found" do
    tc = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
    expect(tc.identifier).to eq("A00001")    
  end

  it "allows a TC to be found - error" do
    expect{Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001x"))}.to raise_error(Errors::NotFoundError, 
      "Failed to find http://www.acme-pharma.com/A00001/V1#A00001x in Thesaurus::ManagedConcept.")  
  end

  it "allows the existance of a TC to be determined" do
    expect(Thesaurus::ManagedConcept.exists?("A00001")).to eq(true)
  end

  it "allows the existance of a TC to be determined - not there" do
    expect(Thesaurus::ManagedConcept.exists?("A00001x")).to eq(false)
  end

  it "finds by properties, single" do
  	results = Thesaurus::ManagedConcept.where({identifier: "A00001"})
  	expect(results.count).to eq(1)
	end

  it "finds by properties, multiple" do
  	results = Thesaurus::ManagedConcept.where({notation: "LHR", label: "London Heathrow"})
  	expect(results.count).to eq(1)
	end

  it "allows a new child TC to be added" do
    params = 
    {
      uri: Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001-A00014"),
      definition: "The Queen's Terminal, the second terminal at Heathrow",
      identifier: "A00014",
      label: "Terminal 2",
      notation: "T2"
    }
    tc = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
    new_object = tc.add_child(params)
    expect(new_object.errors.count).to eq(0)
    tc = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
	#Xwrite_yaml_file(tc.to_h, sub_dir, "add_child_expected_1.yaml")
		expected = read_yaml_file(sub_dir, "add_child_expected_1.yaml")
    expect(tc.to_h).to eq(expected)
    tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001-A00014"))
  #Xwrite_yaml_file(tc.to_h, sub_dir, "add_child_expected_2.yaml")
    expected = read_yaml_file(sub_dir, "add_child_expected_2.yaml")
    expect(tc.to_h).to eq(expected)
  end

  it "prevents a duplicate TC being added" do
    params = 
    {
      uri: Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001-A00014"),
      definition: "Other or mixed race",
      identifier: "A00014",
      label: "New",
      notation: "NEWNEW"
    }
    tc = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
    new_object = tc.add_child(params)
    expect(new_object.errors.count).to eq(0)
    tc = Thesaurus::ManagedConcept.find_children(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
    new_object = tc.add_child(params)
    expect(new_object.errors.count).to eq(1)
    expect(new_object.errors.full_messages[0]).to eq("An existing record exisits in the database")
  end

  it "prevents a TC being added with invalid identifier" do
    params = 
    {
      uri: Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001-A00014"),
      definition: "Other or mixed race",
      identifier: "?",
      label: "New",
      notation: "NEWNEW"
    }
    tc = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
    new_object = tc.add_child(params)
    expect(new_object.errors.count).to eq(1)
    expect(new_object.errors.full_messages[0]).to eq("Identifier contains a part with invalid characters")
  end

  it "prevents a TC being added with invalid data" do
    params = 
    {
      uri: Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001-A00014"),
      definition: "Other or mixed race!@£$%^&*(){}",
      identifier: "?",
      label: "New",
      notation: "NEWNEW"
    }
    tc = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
    new_object = tc.add_child(params)
    expect(new_object.errors.count).to eq(2)
    expect(new_object.errors.full_messages.to_sentence).to eq("Identifier contains a part with invalid characters and Definition contains invalid characters")
  end

  it "allows a TC to be updated" do
    tc = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
    params = 
    {
      uri: Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001-A00014"),
      definition: "Other or mixed race",
      identifier: "A00014",
      label: "New",
      notation: "NEWNEW"
    }
    new_object = tc.add_child(params)
    new_object.label = "New_XXX"
    new_object.notation = "NEWNEWXXX"
    new_object.update
    tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001-A00014"))
  #Xwrite_yaml_file(tc.to_h, sub_dir, "update_expected_1.yaml")
    expected = read_yaml_file(sub_dir, "update_expected_1.yaml")
    expect(tc.to_h).to eq(expected)
  end

  it "allows a TC to be updated, quotes test" do
    tc = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
    params = 
    {
      uri: Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001-A00014"),
      definition: "Other or mixed race",
      identifier: "A00014",
      label: "New",
      notation: "NEWNEW"
    }
    new_object = tc.add_child(params)
    new_object.label = "New \"XXX\""
    new_object.update
    tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001-A00014"))
  #Xwrite_yaml_file(tc.to_h, sub_dir, "update_expected_2.yaml")
    expected = read_yaml_file(sub_dir, "update_expected_2.yaml")
    expect(tc.to_h).to eq(expected)
  end
  
  it "allows a TC to be updated, character test" do
    tc = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
    params = 
    {
      uri: Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001-A00014"),
      definition: "Other or mixed race",
      identifier: "A00014",
      label: "New",
      notation: "NEWNEW"
    }
    new_object = tc.add_child(params)
    new_object.label = vh_all_chars
    new_object.notation = vh_all_chars + "^"
    new_object.definition = vh_all_chars
    new_object.update
    tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001-A00014"))
  #Xwrite_yaml_file(tc.to_h, sub_dir, "update_expected_3.yaml")
    expected = read_yaml_file(sub_dir, "update_expected_3.yaml")
    expect(tc.to_h).to eq(expected)
  end
  
  it "allows to determine if TCs different" do
    tc1 = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
    tc2 = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00002/V1#A00002"))
    results = tc1.diff?(tc2)
    expect(results).to eq(true)
  end

  it "allows to determine if TCs same" do
    tc1 = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
    tc2 = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
    results = tc1.diff?(tc2)
    expect(results).to eq(false)
  end

  it "allows to determine if TCs different - notation" do
    tc1 = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
    tc1.notation = "MODIFIED"
    tc2 = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
    results = tc1.diff?(tc2)
    expect(results).to eq(true)
  end

  it "allows the object to be exported as Hash" do
    tc = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
  #Xwrite_yaml_file(tc.to_h, sub_dir, "to_hash_expected.yaml")    
    expected = read_yaml_file(sub_dir, "to_hash_expected.yaml")
    expect(tc.to_h).to eq(expected)
  end

  it "allows a TC to be created from Hash" do
  #Xtc = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
  #Xwrite_yaml_file(tc.to_h, sub_dir, "from_hash_input.yaml")    
    input = read_yaml_file(sub_dir, "from_hash_input.yaml")
    tc = Thesaurus::ManagedConcept.from_h(input)
  #Xwrite_yaml_file(tc.to_h, sub_dir, "from_hash_expected.yaml")    
    expected = read_yaml_file(sub_dir, "from_hash_expected.yaml")
    expect(tc.to_h).to eq(expected)
  end

  it "allows a TC to be exported as SPARQL" do
    sparql = Sparql::Update.new
    simple_thesaurus_1
    @th.set_initial("NEW_TH", ra)
    @tc_1.set_initial(@tc_1.identifier, @ra)
    @tc_2.set_initial(@tc_2.identifier, @ra)
    sparql.default_namespace(th.uri.namespace)
    @th.to_sparql(sparql, true)
    @tc_1.to_sparql(sparql, true)
    @tc_2.to_sparql(sparql, true)
    full_path = sparql.to_file
  #Xcopy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "managed_concept.ttl")
  end
  
  it "allows a TC to be exported as SPARQL, I" do
    tc = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
    sparql = Sparql::Update.new
    tc.to_sparql(sparql, true)
  #Xwrite_text_file_2(sparql.to_create_sparql, sub_dir, "to_sparql_expected_1.txt")
    check_sparql_no_file(sparql.to_create_sparql, "to_sparql_expected_1.txt") 
  end

  it "allows a TC to be exported as SPARQL, II" do
    sparql = Sparql::Update.new
    simple_thesaurus_1
    @tc_1.set_initial(@tc_1.identifier, @ra)
    sparql.default_namespace(@tc_1.uri.namespace)
    @tc_1.to_sparql(sparql, true)
  #Xwrite_text_file_2(sparql.to_create_sparql, sub_dir, "to_sparql_expected_2.txt")
    check_sparql_no_file(sparql.to_create_sparql, "to_sparql_expected_2.txt") 
  end
  
  it "allows a TC to be destroyed" do
    tc = Thesaurus::ManagedConcept.create({uri: Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001"), identifier: "AAA", notation: "A"})
    tc = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001"))
    result = tc.delete
    expect(result).to eq(1)
    expect{Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001"))}.to raise_error(Errors::NotFoundError, 
      "Failed to find http://www.acme-pharma.com/A00001/V3#A00001 in Thesaurus::ManagedConcept.")  
  end

  it "does not allow a TC to be destroyed if it has children" do
    tc = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
    result = tc.delete
    expect(result).to eq(0)
    expect(tc.errors.count).to eq(1)
    expect(tc.errors.full_messages[0]).to eq("Cannot delete terminology concept with identifier A00001 due to the concept having children")
  end

  it "generates a CSV record with no header" do
    tc = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
    expected = 
    [ 
      "A00001", "Vital Sign Test Codes Extension", 
      "VSTEST", "", "A set of additional Vital Sign Test Codes to extend the CDISC set.", ""
    ]
    expect(tc.to_csv_no_header).to eq(expected)
  end

  it "returns the parent concept" do
    tc = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
    params = 
    {
      uri: Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001-A00014"),
      definition: "Other or mixed race",
      identifier: "A00014",
      label: "New",
      notation: "NEWNEW"
    }
    new_object = tc.add_child(params)
    tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001-A00014"))
    expect(tc.parent).to eq("A00001")
  end

  it "returns the parent concept, none" do
    tc = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
    expect{tc.parent}.to raise_error(Errors::ApplicationLogicError, "Failed to find parent for A00001.")
  end

  it "replaces with previous if no difference" do
    simple_thesaurus_1
    expect(@tc_1.replace_if_no_change(@tc_1).uri).to eq(@tc_1.uri)
  end

  it "replaces with previous, difference" do
    simple_thesaurus_1
    simple_thesaurus_2
    expect(@tc_3.replace_if_no_change(@tc_1).uri).to eq(@tc_3.uri)
  end

  it "replaces with previous, difference" do
    simple_thesaurus_1
    simple_thesaurus_3
    expect(@tc_6.replace_if_no_change(@tc_5).uri).to eq(@tc_6.uri)
  end

end