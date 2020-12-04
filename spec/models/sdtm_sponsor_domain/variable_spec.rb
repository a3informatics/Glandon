require 'rails_helper'

describe SdtmSponsorDomain::Var do

  include DataHelpers
  include SparqlHelpers

  def sub_dir
    return "models/sdtm_sponsor_domain/variable"
  end

  describe "Validation Tests" do

    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    it "validates a valid object" do
      result = SdtmSponsorDomain::Var.new
      result.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
      result.name = "A1234567"
      expect(result.valid?).to eq(true)
    end

    it "does not validate an invalid object" do
      item = SdtmSponsorDomain::Var.new
      result = item.valid?
      expect(item.errors.full_messages.to_sentence).to eq("Uri can't be blank and Name contains invalid characters, is empty or is too long")
      expect(result).to eq(false)
    end

    it "does not validate an invalid object" do
      item = SdtmSponsorDomain::Var.new
      item.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00002")
      item.name = "VSXXXXXXX"
      result = item.valid?
      expect(item.errors.full_messages.to_sentence).to eq("Name contains invalid characters, is empty or is too long")
      expect(result).to eq(false)
    end

  end

  describe "Delete Tests" do

    before :all do
      data_files = ["SDTM_Sponsor_Domain.ttl"]
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    it "delete single parent" do
      uri_check_set_1 =
      [
        { uri: Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD"), present: true},
        { uri: Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD_RS"), present: true},
        { uri: Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD_SI"), present: true},
        { uri: Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD_STUDYID"), present: true},
        { uri: Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD_AENEWVAR"), present: true},
        { uri: Uri.new(uri: "http://www.assero.co.uk/CSN#52070084-cdd3-4ba8-8377-f670e4b0276c"), present: true}
      ]
      uri_check_set_2 =
      [
        { uri: Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD"), present: true},
        { uri: Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD_RS"), present: true},
        { uri: Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD_SI"), present: true},
        { uri: Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD_STUDYID"), present: true},
        { uri: Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD_AENEWVAR"), present: false},
        { uri: Uri.new(uri: "http://www.assero.co.uk/CSN#52070084-cdd3-4ba8-8377-f670e4b0276c"), present: true}
      ]
      parent = SdtmSponsorDomain.find_full(Uri.new(uri:"http://www.s-cubed.dk/AAA/V1#SPD"))
      params2 = {name:"AENEWVAR"}
      non_standard_variable = parent.add_non_standard_variable(params2)
      parent = SdtmSponsorDomain.find_full(parent.id)
      expect(triple_store.check_uris(uri_check_set_1)).to be(true)
      expect(non_standard_variable.delete_or_unlink(parent)).to eq(1)
      parent = SdtmSponsorDomain.find_full(parent.id)
      expect(triple_store.check_uris(uri_check_set_2)).to be(true)
    end

  end



end