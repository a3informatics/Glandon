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
      item = Timepoint.create(label: "TP", lower_bound: 1, upper_bound: 3, offset: 2)
      actual = Timepoint.find(item.uri)
      expect(actual.label).to eq("TP")
      expect(actual.lower_bound).to eq(1)
      expect(actual.upper_bound).to eq(3)
      expect(actual.offset).to eq(2)
      expect(actual.next_timepoint).to eq(nil)
      expect(actual.in_visit).to eq(nil)
      check_file_actual_expected(actual.to_h, sub_dir, "create_expected_1.yaml", equate_method: :hash_equal)
    end

  end

end