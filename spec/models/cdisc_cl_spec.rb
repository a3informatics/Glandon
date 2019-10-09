require 'rails_helper'

describe "CdiscCl" do

    include DataHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/cdisc_term"
  end

  def check_term_differences(results, expected)
    expect(results[:status]).to eq(expected[:status])
    expect(results[:result]).to eq(expected[:result])
    expect(results[:children].count).to eq(expected[:children].count)
    results[:children].each do |key, result|
      found = expected[:children][key]
      expect(result).to eq(found)
    end
  end

  def load_versions(range)
    range.each {|n| load_data_file_into_triple_store("cdisc/ct/CT_V#{n}.ttl")}
  end

  describe "CDISC Terminology General" do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
    end

    after :all do
      #
    end

    it "children"

    it "returns the owner" do
      expect(CdiscTerm).to receive(:owner).and_return(IsoRegistrationAuthority.find_by_short_name("CDISC"))
      result = CdiscTerm.owner
      expect(result.to_h).to eq(IsoRegistrationAuthority.find_by_short_name("CDISC").to_h)
    end

  end

end