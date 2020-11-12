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
      annotation = Form::Annotation.new(uri, "domain_prefix", "domain_long_name", "sdtm_variable", "sdtm_topic_variable", "sdtm_topic_value")
      check_file_actual_expected(annotation, sub_dir, "new_expected_1.yaml", write_file: true)
    end

  end

end