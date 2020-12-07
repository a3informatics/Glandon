require 'rails_helper'

describe Thesaurus::McCustomProperties do

	include DataHelpers
  include PauseHelpers
  include SecureRandomHelpers
  include CustomPropertyHelpers
  
	def sub_dir
    return "models/thesaurus/mc_custom_properties"
  end


  describe "basic tests" do

    before :each do
      data_files = ["iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl"]
      load_files(schema_files, data_files)
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      create_data
    end

    after :each do
    end

    it "existing custom property set" do
      result = @parent.existing_custom_property_set
      check_file_actual_expected(result.map{|x| x.to_s}, sub_dir, "existing_custom_property_expected_1.yaml")
    end

  end

end
