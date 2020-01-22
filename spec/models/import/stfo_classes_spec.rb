require 'rails_helper'

describe Import::STFOClasses do
	
	include DataHelpers
  include ImportHelpers
  include PublicFileHelpers
  include SparqlHelpers

	def sub_dir
    return "models/import/stfo_classes"
  end

	before :each do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "iso_concept_systems_baseline.ttl", "iso_concept_systems_process.ttl"]
    load_files(schema_files, data_files)
    load_cdisc_term_versions(1..10)
  end

  after :each do
  end

  it "sponsor?" do
    object = Import::STFOClasses::STFOCodeList.new
    object.identifier = "SN000123"
    object.narrower << Import::STFOClasses::STFOCodeListItem.new(identifier: "S000123")
    object.narrower << Import::STFOClasses::STFOCodeListItem.new(identifier: "S000124")
    expect(object.sponsor?).to eq(true)
  end

  it "not sponsor?" do
    object = Import::STFOClasses::STFOCodeList.new
    object.identifier = "SN000123"
    object.narrower << Import::STFOClasses::STFOCodeListItem.new(identifier: "C12345")
    object.narrower << Import::STFOClasses::STFOCodeListItem.new(identifier: "S000124")
    expect(object.sponsor?).to eq(false)
  end

  it "sponsor_or_hybrid?" do
    object = Import::STFOClasses::STFOCodeList.new
    object.identifier = "SN000123"
    object.narrower << Import::STFOClasses::STFOCodeListItem.new(identifier: "S000123")
    object.narrower << Import::STFOClasses::STFOCodeListItem.new(identifier: "SC00012")
    expect(object.hybrid_sponsor?).to eq(true)
  end

  it "not sponsor_or_hybrid?" do
    object = Import::STFOClasses::STFOCodeList.new
    object.identifier = "SN000123"
    object.narrower << Import::STFOClasses::STFOCodeListItem.new(identifier: "C12345")
    object.narrower << Import::STFOClasses::STFOCodeListItem.new(identifier: "SC00012")
    expect(object.hybrid_sponsor?).to eq(false)
  end

  it "subset?" do
    object = Import::STFOClasses::STFOCodeList.new
    object.preferred_term = Thesaurus::PreferredTerm.new(label: "Something subset 01")
    expect(object.subset?).to eq(true)    
    object.preferred_term = Thesaurus::PreferredTerm.new(label: "Something Subset 01")
    expect(object.subset?).to eq(true)    
    object.preferred_term = Thesaurus::PreferredTerm.new(label: "Something subsets")
    expect(object.subset?).to eq(false)    
    object.preferred_term = Thesaurus::PreferredTerm.new(label: "Something SUBSET somthing else")
    expect(object.subset?).to eq(true)    
    object.preferred_term = Thesaurus::PreferredTerm.new(label: "Something SUBset thing")
    expect(object.subset?).to eq(true)    
    object.preferred_term = Thesaurus::PreferredTerm.new(label: "Something SUBset")
    expect(object.subset?).to eq(true)    
    object.preferred_term = Thesaurus::PreferredTerm.new(label: "Something SUB set")
    expect(object.subset?).to eq(false)    
  end

  it "extension? I" do
    object = Import::STFOClasses::STFOCodeList.new
    object.identifier = "C76351"
    object.narrower << Import::STFOClasses::STFOCodeListItem.new(identifier: "C74571")
    object.narrower << Import::STFOClasses::STFOCodeListItem.new(identifier: "S000123")
    object.narrower << Import::STFOClasses::STFOCodeListItem.new(identifier: "S000124")
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V10#TH"))
    actual = object.extension?(ct)
    expect(actual).to eq(object)
    check_file_actual_expected(actual.to_h, sub_dir, "extension?_expected_1.yaml", equate_method: :hash_equal)
  end

  it "extension? II" do
    object = Import::STFOClasses::STFOCodeList.new
    object.identifier = "C76351"
    object.narrower << Import::STFOClasses::STFOCodeListItem.new(identifier: "C74571")
    object.narrower << Import::STFOClasses::STFOCodeListItem.new(identifier: "C777")
    object.narrower << Import::STFOClasses::STFOCodeListItem.new(identifier: "SC74571")
    object.narrower << Import::STFOClasses::STFOCodeListItem.new(identifier: "S000123")
    object.narrower << Import::STFOClasses::STFOCodeListItem.new(identifier: "S000124")
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V10#TH"))
    actual = object.extension?(ct)
    expect(actual).to eq(object)
    check_file_actual_expected(actual.to_h, sub_dir, "extension?_expected_2.yaml", equate_method: :hash_equal)
  end

  it "not extension?" do
    object = Import::STFOClasses::STFOCodeList.new
    object.identifier = "C76351"
    object.narrower << Import::STFOClasses::STFOCodeListItem.new(identifier: "C74571")
    object.narrower << Import::STFOClasses::STFOCodeListItem.new(identifier: "S000123")
    object.narrower << Import::STFOClasses::STFOCodeListItem.new(identifier: "S000124X")
    expected = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/C76351/V10#C76351"))
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V10#TH"))
    actual = object.extension?(ct)
    expect(actual).to eq(nil)
  end

  it "referenced?" do
    object = Import::STFOClasses::STFOCodeList.new
    object.identifier = "C76351"
    object.narrower << Import::STFOClasses::STFOCodeListItem.new(identifier: "C74571")
    object.narrower << Import::STFOClasses::STFOCodeListItem.new(identifier: "C74573")
    expected = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/C76351/V10#C76351"))
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V10#TH"))
    actual = object.referenced?(ct)
    expect(actual.uri).to eq(expected.uri)
    check_file_actual_expected(actual.to_h, sub_dir, "reference?_expected_1.yaml", equate_method: :hash_equal)
  end

  it "not referenced?" do
    object = Import::STFOClasses::STFOCodeList.new
    object.identifier = "C76351"
    object.narrower << Import::STFOClasses::STFOCodeListItem.new(identifier: "C74571")
    object.narrower << Import::STFOClasses::STFOCodeListItem.new(identifier: "C74573X")
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V10#TH"))
    actual = object.referenced?(ct)
    expect(actual).to eq(nil)
  end

  it "obtains reference" do
    object = Import::STFOClasses::STFOCodeList.new
    object.identifier = "C76351"
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V10#TH"))
    actual = object.reference(ct)
    check_file_actual_expected(actual.to_h, sub_dir, "reference_expected_1.yaml", equate_method: :hash_equal)
  end

  it "child identifiers" do
    object = Import::STFOClasses::STFOCodeList.new
    object.identifier = "C76351"
    object.narrower << Import::STFOClasses::STFOCodeListItem.new(identifier: "C74571")
    object.narrower << Import::STFOClasses::STFOCodeListItem.new(identifier: "C74573X")
    object.narrower << Import::STFOClasses::STFOCodeListItem.new(identifier: "SN1234")
    object.narrower << Import::STFOClasses::STFOCodeListItem.new(identifier: "X1234")
    actual = object.child_identifiers
    check_file_actual_expected(actual, sub_dir, "child_identifiers_expected_1.yaml", equate_method: :hash_equal)
  end

  it "sponsor child identifiers?" do
    object = Import::STFOClasses::STFOCodeList.new
    object.identifier = "C76351"
    object.narrower << Import::STFOClasses::STFOCodeListItem.new(identifier: "C74571")
    object.narrower << Import::STFOClasses::STFOCodeListItem.new(identifier: "C74573")
    expect(object.sponsor_child_identifiers?).to eq(false)
    object = Import::STFOClasses::STFOCodeList.new
    object.identifier = "C76351"
    object.narrower << Import::STFOClasses::STFOCodeListItem.new(identifier: "S174571")
    object.narrower << Import::STFOClasses::STFOCodeListItem.new(identifier: "S274573")
    expect(object.sponsor_child_identifiers?).to eq(true)
    object = Import::STFOClasses::STFOCodeList.new
    object.identifier = "C76351"
    object.narrower << Import::STFOClasses::STFOCodeListItem.new(identifier: "S174571XX")
    object.narrower << Import::STFOClasses::STFOCodeListItem.new(identifier: "S274573")
    expect(object.sponsor_child_identifiers?).to eq(false)
  end

  it "sponsor code list identifiers" do
    object = Import::STFOClasses::STFOCodeList.new
    object.identifier = "C76351"
    expect(object.sponsor_identifier?).to eq(false)
    object.identifier = "SN12345"
    expect(object.sponsor_identifier?).to eq(false)
    object.identifier = "SN123456"
    expect(object.sponsor_identifier?).to eq(true)
    object.identifier = "SN1234567"
    expect(object.sponsor_identifier?).to eq(false)
    object.identifier = "SN12345X"
    expect(object.sponsor_identifier?).to eq(false)
  end

  it "sponsor code list item identifiers set" do
    expect(Import::STFOClasses::STFOCodeListItem.sponsor_identifier_set?(["S123456"])).to eq(true)
    expect(Import::STFOClasses::STFOCodeListItem.sponsor_identifier_set?(["S123456", "S123457"])).to eq(true)
    expect(Import::STFOClasses::STFOCodeListItem.sponsor_identifier_set?(["S123456", "S123457X"])).to eq(false)
  end

  it "sponsor code list item identifier or referenced set" do
    expect(Import::STFOClasses::STFOCodeListItem.sponsor_identifier_or_referenced_set?(["S123456"])).to eq(true)
    expect(Import::STFOClasses::STFOCodeListItem.sponsor_identifier_or_referenced_set?(["S123456", "S123457"])).to eq(true)
    expect(Import::STFOClasses::STFOCodeListItem.sponsor_identifier_or_referenced_set?(["S123456", "S123457X"])).to eq(false)
    expect(Import::STFOClasses::STFOCodeListItem.sponsor_identifier_or_referenced_set?(["S123456", "SC12345"])).to eq(true)
    expect(Import::STFOClasses::STFOCodeListItem.sponsor_identifier_or_referenced_set?(["SC12333", "SC12345", "S123456"])).to eq(true)
  end

  it "sponsor code list item identifier, referenced or ncit set" do
    expect(Import::STFOClasses::STFOCodeListItem.sponsor_identifier_referenced_or_ncit_set?(["S123456"])).to eq(true)
    expect(Import::STFOClasses::STFOCodeListItem.sponsor_identifier_referenced_or_ncit_set?(["S123456", "S123457"])).to eq(true)
    expect(Import::STFOClasses::STFOCodeListItem.sponsor_identifier_referenced_or_ncit_set?(["S123456", "S123457X"])).to eq(false)
    expect(Import::STFOClasses::STFOCodeListItem.sponsor_identifier_referenced_or_ncit_set?(["S123456", "SC12345"])).to eq(true)
    expect(Import::STFOClasses::STFOCodeListItem.sponsor_identifier_referenced_or_ncit_set?(["SC12333", "SC12345", "S123456"])).to eq(true)
    expect(Import::STFOClasses::STFOCodeListItem.sponsor_identifier_referenced_or_ncit_set?(["SC12333", "SC12345", "C456"])).to eq(true)
    expect(Import::STFOClasses::STFOCodeListItem.sponsor_identifier_referenced_or_ncit_set?(["SC12333", "SC12345", "C45644"])).to eq(true)
  end

  it "sponsor code list item identifiers" do
    object = Import::STFOClasses::STFOCodeListItem.new
    object.identifier = "C76351"
    expect(object.sponsor_identifier?).to eq(false)
    object.identifier = "S12345"
    expect(object.sponsor_identifier?).to eq(false)
    object.identifier = "S123456"
    expect(object.sponsor_identifier?).to eq(true)
    object.identifier = "S1234567"
    expect(object.sponsor_identifier?).to eq(false)
    object.identifier = "S12345X"
    expect(object.sponsor_identifier?).to eq(false)
  end

  it "sponsor and referenced format" do
    expect(Import::STFOClasses::STFOCodeListItem.sponsor_identifier_format?("S123456")).to eq(true)
    expect(Import::STFOClasses::STFOCodeListItem.sponsor_identifier_format?("S12345")).to eq(false)
    expect(Import::STFOClasses::STFOCodeListItem.sponsor_identifier_format?("S1234567")).to eq(false)
    expect(Import::STFOClasses::STFOCodeListItem.sponsor_identifier_format?("S12345X")).to eq(false)
    expect(Import::STFOClasses::STFOCodeListItem.sponsor_referenced_format?("SC12345")).to eq(true)
    expect(Import::STFOClasses::STFOCodeListItem.sponsor_referenced_format?("SC1234")).to eq(true)
    expect(Import::STFOClasses::STFOCodeListItem.sponsor_referenced_format?("SC123456")).to eq(true)
    expect(Import::STFOClasses::STFOCodeListItem.sponsor_referenced_format?("SC1234X")).to eq(false)
  end

  it "NCI format" do
    expect(Import::STFOClasses::STFOCodeListItem.ncit_format?("C123456")).to eq(true)
    expect(Import::STFOClasses::STFOCodeListItem.ncit_format?("S1234567")).to eq(false)
    expect(Import::STFOClasses::STFOCodeListItem.ncit_format?("S12345X")).to eq(false)
  end

end