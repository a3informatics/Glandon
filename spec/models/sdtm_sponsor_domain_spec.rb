require 'rails_helper'

describe SdtmSponsorDomain do

  include DataHelpers
  include SparqlHelpers
  include IsoManagedHelpers
  include SdtmSponsorDomainFactory
  include BiomedicalConceptInstanceFactory

  def sub_dir
    return "models/sdtm_sponsor_domain"
  end

  describe "Basic Tests" do

    before :each do
      data_files = ["SDTM_Sponsor_Domain.ttl"]
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_2.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V1.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V1.ttl")
      load_cdisc_term_versions(1..8)
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
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

    it "allows an Sponsor Domain to get children (variables)" do
      actual = []
      item = SdtmSponsorDomain.find_full(Uri.new(uri:"http://www.s-cubed.dk/AAA/V1#SPD"))
      children = item.get_children
      children_sorted = children.each.sort_by {|x| x[:ordinal]} 
      children_sorted.each {|x| actual << x.to_h}
      check_file_actual_expected(actual, sub_dir, "find_children.yaml", equate_method: :hash_equal)
    end

    it "does create a Sponsor Domain based on a specified IG domain" do
      params = {label:"Sponsor Adverse Events", prefix:"AE", identifier: "SDTM AE"}
      ig_domain = SdtmIgDomain.find_full(Uri.new(uri: "http://www.cdisc.org/SDTM_IG_AE/V1#IGD"))
      sponsor_domain = SdtmSponsorDomain.create_from_ig(params, ig_domain)
      check_dates(sponsor_domain, sub_dir, "create_from_ig_expected_1.yaml", :last_change_date)
      check_file_actual_expected(sponsor_domain.to_h, sub_dir, "create_from_ig_expected_1.yaml", equate_method: :hash_equal)
    end

    it "does create a Sponsor Domain based on a specified IG domain" do
      params = {label:"Sponsor XX Events", prefix:"XX", identifier: "SDTM XX"}
      ig_domain = SdtmIgDomain.find_full(Uri.new(uri: "http://www.cdisc.org/SDTM_IG_AE/V1#IGD"))
      sponsor_domain = SdtmSponsorDomain.create_from_ig(params, ig_domain)
      check_dates(sponsor_domain, sub_dir, "create_from_ig_expected_1.yaml", :last_change_date)
      check_file_actual_expected(sponsor_domain.to_h, sub_dir, "create_from_ig_expected_2.yaml", equate_method: :hash_equal)
    end

    it "does create a Sponsor Domain based on a specified Class" do
      params = {label:"Sponsor Adverse Events", prefix:"AE", identifier: "SDTM AE"}
      sdtm_class = SdtmClass.find_full(Uri.new(uri: "http://www.cdisc.org/SDTM_MODEL_EVENTS/V1#CL"))
      sponsor_domain = SdtmSponsorDomain.create_from_class(params, sdtm_class)
      check_dates(sponsor_domain, sub_dir, "create_from_class_expected_1.yaml", :last_change_date)
      check_file_actual_expected(sponsor_domain.to_h, sub_dir, "create_from_class_expected_1.yaml", equate_method: :hash_equal)
    end

    it "does add a non standard variable" do
      params = {label:"Sponsor Adverse Events", prefix:"AE"}
      ig_domain = SdtmIgDomain.find_full(Uri.new(uri: "http://www.cdisc.org/SDTM_IG_AE/V1#IGD"))
      sponsor_domain = SdtmSponsorDomain.create_from_ig(params, ig_domain)
      result = sponsor_domain.add_non_standard_variable
      check_file_actual_expected(result.to_h, sub_dir, "add_non_standard_variable_expected_1.yaml", equate_method: :hash_equal)
    end

  end

  describe "Get children Tests" do

    before :each do
      data_files = ["SDTM_Sponsor_Domain.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..8)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_2.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V1.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V1.ttl")
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
    end

    it "allows an Sponsor Domain to get children (variables)" do
      actual = []
      item = SdtmSponsorDomain.find_full(Uri.new(uri:"http://www.s-cubed.dk/AAA/V1#SPD"))
      children = item.get_children
      children.each {|x| actual << x.to_h}
      check_file_actual_expected(actual, sub_dir, "find_children.yaml", equate_method: :hash_equal)
    end

  end

  describe "Dependency Tests" do

    before :each do
      data_files = []
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_2.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V1.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V1.ttl")
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      params = {label:"Sponsor Adverse Events", prefix:"AE", identifier: "SDTM AE"}
      @sdtm_class = SdtmClass.find_full(Uri.new(uri: "http://www.cdisc.org/SDTM_MODEL_EVENTS/V1#CL"))
      @domain = SdtmSponsorDomain.create_from_class(params, @sdtm_class)
      @bc_1 = create_biomedical_concept_instance("BC1", "BC 1")
      @bc_2 = create_biomedical_concept_instance("BC2", "BC 2")
      association = @domain.associate([@bc_1.id, @bc_2.id], "SDTM BC Association")
    end

    it "dependency paths" do
      paths = SdtmSponsorDomain.dependency_paths
      check_file_actual_expected(paths, sub_dir, "dependency_paths_expected_1.yaml", equate_method: :hash_equal)
    end

    it "dependencies" do
      uri_mh = Uri.new(uri: "http://www.cdisc.org/SDTM_IG_MH/V1#IGD")
      uri_ce = Uri.new(uri: "http://www.cdisc.org/SDTM_IG_CE/V1#IGD")
      uri_ds = Uri.new(uri: "http://www.cdisc.org/SDTM_IG_DS/V1#IGD")
      uri_ae = Uri.new(uri: "http://www.cdisc.org/SDTM_IG_AE/V1#IGD")
      uri_dv = Uri.new(uri: "http://www.cdisc.org/SDTM_IG_DV/V1#IGD")
      results = @bc_1.dependency_required_by
      expect(results.map{|x| x.uri}).to eq([@domain.uri])
      results = @bc_2.dependency_required_by
      expect(results.map{|x| x.uri}).to eq([@domain.uri])
      results = @sdtm_class.dependency_required_by
      expect(results.map{|x| x.uri}).to match_array([uri_mh, uri_ce , uri_ds, uri_ae, uri_dv, @domain.uri])
    end

  end

  describe "Delete Tests" do

    before :each do
      data_files = ["SDTM_Sponsor_Domain_2.ttl"]
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_2.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_3.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V1.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V1.ttl")
      load_cdisc_term_versions(1..8)
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
    end

    it "delete a domain, based on class" do
      before_count = triple_store.triple_count
      params = {label:"Sponsor Adverse Events", prefix:"AA", identifier: "SDTM AE YYY"}
      sdtm_class = SdtmClass.find_full(Uri.new(uri: "http://www.cdisc.org/SDTM_MODEL_EVENTS/V1#CL"))
      sponsor_domain = SdtmSponsorDomain.create_from_class(params, sdtm_class)
      result = sponsor_domain.delete
      expect(result).to eq(1)
      expect(triple_store.triple_count).to eq(before_count)
    end

    it "delete a domain, based on IG" do
      uri_check_set_1 =
      [
        { uri: Uri.new(uri: "http://www.s-cubed.dk/SDTM_AE_XXX/V1#SPD"), present: true},
        { uri: Uri.new(uri: "http://www.s-cubed.dk/SDTM_AE_XXX/V1#SPD_RS"), present: true},
        { uri: Uri.new(uri: "http://www.s-cubed.dk/SDTM_AE_XXX/V1#SPD_SI"), present: true},
        { uri: Uri.new(uri: "http://www.assero.co.uk/SDV#10ec98dc-a1be-4db1-970a-c9a1d0261ac9"), present: true},
        { uri: Uri.new(uri: "http://www.assero.co.uk/SDV#b810e561-9137-4b7b-96ea-d7c8a886b2c0"), present: true},
        { uri: Uri.new(uri: "http://www.assero.co.uk/SDV#b810e561-9137-4b7b-96ea-d7c8a886b2c0_TMC1"), present: true},
        { uri: Uri.new(uri: "http://www.cdisc.org/SDTM_IG_AE/V1#IGD_AEPRESP_TMC1"), present: true}
      ]
      uri_check_set_2 =
      [
        { uri: Uri.new(uri: "http://www.s-cubed.dk/SDTM_AE_XXX/V1#SPD"), present: false},
        { uri: Uri.new(uri: "http://www.s-cubed.dk/SDTM_AE_XXX/V1#SPD_RS"), present: false},
        { uri: Uri.new(uri: "http://www.s-cubed.dk/SDTM_AE_XXX/V1#SPD_SI"), present: false},
        { uri: Uri.new(uri: "http://www.assero.co.uk/SDV#10ec98dc-a1be-4db1-970a-c9a1d0261ac9"), present: false},
        { uri: Uri.new(uri: "http://www.assero.co.uk/SDV#b810e561-9137-4b7b-96ea-d7c8a886b2c0"), present: false},
        { uri: Uri.new(uri: "http://www.assero.co.uk/SDV#b810e561-9137-4b7b-96ea-d7c8a886b2c0_TMC1"), present: false},
        { uri: Uri.new(uri: "http://www.cdisc.org/SDTM_IG_AE/V1#IGD_AEPRESP_TMC1"), present: true}
      ]
      sponsor_domain = SdtmSponsorDomain.find_full(Uri.new(uri:"http://www.s-cubed.dk/SDTM_AE_XXX/V1#SPD"))
      expect(triple_store.check_uris(uri_check_set_1)).to be(true)
      result = sponsor_domain.delete
      expect(result).to eq(1)
      expect(triple_store.check_uris(uri_check_set_2)).to be(true)
    end

  end

end