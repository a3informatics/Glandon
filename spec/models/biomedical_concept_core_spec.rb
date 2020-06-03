require 'rails_helper'
require 'biomedical_concept_core'

describe BiomedicalConceptCore do

  include DataHelpers
  include SparqlHelpers

  def sub_dir
    return "models"
  end

  before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "BCT.ttl", "BC.ttl"]
    load_files(schema_files, data_files)
    # clear_triple_store
    # load_schema_file_into_triple_store("ISO11179Types.ttl")
    # load_schema_file_into_triple_store("ISO11179Identification.ttl")
    # load_schema_file_into_triple_store("ISO11179Registration.ttl")
    # load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    # load_schema_file_into_triple_store("business_operational.ttl")
    # load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")
    # load_test_file_into_triple_store("iso_registration_authority_real.ttl")
    # load_test_file_into_triple_store("iso_namespace_real.ttl")
    # load_test_file_into_triple_store("BCT.ttl")
    # load_test_file_into_triple_store("BC.ttl")
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
  end

  it "allows validity of the object to be checked - error" do
    result = BiomedicalConceptCore.new
    result.valid?
    expect(result.errors.count).to eq(4)
    expect(result.errors.full_messages[0]).to eq("Registration State error: Registration authority error: Uri can't be blank")
    expect(result.errors.full_messages[1]).to eq("Registration State error: Registration authority error: Organization identifier is invalid")
    expect(result.errors.full_messages[2]).to eq("Registration State error: Registration authority error: Ra namespace: Empty object")
    expect(result.errors.full_messages[3]).to eq("Scoped Identifier error: Identifier contains invalid characters")
    expect(result.valid?).to eq(false)
  end

  it "allows validity of the object to be checked" do
    result = BiomedicalConceptCore.new
    ra = IsoRegistrationAuthority.new
    ra.uri = "na" # Bit naughty
    ra.organization_identifier = "123456789"
    ra.international_code_designator = "DUNS"
    ra.ra_namespace = IsoNamespace.find(Uri.new(uri:"http://www.assero.co.uk/NS#ACME"))
    result.registrationState.registrationAuthority= ra
    result.scopedIdentifier.identifier = "123 DEF edr"
    valid = result.valid?
    expect(result.errors.count).to eq(0)
    expect(valid).to eq(true)
  end

  it "allows the object to be found" do
    item = BiomedicalConceptCore.find("BCT-Obs_PQR", "http://www.assero.co.uk/MDRBCTs/V1")
    expect(item.identifier).to eq("Obs PQR")
  end

  it "allows the properties to be returned" do
    item = BiomedicalConceptCore.find("BC-ACME_BC_C25206", "http://www.assero.co.uk/MDRBCs/V1")
    json = item.get_properties
    check_file_actual_expected(json, sub_dir, "bc_core_properties_find.yaml", equate_method: :hash_equal)
  end

  it "allows the properties to be update the object" do
    item = BiomedicalConceptCore.find("BC-ACME_BC_C25206", "http://www.assero.co.uk/MDRBCs/V1")
    json = item.get_properties
    json[:children][3][:question_text] = "Updated Question text"
    item.set_properties(json)
    actual = item.get_properties
    actual[:children].sort_by! {|x| x[:id]}
    check_file_actual_expected(actual, sub_dir, "bc_core_properties_update.yaml", equate_method: :hash_equal)
  end

  it "allows the object to be exported as JSON" do
    item = BiomedicalConceptCore.find("BC-ACME_BC_C25206", "http://www.assero.co.uk/MDRBCs/V1")
    check_file_actual_expected(item.to_json, sub_dir, "bc_core_json.yaml", equate_method: :hash_equal)
  end

  it "allows the object to be created from JSON" do
    hash = read_yaml_file(sub_dir, "bc_core_json.yaml")
    item = BiomedicalConceptCore.from_json(hash)
    check_file_actual_expected(item.to_json, sub_dir, "bc_core_from_json.yaml", equate_method: :hash_equal)

  end

  it "allows an object to be exported as SPARQL" do
    item = BiomedicalConceptCore.find("BC-ACME_BC_C25206", "http://www.assero.co.uk/MDRBCs/V1")
    sparql = SparqlUpdateV2.new
    item.to_sparql_v2(sparql)
#X write_text_file_2(sparql.to_s, sub_dir, "bc_core_sparql.txt")
    check_sparql_no_file(sparql.to_s, "bc_core_sparql.txt")
  end

end
