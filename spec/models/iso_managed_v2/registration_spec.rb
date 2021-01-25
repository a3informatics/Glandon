require 'rails_helper'

describe IsoManagedV2::Registration do

  include DataHelpers
  include IsoManagedHelpers
  include IsoManagedFactory

  def sub_dir
    return "models/iso_managed_v2/registration"
  end

  describe "Filter to Owned" do

    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    before :each do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
    end

    it "filter_to_owned I" do
      item_1 = create_iso_managed("ITEM 1", "This is item 1")
      item_2 = create_iso_managed("ITEM 2", "This is item 2")
      item_3 = create_iso_managed("ITEM 3", "This is item 3")
      item_4 = create_iso_managed("ITEM 4", "This is item 4")
      item_5 = create_iso_managed("ITEM 5", "This is item 5")
      item_4 = change_ownership(item_4, IsoRegistrationAuthority.find_by_short_name("CDISC"))
      item_5 = change_ownership(item_5, IsoRegistrationAuthority.find_by_short_name("CDISC"))
      results = IsoManagedV2.filter_to_owned([item_1.uri.to_id, item_2.uri.to_id, item_3.uri.to_id, item_4.uri.to_id, item_5.uri.to_id])
      check_file_actual_expected(results.map{|x| x.to_s}, sub_dir, "filter_to_owned_expected_1.yaml", equate_method: :hash_equal)
    end

    it "filter_to_owned II" do
      item_1 = create_iso_managed("ITEM 1", "This is item 1")
      item_2 = create_iso_managed("ITEM 2", "This is item 2")
      item_3 = create_iso_managed("ITEM 3", "This is item 3")
      results = IsoManagedV2.filter_to_owned([item_1.uri.to_id, item_2.uri.to_id, item_3.uri.to_id])
      check_file_actual_expected(results.map{|x| x.to_s}, sub_dir, "filter_to_owned_expected_2.yaml", equate_method: :hash_equal)
    end

    it "filter_to_owned III" do
      item_1 = create_iso_managed("ITEM 1", "This is item 1")
      item_2 = create_iso_managed("ITEM 2", "This is item 2")
      item_3 = create_iso_managed("ITEM 3", "This is item 3")
      item_4 = create_iso_managed("ITEM 4", "This is item 4")
      item_5 = create_iso_managed("ITEM 5", "This is item 5")
      item_1 = change_ownership(item_1, IsoRegistrationAuthority.find_by_short_name("CDISC"))
      item_2 = change_ownership(item_2, IsoRegistrationAuthority.find_by_short_name("CDISC"))
      item_3 = change_ownership(item_3, IsoRegistrationAuthority.find_by_short_name("CDISC"))
      item_4 = change_ownership(item_4, IsoRegistrationAuthority.find_by_short_name("CDISC"))
      item_5 = change_ownership(item_5, IsoRegistrationAuthority.find_by_short_name("CDISC"))
      results = IsoManagedV2.filter_to_owned([item_1.uri.to_id, item_2.uri.to_id, item_3.uri.to_id, item_4.uri.to_id, item_5.uri.to_id])
      check_file_actual_expected(results.map{|x| x.to_s}, sub_dir, "filter_to_owned_expected_3.yaml", equate_method: :hash_equal)
    end

    it "filter_to_owned IV" do
      expect(IsoManagedV2.filter_to_owned([])).to eq([])
    end

  end

  describe "Advance to Released State" do

    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    before :each do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
    end

    it "advance_to_released_state I" do
      item_1 = create_iso_managed("ITEM 1", "This is item 1")
      item_2 = create_iso_managed("ITEM 2", "This is item 2")
      item_3 = create_iso_managed("ITEM 3", "This is item 3")
      item_4 = create_iso_managed("ITEM 4", "This is item 4")
      item_5 = create_iso_managed("ITEM 5", "This is item 5")
      item_1 = change_ownership(item_1, IsoRegistrationAuthority.find_by_short_name("CDISC"))
      item_2 = change_ownership(item_2, IsoRegistrationAuthority.find_by_short_name("CDISC"))
      item_3 = change_ownership(item_3, IsoRegistrationAuthority.find_by_short_name("CDISC"))
      item_4 = change_ownership(item_4, IsoRegistrationAuthority.find_by_short_name("CDISC"))
      item_5 = change_ownership(item_5, IsoRegistrationAuthority.find_by_short_name("CDISC"))
      results = IsoManagedV2.advance_to_released_state([item_1.uri.to_id, item_2.uri.to_id, item_3.uri.to_id, item_4.uri.to_id, item_5.uri.to_id])
      check_file_actual_expected(results.map{|x| x.to_s}, sub_dir, "advanced_to_release_state_expected_1.yaml", equate_method: :hash_equal, write_file: true)
    end

  end

end