require 'rails_helper'

describe Form do

  include DataHelpers
  include ValidationHelpers
  include SparqlHelpers
  include PublicFileHelpers
  
  def sub_dir
    return "models/form/data"
  end

  describe "simple form data" do

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
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_transcelerate_identification.ttl")
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

  describe "Find items" do

    before :all  do
      IsoHelpers.clear_cache
    end

    before :each do
      data_files = ["ACME_FN000120_1.ttl"]
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_transcelerate_identification.ttl")
    end

    it "allows a form to be found" do
      form = Form.find(Uri.new(uri:"http://www.transceleratebiopharmainc.com/DAD/V1#F"))
      expect(form.label).to eq("Disability Assessment For Dementia (DAD) (Pilot)")
    end

    it "allows a group to be found" do
      group = Form::Group::Normal.find(Uri.new(uri:"http://www.transceleratebiopharmainc.com/DAD/V1#F_NG1"))
      expect(group.has_item.count).to eq(1)
    end

    it "allows a question to be found" do
      question = Form::Item::Question.find(Uri.new(uri:"http://www.transceleratebiopharmainc.com/DAD/V1#F_NG2_Q1"))
      expect(question.label).to eq("INFORMATION NOT OBTAINED ")
      expect(question.question_text).to eq("INFORMATION NOT OBTAINED ")
    end

    it "allows a mapping to be found" do
      mapping = Form::Item::Mapping.find(Uri.new(uri:"http://www.transceleratebiopharmainc.com/DAD/V1#F_NG1_MA1"))
      expect(mapping.label).to eq("Mapping 1")
      expect(mapping.mapping).to eq("QSCAT=\"DISABILITY ASSESSMENT FOR DEMENTIA (DAD)\"")
    end

    it "allows a form to be exported as SPARQL I" do
      form = Form.find(Uri.new(uri:"http://www.transceleratebiopharmainc.com/DAD/V1#F"))
      sparql = Sparql::Update.new
      form.to_sparql(sparql, true)
    #Xwrite_text_file_2(sparql.to_create_sparql, sub_dir, "to_sparql_expected_1.ttl")
      check_sparql_no_file(sparql.to_create_sparql, "to_sparql_expected_1.ttl")
    end

  end
  
  describe "DAD" do

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
          ordinal: 2,
          note: ""
        })
      @ng_3 = Form::Group::Normal.from_h({
          label: "HYGIENE",
          completion: "",
          optional: "false",
          repeating: "false",
          ordinal: 3,
          note: ""
        })
      @ng_3_ng_2 = Form::Group::Normal.from_h({
          label: "1. Undertake to wash himself/herself or to take a bath or a shower",
          completion: "",
          optional: "false",
          repeating: "false",
          ordinal: 2,
          note: ""
        })
      @ng_4 = Form::Group::Normal.from_h({
          label: "",
          completion: "",
          optional: "false",
          repeating: "false",
          ordinal: 4,
          note: ""
        })
      @ng_5 = Form::Group::Normal.from_h({
          label: "",
          completion: "",
          optional: "false",
          repeating: "false",
          ordinal: 5,
          note: ""
        })
      @ng_6 = Form::Group::Normal.from_h({
          label: "",
          completion: "",
          optional: "false",
          repeating: "false",
          ordinal: 6,
          note: ""
        })
      @ng_7 = Form::Group::Normal.from_h({
          label: "",
          completion: "",
          optional: "false",
          repeating: "false",
          ordinal: 7,
          note: ""
        })
      @ng_8 = Form::Group::Normal.from_h({
          label: "",
          completion: "",
          optional: "false",
          repeating: "false",
          ordinal: 8,
          note: ""
        })
      @ng_9 = Form::Group::Normal.from_h({
          label: "",
          completion: "",
          optional: "false",
          repeating: "false",
          ordinal: 9,
          note: ""
        })
      @ng_10 = Form::Group::Normal.from_h({
          label: "",
          completion: "",
          optional: "false",
          repeating: "false",
          ordinal: 10,
          note: ""
        })
      @ng_11 = Form::Group::Normal.from_h({
          label: "",
          completion: "",
          optional: "false",
          repeating: "false",
          ordinal: 11,
          note: ""
        })
      @ng_12 = Form::Group::Normal.from_h({
          label: "",
          completion: "",
          optional: "false",
          repeating: "false",
          ordinal: 12,
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
      @m_1 = Form::Item::Mapping.from_h({
        label: "Mapping 1",
        completion: "",
        note: "",
        optional: "false",
        ordinal: 1,
        mapping: "QSCAT=\"DISABILITY ASSESSMENT FOR DEMENTIA (DAD)\""
      })
      @m_2 = Form::Item::Mapping.from_h({
        label: "Mapping 2",
        completion: "",
        note: "",
        optional: "false",
        ordinal: 1,
        mapping: "QSSCAT='HYGIENE\""
      })
      @m_3 = Form::Item::Mapping.from_h({
        label: "Mapping 2",
        completion: "",
        note: "",
        optional: "false",
        ordinal: 1,
        mapping: "QSTESTCD=\"DAITM01\""
      })

      @ng_2.has_item << @q_1
      @ng_2.has_item << @q_2
      @ng_1.has_item << @m_1
      @ng_3.has_sub_group << @ng_3_ng_2
      # @ng_3.has_sub_group << @ng_3_ng_3
      # @ng_3.has_sub_group << @ng_3_ng_4
      # @ng_3.has_sub_group << @ng_3_ng_5
      # @ng_3.has_sub_group << @ng_3_ng_6
      # @ng_3.has_sub_group << @ng_3_ng_7
      # @ng_3.has_sub_group << @ng_3_ng_8
      @f_1.has_group << @ng_1
      @f_1.has_group << @ng_2
      @f_1.has_group << @ng_3
      @f_1.has_group << @ng_4
      @f_1.has_group << @ng_5
      @f_1.has_group << @ng_6
      @f_1.has_group << @ng_7
      @f_1.has_group << @ng_8
      @f_1.has_group << @ng_9
      @f_1.has_group << @ng_10
      @f_1.has_group << @ng_11
      @f_1.has_group << @ng_12
      @f_1.set_initial("DAD")
    end

    before :all  do
      IsoHelpers.clear_cache
    end

    before :each do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_transcelerate_identification.ttl")
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

  end

  describe "ACME_F LAB SAMPLES" do

    def simple_form_1
      @f_1 = Form.from_h({
        label: "F Laboratory Samples"
      })
      @ng_1 = Form::Group::Normal.from_h({
          label: "Sample",
          completion: "",
          optional: "false",
          repeating: "false",
          ordinal: 1,
          note: ""
        })
      @ng_1_ng_1 = Form::Group::Normal.from_h({
          label: "Laboratory Sample - Not Done",
          completion: "",
          optional: "false",
          repeating: "false",
          ordinal: 1,
          note: ""
        })
      @ng_1_ng_5 = Form::Group::Normal.from_h({
          label: "Laboratory Sample - Urine",
          completion: "",
          optional: "false",
          repeating: "false",
          ordinal: 5,
          note: ""
        })
      @ng_1_ng_3 = Form::Group::Normal.from_h({
          label: "Laboratory Sample - Blood",
          completion: "",
          optional: "false",
          repeating: "false",
          ordinal: 3,
          note: ""
        })
      @m_1 = Form::Item::Mapping.from_h({
        label: "Mapping 6",
        completion: "",
        note: "",
        optional: "false",
        ordinal: 4,
        mapping: "LBTUBE=URINE"
      })
      @m_2 = Form::Item::Mapping.from_h({
        label: "Mapping 5",
        completion: "",
        note: "",
        optional: "false",
        ordinal: 2,
        mapping: "LBTUBE=BLOOD"
      })
      @bcp_1 = Form::Item::BcProperty.from_h({
        label: "Reason Not Done (--REASND)",
        completion: "",
        optional: "false",
        ordinal: 1,
        note: ""
      })
      @bcp_2 = Form::Item::BcProperty.from_h({
        label: "Date Time (--DTC)",
        completion: "",
        optional: "false",
        ordinal: 1,
        note: ""
      })
      @bcp_3 = Form::Item::BcProperty.from_h({
        label: "Reason Not Done (--REASND)",
        completion: "",
        optional: "false",
        ordinal: 2,
        note: ""
      })
      @bcp_4 = Form::Item::BcProperty.from_h({
        label: "Specimen (--SPEC)",
        completion: "",
        optional: "false",
        ordinal: 3,
        note: ""
      })
      @bcp_5 = Form::Item::BcProperty.from_h({
        label: "Date Time (--DTC)",
        completion: "",
        optional: "false",
        ordinal: 1,
        note: ""
      })
      @bcp_6 = Form::Item::BcProperty.from_h({
        label: "Reason Not Done (--REASND)",
        completion: "",
        optional: "false",
        ordinal: 2,
        note: ""
      })
      @bcp_7 = Form::Item::BcProperty.from_h({
        label: "Specimen (--SPEC)",
        completion: "",
        optional: "false",
        ordinal: 3,
        note: ""
      })

      @ng_1.has_item << @m_1
      @ng_1.has_item << @m_2
      @ng_1_ng_1.has_item << @bcp_1
      @ng_1_ng_5.has_item << @bcp_2
      @ng_1_ng_5.has_item << @bcp_3
      @ng_1_ng_5.has_item << @bcp_4
      @ng_1_ng_3.has_item << @bcp_5
      @ng_1_ng_3.has_item << @bcp_6
      @ng_1_ng_3.has_item << @bcp_7
      @ng_1.has_sub_group << @ng_1_ng_1
      @ng_1.has_sub_group << @ng_1_ng_5
      @ng_1.has_sub_group << @ng_1_ng_3
      @f_1.has_group << @ng_1
      @f_1.set_initial("SAMPLES")
    end

    before :all  do
      IsoHelpers.clear_cache
    end

    before :each do
      data_files = ["ACME_FN000120_1.ttl", "ACME_F_LAB_SAMPLES.ttl"]
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_transcelerate_identification.ttl")
    end

    it "file" do
      simple_form_1
      sparql = Sparql::Update.new
      sparql.default_namespace(@f_1.uri.namespace)
      @f_1.to_sparql(sparql, true)
      @ng_1.to_sparql(sparql, true)
      @ng_1_ng_1.to_sparql(sparql, true)
      @ng_1_ng_3.to_sparql(sparql, true)
      @ng_1_ng_5.to_sparql(sparql, true)
      full_path = sparql.to_file
    #Xcopy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "ACME_F_LAB_SAMPLES.ttl")
    end

  end

  describe "ACME_F ECG" do

    def simple_form_1
      @f_1 = Form.from_h({
        label: "ECG Measurements"
      })
      @ng_1 = Form::Group::Normal.from_h({
          label: "Details - P Wave",
          completion: "",
          optional: "false",
          repeating: "false",
          ordinal: 1,
          note: ""
        })
      @ng_1_cg_1 = Form::Group::Common.from_h({
          label: "Collection details",
          completion: "",
          optional: "false",
          repeating: "false",
          ordinal: 1,
          note: ""
        })
      @ng_1_ng_2 = Form::Group::Normal.from_h({
          label: "P Wave Amplitude, Aggregate" ,
          completion: "",
          optional: "false",
          repeating: "false",
          ordinal: 2 ,
          note: ""
        })
      @ng_1_ng_3 = Form::Group::Normal.from_h({
          label: "P Wave Duration, Aggregate",
          completion: "",
          optional: "false",
          repeating: "false",
          ordinal: 3,
          note: ""
        })
      @ci_1 = Form::Item::Common.from_h({
        label: "Date Time (--DTC)",
        completion: "",
        note: "",
        optional: "false",
        ordinal: 1
      })
      @ci_2 = Form::Item::Common.from_h({
        label: "Reason Not Done (--STAT)",
        completion: "",
        note: "",
        optional: "false",
        ordinal: 2
      })
      @ci_3 = Form::Item::Common.from_h({
        label: "Reason Not Done (--REASND)",
        completion: "",
        note: "",
        optional: "false",
        ordinal: 3
      })
      @ng_1.has_common << @ng_1_cg_1
      @ng_1_cg_1.has_item << @ci_1
      @ng_1_cg_1.has_item << @ci_2
      @ng_1_cg_1.has_item << @ci_3
      @ng_1.has_sub_group << @ng_1_ng_2
      @ng_1.has_sub_group << @ng_1_ng_3
      @f_1.has_group << @ng_1
      @f_1.set_initial("ECG")
    end

    before :all  do
      IsoHelpers.clear_cache
    end

    before :each do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_transcelerate_identification.ttl")
    end

    it "file" do
      simple_form_1
      sparql = Sparql::Update.new
      sparql.default_namespace(@f_1.uri.namespace)
      @f_1.to_sparql(sparql, true)
      @ng_1.to_sparql(sparql, true)
      @ng_1_cg_1.to_sparql(sparql, true)
      @ng_1_ng_2.to_sparql(sparql, true)
      @ng_1_ng_3.to_sparql(sparql, true)
      full_path = sparql.to_file
    #Xcopy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "ACME_F_ECG.ttl")
    end

  end

  describe "ACME_F DEMOGRAPHICS" do

    def simple_form_1
      @f_1 = Form.from_h({
        label: "Demographics"
      })
      @ng_1 = Form::Group::Normal.from_h({
          label: "DEMOGRAPHICS",
          completion: "",
          optional: "false",
          repeating: "false",
          ordinal: 1,
          note: ""
        })
      @q_1 = Form::Item::Question.from_h({
          label: "Age",
          completion: "",
          mapping: "AGE",
          question_text: "Age (Years)",
          optional: "false",
          format: "3",
          ordinal: 1,
          note: "FDA Validation Rules and SDTM expected variable.\n\nIf the protocol calls for the collection of Birth date and derivation of Age then this item must be set in calculated and visible for the investigator."
        })
      @q_2 = Form::Item::Question.from_h({
          label: "Birth Date",
          completion: "",
          mapping: "BRTHDTC",
          question_text: "Date of Birth",
          optional: "true",
          format: "",
          ordinal: 3,
          note: ""
        })
      @q_3 = Form::Item::Question.from_h({
          label: "SEX",
          completion: "",
          mapping: "SEX",
          question_text: "Sex",
          optional: "false",
          format: "1",
          ordinal: 4,
          note: "When Rave PF URL is used together with the Lab Admin Module, then the values within Rave must be 1=M and 2=F."
        })
      # tc_1 = Thesaurus::UnmanagedConcept.from_h({
      #     label: "Thesaurus Concept Reference",
      #     identifier: "A000012",
      #     definition: "The oldest LHR Terminal",
      #     notation: "T1"
      #   })
      @q_4 = Form::Item::Question.from_h({
          label: "Ethnicity",
          completion: "",
          mapping: "ETHNIC",
          question_text: "Ethnicity",
          optional: "true",
          format: "22",
          ordinal: 5,
          note: "Optionally used depending on protocol specifications\nFDA requirement, missing variable must be justified in SDTM RG"
        })
      @q_5 = Form::Item::Question.from_h({
          label: "Race",
          completion: "If the subject is of mixed race, select the race that corresponds to the dominant ethnic group or to the ethnic group that the subject considers him/herself belonging to and ensure this correspondence with a note in the source documents.",
          mapping: "RACE",
          question_text: "Race",
          optional: "true",
          format: "41",
          ordinal: 6,
          note: "Optionally used depending on protocol specifications\nSDTM and FDA requirements.\n\nBLACK can be used instead of BLACK OR AFRICAN AMERICAN when collected outside US.\n\nFree text collected in SPECIFY field must set in RACEOTH variable, pre-printed term are set in RACE variable.\n\nThis item can be automatically populated by the system if only one race is planned to be used in the protocol"
        })
      @q_6 = Form::Item::Question.from_h({
          label: "Other, specify",
          completion: "If \"Other\" is selected (e.g. Mixture of 2 races), the \"specify\" field is used to collect the information. \n\nDo not record any variation on the predefined options.",
          mapping: "SUPPDM.DMRACEOT",
          question_text: "If Other, Specify",
          optional: "true",
          format: "200",
          ordinal: 7,
          note: "Missing values must be justified in SDTMRG.\n"
        })
      @m_1 = Form::Item::Mapping.from_h({
        label: "Mapping 7",
        completion: "",
        note: "",
        optional: "false",
        ordinal: 2,
        mapping: "AGEU=YEARS"
      })
      @ng_1.has_item << @q_1
      @ng_1.has_item << @m_1
      @ng_1.has_item << @q_2
      @ng_1.has_item << @q_3
      @ng_1.has_item << @q_4
      @ng_1.has_item << @q_5
      @ng_1.has_item << @q_6
      # @q_3.has_coded_value << 
      @f_1.has_group << @ng_1
      @f_1.set_initial("ECG")
    end

    before :all  do
      IsoHelpers.clear_cache
    end

    before :each do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_transcelerate_identification.ttl")
    end

    it "file" do
      simple_form_1
      sparql = Sparql::Update.new
      sparql.default_namespace(@f_1.uri.namespace)
      @f_1.to_sparql(sparql, true)
      @ng_1.to_sparql(sparql, true)
      full_path = sparql.to_file
    #Xcopy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "ACME_F_DEMOGRAPHICS.ttl")
    end

  end

  describe "ACME_VSTAINFLUENZA" do

    def simple_form_1
      @f_1 = Form.from_h({
        label: "Vital Signs - Therapeutic Area - Influenza"
      })
      @ng_1 = Form::Group::Normal.from_h({
          label: "Group",
          completion: "",
          optional: "false",
          repeating: "false",
          ordinal: 1,
          note: ""
        })
      @ng_1_ng_1= Form::Group::Normal.from_h({
          label: "Heart Rate",
          completion: "",
          optional: "false",
          repeating: "false",
          ordinal: 1,
          note: ""
        })
      @bcp_1 = Form::Item::BcProperty.from_h({
        label: "Result Value (--ORRES)",
        completion: "",
        optional: "false",
        ordinal: 1,
        note: ""
      })
      @bcp_2 = Form::Item::BcProperty.from_h({
        label: "Result Units (--ORRESU)",
        completion: "",
        optional: "false",
        ordinal: 2,
        note: ""
      })
      @ng_1_ng_2= Form::Group::Normal.from_h({
          label: "Systolic Blood Pressure",
          completion: "",
          optional: "false",
          repeating: "false",
          ordinal: 2,
          note: ""
        })
      @bcp_3 = Form::Item::BcProperty.from_h({
        label: "Body Position (--POS)",
        completion: "",
        optional: "false",
        ordinal: 1,
        note: ""
      })
      @bcp_4 = Form::Item::BcProperty.from_h({
        label: "Result Value (--ORRES)",
        completion: "",
        optional: "false",
        ordinal: 2,
        note: ""
      })
      @bcp_5 = Form::Item::BcProperty.from_h({
        label: "Result Units (--ORRESU)",
        completion: "",
        optional: "false",
        ordinal: 3,
        note: ""
      })
      @ng_1_ng_3= Form::Group::Normal.from_h({
          label: "Diastolic Blood Pressure",
          completion: "",
          optional: "false",
          repeating: "false",
          ordinal: 3,
          note: ""
        })
      @bcp_6 = Form::Item::BcProperty.from_h({
        label: "Result Value (--ORRES)",
        completion: "",
        optional: "false",
        ordinal: 1,
        note: ""
      })
      @bcp_7 = Form::Item::BcProperty.from_h({
        label: "Result Units (--ORRESU)",
        completion: "",
        optional: "false",
        ordinal: 2,
        note: ""
      })
      @ng_1_ng_4= Form::Group::Normal.from_h({
          label: "Respiratory Rate",
          completion: "",
          optional: "false",
          repeating: "false",
          ordinal: 4,
          note: ""
        })
      @bcp_8 = Form::Item::BcProperty.from_h({
        label: "Date Time (--DTC)",
        completion: "",
        optional: "false",
        ordinal: 1,
        note: ""
      })
      @bcp_9 = Form::Item::BcProperty.from_h({
        label: "Result Units (--ORRESU)",
        completion: "",
        optional: "false",
        ordinal: 2,
        note: ""
      })
     
      @ng_1.has_sub_group << @ng_1_ng_1
      @ng_1.has_sub_group << @ng_1_ng_2
      @ng_1.has_sub_group << @ng_1_ng_3
      @ng_1.has_sub_group << @ng_1_ng_4
      @ng_1_ng_1.has_item << @bcp_1
      @ng_1_ng_1.has_item << @bcp_2
      #@bcp_1.has_property << 
      #@bcp_2.has_property << 
      @ng_1_ng_2.has_item << @bcp_3
      @ng_1_ng_2.has_item << @bcp_4
      @ng_1_ng_2.has_item << @bcp_5
      @ng_1_ng_3.has_item << @bcp_6
      @ng_1_ng_3.has_item << @bcp_7
      @ng_1_ng_4.has_item << @bcp_8
      @ng_1_ng_4.has_item << @bcp_9
      @f_1.has_group << @ng_1
      @f_1.set_initial("INFLUENZA")
    end

    before :all  do
      IsoHelpers.clear_cache
    end

    before :each do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_transcelerate_identification.ttl")
    end

    it "file" do
      simple_form_1
      sparql = Sparql::Update.new
      sparql.default_namespace(@f_1.uri.namespace)
      @f_1.to_sparql(sparql, true)
      @ng_1.to_sparql(sparql, true)
      @ng_1_ng_1.to_sparql(sparql, true)
      @ng_1_ng_2.to_sparql(sparql, true)
      @ng_1_ng_3.to_sparql(sparql, true)
      @ng_1_ng_4.to_sparql(sparql, true)
      full_path = sparql.to_file
    #Xcopy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "ACME_VSTAINFLUENZA.ttl")
    end

  end

end