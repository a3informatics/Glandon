require 'rails_helper'

describe IsoManagedV2::RegistrationStatus do

  include DataHelpers
  include IsoManagedHelpers
  include IsoManagedFactory

  def sub_dir
    return "models/iso_managed_v2/registration_status"
  end

  describe "Status General" do

    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    it "provides summary of status" do
      expected = 
      {
        :current => false,
        :next_state => {
          :definition=>"The Administered Item has been proposed for progression through the registration levels.", 
          :label=>"Candidate"
        },
        :semantic_version => 
        {
          :editable=>false, :label=>"0.1.0", 
          :next_versions=>{:major=>"1.0.0", :minor=>"0.1.0", :patch=>"0.0.1"}
        },
        :state => {
          :definition=>"Submitter wishes to make the community that uses this metadata register aware of the existence of an Administered Item in their local domain.", 
          :label=>"Incomplete"
        },
        :version_label => ""
      }
      item = create_iso_managed("ITEM 1", "This is item 1")
      result = item.status_summary
      expect(result).to eq(expected)
    end

    it "update status permitted, default" do
      item = create_iso_managed("ITEM 2", "This is item 1")
      expect(item.update_status_permitted?).to eq(true)
    end

    it "update status related items, default" do
      item = create_iso_managed("ITEM 3", "This is item 1")
      expect(item.update_status_dependent_items(:update)).to eq([])
    end

    it "next state, basic" do
      item = create_iso_managed("ITEM 4", "This is item 1")
      item.next_state(administrative_note: "admin note", unresolved_issue: "unresolved")
      item = IsoManagedV2.find_minimum(item.uri)
      fix_dates(item, sub_dir, "next_state_expected_1.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(item.to_h, sub_dir, "next_state_expected_1.yaml", equate_method: :hash_equal)
    end

    it "next state, standard" do
      item = create_iso_managed("ITEM 5", "This is item 1")
      IsoManagedHelpers.make_item_standard(item)
      item.next_state(administrative_note: "admin note", unresolved_issue: "unresolved")
      item = IsoManagedV2.find_minimum(item.uri)
      fix_dates(item, sub_dir, "next_state_expected_2.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(item.to_h, sub_dir, "next_state_expected_2.yaml", equate_method: :hash_equal)
    end

    it "next state, superseded" do
      item = create_iso_managed("ITEM 6", "This is item 1")
      IsoManagedHelpers.make_item_superseded(item)
      item.next_state(administrative_note: "admin note", unresolved_issue: "unresolved")
      item = IsoManagedV2.find_minimum(item.uri)
      fix_dates(item, sub_dir, "next_state_expected_3.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(item.to_h, sub_dir, "next_state_expected_3.yaml", equate_method: :hash_equal)
    end

    it "allows the item status to be updated, error" do
      item = create_iso_managed("ITEM 7", "This is item 1")
      IsoManagedHelpers.make_item_superseded(item)
      item.next_state(administrative_note: "§§§§§§§§§admin note", unresolved_issue: "unresolved§§§§§§§")
    end

    it "generates the audit message for Status update" do
      item = create_iso_managed("ITEM 8", "This is item 1")
      IsoManagedHelpers.make_item_candidate(item)
      expect(item.audit_message_status_update).to eq("Unknown audit type owner: S-cubed, identifier: ITEM 8, state was updated from Incomplete to Candidate.")
    end

    it "provides the registration status summary hash" do
      item = create_iso_managed("ITEM 10", "This is item 10")
      result = item.registration_status_summary(:fast_forward)
      check_file_actual_expected(result, sub_dir, "registration_status_summary_expected_1.yaml", equate_method: :hash_equal)
    end

  end

  # describe "Filter to Owned" do

  #   before :all do
  #     load_files(schema_files, [])
  #     load_data_file_into_triple_store("mdr_identification.ttl")
  #   end

  #   it "filter_to_owned I" do
  #     item_1 = create_iso_managed("ITEM 1A", "This is item 1")
  #     item_2 = create_iso_managed("ITEM 2A", "This is item 2")
  #     item_3 = create_iso_managed("ITEM 3A", "This is item 3")
  #     item_4 = create_iso_managed("ITEM 4A", "This is item 4")
  #     item_5 = create_iso_managed("ITEM 5A", "This is item 5")
  #     item_4 = change_ownership(item_4, IsoRegistrationAuthority.find_by_short_name("CDISC"))
  #     item_5 = change_ownership(item_5, IsoRegistrationAuthority.find_by_short_name("CDISC"))
  #     results = IsoManagedV2.filter_to_owned([item_1.uri.to_id, item_2.uri.to_id, item_3.uri.to_id, item_4.uri.to_id, item_5.uri.to_id])
  #     check_file_actual_expected(results.map{|x| x.to_s}, sub_dir, "filter_to_owned_expected_1.yaml", equate_method: :hash_equal)
  #   end

  #   it "filter_to_owned II" do
  #     item_1 = create_iso_managed("ITEM 1B", "This is item 1")
  #     item_2 = create_iso_managed("ITEM 2B", "This is item 2")
  #     item_3 = create_iso_managed("ITEM 3B", "This is item 3")
  #     results = IsoManagedV2.filter_to_owned([item_1.uri.to_id, item_2.uri.to_id, item_3.uri.to_id])
  #     check_file_actual_expected(results.map{|x| x.to_s}, sub_dir, "filter_to_owned_expected_2.yaml", equate_method: :hash_equal)
  #   end

  #   it "filter_to_owned III" do
  #     item_1 = create_iso_managed("ITEM 1C", "This is item 1")
  #     item_2 = create_iso_managed("ITEM 2C", "This is item 2")
  #     item_3 = create_iso_managed("ITEM 3C", "This is item 3")
  #     item_4 = create_iso_managed("ITEM 4C", "This is item 4")
  #     item_5 = create_iso_managed("ITEM 5C", "This is item 5")
  #     item_1 = change_ownership(item_1, IsoRegistrationAuthority.find_by_short_name("CDISC"))
  #     item_2 = change_ownership(item_2, IsoRegistrationAuthority.find_by_short_name("CDISC"))
  #     item_3 = change_ownership(item_3, IsoRegistrationAuthority.find_by_short_name("CDISC"))
  #     item_4 = change_ownership(item_4, IsoRegistrationAuthority.find_by_short_name("CDISC"))
  #     item_5 = change_ownership(item_5, IsoRegistrationAuthority.find_by_short_name("CDISC"))
  #     results = IsoManagedV2.filter_to_owned([item_1.uri.to_id, item_2.uri.to_id, item_3.uri.to_id, item_4.uri.to_id, item_5.uri.to_id])
  #     check_file_actual_expected(results.map{|x| x.to_s}, sub_dir, "filter_to_owned_expected_3.yaml", equate_method: :hash_equal)
  #   end

  #   it "filter_to_owned IV" do
  #     expect(IsoManagedV2.filter_to_owned([])).to eq([])
  #   end

  # end

  def check_mi_array(items, filename, write_file=false)
    results = []
    unless write_file
      items.each_with_index do |x, index| 
        results << IsoManagedV2.find_minimum(x.uri).to_h 
        expected = read_yaml_file(sub_dir, filename)
        [:last_change_date, :creation_date].each do |a|
          expect(results[index][a].to_time_with_default).to be_within(5.seconds).of Time.now
          results[index][a] = expected[index][a]
        end
        [:effective_date].each do |a|
          now = Time.now.to_i
          just_now = Time.now.to_i - 5
          next unless (just_now..now).include?(results[index][:has_state][a].to_time_with_default.to_i)
          results[index][:has_state][a] = expected[index][:has_state][a]
        end
      end
    else
      items.each_with_index do |x, index| 
        results << IsoManagedV2.find_minimum(x.uri).to_h 
      end
    end
    check_file_actual_expected(results, sub_dir, filename, equate_method: :hash_equal, write_file: write_file)
  end

  describe "Fast Forward State" do

    before :each do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
      @cdisc_ra = IsoRegistrationAuthority.find_by_short_name("CDISC")
    end

    it "fast forward set, simple case" do
      items = []
      results = []
      (1..5).each_with_index { |x, index| items << create_iso_managed("ITEM #{index+1}", "This is item #{index+1}") }
      results = IsoManagedV2.find_minimum_set(items.map{ |x| x.uri })
      check_file_actual_expected(results.map{ |x| x.uri.to_s}, sub_dir, "fast_forward_permitted_expected_1.yaml", equate_method: :hash_equal)
    end

    it "fast forward state, simple case" do
      items = []
      results = []
      (1..5).each_with_index { |x, index| items << create_iso_managed("ITEM #{index+1}", "This is item #{index+1}") }
      [items[0], items[1]].each { |x| x = change_ownership(x, @cdisc_ra) }
      result = IsoManagedV2.fast_forward_state(items.map{ |x| x.uri })
      expect(result).to eq(true)
      expect(items.map { |x| IsoManagedV2.find_minimum(x.uri).registration_status }).to eq(["Incomplete", "Incomplete", "Standard", "Standard", "Standard"])
      check_mi_array(items, "fast_forward_state_expected_1.yaml")
    end

    it "fast forward state, previous version" do
      items = []
      results = []
      (1..5).each_with_index { |x, index| items << create_iso_managed("ITEM #{index+1}", "This is item #{index+1}") }
      [items[0], items[1]].each { |x| x = change_ownership(x, @cdisc_ra) }
      next_version = create_iso_managed("ITEM 6", "This is item 6")
      next_version.has_previous_version = items.last
      next_version.save
      result = IsoManagedV2.fast_forward_state(items.map{ |x| x.uri })
      expect(result).to eq(true)
      expect(items.map { |x| IsoManagedV2.find_minimum(x.uri).registration_status }).to eq(["Incomplete", "Incomplete", "Standard", "Standard", "Incomplete"])
      items.each_with_index { |x, index| results << IsoManagedV2.find_minimum(x.uri).to_h }
      check_mi_array(items, "fast_forward_state_expected_2.yaml")
    end

    it "checks fast forward allowed" do
      item = create_iso_managed("ITEM 1", "This is item 1")
      expect(item.fast_forward?).to eq(true)
      change_ownership(item, @cdisc_ra)
      expect(item.fast_forward?).to eq(false)
      previous_version = create_iso_managed("ITEM 2", "This is item 2")
      next_version = create_iso_managed("ITEM 3", "This is item 3")
      next_version.has_previous_version = previous_version
      next_version.save
      expect(previous_version.fast_forward?).to eq(false)
      expect(next_version.fast_forward?).to eq(true)
      item = create_iso_managed("ITEM 4", "This is item 4")
      IsoManagedHelpers.make_item_superseded(item)
      expect(item.fast_forward?).to eq(false)
    end

  end

  describe "Rewind State" do

    before :each do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
      @cdisc_ra = IsoRegistrationAuthority.find_by_short_name("CDISC")
    end

    it "rewind set, simple case" do
      items = []
      results = []
      (1..5).each_with_index { |x, index| items << create_iso_managed("ITEM #{index+1}", "This is item #{index+1}") }
      results = IsoManagedV2.find_minimum_set(items.map{ |x| x.uri })
      check_file_actual_expected(results.map{ |x| x.uri.to_s}, sub_dir, "rewind_permitted_expected_1.yaml", equate_method: :hash_equal)
    end

    it "rewind state, simple case" do
      items = []
      results = []
      (1..5).each_with_index { |x, index| items << create_iso_managed("ITEM #{index+1}", "This is item #{index+1}") }
      [items[0], items[1]].each_with_index { |x, index| items[index] = change_ownership(x, @cdisc_ra) }
      [items[0], items[1], items[2], items[3], items[4]].each_with_index { |x, index| items[index] = IsoManagedHelpers.make_item_standard(x) }
      result = IsoManagedV2.rewind_state(items.map{ |x| x.uri })
      expect(result).to eq(true)
      expect(items.map { |x| IsoManagedV2.find_minimum(x.uri).registration_status }).to eq(["Standard", "Standard", "Incomplete", "Incomplete", "Incomplete"])
      check_mi_array(items, "rewind_state_expected_1.yaml")
    end

    it "rewind state, previous at standard, should rewind" do
      items = []
      results = []
      (1..5).each_with_index { |x, index| items << create_iso_managed("ITEM #{index+1}", "This is item #{index+1}") }
      [items[0], items[1]].each_with_index { |x, index| items[index] = change_ownership(x, @cdisc_ra) }
      [items[0], items[1], items[2], items[3], items[4]].each_with_index { |x, index| items[index] = IsoManagedHelpers.make_item_standard(x) }
      items[5] = IsoManagedHelpers.next_version(items[2])
      items[5] = IsoManagedHelpers.make_item_qualified(items[5]) 
      result = IsoManagedV2.rewind_state([items[0].uri, items[1].uri, items[3].uri, items[4].uri, items[5].uri])
      expect(items.map { |x| IsoManagedV2.find_minimum(x.uri).registration_status }).to eq(["Standard", "Standard", "Standard", "Incomplete", "Incomplete", "Incomplete"])
      check_mi_array(items, "rewind_state_expected_2.yaml")
    end

    it "rewind state, previous not at standard, no rewind" do
      items = []
      results = []
      (1..5).each_with_index { |x, index| items << create_iso_managed("ITEM #{index+1}", "This is item #{index+1}") }
      [items[0], items[1]].each_with_index { |x, index| items[index] = change_ownership(x, @cdisc_ra) }
      [items[0], items[1], items[2], items[3], items[4]].each_with_index { |x, index| items[index] = IsoManagedHelpers.make_item_standard(x) }
      items[5] = IsoManagedHelpers.next_version(items[2])
      items[5] = IsoManagedHelpers.make_item_qualified(items[5]) 
      items[6] = IsoManagedHelpers.next_version(items[5])
      result = IsoManagedV2.rewind_state([items[0].uri, items[1].uri, items[3].uri, items[4].uri, items[6].uri])
      expect(items.map { |x| IsoManagedV2.find_minimum(x.uri).registration_status }).to eq(["Standard", "Standard", "Standard", "Incomplete", "Incomplete", "Qualified", "Qualified"])
      check_mi_array(items, "rewind_state_expected_3.yaml")
    end

    it "rewind state, previous at standard, should rewind, remove current" do
      items = []
      results = []
      (1..5).each_with_index do |x, index| 
        items << create_iso_managed("ITEM #{index+1}", "This is item #{index+1}") 
        items[index] = make_current(items[index])
      end
      [items[0], items[1]].each_with_index do |x, index| 
        items[index] = change_ownership(x, @cdisc_ra)
      end
      expect(items.map { |x| x.current? }).to eq([true, true, true, true, true])
      [items[0], items[1], items[2], items[3], items[4]].each_with_index { |x, index| items[index] = IsoManagedHelpers.make_item_standard(x) }
      items[5] = IsoManagedHelpers.next_version(items[2])
      items[5] = IsoManagedHelpers.make_item_qualified(items[5]) 
      expect(items.map { |x| x.current? }).to eq([true, true, true, true, true, false])
      result = IsoManagedV2.rewind_state([items[0].uri, items[1].uri, items[3].uri, items[4].uri, items[5].uri])
      items.each_with_index { |x, index| items[index] = IsoManagedV2.find_minimum(x.uri)}
      expect(items.map { |x| x.registration_status }).to eq(["Standard", "Standard", "Standard", "Incomplete", "Incomplete", "Incomplete"])
      expect(items.map { |x| x.current? }).to eq([true, true, true, false, false, false])
      check_mi_array(items, "rewind_state_expected_4.yaml")
    end

    it "checks rewind allowed" do
      item = create_iso_managed("ITEM 1", "This is item 1")
      IsoManagedHelpers.make_item_standard(item)
      expect(item.rewind?).to eq(true)
      change_ownership(item, @cdisc_ra)
      expect(item.rewind?).to eq(false)
      previous_version = create_iso_managed("ITEM 2", "This is item 2")
      IsoManagedHelpers.make_item_standard(previous_version)
      next_version = create_iso_managed("ITEM 3", "This is item 3")
      next_version.has_previous_version = previous_version
      next_version.save
      expect(previous_version.rewind?).to eq(false)
      expect(next_version.rewind?).to eq(true)
    end

  end

end