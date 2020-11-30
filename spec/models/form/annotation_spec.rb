require 'rails_helper'

describe Form::Annotation do

	include DataHelpers

	def sub_dir
    return "models/form/annotation"
  end

  describe "basic tests" do

    before :each do
      load_files(schema_files, [])
    end

    it "create an instance" do
      uri = Uri.new(uri: "http://www.s-cubed.dk/A#A1")
      params = {uri: uri, domain_prefix: "dom_prefix",domain_long_name: "dom_long_name", sdtm_variable: "sdtm_variable" , sdtm_topic_variable:"sdtm_topic_variable" , sdtm_topic_value:"sdtm_topic_value"}
      annotation = Form::Annotation.new(params)
      check_file_actual_expected(annotation.to_h, sub_dir, "new_expected_1.yaml")
    end

    it "domain prefix" do
      uri = Uri.new(uri: "http://www.s-cubed.dk/A#A1")
      params = {uri: uri, domain_prefix: "domain_prefix_expected",domain_long_name: "dom_long_name", sdtm_variable: "sdtm_variable" , sdtm_topic_variable:"sdtm_topic_variable" , sdtm_topic_value:"sdtm_topic_value"}
      annotation = Form::Annotation.new(params)
      result = annotation.domain_prefix
      check_file_actual_expected(result, sub_dir, "domain_prefix_expected_1.yaml")
    end

    it "domain long name" do
      uri = Uri.new(uri: "http://www.s-cubed.dk/A#A1")
      params = {uri: uri, domain_prefix: "dom_prefix",domain_long_name: "domain_long_name_expected", sdtm_variable: "sdtm_variable" , sdtm_topic_variable:"sdtm_topic_variable" , sdtm_topic_value:"sdtm_topic_value"}
      annotation = Form::Annotation.new(params)
      result = annotation.domain_long_name
      check_file_actual_expected(result, sub_dir, "domain_long_name_expected_1.yaml")
    end

  end

end