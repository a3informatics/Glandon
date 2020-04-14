require 'rails_helper'

describe Form do

  include DataHelpers
  include ValidationHelpers
  include SparqlHelpers
  include PublicFileHelpers
  
  def sub_dir
    return "models/form/data"
  end

  describe "general tests" do

    def simple_form_1
      @f_1 = Form.new
      @g_1 = Form::Group::Normal.from_h({
          label: "Question Group",
          completion: "",
          optional: "false",
          repeating: "false",
          ordinal: 1,
          note: ""
        })
      @q_1 = Form::Item::Question.from_h({
          label: "Race",
          completion: "Race must be self-reported by the subject (not judged by the site)",
          mapping: "RACE",
          question_text: "Race:",
          optional: "false",
          format: "",
          ordinal: 1,
          note: ""
        })
      @q_2 = Form::Item::Question.from_h({
          label: "Sex",
          completion: "* Indicate the appropriate sex.",
          mapping: "SEX",
          question_text: "Sex:",
          optional: "false",
          format: "",
          ordinal: 2,
          note: ""
        })
      @tl_1 = Form::Item::TextLabel.from_h({
          label_text: "Label Text 1",
          ordinal: 1
        })
      @tl_2 = Form::Item::TextLabel.from_h({
        label_text: "Label Text 2",
        ordinal: 2
      })
      @ph_1 = Form::Item::Placeholder.from_h({
        free_text: "Free text",
        ordinal: 1
      })
      @ph_2 = Form::Item::Placeholder.from_h({
        free_text: "Free text 2",
        ordinal: 2
      })
      @m_1 = Form::Item::Mapping.from_h({
        mapping: "Mapping",
        ordinal: 1
      })
      @m_2 = Form::Item::Mapping.from_h({
        mapping: "Mapping",
        ordinal: 2
      })

      @g_1.has_item << @tl_1
      @g_1.has_item << @tl_2
      @g_1.has_item << @q_1
      @g_1.has_item << @q_2
      @g_1.has_item << @ph_1
      @g_1.has_item << @ph_2
      @g_1.has_item << @m_1
      @g_1.has_item << @m_2
      @f_1.has_group << @g_1
      @f_1.set_initial("Demographics")
    end

    before :all  do
      IsoHelpers.clear_cache
    end

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
    end

    it "file" do
      simple_form_1
      sparql = Sparql::Update.new
      sparql.default_namespace(@f_1.uri.namespace)
      @f_1.to_sparql(sparql, true)
      @g_1.to_sparql(sparql, true)
      full_path = sparql.to_file
    copy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "simple_form_data.ttl")
    end 

  end

  describe "general tests" do

    def simple_form_2
      @f_1 = Form.new
      @ng_1 = Form::Group::Normal.from_h({
          label: "Question Group",
          completion: "",
          optional: "false",
          repeating: "false",
          ordinal: 1,
          note: ""
        })
      @g_1 = Form::Group::Common.from_h({
          label: "Question Common Group",
          completion: "",
          optional: "false",
          ordinal: 1,
          note: ""
        })
      @ci_1 = Form::Item::Common.from_h({
          label: "Race",
          completion: "Race must be self-reported by the subject (not judged by the site)",
          optional: "false",
          ordinal: 1,
          note: ""
        })
      @bcp_1 = Form::Item::BcProperty.from_h({
          label: "Bc property 1",
          completion: "",
          optional: "false",
          ordinal: 1,
          note: ""
        })
      @bcp_2 = Form::Item::BcProperty.from_h({
          label: "Bc property 2",
          completion: "",
          optional: "false",
          ordinal: 2,
          note: ""
        })
      @ng_1.has_common << @g_1
      @g_1.has_item << @ci_1
      @ci_1.has_common_item << @bcp_1
      @ci_1.has_common_item << @bcp_2
      # @bcp_1.has_property << 
      # @bcp_2.has_property << 
      @f_1.has_group << @ng_1
      @f_1.set_initial("Demographics")
    end

    before :all  do
      IsoHelpers.clear_cache
    end

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
    end

    it "file" do
      simple_form_2
      sparql = Sparql::Update.new
      sparql.default_namespace(@f_1.uri.namespace)
      @f_1.to_sparql(sparql, true)
      @ng_1.to_sparql(sparql, true)
      @ci_1.to_sparql(sparql, true)
      @g_1.to_sparql(sparql, true)
      full_path = sparql.to_file
    copy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "simple_form_data2.ttl")
    end 

  end

end