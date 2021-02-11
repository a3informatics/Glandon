require 'rails_helper'

describe IsoConceptV2::CodedValueSetTmc do

	include DataHelpers
  include PauseHelpers

	def sub_dir
    return "models/iso_concept_v2/coded_value_set_tmc"
  end

  describe "basic tests" do

    before :each do
      data_files = ["iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl"]
      load_files(schema_files, data_files)
      @parent = Thesaurus::ManagedConcept.new
      @parent.uri = Uri.new(uri: "http://www.assero.co.uk/A#parent")
      @collection_as_objects = [create_ref(1, "A"), create_ref(2, "B")]
      @collection_as_uris = [create_ref(1, "A").uri, create_ref(2, "B").uri]
      @collection_as_ids = [create_ref(1, "A").uri.to_id, create_ref(2, "B").uri.to_id]
    end

    def create_ref(ordinal, ref="ref")
      ref_uri = Uri.new(uri: "http://www.assero.co.uk/A##{ref}")
      OperationalReferenceV3::TmcReference.create({label: "The Label", ordinal: ordinal, reference: ref_uri,}, @parent)
    end

    it "create a class, empty" do
      set = IsoConceptV2::CodedValueSetTmc.new([], @parent)
      check_file_actual_expected(set.items, sub_dir, "new_expected_1.yaml")
    end

    it "create a class, collection objects" do
      set = IsoConceptV2::CodedValueSetTmc.new(@collection_as_objects, @parent)
      check_file_actual_expected(set.items.map{|x| x.to_h}, sub_dir, "new_expected_2.yaml", equate_method: :hash_equal)
    end

    it "create a class, collection uris" do
      set = IsoConceptV2::CodedValueSetTmc.new(@collection_as_uris, @parent)
      check_file_actual_expected(set.items.map{|x| x.to_h}, sub_dir, "new_expected_2.yaml", equate_method: :hash_equal)
    end

    it "create a class, collection ids" do
      set = IsoConceptV2::CodedValueSetTmc.new(@collection_as_ids, @parent)
      check_file_actual_expected(set.items.map{|x| x.to_h}, sub_dir, "new_expected_2.yaml", equate_method: :hash_equal)
    end

    it "adds an item" do
      set = IsoConceptV2::CodedValueSetTmc.new(@collection_as_ids, @parent)
      ref_uri = Uri.new(uri: "http://www.assero.co.uk/A#C")
      set.add(ref_uri, 3)
      check_file_actual_expected(set.items.map{|x| x.to_h}, sub_dir, "new_expected_3.yaml", equate_method: :hash_equal)
    end

  end

  describe "basic tests" do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..10)
      @parent = Thesaurus::ManagedConcept.new
      @parent.uri = Uri.new(uri: "http://www.assero.co.uk/A#parent")
    end

    def create_proper_ref(ordinal, cl)
      OperationalReferenceV3::TmcReference.create({label: "Anything", ordinal: ordinal, reference: cl.uri}, @parent)
    end

    it "update" do
      cl = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C74457/V10#C74457"))
      ref_1 = create_proper_ref(1, cl)
      cl = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C66780/V4#C66780"))
      ref_2 = create_proper_ref(2, cl)
      collection = [ref_1.id, ref_2.id]
      set = IsoConceptV2::CodedValueSetTmc.new(collection, @parent)
      set.update({ct_reference: [ref_1.reference.to_id, ref_2.reference.to_id]})
      check_file_actual_expected(set.items.map{|x| x.to_h}, sub_dir, "update_expected_1.yaml", equate_method: :hash_equal)
    end

  end

end
