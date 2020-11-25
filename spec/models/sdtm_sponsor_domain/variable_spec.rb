require 'rails_helper'

describe SdtmSponsorDomain::Variable do

  include DataHelpers
  include SparqlHelpers

  def sub_dir
    return "models/sdtm_sponsor_domain/variable"
  end

  before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
  end

  it "validates a valid object" do
    result = SdtmSponsorDomain::Variable.new
    result.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
    expect(result.valid?).to eq(true)
  end

  it "does not validate an invalid object" do
    item = SdtmSponsorDomain::Variable.new
    result = item.valid?
    expect(item.errors.full_messages.to_sentence).to eq("Uri can't be blank")
    expect(result).to eq(false)
  end

end