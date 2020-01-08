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

  it "referenced?" do
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

end