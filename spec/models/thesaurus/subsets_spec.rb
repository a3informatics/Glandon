require 'rails_helper'

describe "Thesaurus::Subsets" do

  include DataHelpers
  include IsoManagedHelpers

  def sub_dir
    return "models/thesaurus/subsets"
  end

  describe "Subset Code List Checks" do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_subsets_1.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..20)
      NameValue.destroy_all
      NameValue.create(name: "thesaurus_parent_identifier", value: "123")
      NameValue.create(name: "thesaurus_child_identifier", value: "456")
    end

    it "determines if an item is subsetted" do
      cl = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri:"http://www.cdisc.org/C66726/V19#C66726"))
      subsets = cl.subsetted_by
      expect(subsets.count).to eq(2)
      expect(subsets[0][:s].to_s).to eq("http://www.s-cubed.dk/S000001/V19#S000001")
      expect(subsets[1][:s].to_s).to eq("http://www.s-cubed.dk/S000002/V19#S000002")
    end

    it "determines if an item is subsetted, none found" do
      cl2 = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri:"http://www.cdisc.org/C87162/V19#C87162"))
      expect(cl2.subsetted_by).to eq(nil)
    end

    it "determines if an item is a subset and finds" do
      cl = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri:"http://www.s-cubed.dk/S000001/V19#S000001"))
      expect(cl.subset?).to eq(true)
      expect(cl.subset_of).to_not eq(nil)
      expect(cl.subset_of.to_s).to eq("http://www.cdisc.org/C66726/V19#C66726")
      cl = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri:"http://www.cdisc.org/C66726/V19#C66726"))
      expect(cl.subset?).to eq(false)
      expect(cl.subset_of).to eq(nil)
    end

  end

  describe "Upgrades" do
  
    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..45)
      NameValue.destroy_all
      NameValue.create(name: "thesaurus_parent_identifier", value: "123")
      NameValue.create(name: "thesaurus_child_identifier", value: "456")
    end

    it "can upgrade a subset" do
      tc_32 = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C99079/V32#C99079"))
      tc_34 = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C99079/V34#C99079"))
      tc_45 = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C99079/V45#C99079"))
      item_1 = tc_32.create_subset
      item_1 = Thesaurus::ManagedConcept.find_minimum(item_1.id)
      expect(item_1.subsets_links.to_s).to eq("http://www.cdisc.org/C99079/V32#C99079")
      expect(item_1.is_ordered_objects).not_to be(nil)
      expect(item_1.is_ordered_objects.members).to be(nil)
      expect(item_1.narrower.count).to eq(0)
      uri_1 = Uri.new(uri: "http://www.cdisc.org/C99079/V28#C99079_C42872")
      uri_2 = Uri.new(uri: "http://www.cdisc.org/C99079/V28#C99079_C48262")
      uri_3 = Uri.new(uri: "http://www.cdisc.org/C99079/V34#C99079_C16032")
      item_1.is_ordered.add([uri_1.to_id, uri_2.to_id])
      item_1 = Thesaurus::ManagedConcept.find_with_properties(item_1.id)
      expect(item_1.subsets_links.to_s).to eq("http://www.cdisc.org/C99079/V32#C99079")
      item_1.narrower_objects
      expect(item_1.narrower.count).to eq(2)
      result = item_1.to_h
      result[:preferred_term] = "http://www.assero.co.uk/PT#17af17b8-1ad2-4151-ba39-c6c27de2480a"
      result[:is_ordered] = "http://www.assero.co.uk/TS#aef73f0b-3538-4c42-a74b-4c6d346021ec"
      result[:last_change_date] = "2020-02-16T18:31:47+01:00"
      result[:creation_date] = "2020-02-16T18:31:47+01:00"
      check_file_actual_expected(result, sub_dir, "upgrade_expected_1a.yaml", equate_method: :hash_equal)
      check_file_actual_expected(item_1.is_ordered_objects.list.map{|x| x.item.to_s}, sub_dir, "upgrade_list_expected_1a.yaml", equate_method: :hash_equal)
      item_2 = item_1.upgrade_subset(tc_34)
      item_2 = Thesaurus::ManagedConcept.find(item_2.uri)
      expect(item_2.narrower.count).to eq(2)
      result = item_2.to_h
      result[:preferred_term] = "http://www.assero.co.uk/PT#17af17b8-1ad2-4151-ba39-c6c27de2480a"
      result[:is_ordered] = "http://www.assero.co.uk/TS#aef73f0b-3538-4c42-a74b-4c6d346021ec"
      result[:last_change_date] = "2020-02-16T18:31:47+01:00"
      result[:creation_date] = "2020-02-16T18:31:47+01:00"
      check_file_actual_expected(result, sub_dir, "upgrade_expected_1b.yaml", equate_method: :hash_equal)
      check_file_actual_expected(item_2.is_ordered_objects.list.map{|x| x.item.to_s}, sub_dir, "upgrade_list_expected_1b.yaml", equate_method: :hash_equal)
      item_2.is_ordered_objects.add([uri_3.to_id])
      item_3 = item_1.upgrade_subset(tc_45)
      item_3 = Thesaurus::ManagedConcept.find(item_3.uri)
      expect(item_3.narrower.count).to eq(3)
      result = item_3.to_h
      result[:preferred_term] = "http://www.assero.co.uk/PT#17af17b8-1ad2-4151-ba39-c6c27de2480a"
      result[:is_ordered] = "http://www.assero.co.uk/TS#aef73f0b-3538-4c42-a74b-4c6d346021ec"
      result[:last_change_date] = "2020-02-16T18:31:47+01:00"
      result[:creation_date] = "2020-02-16T18:31:47+01:00"
      check_file_actual_expected(result, sub_dir, "upgrade_expected_1c.yaml", equate_method: :hash_equal)
      check_file_actual_expected(item_3.is_ordered_objects.list.map{|x| x.item.to_s}, sub_dir, "upgrade_list_expected_1c.yaml", equate_method: :hash_equal)
      tc_32 = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C99079/V32#C99079"))
      expect(tc_32.narrower.count).to eq(7)
      tc_34 = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C99079/V34#C99079"))
      expect(tc_34.narrower.count).to eq(8)
      tc_45 = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C99079/V45#C99079"))
      expect(tc_45.narrower.count).to eq(10)
    end

  end

end
