require 'rails_helper'

describe Form::Annotations do

	include DataHelpers

	def sub_dir
    return "models/form/annotations"
  end

  describe "basic tests" do

    before :each do
      data_files = []
      load_files(schema_files, [])
      load_cdisc_term_versions(1..1)
      load_data_file_into_triple_store("mdr_identification.ttl")
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
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      form = Form.create(label: "Form1", identifier: "XXX")
      form.add_child({type:"normal_group"})
      normal_group = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#NG_1760cbb1-a370-41f6-a3b3-493c1d9c2238"))
      normal_group.add_child({type:"question"})
      normal_group.add_child({type:"question"})
      normal_group.add_child({type:"question"})
      form = Form.find_full(form.uri)
      uri1 = Uri.new(uri: "http://www.s-cubed.dk/A#A1")
      params = {uri: uri1, domain_prefix: "dom_prefix1",domain_long_name: "dom_long_name1", sdtm_variable: "sdtm_variable" , sdtm_topic_variable:"sdtm_topic_variable" , sdtm_topic_value:"sdtm_topic_value"}
      annotation_1 = Form::Annotation.new(params)
      uri2 = Uri.new(uri: "http://www.s-cubed.dk/A#A2")
      params = {uri: uri2, domain_prefix: "dom_prefix2",domain_long_name: "dom_long_name2", sdtm_variable: "sdtm_variable" , sdtm_topic_variable:"sdtm_topic_variable" , sdtm_topic_value:"sdtm_topic_value"}
      annotation_2 = Form::Annotation.new(params)
      uri3 = Uri.new(uri: "http://www.s-cubed.dk/A#A3")
      params = {uri: uri3, domain_prefix: "dom_prefix3",domain_long_name: "dom_long_name3", sdtm_variable: "sdtm_variable" , sdtm_topic_variable:"sdtm_topic_variable" , sdtm_topic_value:"sdtm_topic_value"}
      annotation_3 = Form::Annotation.new(params)
      annotations = Form::Annotations.new(form)
      annotations.instance_variable_set(:@annotation_set, [annotation_1, annotation_2, annotation_3])
      annotations.instance_variable_set(:@domain_list, annotations.domain_list)
      check_file_actual_expected(annotations.to_h, sub_dir, "new_expected_2.yaml")
    end

    it "annotation for uri" do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      form = Form.create(label: "Form1", identifier: "XXX")
      form.add_child({type:"normal_group"})
      form = Form.find_full(form.uri)
      uri1 = Uri.new(uri: "http://www.s-cubed.dk/A#A1")
      params = {uri: uri1, domain_prefix: "dom_prefix",domain_long_name: "dom_long_name", sdtm_variable: "sdtm_variable" , sdtm_topic_variable:"sdtm_topic_variable" , sdtm_topic_value:"sdtm_topic_value"}
      annotation_1 = Form::Annotation.new(params)
      uri2 = Uri.new(uri: "http://www.s-cubed.dk/A#A2")
      params = {uri: uri2, domain_prefix: "dom_prefix",domain_long_name: "dom_long_name", sdtm_variable: "sdtm_variable" , sdtm_topic_variable:"sdtm_topic_variable" , sdtm_topic_value:"sdtm_topic_value"}
      annotation_2 = Form::Annotation.new(params)
      uri3 = Uri.new(uri: "http://www.s-cubed.dk/A#A3")
      params = {uri: uri3, domain_prefix: "dom_prefix",domain_long_name: "dom_long_name", sdtm_variable: "sdtm_variable" , sdtm_topic_variable:"sdtm_topic_variable" , sdtm_topic_value:"sdtm_topic_value"}
      annotation_3 = Form::Annotation.new(params)
      annotations = Form::Annotations.new(form)
      annotations.instance_variable_set(:@annotation_set, [annotation_1, annotation_2, annotation_3])
      result = annotations.annotation_for_uri(uri2)
      check_file_actual_expected(result.to_h, sub_dir, "annotation_for_uri_expected_1.yaml")
    end

    it "domain list" do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      form = Form.create(label: "Form1", identifier: "XXX")
      form.add_child({type:"normal_group"})
      form = Form.find_full(form.uri)
      uri1 = Uri.new(uri: "http://www.s-cubed.dk/A#A1")
      params = {uri: uri1, domain_prefix: "dom_prefix1",domain_long_name: "dom_long_name1", sdtm_variable: "sdtm_variable" , sdtm_topic_variable:"sdtm_topic_variable" , sdtm_topic_value:"sdtm_topic_value"}
      annotation_1 = Form::Annotation.new(params)
      uri2 = Uri.new(uri: "http://www.s-cubed.dk/A#A2")
      params = {uri: uri2, domain_prefix: "dom_prefix2",domain_long_name: "dom_long_name2", sdtm_variable: "sdtm_variable" , sdtm_topic_variable:"sdtm_topic_variable" , sdtm_topic_value:"sdtm_topic_value"}
      annotation_2 = Form::Annotation.new(params)
      uri3 = Uri.new(uri: "http://www.s-cubed.dk/A#A3")
      params = {uri: uri3, domain_prefix: "dom_prefix3",domain_long_name: "dom_long_name3", sdtm_variable: "sdtm_variable" , sdtm_topic_variable:"sdtm_topic_variable" , sdtm_topic_value:"sdtm_topic_value"}
      annotation_3 = Form::Annotation.new(params)
      annotations = Form::Annotations.new(form)
      annotations.instance_variable_set(:@annotation_set, [annotation_1, annotation_2, annotation_3])
      result = annotations.domain_list
      check_file_actual_expected(result, sub_dir, "domain_list_expected_1.yaml")
    end

  end

end