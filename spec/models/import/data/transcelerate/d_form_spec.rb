require 'rails_helper'

describe Form do

  include DataHelpers
  include PublicFileHelpers
  include SparqlHelpers
  include IsoHelpers

  def sub_dir
    return "models/import/data/transcelerate"
  end

  before :all do
    IsoHelpers.clear_cache
    load_files(schema_files, [])
    load_cdisc_term_versions(1..62)
    load_data_file_into_triple_store("mdr_transcelerate_identification.ttl")
  end

  after :all do
    #
  end

  before :each do
    #
  end

  after :each do
    delete_all_public_test_files
  end

  describe "DAD" do

    def simple_form_3
      @hackathon_form_1 = Form.from_h({
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
      @hackathon_form_1.has_group << @ng_1
      @hackathon_form_1.has_group << @ng_2
      @hackathon_form_1.has_group << @ng_3
      @hackathon_form_1.has_group << @ng_4
      @hackathon_form_1.has_group << @ng_5
      @hackathon_form_1.has_group << @ng_6
      @hackathon_form_1.has_group << @ng_7
      @hackathon_form_1.has_group << @ng_8
      @hackathon_form_1.has_group << @ng_9
      @hackathon_form_1.has_group << @ng_10
      @hackathon_form_1.has_group << @ng_11
      @hackathon_form_1.has_group << @ng_12
      @hackathon_form_1.set_initial("F DAD")
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
      sparql.default_namespace(@hackathon_form_1.uri.namespace)
      @hackathon_form_1.to_sparql(sparql, true)
      @ng_1.to_sparql(sparql, true)
      @ng_2.to_sparql(sparql, true)
      full_path = sparql.to_file
    copy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "hackathon_form_dad.ttl")
    end

  end

  describe "LAB SAMPLES" do

    def simple_form_1
      @hackathon_form_1 = Form.from_h({
        label: "Laboratory Samples"
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
      # @bcp_1.has_property << OperationalReferenceV3.from_h({label: "BC Property Reference", local_label: "", enabled: true, ordinal: 0, optional: false})
      # @bcp_2.has_property << OperationalReferenceV3.from_h({label: "BC Property Reference", local_label: "", enabled: true, ordinal: 0, optional: false})
      # @bcp_3.has_property << OperationalReferenceV3.from_h({label: "BC Property Reference", local_label: "", enabled: true, ordinal: 0, optional: false})
      # @bcp_4.has_property << OperationalReferenceV3.from_h({label: "BC Property Reference", local_label: "", enabled: true, ordinal: 0, optional: false})
      # @bcp_4.has_coded_value << Uri.new(uri: "http://www.assero.co.uk/MDRThesaurus/CDISC/V53#CLI-C78734_C13283")
      # @bcp_5.has_property << OperationalReferenceV3.from_h({label: "BC Property Reference", local_label: "", enabled: true, ordinal: 0, optional: false})
      # @bcp_6.has_property << OperationalReferenceV3.from_h({label: "BC Property Reference", local_label: "", enabled: true, ordinal: 0, optional: false})
      # @bcp_7.has_property << OperationalReferenceV3.from_h({label: "BC Property Reference", local_label: "", enabled: true, ordinal: 0, optional: false})
      # @bcp_7.has_coded_value << Uri.new(uri: "http://www.assero.co.uk/MDRThesaurus/CDISC/V53#CLI-C78734_C12434")
      @hackathon_form_1.has_group << @ng_1
      @hackathon_form_1.set_initial("F LAB SAMPLES")
    end

    it "file" do
      simple_form_1
      sparql = Sparql::Update.new
      sparql.default_namespace(@hackathon_form_1.uri.namespace)
      @hackathon_form_1.to_sparql(sparql, true)
      @ng_1.to_sparql(sparql, true)
      @ng_1_ng_1.to_sparql(sparql, true)
      @ng_1_ng_3.to_sparql(sparql, true)
      @ng_1_ng_5.to_sparql(sparql, true)
      full_path = sparql.to_file
    copy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "hackathon_form_lab_samples.ttl")
    end

  end

  describe "ECG" do

    def simple_form_1
      @hackathon_form_1 = Form.from_h({
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
      @hackathon_form_1.has_group << @ng_1
      @hackathon_form_1.set_initial("F ECG")
    end

    it "file" do
      simple_form_1
      sparql = Sparql::Update.new
      sparql.default_namespace(@hackathon_form_1.uri.namespace)
      @hackathon_form_1.to_sparql(sparql, true)
      @ng_1.to_sparql(sparql, true)
      @ng_1_cg_1.to_sparql(sparql, true)
      @ng_1_ng_2.to_sparql(sparql, true)
      @ng_1_ng_3.to_sparql(sparql, true)
      full_path = sparql.to_file
    copy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "hackathon_form_ecg.ttl")
    end

  end

  describe "DEMOGRAPHICS" do

    def simple_form_1
      @hackathon_form_1 = Form.from_h({
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
      # @q_3.has_coded_value << Uri.new(uri: "http://www.assero.co.uk/MDRThesaurus/CDISC/V54#CLI-C66731_C16576")
      # @q_3.has_coded_value << Uri.new(uri: "http://www.assero.co.uk/MDRThesaurus/CDISC/V54#CLI-C66731_C20197")
      # @q_4.has_coded_value << Uri.new(uri: "http://www.assero.co.uk/MDRThesaurus/CDISC/V54#CLI-C66790_C17459")
      # @q_4.has_coded_value << Uri.new(uri: "http://www.assero.co.uk/MDRThesaurus/CDISC/V54#CLI-C66790_C41222")
      # @q_4.has_coded_value << Uri.new(uri: "http://www.assero.co.uk/MDRThesaurus/CDISC/V54#CLI-C66790_C43234")
      # @q_4.has_coded_value << Uri.new(uri: "http://www.assero.co.uk/MDRThesaurus/CDISC/V54#CLI-C66790_C17998")
      # @q_5.has_coded_value << Uri.new(uri: "http://www.assero.co.uk/MDRThesaurus/CDISC/V54#CLI-C128689_C41259")
      # @q_5.has_coded_value << Uri.new(uri: "http://www.assero.co.uk/MDRThesaurus/CDISC/V54#CLI-C128689_C41260")
      # @q_5.has_coded_value << Uri.new(uri: "http://www.assero.co.uk/MDRThesaurus/CDISC/V54#CLI-C128689_C16352")
      # @q_5.has_coded_value << Uri.new(uri: "http://www.assero.co.uk/MDRThesaurus/CDISC/V54#CLI-C128689_C41219")
      # @q_5.has_coded_value << Uri.new(uri: "http://www.assero.co.uk/MDRThesaurus/CDISC/V54#CLI-C128689_C41261")
      # @q_5.has_coded_value << Uri.new(uri: "http://www.assero.co.uk/MDRThesaurus/ACME/V7#TH-ACME_CDISCEXTENSION_C128689X_OTHER")
      @hackathon_form_1.has_group << @ng_1
      @hackathon_form_1.set_initial("F DM")
    end

    it "file" do
      simple_form_1
      sparql = Sparql::Update.new
      sparql.default_namespace(@hackathon_form_1.uri.namespace)
      @hackathon_form_1.to_sparql(sparql, true)
      @ng_1.to_sparql(sparql, true)
      full_path = sparql.to_file
    copy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "hackathon_form_dm.ttl")
    end

  end

  describe "VS INFLUENZA" do

    def simple_form_1
      @hackathon_form_1 = Form.from_h({
        label: "Vital Signs - Influenza"
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
      @hackathon_form_1.has_group << @ng_1
      @hackathon_form_1.set_initial("F VS INFLUENZA")
    end

    it "file" do
      simple_form_1
      sparql = Sparql::Update.new
      sparql.default_namespace(@hackathon_form_1.uri.namespace)
      @hackathon_form_1.to_sparql(sparql, true)
      @ng_1.to_sparql(sparql, true)
      @ng_1_ng_1.to_sparql(sparql, true)
      @ng_1_ng_2.to_sparql(sparql, true)
      @ng_1_ng_3.to_sparql(sparql, true)
      @ng_1_ng_4.to_sparql(sparql, true)
      full_path = sparql.to_file
    copy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "hackathon_form_vs_influenza.ttl")
    end

  end

  describe "CIBIC+" do

    def simple_form_1
      @hackathon_form_1 = Form.from_h({
        label: "Clinician's Interview-Based Impression of Change (CIBIC+) (Pilot)"
      })
      @ng_1 = Form::Group::Normal.from_h({
          label: " ",
          completion: "",
          optional: "false",
          repeating: "false",
          ordinal: 1,
          note: ""
        })
      @q_1 = Form::Item::Question.from_h({
          label: "Question 2",
          completion: "",
          mapping: "NOT SUBMITTED",
          question_text: "INFORMATION NOT OBTAINED ",
          optional: "false",
          format: "",
          ordinal: 1,
          note: ""
        })
      @q_2 = Form::Item::Question.from_h({
          label: "Question 3",
          completion: "",
          mapping: "NOT SUBMITTED",
          question_text: "Clinician's initials ",
          optional: "false",
          format: "3",
          ordinal: 2,
          note: ""
        })
      @ng_1_ng_1= Form::Group::Normal.from_h({
          label: "Clinician's Interview-Based Impression Of Change (CIBIC+)",
          completion: "",
          optional: "false",
          repeating: "false",
          ordinal: 3,
          note: ""
        })
      @bcp_1 = Form::Item::BcProperty.from_h({
        label: "Date Time (--DTC)",
        completion: "",
        optional: "false",
        ordinal: 1,
        note: ""
      })
      @bcp_2 = Form::Item::BcProperty.from_h({
        label: "Result Value (--ORRES)",
        completion: "",
        optional: "false",
        ordinal: 2,
        note: ""
      })
      @ng_1.has_item << @q_1
      @ng_1.has_item << @q_1
      @ng_1.has_sub_group << @ng_1_ng_1
      @ng_1_ng_1.has_item << @bcp_1
      @ng_1_ng_1.has_item << @bcp_2
      @bcp_1.has_property << OperationalReferenceV3.from_h({label: "BC Property Reference", local_label: "", enabled: true, ordinal: 0, optional: false})
      @bcp_2.has_property << OperationalReferenceV3.from_h({label: "BC Property Reference", local_label: "", enabled: true, ordinal: 0, optional: false})
      # @bcp_2.has_coded_value <<
      # @bcp_2.has_coded_value << 
      # @bcp_2.has_coded_value << 
      # @bcp_2.has_coded_value << 
      # @bcp_2.has_coded_value << 
      # @bcp_2.has_coded_value << 
      # @bcp_2.has_coded_value << 
      @hackathon_form_1.has_group << @ng_1
      @hackathon_form_1.set_initial("F CIBIC")
    end

    it "file" do
      simple_form_1
      sparql = Sparql::Update.new
      sparql.default_namespace(@hackathon_form_1.uri.namespace)
      @hackathon_form_1.to_sparql(sparql, true)
      @ng_1.to_sparql(sparql, true)
      @ng_1_ng_1.to_sparql(sparql, true)
      @bcp_1.to_sparql(sparql, true)
      @bcp_2.to_sparql(sparql, true)
      full_path = sparql.to_file
    copy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "hackathon_form_cibic.ttl")
    end

  end

  describe "HEIGHT" do

    def simple_form_1
      @hackathon_form_1 = Form.from_h({
        label: "Height (Pilot)"
      })
      @ng_1 = Form::Group::Normal.from_h({
          label: " ",
          completion: "",
          optional: "false",
          repeating: "false",
          ordinal: 1,
          note: ""
        })
      @q_1 = Form::Item::Question.from_h({
          label: "Completion status",
          completion: "",
          mapping: "VSSTAT",
          question_text: " Completion Status",
          optional: "false",
          format: "1",
          ordinal: 1,
          note: ""
        })
      @ph_1 = Form::Item::Placeholder.from_h({
        free_text: "Measure with shoes off. Round up or down to the nearest tenth inch or tenth centimeter.",
        ordinal: 2,
        label: "Placeholder 2"
      })
      @q_2 = Form::Item::Question.from_h({
          label: "Height",
          completion: "",
          mapping: "VSORRES",
          question_text: "Height",
          optional: "false",
          format: "5.1",
          ordinal: 3,
          note: ""
        })
      @q_3 = Form::Item::Question.from_h({
          label: "Unit",
          completion: "",
          mapping: "VSORRESU",
          question_text: "Unit",
          optional: "false",
          format: "20",
          ordinal: 4,
          note: ""
        })
      @ng_1.has_item << @q_1
      @ng_1.has_item << @q_2
      @ng_1.has_item << @q_3
      @ng_1.has_item << @ph_1
      @q_1.has_coded_value << Uri.new(uri: "http://www.cdisc.org/C66789/V4#C66789_C49484")
      @q_2.has_coded_value << Uri.new(uri: "http://www.cdisc.org/C66770/V4#C66770_C49668")
      @q_2.has_coded_value << Uri.new(uri: "http://www.cdisc.org/C66770/V2#C66770_C48500")
      @hackathon_form_1.has_group << @ng_1
      @hackathon_form_1.set_initial("F HEIGHT")
    end

    it "file" do
      simple_form_1
      sparql = Sparql::Update.new
      sparql.default_namespace(@hackathon_form_1.uri.namespace)
      @hackathon_form_1.to_sparql(sparql, true)
      @ng_1.to_sparql(sparql, true)
      @q_1.to_sparql(sparql, true)
      @q_2.to_sparql(sparql, true)
      full_path = sparql.to_file
    copy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "hackathon_form_height.ttl")
    end

  end

  describe "WEIGHT" do

    def simple_form_1
      @hackathon_form_1 = Form.from_h({
        label: " Weight (Pilot)"
      })
      @ng_1 = Form::Group::Normal.from_h({
          label: " ",
          completion: "",
          optional: "false",
          repeating: "false",
          ordinal: 1,
          note: ""
        })
      @ng_2 = Form::Group::Normal.from_h({
          label: " ",
          completion: "",
          optional: "false",
          repeating: "false",
          ordinal: 2,
          note: ""
        })
      @q_1 = Form::Item::Question.from_h({
          label: " INFORMATION NOT OBTAINED",
          completion: "",
          mapping: "NOT SUBMITTED",
          question_text: "INFORMATION NOT OBTAINED",
          optional: "false",
          format: "1",
          ordinal: 2,
          note: ""
        })
      @ph_1 = Form::Item::Placeholder.from_h({
        free_text: "Tick in text field, if applicable",
        ordinal: 1,
        label: "Placeholder 2"
      })
      @ph_2 = Form::Item::Placeholder.from_h({
        free_text: "Measure with shoes off. Round up or down to the nearest tenth kilogram or tenth pound.",
        ordinal: 1,
        label: "Placeholder 3"
      })
      @q_2 = Form::Item::Question.from_h({
          label: " Weight",
          completion: "",
          mapping: "VSORRES",
          question_text: "Weight",
          optional: "false",
          format: "5.1",
          ordinal: 2,
          note: ""
        })
      @q_3 = Form::Item::Question.from_h({
          label: "Unit",
          completion: "",
          mapping: "VSORRESU",
          question_text: "Unit",
          optional: "false",
          format: "20",
          ordinal: 3,
          note: ""
        })
      @ng_1.has_item << @ph_1
      @ng_1.has_item << @q_1
      @ng_2.has_item << @q_2
      @ng_2.has_item << @ph_2
      @ng_2.has_item << @q_3
      @q_3.has_coded_value << Uri.new(uri: "http://www.cdisc.org/C66770/V4#C66770_C28252")
      @q_3.has_coded_value << Uri.new(uri: "http://www.cdisc.org/C71620/V6#C71620_C48531")
      @hackathon_form_1.has_group << @ng_1
      @hackathon_form_1.has_group << @ng_2
      @hackathon_form_1.set_initial("F WEIGHT")
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
      sparql.default_namespace(@hackathon_form_1.uri.namespace)
      @hackathon_form_1.to_sparql(sparql, true)
      @ng_1.to_sparql(sparql, true)
      @ng_2.to_sparql(sparql, true)
      @q_3.to_sparql(sparql, true)
      full_path = sparql.to_file
    copy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "hackathon_form_weight.ttl")
    end

  end

  describe "Heart Rate and Blood Pressure" do

    def simple_form_1
      @hackathon_form_1 = Form.from_h({
        label: "Heart rate and blood pressure (Pilot)"
      })
      @ng_1 = Form::Group::Normal.from_h({
          label: "Group",
          completion: "",
          optional: "false",
          repeating: "false",
          ordinal: 1,
          note: ""
        })
      @ng_2 = Form::Group::Normal.from_h({
          label: "HEART RATE AND BLOOD PRESSURE",
          completion: "",
          optional: "false",
          repeating: "false",
          ordinal: 2,
          note: ""
        })
      @ph_1 = Form::Item::Placeholder.from_h({
        free_text: "Blood pressure and pulse must be taken after the patient has been lying down for 5 minutes (supine) and after standing for 1 minute (standing) and 3 minutes.",
        ordinal: 1,
        label: "Placeholder 1"
      })
      @q_1 = Form::Item::Question.from_h({
          label: "Time",
          completion: "",
          mapping: "VSTPT",
          question_text: "Reference Time (5 minutes)",
          optional: "false",
          format: "1",
          ordinal: 2,
          note: ""
        })
      @q_2 = Form::Item::Question.from_h({
          label: "Code",
          completion: "",
          mapping: "VSTPTNUM",
          question_text: "Timing Code",
          optional: "false",
          format: "3",
          ordinal: 2,
          note: ""
        })
      @q_3 = Form::Item::Question.from_h({
          label: "Position",
          completion: "",
          mapping: "VSPOS",
          question_text: "Position",
          optional: "false",
          format: "3",
          ordinal: 3,
          note: ""
        })
      @m_1 = Form::Item::Mapping.from_h({
        mapping: "VSTESTCD = PULSE",
        ordinal: 4,
        label: "Mapping 5",
        optional: "false"
      })
      @q_4 = Form::Item::Question.from_h({
          label: "HR",
          completion: "",
          mapping: "VSORRES",
          question_text: "Heart Rate",
          optional: "false",
          format: "3",
          ordinal: 5,
          note: ""
        })
      @q_5 = Form::Item::Question.from_h({
          label: "HR UNIT",
          completion: "",
          mapping: "VSORRESU",
          question_text: "Heart Rate Unit",
          optional: "false",
          format: "20",
          ordinal: 6,
          note: ""
        })
      @q_6 = Form::Item::Question.from_h({
          label: "Systolic BP",
          completion: "",
          mapping: "VSORRES",
          question_text: "Systolic BP",
          optional: "false",
          format: "3",
          ordinal: 7,
          note: ""
        })
      @q_7 = Form::Item::Question.from_h({
          label: "Diastolic BP",
          completion: "",
          mapping: "VSORRES",
          question_text: "Diastolic BP",
          optional: "false",
          format: "3",
          ordinal: 8,
          note: ""
        })
      @q_8 = Form::Item::Question.from_h({
          label: "BP Unit",
          completion: "",
          mapping: "VSORRESU",
          question_text: "Unit ",
          optional: "false",
          format: "20",
          ordinal: 9,
          note: ""
        })
      @ng_1.has_item << @ph_1
      @ng_2.has_item << @q_1
      @ng_2.has_item << @m_1
      @ng_2.has_item << @q_3
      @ng_2.has_item << @q_2
      @ng_2.has_item << @q_4
      @ng_2.has_item << @q_5
      @ng_2.has_item << @q_6
      @ng_2.has_item << @q_7
      @ng_2.has_item << @q_8
      @q_3.has_coded_value << Uri.new(uri: "http://www.cdisc.org/C71148/V6#C71148_C62167")
      @q_3.has_coded_value << Uri.new(uri: "http://www.cdisc.org/C71148/V6#C71148_C62166")
      @q_5.has_coded_value << Uri.new(uri: "http://www.cdisc.org/C71620/V6#C71620_C49673")
      @q_8.has_coded_value << Uri.new(uri: "http://www.cdisc.org/C66770/V4#C66770_C49670")
      @hackathon_form_1.has_group << @ng_1
      @hackathon_form_1.has_group << @ng_2
      @hackathon_form_1.set_initial("F HR BP")
    end

    it "file" do
      simple_form_1
      sparql = Sparql::Update.new
      sparql.default_namespace(@hackathon_form_1.uri.namespace)
      @hackathon_form_1.to_sparql(sparql, true)
      @ng_1.to_sparql(sparql, true)
      @ng_2.to_sparql(sparql, true)
      @q_3.to_sparql(sparql, true)
      @q_5.to_sparql(sparql, true)
      @q_8.to_sparql(sparql, true)
      full_path = sparql.to_file
    copy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "hackathon_form_hr_bp.ttl")
    end

  end

  describe "Alzheimer's Disease" do

    def simple_form_1
      @hackathon_form_1 = Form.from_h({
        label: "Alzheimer's Disease Assessment Scale - Cognition (Pilot)"
      })
      @ng_1 = Form::Group::Normal.from_h({
          label: " ",
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
          ordinal: 3,
          note: ""
        })
      @q_3 = Form::Item::Question.from_h({
          label: "1. Word Recall Task",
          completion: "",
          mapping: "QSORRES",
          question_text: " 1. Word Recall Task (max = 10)",
          optional: "false",
          format: "2",
          ordinal: 4,
          note: ""
        })
      @q_4 = Form::Item::Question.from_h({
          label: "2. Naming Objects and Fingers",
          completion: "",
          mapping: "QSORRES",
          question_text: "2. Naming Objects and Fingers (refer to 5 categories in manual) (max = 5)",
          optional: "false",
          format: "1",
          ordinal: 5,
          note: ""
        })
      @q_5 = Form::Item::Question.from_h({
          label: "3. Delayed Word Recall",
          completion: "",
          mapping: "QSORRES",
          question_text: "3. Delayed Word Recall (max = 10) ",
          optional: "false",
          format: "2",
          ordinal: 6,
          note: ""
        })
      @q_6 = Form::Item::Question.from_h({
          label: "4. Commands",
          completion: "",
          mapping: "QSORRES",
          question_text: "4. Commands (max = 5)",
          optional: "false",
          format: "1",
          ordinal: 7,
          note: ""
        })
      @q_7 = Form::Item::Question.from_h({
          label: "5. Constructional Praxis",
          completion: "",
          mapping: "QSORRES",
          question_text: "5. Constructional Praxis (max = 5)",
          optional: "false",
          format: "1",
          ordinal: 8,
          note: ""
        })
      @q_8 = Form::Item::Question.from_h({
          label: "6. Ideational Praxis",
          completion: "",
          mapping: "QSORRES",
          question_text: "6. Ideational Praxis (max = 5)",
          optional: "false",
          format: "1",
          ordinal: 9,
          note: ""
        })
      @q_9 = Form::Item::Question.from_h({
          label: "7. Orientation",
          completion: "",
          mapping: "QSORRES",
          question_text: "7. Orientation (max = 8)",
          optional: "false",
          format: "1",
          ordinal: 10,
          note: ""
        })
      @q_10 = Form::Item::Question.from_h({
          label: "8. Word Recognition",
          completion: "",
          mapping: "QSORRES",
          question_text: "8. Word Recognition (max = 12)",
          optional: "false",
          format: "2",
          ordinal: 11,
          note: ""
        })
      @q_11 = Form::Item::Question.from_h({
          label: "9. Attention/Visual Search Task",
          completion: "",
          mapping: "QSORRES",
          question_text: "9. Attention/Visual Search Task (max = 40)",
          optional: "false",
          format: "2",
          ordinal: 12,
          note: ""
        })
      @q_12 = Form::Item::Question.from_h({
          label: "10. Maze Solution",
          completion: "",
          mapping: "QSORRES",
          question_text: "10. Maze Solution (max = 240)",
          optional: "false",
          format: "3",
          ordinal: 13,
          note: ""
        })
      @q_13 = Form::Item::Question.from_h({
          label: "Unit",
          completion: "",
          mapping: "QSORRESU",
          question_text: "10. Maze Solution - Unit",
          optional: "false",
          format: "7",
          ordinal: 14,
          note: ""
        })
      @q_14 = Form::Item::Question.from_h({
          label: "11. Spoken Language Ability",
          completion: "",
          mapping: "QSORRES",
          question_text: "11. Spoken Language Ability (max = 5)",
          optional: "false",
          format: "1",
          ordinal: 15,
          note: ""
        })
      @q_15 = Form::Item::Question.from_h({
          label: "12. Comprehension of Spoken Language",
          completion: "",
          mapping: "QSORRES",
          question_text: "12. Comprehension of Spoken Language (max = 5)",
          optional: "false",
          format: "1",
          ordinal: 16,
          note: ""
        })
      @q_16 = Form::Item::Question.from_h({
          label: "13. Word Finding Difficulty in Spontaneous Speech" ,
          completion: "",
          mapping: "QSORRES",
          question_text: "13. Word Finding Difficulty in Spontaneous Speech (max = 5)",
          optional: "false",
          format: "1",
          ordinal: 17,
          note: ""
        })
      @q_17 = Form::Item::Question.from_h({
          label: "14. Recall of Test Instructions",
          completion: "",
          mapping: "QSORRES",
          question_text: "14. Recall of Test Instructions (max = 5)",
          optional: "false",
          format: "1",
          ordinal: 18,
          note: ""
        })
      @m_1 = Form::Item::Mapping.from_h({
        label: "Mapping 18",
        completion: "",
        note: "",
        optional: "false",
        ordinal: 19,
        mapping: "QSCAT=ALZHEIMER'S DISEASE ASSESSMENT SCALE"
      })
      @m_2 = Form::Item::Mapping.from_h({
        label: "Mapping 19",
        completion: "",
        note: "",
        optional: "false",
        ordinal: 20,
        mapping: "QSTESTCD IN (ACITM01, ACITM02, ACITM03, ACITM04, ACITM05, ACITM06, ACITM07, ACITM08, ACITM09, ACITM10, ACITM11, ACITM12, ACITM13, ACITM14)"
      })
      @ng_1_cg_1 = Form::Group::Common.from_h({
        label: "Questionnaire",
        completion: "",
        note: "",
        optional: "false",
        ordinal: 3
      })
      @ng_1.has_item << @q_1
      @ng_1.has_item << @q_2
      @ng_1.has_item << @q_3
      @ng_1.has_item << @q_4
      @ng_1.has_item << @q_5
      @ng_1.has_item << @q_6
      @ng_1.has_item << @q_7
      @ng_1.has_item << @q_8
      @ng_1.has_item << @q_9
      @ng_1.has_item << @q_10
      @ng_1.has_item << @q_11
      @ng_1.has_item << @q_12
      @ng_1.has_item << @q_13
      @ng_1.has_item << @q_14
      @ng_1.has_item << @q_15
      @ng_1.has_item << @q_16
      @ng_1.has_item << @q_17
      @ng_1.has_item << @m_1
      @ng_1.has_item << @m_2
      @q_13.has_coded_value << Uri.new(uri: "http://www.cdisc.org/C71620/V6#C71620_C42535")
      @ng_1.has_common << @ng_1_cg_1
      @hackathon_form_1.has_group << @ng_1
      @hackathon_form_1.set_initial("F AD")
    end

    it "file" do
      simple_form_1
      sparql = Sparql::Update.new
      sparql.default_namespace(@hackathon_form_1.uri.namespace)
      @hackathon_form_1.to_sparql(sparql, true)
      @ng_1.to_sparql(sparql, true)
      @q_13.to_sparql(sparql, true)
      full_path = sparql.to_file
    copy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "hackathon_form_ad.ttl")
    end

  end

  describe "DEMOGRAPHICS Pilot" do

    def simple_form_1
      @hackathon_form_1 = Form.from_h({
        label: "Demographics (Pilot)"
      })
      @ng_1 = Form::Group::Normal.from_h({
          label: "DEMOGRAPHICS",
          completion: "",
          optional: "false",
          repeating: "false",
          ordinal: 1,
          note: ""
        })
      @ng_1_cg_1 = Form::Group::Common.from_h({
          label: "Common Group",
          completion: "",
          optional: "false",
          repeating: "false",
          ordinal: 1,
          note: ""
        })
      @ci_1 = Form::Item::Question.from_h({
          label: "Date Time (--DTC)",
          completion: "",
          optional: "false",
          ordinal: 1,
          note: ""
        })
      @ng_1_ng_1 = Form::Group::Normal.from_h({
          label: "Date of Birth",
          completion: "",
          optional: "false",
          repeating: "false",
          ordinal: 2,
          note: ""
        })
      @bcp_1 = Form::Item::BcProperty.from_h({
        label: "Date Time (--DTC)",
        completion: "",
        optional: "false",
        ordinal: 1,
        note: ""
      })
      @bcp_2 = Form::Item::BcProperty.from_h({
        label: "Result Value (--ORRES)",
        completion: "",
        optional: "false",
        ordinal: 2,
        note: ""
      })
      @bcp_3 = Form::Item::BcProperty.from_h({
        label: "Result Units (--ORRESU)",
        completion: "",
        optional: "false",
        ordinal: 3,
        note: ""
      })
      @ng_1_ng_2 = Form::Group::Normal.from_h({
          label: "Sex",
          completion: "",
          optional: "false",
          repeating: "false",
          ordinal: 3,
          note: ""
        })
      @bcp_4 = Form::Item::BcProperty.from_h({
        label: "Date Time (--DTC)",
        completion: "",
        optional: "false",
        ordinal: 1,
        note: ""
      })
      @bcp_5 = Form::Item::BcProperty.from_h({
        label: "Result Value (--ORRES)",
        completion: "",
        optional: "false",
        ordinal: 2,
        note: ""
      })
      @ng_1_ng_3 = Form::Group::Normal.from_h({
          label: "Race",
          completion: "",
          optional: "false",
          repeating: "false",
          ordinal: 4,
          note: ""
        })
      @bcp_6 = Form::Item::BcProperty.from_h({
        label: "Date Time (--DTC)",
        completion: "",
        optional: "false",
        ordinal: 1,
        note: ""
      })
      @bcp_7 = Form::Item::BcProperty.from_h({
        label: "Result Value (--ORRES)",
        completion: "",
        optional: "false",
        ordinal: 2,
        note: ""
      })
      @ng_1.has_common << @ng_1_cg_1
      @ng_1.has_sub_group << @ng_1_ng_1
      @ng_1.has_sub_group << @ng_1_ng_2
      @ng_1.has_sub_group << @ng_1_ng_3
      @ng_1_cg_1.has_item << @ci_1
      @ng_1_ng_1.has_item << @bcp_1
      @ng_1_ng_1.has_item << @bcp_2
      @ng_1_ng_1.has_item << @bcp_3
      @ng_1_ng_2.has_item << @bcp_4
      @ng_1_ng_2.has_item << @bcp_5
      @ng_1_ng_3.has_item << @bcp_6
      @ng_1_ng_3.has_item << @bcp_7
      @hackathon_form_1.has_group << @ng_1
      @hackathon_form_1.set_initial("F DM PILOT")
    end

    it "file" do
      simple_form_1
      sparql = Sparql::Update.new
      sparql.default_namespace(@hackathon_form_1.uri.namespace)
      @hackathon_form_1.to_sparql(sparql, true)
      @ng_1.to_sparql(sparql, true)
      @ng_1_cg_1.to_sparql(sparql, true)
      @ng_1_ng_1.to_sparql(sparql, true)
      @ng_1_ng_2.to_sparql(sparql, true)
      @ng_1_ng_3.to_sparql(sparql, true)
      full_path = sparql.to_file
    copy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "hackathon_form_dm_pilot.ttl")
    end

  end

  describe "Diabetes" do

    def simple_form_1
      @hackathon_form_1 = Form.from_h({
        label: "Vital Signs - Diabetes "
      })
      @ng_1 = Form::Group::Normal.from_h({
          label: "Group",
          completion: "",
          optional: "false",
          repeating: "false",
          ordinal: 1,
          note: ""
        })
      @ng_1_ng_1 = Form::Group::Normal.from_h({
          label: "Height",
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
      @ng_1_ng_2 = Form::Group::Normal.from_h({
          label: "Weight",
          completion: "",
          optional: "false",
          repeating: "false",
          ordinal: 2,
          note: ""
        })
      @bcp_3 = Form::Item::BcProperty.from_h({
        label: "Result Value (--ORRES)",
        completion: "",
        optional: "false",
        ordinal: 1,
        note: ""
      })
      @bcp_4 = Form::Item::BcProperty.from_h({
        label: "Result Units (--ORRESU)",
        completion: "",
        optional: "false",
        ordinal: 2,
        note: ""
      })
      @ng_1_ng_3 = Form::Group::Normal.from_h({
          label: "BMI",
          completion: "",
          optional: "false",
          repeating: "false",
          ordinal: 3,
          note: ""
        })
      @bcp_5 = Form::Item::BcProperty.from_h({
        label: "Result Value (--ORRES)",
        completion: "",
        optional: "false",
        ordinal: 1,
        note: ""
      })
      @bcp_6 = Form::Item::BcProperty.from_h({
        label: "Result Units (--ORRESU)",
        completion: "",
        optional: "false",
        ordinal: 2,
        note: ""
      })
      @ng_1_ng_4 = Form::Group::Normal.from_h({
          label: "BMI",
          completion: "",
          optional: "false",
          repeating: "false",
          ordinal: 4,
          note: ""
        })
      @bcp_7 = Form::Item::BcProperty.from_h({
        label: "Result Value (--ORRES)",
        completion: "",
        optional: "false",
        ordinal: 1,
        note: ""
      })
      @bcp_8 = Form::Item::BcProperty.from_h({
        label: "Result Units (--ORRESU)",
        completion: "",
        optional: "false",
        ordinal: 2,
        note: ""
      })
      @ng_1_ng_5 = Form::Group::Normal.from_h({
          label:  "Systolic Blood Pressure",
          completion: "",
          optional: "false",
          repeating: "false",
          ordinal: 5,
          note: ""
        })
      @bcp_9 = Form::Item::BcProperty.from_h({
        label: "Body Position (--POS)",
        completion: "",
        optional: "false",
        ordinal: 1,
        note: ""
      })
      @bcp_10 = Form::Item::BcProperty.from_h({
        label: "Result Value (--ORRES)",
        completion: "",
        optional: "false",
        ordinal: 2,
        note: ""
      })
      @bcp_11 = Form::Item::BcProperty.from_h({
        label: "Result Units (--ORRESU)",
        completion: "",
        optional: "false",
        ordinal: 3,
        note: ""
      })
      @ng_1_ng_6 = Form::Group::Normal.from_h({
          label:  "Diastolic Blood Pressure",
          completion: "",
          optional: "false",
          repeating: "false",
          ordinal: 6,
          note: ""
        })
      @bcp_12 = Form::Item::BcProperty.from_h({
        label: "Result Value (--ORRES)",
        completion: "",
        optional: "false",
        ordinal: 1,
        note: ""
      })
      @bcp_13 = Form::Item::BcProperty.from_h({
        label: "Result Units (--ORRESU)",
        completion: "",
        optional: "false",
        ordinal: 2,
        note: ""
      })
      @ng_1_ng_7 = Form::Group::Normal.from_h({
          label:  "Waist circumference",
          completion: "",
          optional: "false",
          repeating: "false",
          ordinal: 7,
          note: ""
        })
      @bcp_14 = Form::Item::BcProperty.from_h({
        label: "Result Value (--ORRES)",
        completion: "",
        optional: "false",
        ordinal: 1,
        note: ""
      })
      @bcp_15 = Form::Item::BcProperty.from_h({
        label: "Result Units (--ORRESU)",
        completion: "",
        optional: "false",
        ordinal: 2,
        note: ""
      })
      @ng_1_ng_8 = Form::Group::Normal.from_h({
          label:  "Hip circumference",
          completion: "",
          optional: "false",
          repeating: "false",
          ordinal: 8,
          note: ""
        })
      @bcp_16 = Form::Item::BcProperty.from_h({
        label: "Result Value (--ORRES)",
        completion: "",
        optional: "false",
        ordinal: 1,
        note: ""
      })
      @bcp_17 = Form::Item::BcProperty.from_h({
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
      @ng_1.has_sub_group << @ng_1_ng_5
      @ng_1.has_sub_group << @ng_1_ng_6
      @ng_1.has_sub_group << @ng_1_ng_7
      @ng_1.has_sub_group << @ng_1_ng_8
      @ng_1_ng_1.has_item << @bcp_1
      @ng_1_ng_1.has_item << @bcp_2
      @ng_1_ng_2.has_item << @bcp_3
      @ng_1_ng_2.has_item << @bcp_4
      @ng_1_ng_3.has_item << @bcp_5
      @ng_1_ng_3.has_item << @bcp_6
      @ng_1_ng_4.has_item << @bcp_7
      @ng_1_ng_4.has_item << @bcp_8
      @ng_1_ng_5.has_item << @bcp_9
      @ng_1_ng_5.has_item << @bcp_10
      @ng_1_ng_5.has_item << @bcp_11
      @ng_1_ng_6.has_item << @bcp_12
      @ng_1_ng_6.has_item << @bcp_13
      @ng_1_ng_7.has_item << @bcp_14
      @ng_1_ng_7.has_item << @bcp_15
      @ng_1_ng_8.has_item << @bcp_16
      @ng_1_ng_8.has_item << @bcp_17
      @hackathon_form_1.has_group << @ng_1
      @hackathon_form_1.set_initial("VS DIABETES")
    end

    it "file" do
      simple_form_1
      sparql = Sparql::Update.new
      sparql.default_namespace(@hackathon_form_1.uri.namespace)
      @hackathon_form_1.to_sparql(sparql, true)
      @ng_1.to_sparql(sparql, true)
      @ng_1_ng_1.to_sparql(sparql, true)
      @ng_1_ng_2.to_sparql(sparql, true)
      @ng_1_ng_3.to_sparql(sparql, true)
      @ng_1_ng_4.to_sparql(sparql, true)
      @ng_1_ng_5.to_sparql(sparql, true)
      @ng_1_ng_6.to_sparql(sparql, true)
      @ng_1_ng_7.to_sparql(sparql, true)
      @ng_1_ng_8.to_sparql(sparql, true)
      full_path = sparql.to_file
    copy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "hackathon_form_vs_diabetes.ttl")
    end

  end

end