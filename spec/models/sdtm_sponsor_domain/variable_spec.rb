require 'rails_helper'

describe SdtmSponsorDomain::VariableSSD do

  include DataHelpers
  include SparqlHelpers
  include IsoManagedHelpers
  include SdtmSponsorDomainFactory
  include SdtmSponsorDomainVariableFactory

  def sub_dir
    return "models/sdtm_sponsor_domain/variable"
  end

  def make_standard(item)
    IsoManagedHelpers.make_item_standard(item)
  end

  describe "Validation Tests" do

    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    it "validates a valid object" do
      result = SdtmSponsorDomain::VariableSSD.new
      result.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
      result.name = "A1234567"
      expect(result.valid?).to eq(true)
    end

    it "does not validate an invalid object" do
      result = SdtmSponsorDomain::VariableSSD.new
      expect(result.valid?).to eq(false)
      expect(result.errors.full_messages.to_sentence).to eq("Uri can't be blank and Name contains invalid characters, is empty or is too long")
    end

    it "does not validate an invalid object" do
      result = SdtmSponsorDomain::VariableSSD.new
      result.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00002")
      result.name = "VSXXXXXXX"
      expect(result.valid?).to eq(false)
      expect(result.errors.full_messages.to_sentence).to eq("Name contains invalid characters, is empty or is too long")
    end

    it "validates a valid object(using factory)" do
      params = {name: "A1234567", uri: Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")}
      result = create_sdtm_sponsor_domain_non_standard_variable(params)
      expect(result.valid?).to eq(true)
    end

  end

  describe "Delete Tests" do

    before :each do
      data_files = ["SDTM_Sponsor_Domain.ttl"]
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    before :each do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
    end

    it "delete error, standard variable" do
      sponsor_domain = create_sdtm_sponsor_domain("YYY", "SDTM Sponsor Domain", "AB")
      ns_var_1 = create_and_add_standard_variable(sponsor_domain)
      sponsor_domain = SdtmSponsorDomain.find_full(sponsor_domain.uri)
      result = ns_var_1.delete(sponsor_domain, sponsor_domain)
      expect(result.errors.count).to eq(1)
      expect(result.errors.full_messages.to_sentence).to eq("The variable cannot be deleted as it is a standard variable.")
      expect(result).to eq(ns_var_1)
    end

    it "delete single parent" do
      uri_check_set_1 =
      [
        { uri: Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD"), present: true},
        { uri: Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD_RS"), present: true},
        { uri: Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD_SI"), present: true},
        { uri: Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD_STUDYID"), present: true},
        { uri: Uri.new(uri: "http://www.assero.co.uk/SDV#1760cbb1-a370-41f6-a3b3-493c1d9c2238"), present: true},
        { uri: Uri.new(uri: "http://www.assero.co.uk/CSN#52070084-cdd3-4ba8-8377-f670e4b0276c"), present: true}
      ]
      uri_check_set_2 =
      [
        { uri: Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD"), present: true},
        { uri: Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD_RS"), present: true},
        { uri: Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD_SI"), present: true},
        { uri: Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD_STUDYID"), present: true},
        { uri: Uri.new(uri: "http://www.assero.co.uk/SDV#1760cbb1-a370-41f6-a3b3-493c1d9c2238"), present: false},
        { uri: Uri.new(uri: "http://www.assero.co.uk/CSN#52070084-cdd3-4ba8-8377-f670e4b0276c"), present: true}
      ]
      parent = SdtmSponsorDomain.find_full(Uri.new(uri:"http://www.s-cubed.dk/AAA/V1#SPD"))
      non_standard_variable = parent.add_non_standard_variable
      parent = SdtmSponsorDomain.find_full(parent.id)
      expect(triple_store.check_uris(uri_check_set_1)).to be(true)
      expect(non_standard_variable.delete(parent, parent)).to eq(1)
      parent = SdtmSponsorDomain.find_full(parent.id)
      expect(triple_store.check_uris(uri_check_set_2)).to be(true)
    end

    it "delete multiple parent" do
      uri_check_set_1 =
      [
        { uri: Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD"), present: true},
        { uri: Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD_RS"), present: true},
        { uri: Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD_SI"), present: true},
        { uri: Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD_STUDYID"), present: true},
        { uri: Uri.new(uri: "http://www.assero.co.uk/SDV#1760cbb1-a370-41f6-a3b3-493c1d9c2238"), present: true},
        { uri: Uri.new(uri: "http://www.assero.co.uk/SDV#4646b47a-4ae4-4f21-b5e2-565815c8cded"), present: true},
        { uri: Uri.new(uri: "http://www.assero.co.uk/CSN#52070084-cdd3-4ba8-8377-f670e4b0276c"), present: true}
      ]
      uri_check_set_2 =
      [
        { uri: Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD"), present: true},
        { uri: Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD_RS"), present: true},
        { uri: Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD_SI"), present: true},
        { uri: Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD_STUDYID"), present: true},
        { uri: Uri.new(uri: "http://www.assero.co.uk/SDV#1760cbb1-a370-41f6-a3b3-493c1d9c2238"), present: true},
        { uri: Uri.new(uri: "http://www.assero.co.uk/SDV#4646b47a-4ae4-4f21-b5e2-565815c8cded"), present: true},
        { uri: Uri.new(uri: "http://www.assero.co.uk/CSN#52070084-cdd3-4ba8-8377-f670e4b0276c"), present: true}
      ]
      parent = SdtmSponsorDomain.find_full(Uri.new(uri:"http://www.s-cubed.dk/AAA/V1#SPD"))
      make_standard(parent)
      new_1 = parent.add_non_standard_variable
      new_2 = parent.add_non_standard_variable
      parent = SdtmSponsorDomain.find_full(parent.uri)
      check_file_actual_expected(parent.to_h, sub_dir, "delete_var_1a.yaml", equate_method: :hash_equal)
      expect(triple_store.check_uris(uri_check_set_1)).to be(true)
      new_parent = parent.create_next_version
      new_parent = SdtmSponsorDomain.find_full(new_parent.uri)
      expect(new_parent.includes_column.count).to eq(43)
      non_standard_variable = SdtmSponsorDomain::VariableSSD.find_full(new_1.uri)
      expect(non_standard_variable.delete(new_parent, new_parent)).to eq(1)
      parent = SdtmSponsorDomain.find_full(parent.id)
      expect(parent.includes_column.count).to eq(43)
      check_file_actual_expected(parent.to_h, sub_dir, "delete_var_1a.yaml", equate_method: :hash_equal)
      new_parent = SdtmSponsorDomain.find_full(new_parent.uri)
      expect(new_parent.includes_column.count).to eq(42)
      fix_dates(new_parent, sub_dir, "delete_var_1b.yaml", :creation_date, :last_change_date)
      new_parent.includes_column = new_parent.includes_column.sort_by{|x| x.ordinal}
      check_file_actual_expected(new_parent.to_h, sub_dir, "delete_var_1b.yaml", equate_method: :hash_equal)
      expect(triple_store.check_uris(uri_check_set_2)).to be(true)
    end

  end

  describe "Standard Variable Tests" do

    before :all do
      data_files = ["SDTM_Sponsor_Domain.ttl"]
      load_files(schema_files, data_files)
    end

    it "standard variable, true" do
      sponsor_variable = SdtmSponsorDomain::VariableSSD.find_full(Uri.new(uri:"http://www.s-cubed.dk/AAA/V1#SPD_STUDYID"))
      expect(sponsor_variable.standard?).to eq(true)
    end

    it "standard variable, false" do
      sponsor_domain = SdtmSponsorDomain.find_full(Uri.new(uri:"http://www.s-cubed.dk/AAA/V1#SPD"))
      non_standard = sponsor_domain.add_non_standard_variable
      expect(non_standard.standard?).to eq(false)
    end

  end

  describe "Update Tests" do

    before :all do
      data_files = ["SDTM_Sponsor_Domain.ttl"]
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    before :each do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
    end

    it "update, standard variable, used" do
      sponsor_domain = SdtmSponsorDomain.find_full(Uri.new(uri:"http://www.s-cubed.dk/AAA/V1#SPD"))
      sponsor_variable = SdtmSponsorDomain::VariableSSD.find_full(Uri.new(uri:"http://www.s-cubed.dk/AAA/V1#SPD_STUDYID"))
      params = {description: "description updated", used: false}
      result = sponsor_variable.update_with_clone(params, sponsor_domain)
      check_file_actual_expected(result.to_h, sub_dir, "update_var_2.yaml", equate_method: :hash_equal)
    end

    it "update, standard variable, notes, comment and method" do
      sponsor_domain = SdtmSponsorDomain.find_full(Uri.new(uri:"http://www.s-cubed.dk/AAA/V1#SPD"))
      sponsor_variable = SdtmSponsorDomain::VariableSSD.find_full(Uri.new(uri:"http://www.s-cubed.dk/AAA/V1#SPD_STUDYID"))
      params = {description: "description updated", label: "label updated", notes: "Notes updated", comment: "Comment updated", method: "Method updated"}
      result = sponsor_variable.update_with_clone(params, sponsor_domain)
      check_file_actual_expected(result.to_h, sub_dir, "update_var_5.yaml", equate_method: :hash_equal)
    end

    it "update error, standard variable" do
      sponsor_domain = SdtmSponsorDomain.find_full(Uri.new(uri:"http://www.s-cubed.dk/AAA/V1#SPD"))
      sponsor_variable = SdtmSponsorDomain::VariableSSD.find_full(Uri.new(uri:"http://www.s-cubed.dk/AAA/V1#SPD_STUDYID"))
      params = {description: "description updated"}
      result = sponsor_variable.update_with_clone(params, sponsor_domain)
      expect(result.errors.count).to eq(1)
      expect(result.errors.full_messages.to_sentence).to eq("The variable cannot be updated as it is a standard variable.")
    end

    it "update, non standard variable" do
      sponsor_domain = SdtmSponsorDomain.find_full(Uri.new(uri:"http://www.s-cubed.dk/AAA/V1#SPD"))
      non_standard = sponsor_domain.add_non_standard_variable
      params2 = {description:"description updated", notes: "Notes updated", comment: "Comment updated", method: "Method updated"}
      result = non_standard.update_with_clone(params2, sponsor_domain)
      check_file_actual_expected(result.to_h, sub_dir, "update_var_1a.yaml", equate_method: :hash_equal)
    end

  end

  describe "Update Tests (Using factories)" do

    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    before :each do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
    end

    it "update error, non standard variable, name change invalid" do
      sponsor_domain = create_sdtm_sponsor_domain("YYY", "SDTM Sponsor Domain", "AB")
      ns_var_1 = create_and_add_non_standard_variable(sponsor_domain)
      ns_var_2 = create_and_add_non_standard_variable(sponsor_domain)
      sponsor_domain = SdtmSponsorDomain.find_full(sponsor_domain.uri)
      result = ns_var_2.update_with_clone({name:"ABXXX001"}, sponsor_domain)
      expect(result.errors.count).to eq(1)
      expect(result.errors.full_messages.to_sentence).to eq("Name duplicate detected 'ABXXX001'")
      check_file_actual_expected(result.to_h, sub_dir, "update_var_3.yaml", equate_method: :hash_equal)
    end

    it "update, non standard variable, name change valid" do
      sponsor_domain = create_sdtm_sponsor_domain("ZZZ", "SDTM Sponsor Domain", "AB")
      ns_var_1 = create_and_add_non_standard_variable(sponsor_domain)
      ns_var_2 = create_and_add_non_standard_variable(sponsor_domain)
      sponsor_domain = SdtmSponsorDomain.find_full(sponsor_domain.uri)
      result = ns_var_2.update_with_clone({name:"ABNEW"}, sponsor_domain)
      expect(result.errors.count).to eq(0)
      check_file_actual_expected(result.to_h, sub_dir, "update_var_4.yaml", equate_method: :hash_equal)
    end

  end

  describe "Update Tests, CT Reference" do

    before :each do
      data_files = ["SDTM_Sponsor_Domain.ttl"]
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_cdisc_term_versions(1..4)
    end

    before :each do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
    end

    it "update, ct ref" do
      cl_1 = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C66767/V4#C66767"))
      cl_2 = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C66768/V4#C66768"))
      cl_3 = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C66780/V4#C66780"))
      sponsor_domain = SdtmSponsorDomain.find_full(Uri.new(uri:"http://www.s-cubed.dk/AAA/V1#SPD"))

      non_standard = sponsor_domain.add_non_standard_variable
      params = {description:"description updated", ct_reference: [cl_1.id]}
      non_standard = non_standard.update_with_clone(params, sponsor_domain)
      expect(non_standard.errors.count).to eq(0)
      sponsor_variable = SdtmSponsorDomain::VariableSSD.find_full(non_standard.id)
      check_file_actual_expected(non_standard.to_h, sub_dir, "update_ct_ref_expected_1a.yaml", equate_method: :hash_equal)
      ct_ref = OperationalReferenceV3::TmcReference.find(Uri.new(uri:"http://www.assero.co.uk/SDV#1760cbb1-a370-41f6-a3b3-493c1d9c2238_TMC1"))

      params2 = {description:"description updated 2", ct_reference: [cl_2.id]}
      non_standard = non_standard.update_with_clone(params2, sponsor_domain)
      expect(non_standard.errors.count).to eq(0)
      sponsor_variable = SdtmSponsorDomain::VariableSSD.find_full(non_standard.id)
      check_file_actual_expected(non_standard.to_h, sub_dir, "update_ct_ref_expected_1b.yaml", equate_method: :hash_equal)

      params3 = {description:"description updated 3", ct_reference: [cl_3.id]}
      non_standard = non_standard.update_with_clone(params3, sponsor_domain)
      expect(non_standard.errors.count).to eq(0)
      sponsor_variable = SdtmSponsorDomain::VariableSSD.find_full(non_standard.id)
      check_file_actual_expected(non_standard.to_h, sub_dir, "update_ct_ref_expected_1c.yaml", equate_method: :hash_equal)
    end

    it "update II, ct ref" do
      cl_1 = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C66767/V4#C66767"))
      cl_2 = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C66768/V4#C66768"))
      cl_3 = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C66780/V4#C66780"))
      sponsor_domain = SdtmSponsorDomain.find_full(Uri.new(uri:"http://www.s-cubed.dk/AAA/V1#SPD"))

      non_standard = sponsor_domain.add_non_standard_variable
      params = {description:"description updated", ct_reference: [cl_1.id]}
      non_standard = non_standard.update_with_clone(params, sponsor_domain)
      expect(non_standard.errors.count).to eq(0)
      sponsor_variable = SdtmSponsorDomain::VariableSSD.find_full(non_standard.id)
      check_file_actual_expected(non_standard.to_h, sub_dir, "update_ct_ref_expected_2a.yaml", equate_method: :hash_equal)
      ct_ref = OperationalReferenceV3::TmcReference.find(Uri.new(uri:"http://www.assero.co.uk/SDV#1760cbb1-a370-41f6-a3b3-493c1d9c2238_TMC1"))

      params2 = {description:"description updated 2", ct_reference: []}
      non_standard = non_standard.update_with_clone(params2, sponsor_domain)
      expect(non_standard.errors.count).to eq(0)
      sponsor_variable = SdtmSponsorDomain::VariableSSD.find_full(non_standard.id)
      check_file_actual_expected(non_standard.to_h, sub_dir, "update_ct_ref_expected_2b.yaml", equate_method: :hash_equal)

      params3 = {description:"description updated 3", ct_reference: [cl_3.id]}
      non_standard = non_standard.update_with_clone(params3, sponsor_domain)
      expect(non_standard.errors.count).to eq(0)
      sponsor_variable = SdtmSponsorDomain::VariableSSD.find_full(non_standard.id)
      check_file_actual_expected(non_standard.to_h, sub_dir, "update_ct_ref_expected_2c.yaml", equate_method: :hash_equal)
    end

  end


  describe "Correct prefix" do

    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    before :each do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
    end

    it "correct prefix, true, parent for validation nil" do
      sponsor_domain = create_sdtm_sponsor_domain("YYY", "SDTM Sponsor Domain", "AB")
      ns_var_1 = create_and_add_non_standard_variable(sponsor_domain)
      sponsor_domain = SdtmSponsorDomain.find_full(sponsor_domain.uri)
      ns_var_1.instance_variable_set(:@parent_for_validation, nil)
      expect(ns_var_1.correct_prefix?).to eq(true)
    end

    it "correct prefix, true" do
      sponsor_domain = create_sdtm_sponsor_domain("YYY", "SDTM Sponsor Domain", "AB")
      ns_var_1 = create_and_add_non_standard_variable(sponsor_domain)
      sponsor_domain = SdtmSponsorDomain.find_full(sponsor_domain.uri)
      ns_var_1.instance_variable_set(:@parent_for_validation, sponsor_domain)
      expect(ns_var_1.correct_prefix?).to eq(true)
    end

    it "correct prefix, false" do
      sponsor_domain = create_sdtm_sponsor_domain("YYY", "SDTM Sponsor Domain", "AB")
      ns_var_1 = create_and_add_non_standard_variable(sponsor_domain)
      ns_var_1.update_with_clone({name:"NEWNAME"}, sponsor_domain)
      sponsor_domain = SdtmSponsorDomain.find_full(sponsor_domain.uri)
      ns_var_1.instance_variable_set(:@parent_for_validation, sponsor_domain)
      expect(ns_var_1.errors.full_messages.to_sentence).to eq("Name prefix does not match 'AB'")
      expect(ns_var_1.correct_prefix?).to eq(false)
    end

  end

  describe "Clone Tests" do

    before :each do
      data_files = ["SDTM_Sponsor_Domain.ttl"]
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    it "clone" do
      sponsor_variable = SdtmSponsorDomain::VariableSSD.find_full(Uri.new(uri:"http://www.s-cubed.dk/AAA/V1#SPD_STUDYID"))
      result = sponsor_variable.clone
      check_file_actual_expected(result.to_h, sub_dir, "clone_expected_1.yaml", equate_method: :hash_equal)
    end

  end 

end