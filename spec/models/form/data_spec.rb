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
    #Xcopy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "simple_form_data.ttl")
    end 

  end

  describe "DAD_pilot_form" do

    before :all  do
      IsoHelpers.clear_cache
    end

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "ACME_FN000120_1.ttl", "simple_form_data.ttl"]
      load_files(schema_files, data_files)
    end

    # it "allows forms to be found" do
    # byebug
    #   form = Form.unique
    #   expect(form.label).to eq("Disability Assessment For Dementia (DAD) (Pilot)")
    # end

    it "allows a form to be found" do
      form = Form.find(Uri.new(uri:"http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_FN000120"))
      expect(form.label).to eq("Disability Assessment For Dementia (DAD) (Pilot)")
    end

    it "allows a group to be found" do
      group = Form::Group::Normal.find(Uri.new(uri:"http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_FN000120_G1"))
      # expect(group.label).to eq("Disability Assessment For Dementia (DAD) (Pilot)")
    end

    it "allows a question to be found" do
      question = Form::Item::Question.find(Uri.new(uri:"http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_FN000120_G2_I1"))
      expect(question.label).to eq("INFORMATION NOT OBTAINED ")
      expect(question.question_text).to eq("INFORMATION NOT OBTAINED ")
    end

    it "allows a mapping to be found" do
      mapping = Form::Item::Mapping.find(Uri.new(uri:"http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_FN000120_G3_I1"))
      expect(mapping.label).to eq("Mapping 2")
      expect(mapping.mapping).to eq("QSSCAT='HYGIENE\"")
    end

    it "allows a form to be exported as SPARQL I" do
      form = Form.find(Uri.new(uri:"http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_FN000120"))
      sparql = Sparql::Update.new
      form.to_sparql(sparql, true)
    #Xwrite_text_file_2(sparql.to_create_sparql, sub_dir, "to_sparql_expected_1.ttl")
      check_sparql_no_file(sparql.to_create_sparql, "to_sparql_expected_1.ttl")
    end

    it "allows an item to be exported as SPARQL I" do
      question = Form::Item::Question.find(Uri.new(uri:"http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_FN000120_G2_I1"))
      sparql = Sparql::Update.new
      question.to_sparql(sparql, true)
    #Xwrite_text_file_2(sparql.to_create_sparql, sub_dir, "question_to_sparql_expected_1.ttl")
      check_sparql_no_file(sparql.to_create_sparql, "question_to_sparql_expected_1.ttl")
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
    #Xcopy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "simple_form_data2.ttl")
    end 

  end

  describe "general tests" do

    def simple_form_3
      @f_1 = Form.from_h({
        label: "Disability Assessment For Dementia (DAD) (Pilot)"
      })
      @ng_1 = Form::Group::Normal.from_h({
          label: "",
          completion: "",
          optional: "false",
          repeating: "false",
          ordinal: 1,
          note: ""
        })
        @ng_2 = Form::Group::Normal.from_h({
          label: "",
          completion: "",
          optional: "false",
          repeating: "false",
          ordinal: 1,
          note: ""
        })
  @q_1 = Form::Item::Question.from_h({
          label: "INFORMATION NOT OBTAINED ",
          completion: "",
          mapping: "NOT SUBMITTED",
          question_text: "INFORMATION NOT OBTAINED ",
          optional: "false",
          format: "",
          ordinal: 1,
          note: ""
        })
      @q_2 = Form::Item::Question.from_h({
          label: "Clinician's initials ",
          completion: "First/Middle/Last",
          mapping: "NOT SUBMITTED",
          question_text: "Clinician's initials ",
          optional: "false",
          format: "3",
          ordinal: 2,
          note: ""
        })
  #     @tl_1 = Form::Item::TextLabel.from_h({
  #         label_text: "Label Text 1",
  #         ordinal: 1
  #       })
  #     @tl_2 = Form::Item::TextLabel.from_h({
  #       label_text: "Label Text 2",
  #       ordinal: 2
  #     })
  #     @ph_1 = Form::Item::Placeholder.from_h({
  #       free_text: "Free text",
  #       ordinal: 1
  #     })
  #     @ph_2 = Form::Item::Placeholder.from_h({
  #       free_text: "Free text 2",
  #       ordinal: 2
  #     })
      @m_1 = Form::Item::Mapping.from_h({
        label: "Mapping 1",
        completion: "",
        note: "",
        optional: "false",
        ordinal: 1,
        mapping: "QSCAT=\"DISABILITY ASSESSMENT FOR DEMENTIA (DAD)\""
      })

      @ng_2.has_item << @q_1
      @ng_2.has_item << @q_2
      @ng_1.has_item << @m_1
      @f_1.has_group << @ng_1
      @f_1.has_group << @ng_2
      @f_1.set_initial("Demographics")
    end

    before :all  do
      IsoHelpers.clear_cache
    end

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "ACME_FN000120_1.ttl"]
      load_files(schema_files, data_files)
    end

    it "file" do
      simple_form_3
      sparql = Sparql::Update.new
      sparql.default_namespace(@f_1.uri.namespace)
      @f_1.to_sparql(sparql, true)
      @ng_1.to_sparql(sparql, true)
      @ng_2.to_sparql(sparql, true)
      full_path = sparql.to_file
    #Xcopy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "ACME_FN000120_1.ttl")
    end

    it "allows forms to be found" do
      form = Form.unique
    byebug
    end 

  end

end