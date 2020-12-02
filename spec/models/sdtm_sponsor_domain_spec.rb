require 'rails_helper'

describe SdtmSponsorDomain do

  include DataHelpers
  include SparqlHelpers

  def sub_dir
    return "models/sdtm_sponsor_domain"
  end

  before :all do
    data_files = []
    load_files(schema_files, data_files)
    load_data_file_into_triple_store("mdr_identification.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems_migration_2.ttl")
    load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V1.ttl")
    load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V1.ttl")
  end

  it "validates a valid object" do
    result = SdtmSponsorDomain.new
    result.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
    ra = IsoRegistrationAuthority.find(Uri.new(uri:"http://www.assero.co.uk/RA#DUNS123456789"))
    result.has_state = IsoRegistrationStateV2.new
    result.has_state.uri = "na"
    result.has_state.by_authority = ra
    result.has_identifier = IsoScopedIdentifierV2.new
    result.has_identifier.uri = "na"
    result.has_identifier.identifier = "HELLO WORLD"
    result.has_identifier.semantic_version = "0.1.0"
    expect(result.valid?).to eq(true)
  end

  it "does not validate an invalid object" do
    item = SdtmSponsorDomain.new
    result = item.valid?
    expect(item.errors.full_messages.to_sentence).to eq("Uri can't be blank, Has identifier empty object, and Has state empty object")
    expect(result).to eq(false)
  end

  it "does create a Sponsor Domain based on a specified IG domain" do
    params = {label:"Sponsor Adverse Events", prefix:"AE"}
    ig_domain = SdtmIgDomain.find_full(Uri.new(uri: "http://www.cdisc.org/SDTM_IG_AE/V1#IGD"))
    sponsor_domain = SdtmSponsorDomain.create_from_ig(params, ig_domain)
    check_file_actual_expected(sponsor_domain.to_h, sub_dir, "create_from_ig_expected_1.yaml", equate_method: :hash_equal, write_file: true)
  end

  it "does add a non standard variable" do
    params = {label:"Sponsor Adverse Events", prefix:"AE"}
    ig_domain = SdtmIgDomain.find_full(Uri.new(uri: "http://www.cdisc.org/SDTM_IG_AE/V1#IGD"))
    sponsor_domain = SdtmSponsorDomain.create_from_ig(params, ig_domain)
    sponsor_domain.save
    sponsor_domain = SdtmSponsorDomain.find_full(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#SPD"))
    params2 = {name:"NEWVAR"}
    sponsor_domain.add_non_standard_variable(params2)
    check_file_actual_expected(sponsor_domain.to_h, sub_dir, "add_non_standard_variable_expected_1.yaml", equate_method: :hash_equal)
  end

  it "does add a non standard variable, error" do
    params = {identifier:"XXX", label:"Sponsor Adverse Events", prefix:"AE"}
    ig_domain = SdtmIgDomain.find_full(Uri.new(uri: "http://www.cdisc.org/SDTM_IG_AE/V1#IGD"))
    sponsor_domain = SdtmSponsorDomain.create_from_ig(params, ig_domain)
    sponsor_domain.save
    sponsor_domain = SdtmSponsorDomain.find_full(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#SPD"))
    params2 = {name:"SDISAB"}
    result = sponsor_domain.add_non_standard_variable(params2)
    expect(result.errors.count).to eq(1)
    expect(result.errors.full_messages.to_sentence).to eq("http://www.s-cubed.dk/XXX/V1#SPD_AESDISAB already exists in the database")
    #check_file_actual_expected(sponsor_domain.to_h, sub_dir, "add_non_standard_variable_expected_2.yaml", equate_method: :hash_equal, write_file: true)
  end

end