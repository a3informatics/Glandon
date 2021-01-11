require 'rails_helper'
require 'sdtm_sponsor_domain/variable'

describe SdtmSponsorDomain::Variable do

  include DataHelpers
  include SparqlHelpers
  include IsoManagedHelpers

  def sub_dir
    return "models/sdtm_sponsor_domain/variable"
  end

  def make_standard(item)
    params = {}
    params[:registration_status] = "Standard"
    params[:previous_state] = "Incomplete"
    item.update_status(params)
  end

  describe "Validation Tests" do

    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    it "validates a valid object" do
      result = SdtmSponsorDomain::Variable.new
      result.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
      result.name = "A1234567"
      expect(result.valid?).to eq(true)
    end

    it "does not validate an invalid object" do
      item = SdtmSponsorDomain::Variable.new
      result = item.valid?
      expect(item.errors.full_messages.to_sentence).to eq("Uri can't be blank and Name contains invalid characters, is empty or is too long")
      expect(result).to eq(false)
    end

    it "does not validate an invalid object" do
      item = SdtmSponsorDomain::Variable.new
      item.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00002")
      item.name = "VSXXXXXXX"
      result = item.valid?
      expect(item.errors.full_messages.to_sentence).to eq("Name contains invalid characters, is empty or is too long")
      expect(result).to eq(false)
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
      non_standard_variable = SdtmSponsorDomain::Variable.find_full(new_1.uri)
      expect(non_standard_variable.delete(new_parent, new_parent)).to eq(1)
      parent = SdtmSponsorDomain.find_full(parent.id)
      expect(parent.includes_column.count).to eq(43)
      check_file_actual_expected(parent.to_h, sub_dir, "delete_var_1a.yaml", equate_method: :hash_equal)
      new_parent = SdtmSponsorDomain.find_full(new_parent.uri)
      expect(new_parent.includes_column.count).to eq(42)
      check_dates(new_parent, sub_dir, "delete_var_1b.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(new_parent.to_h, sub_dir, "delete_var_1b.yaml", equate_method: :hash_equal)
      expect(triple_store.check_uris(uri_check_set_2)).to be(true)
    end

  end

  # describe "Toggle Tests" do

  #   before :each do
  #     data_files = ["SDTM_Sponsor_Domain.ttl"]
  #     load_files(schema_files, data_files)
  #     load_data_file_into_triple_store("mdr_identification.ttl")
  #   end

  #   it "toggle single parent" do
  #     parent = SdtmSponsorDomain.find_full(Uri.new(uri:"http://www.s-cubed.dk/AAA/V1#SPD"))
  #     sponsor_variable = SdtmSponsorDomain::Var.find_full(Uri.new(uri:"http://www.s-cubed.dk/AAA/V1#SPD_STUDYID"))
  #     expect(sponsor_variable.used).to eq(true)
  #     sponsor_variable.toggle_with_clone(parent)
  #     sponsor_variable = SdtmSponsorDomain::Var.find_full(Uri.new(uri:"http://www.s-cubed.dk/AAA/V1#SPD_STUDYID"))
  #     expect(sponsor_variable.used).to eq(false)
  #   end

  #   it "toggle multiple parent" do
  #     parent = SdtmSponsorDomain.find_full(Uri.new(uri:"http://www.s-cubed.dk/AAA/V1#SPD"))
  #     make_standard(parent)
  #     #check_dates(parent, sub_dir, "toggle_var_1a.yaml", :creation_date, :last_change_date)
  #     check_file_actual_expected(parent.to_h, sub_dir, "toggle_var_1a.yaml", equate_method: :hash_equal)
  #     new_parent = parent.create_next_version
  #     new_parent = SdtmSponsorDomain.find_full(new_parent.uri)
  #     sponsor_variable = SdtmSponsorDomain::Var.find_full(Uri.new(uri:"http://www.s-cubed.dk/AAA/V1#SPD_STUDYID"))
  #     expect(sponsor_variable.used).to eq(true)
  #     sponsor_variable.toggle_with_clone(new_parent)
  #     sponsor_variable = SdtmSponsorDomain::Var.find_full(Uri.new(uri:"http://www.s-cubed.dk/AAA/V1#SPD_STUDYID"))
  #     expect(sponsor_variable.used).to eq(true)
  #     new_sponsor_variable = SdtmSponsorDomain::Var.find_full(Uri.new(uri:"http://www.s-cubed.dk/AAA/V2#SPD_STUDYID"))
  #     expect(new_sponsor_variable.used).to eq(false)
  #     parent = SdtmSponsorDomain.find_full(parent.id)
  #     #check_dates(parent, sub_dir, "toggle_var_1a.yaml", :creation_date, :last_change_date)
  #     check_file_actual_expected(parent.to_h, sub_dir, "toggle_var_1a.yaml", equate_method: :hash_equal)
  #     new_parent = SdtmSponsorDomain.find_full(new_parent.uri)
  #     check_dates(new_parent, sub_dir, "toggle_var_1b.yaml", :creation_date, :last_change_date)
  #     check_file_actual_expected(new_parent.to_h, sub_dir, "toggle_var_1b.yaml", equate_method: :hash_equal)
  #   end

  # end

  describe "Standard? Tests" do

    before :all do
      data_files = ["SDTM_Sponsor_Domain.ttl"]
      load_files(schema_files, data_files)
    end

    it "standard true" do
      sponsor_variable = SdtmSponsorDomain::Variable.find_full(Uri.new(uri:"http://www.s-cubed.dk/AAA/V1#SPD_STUDYID"))
      expect(sponsor_variable.standard?).to eq(true)
    end

    it "standard false" do
      sponsor_domain = SdtmSponsorDomain.find_full(Uri.new(uri:"http://www.s-cubed.dk/AAA/V1#SPD"))
      non_standard = sponsor_domain.add_non_standard_variable
      expect(non_standard.standard?).to eq(false)
    end

  end

  describe "Update Tests" do

    before :all do
      data_files = ["SDTM_Sponsor_Domain.ttl"]
      load_files(schema_files, data_files)
    end

    before :each do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
    end

    it "update error, variable standard" do
      sponsor_domain = SdtmSponsorDomain.find_full(Uri.new(uri:"http://www.s-cubed.dk/AAA/V1#SPD"))
      sponsor_variable = SdtmSponsorDomain::Variable.find_full(Uri.new(uri:"http://www.s-cubed.dk/AAA/V1#SPD_STUDYID"))
      params = {description: "description updated"}
      result = sponsor_variable.update_with_clone(params, sponsor_domain)
      expect(result.errors.count).to eq(1)
      expect(result.errors.full_messages.to_sentence).to eq("The variable cannot be updated as it is a standard variable.")
    end

    it "update, non standard variable" do
      sponsor_domain = SdtmSponsorDomain.find_full(Uri.new(uri:"http://www.s-cubed.dk/AAA/V1#SPD"))
      non_standard = sponsor_domain.add_non_standard_variable
      params2 = {description:"description updated"}
      result = non_standard.update_with_clone(params2, sponsor_domain)
      check_file_actual_expected(result.to_h, sub_dir, "update_var_1a.yaml", equate_method: :hash_equal)
    end

    it "update used, variable standard" do
      sponsor_domain = SdtmSponsorDomain.find_full(Uri.new(uri:"http://www.s-cubed.dk/AAA/V1#SPD"))
      sponsor_variable = SdtmSponsorDomain::Variable.find_full(Uri.new(uri:"http://www.s-cubed.dk/AAA/V1#SPD_STUDYID"))
      params = {description: "description updated", used: false}
      result = sponsor_variable.update_with_clone(params, sponsor_domain)
      check_file_actual_expected(result.to_h, sub_dir, "update_var_2.yaml", equate_method: :hash_equal)
    end

  end

end