require 'rails_helper'

describe IsoConceptV2::CodedValueSet do

	include DataHelpers
  include PauseHelpers

	def sub_dir
    return "models/iso_concept_v2/coded_value_set"
  end

  describe "basic tests" do

    before :each do
      data_files = ["iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl"]
      load_files(schema_files, data_files)
      @parent = Thesaurus::UnmanagedConcept.new
      @parent.uri = Uri.new(uri: "http://www.assero.co.uk/A#parent")
      @collection_as_objects = [create_ref(1, "A"), create_ref(2, "B")]
      @collection_as_uris = [create_ref(1, "A").uri, create_ref(2, "B").uri]
      @collection_as_ids = [create_ref(1, "A").uri.to_id, create_ref(2, "B").uri.to_id]
    end

    after :each do
    end

    def create_ref(ordinal, ref="ref")
      ref_uri = Uri.new(uri: "http://www.assero.co.uk/A##{ref}")
      context_uri = Uri.new(uri: "http://www.assero.co.uk/A#context")
      OperationalReferenceV3::TucReference.create({label: "The Label", local_label: "Something local", ordinal: ordinal, reference: ref_uri, context: context_uri}, @parent)
    end

    it "create a class, empty" do
      set = IsoConceptV2::CodedValueSet.new([], @parent)
      check_file_actual_expected(set.items, sub_dir, "new_expected_1.yaml")
    end

    it "create a class, collection objects" do
      set = IsoConceptV2::CodedValueSet.new(@collection_as_objects, @parent)
      check_file_actual_expected(set.items.map{|x| x.to_h}, sub_dir, "new_expected_2.yaml", equate_method: :hash_equal)
    end

    it "create a class, collection uris" do
      set = IsoConceptV2::CodedValueSet.new(@collection_as_uris, @parent)
      check_file_actual_expected(set.items.map{|x| x.to_h}, sub_dir, "new_expected_2.yaml", equate_method: :hash_equal)
    end

    it "create a class, collection ids" do
      set = IsoConceptV2::CodedValueSet.new(@collection_as_ids, @parent)
      check_file_actual_expected(set.items.map{|x| x.to_h}, sub_dir, "new_expected_2.yaml", equate_method: :hash_equal)
    end

    it "adds an item" do
      set = IsoConceptV2::CodedValueSet.new(@collection_as_ids, @parent)
      ref_uri = Uri.new(uri: "http://www.assero.co.uk/A#C")
      context_uri = Uri.new(uri: "http://www.assero.co.uk/A#context")
      set.add({id: ref_uri, context_id: context_uri}, 3)
      check_file_actual_expected(set.items.map{|x| x.to_h}, sub_dir, "new_expected_3.yaml", equate_method: :hash_equal)
    end

  end

  describe "basic tests" do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..10)
      @parent = Thesaurus::UnmanagedConcept.new
      @parent.uri = Uri.new(uri: "http://www.assero.co.uk/A#parent")
    end

    after :each do
    end

    def create_proper_ref(ordinal, cl, cli)
      OperationalReferenceV3::TucReference.create({label: "Anything", local_label: "Something local", ordinal: ordinal, reference: cli.uri, context: cl.uri}, @parent)
    end

    it "update" do
      cl = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C74457/V10#C74457"))
      cli = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C74457/V10#C74457_C41259"))
      ref_1 = create_proper_ref(1, cl, cli)
      cli = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C74457/V10#C74457_C41260"))
      ref_2 = create_proper_ref(2, cl, cli)
      collection = [ref_1.id, ref_2.id]
      set = IsoConceptV2::CodedValueSet.new(collection, @parent)
      cli = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C74457/V10#C74457_C41219"))
      set.update({has_coded_value: [{id: ref_1.reference.to_id, context_id: cl.id}, {id: ref_2.reference.to_id, context_id: cl.id}, {id: cli.id, context_id: cl.id}]})
      check_file_actual_expected(set.items.map{|x| x.to_h}, sub_dir, "update_expected_1.yaml", equate_method: :hash_equal)
    end

  end

end
