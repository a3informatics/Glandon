require 'rails_helper'

describe "Timepoint" do

  include DataHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/timepoint"
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
      offset = Timepoint::Offset.create(label: "TP", window_minus: 1, window_plus: 3, window_offset: 2, unit: "Week")
      item = Timepoint.create(label: "TP", lower_bound: 1, upper_bound: 3, at_offset: offset.uri)
      actual = Timepoint.find(item.uri)
      expect(actual.label).to eq("TP")
      expect(actual.next_timepoint).to eq(nil)
      expect(actual.at_offset).to eq(offset.uri)
      expect(actual.in_visit).to eq(nil)
      check_file_actual_expected(actual.to_h, sub_dir, "create_expected_1.yaml", equate_method: :hash_equal)
    end

    it "set unit" do
      allow(SecureRandom).to receive(:uuid).and_return("1234-5678-9012-3301")
      offset = Timepoint::Offset.create(label: "TP", window_minus: 1, window_plus: 3, window_offset: 2, unit: "Week")
      item = Timepoint.create(label: "TP", lower_bound: 1, upper_bound: 3, at_offset: offset.uri)
      item = Timepoint.find(item.uri)
      item.set_unit("MONTH")
      actual = Timepoint.find(offset.uri)
      expect(actual.unit).to eq("Month")
      item.set_unit("days")
      actual = Timepoint.find(offset.uri)
      expect(actual.unit).to eq("Day")
    end

  end

end