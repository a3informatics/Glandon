require 'rails_helper'

describe "Timepoint::Offset" do

  include DataHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/timepoint/offset"
  end

  describe "basic tests" do

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
    end

    after :each do
    end

    it "create an instance" do
      allow(SecureRandom).to receive(:uuid).and_return("1234-5678-9012-3301")
      item = Timepoint::Offset.create(label: "TP", window_minus: 1, window_plus: 3, window_offset: 2)
      actual = Timepoint::Offset.find(item.uri)
      expect(actual.label).to eq("TP")
      expect(actual.window_minus).to eq(1)
      expect(actual.window_plus).to eq(3)
      expect(actual.window_offset).to eq(2)
      check_file_actual_expected(actual.to_h, sub_dir, "create_expected_1.yaml", equate_method: :hash_equal)
    end

  end

end