require 'rails_helper'

describe "Arm" do

  include DataHelpers

  def sub_dir
    return "models/arm"
  end

  describe "basic tests" do

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
    end

    after :each do
    end

    it "create an instance" do
      item = Arm.create(label: "XXX", description:"D", arm_type:"type")
      actual = Arm.find(item.uri)
      expect(actual.label).to eq("XXX")
      expect(actual.description).to eq("D")
      expect(actual.arm_type).to eq("type")
      check_file_actual_expected(actual.to_h, sub_dir, "create_expected_1.yaml", equate_method: :hash_equal)
    end

  end

end