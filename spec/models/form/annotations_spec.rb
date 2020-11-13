require 'rails_helper'

describe Form::Annotations do

	include DataHelpers

	def sub_dir
    return "models/form/annotations"
  end

  describe "basic tests" do

    before :each do
      data_files = ["forms/form_test.ttl","biomedical_concept_instances.ttl", "biomedical_concept_templates.ttl" ]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..1)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V4.ttl")      
    end

    it "create an instance, empty" do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      form = Form.create(label: "Form1", identifier: "XXX")
      form.add_child({type:"normal_group"})
      normal_group = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#NG_1760cbb1-a370-41f6-a3b3-493c1d9c2238"))
      normal_group.add_child({type:"question"})
      normal_group.add_child({type:"question"})
      normal_group.add_child({type:"question"})
      form = Form.find_full(form.uri)
      annotations = Form::Annotations.new(form)
      check_file_actual_expected(annotations.to_h, sub_dir, "new_expected_1.yaml")
    end

    it "create an instance, populated" do
      form = Form.find_full(Uri.new(uri: "http://www.s-cubed.dk/form_test/V1#F"))
      annotations = Form::Annotations.new(form)
      check_file_actual_expected(annotations.to_h, sub_dir, "new_expected_2.yaml")
    end

    it "annotation for uri" do
      form = Form.find_full(Uri.new(uri: "http://www.s-cubed.dk/form_test/V1#F"))
      annotations = Form::Annotations.new(form)
      uri = "http://www.s-cubed.dk/form_test/V1#F_NG4_Q1"
      result = annotations.annotation_for_uri(uri)
      check_file_actual_expected(result.to_h, sub_dir, "annotation_for_uri_expected_1.yaml")
    end

    it "domain list" do
      form = Form.find_full(Uri.new(uri: "http://www.s-cubed.dk/form_test/V1#F"))
      annotations = Form::Annotations.new(form)
      result = annotations.domain_list
      check_file_actual_expected(result, sub_dir, "domain_list_expected_1.yaml")
    end

    # it "add domain class" do
    #   form = Form.find_full(Uri.new(uri: "http://www.s-cubed.dk/form_test/V1#F"))
    #   annotations = Form::Annotations.new(form)
    #   result = annotations.add_domain_class({VS: "Vital Signs"}, "Class name")
    #   check_file_actual_expected(annotations.domain_list, sub_dir, "add_domain_class_expected_1.yaml", write_file: true)
    # end

  end

  describe "Queries" do

    before :each do
      data_files = ["forms/form_test_2.ttl", "forms/form_test.ttl","biomedical_concept_instances.ttl", "biomedical_concept_templates.ttl" ]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..1)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V4.ttl")      
    end

    it "Item annotations" do
      form = Form.find_full(Uri.new(uri: "http://www.s-cubed.dk/form_test/V1#F"))
      annotations = Form::Annotations.new(form)
      check_file_actual_expected(annotations.to_h, sub_dir, "item_annotations_expected_1.yaml")
    end

    it "BC annotations" do
      form = Form.find_full(Uri.new(uri: "http://www.s-cubed.dk/form_test/V1#F"))
      annotations = Form::Annotations.new(form)
      check_file_actual_expected(annotations.to_h, sub_dir, "bc_annotations_expected_1.yaml")
    end

  end

end