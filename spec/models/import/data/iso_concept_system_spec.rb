require 'rails_helper'

describe IsoConceptSystem do

	include DataHelpers
  include PauseHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/import/data/base/cs"
  end

  describe "Baseline Create Tags" do

    before :all do
      data_files = []
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    after :all do
      delete_all_public_test_files
    end

    it "Baseline Tags" do
      cs = IsoConceptSystem.root
      cdisc = cs.add({label: "CDISC", description: "CDISC related tags"})
      sdtm = cdisc.add({label: "SDTM", description: "SDTM related information."})
      cdash = cdisc.add({label: "CDASH", description: "CDASH related information."})
      adam = cdisc.add({label: "ADaM", description: "ADaM related information."})
      send = cdisc.add({label: "SEND", description: "SEND related information."})
      protocol = cdisc.add({label: "Protocol", description: "Protocol related information."})
      qs = cdisc.add({label: "QS", description: "Questionnaire related information."})
      qs_ft = cdisc.add({label: "QS-FT", description: "Questionnaire and Functional Test related information."})
      coa = cdisc.add({label: "COA", description: "Clinical Outcome Assessent related information."})
      qrs = cdisc.add({label: "QRS", description: "Questionnaire and Rating Scale related information."})

      cs.is_top_concept_objects
      cdisc.narrower_objects

      sparql = Sparql::Update.new
      sparql.default_namespace(cs.uri.namespace)
      cs.to_sparql(sparql, true)
      cdisc.to_sparql(sparql, true)
      cdisc.narrower.each {|x| x.to_sparql(sparql, true)}
      file = sparql.to_file
    #Xcopy_file_from_public_files_rename("test", file.basename, sub_dir, "mdr_iso_concept_systems.ttl")
    end

  end

  describe "Migration One" do

    before :all do
      data_files = []
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
    end

    after :all do
      delete_all_public_test_files
    end

    it "migration 1, add define.xml" do
      cs = IsoConceptSystem.root
      cdisc = IsoConceptSystem.path(["CDISC"])
      define = cdisc.add({label: "Define-XML", description: "Define.xml related information."})
      
      sparql = Sparql::Update.new
      sparql.default_namespace(cs.uri.namespace)
      define.to_sparql(sparql, true)
      sparql.add({uri: cdisc.uri}, {namespace: Uri.namespaces.namespace_from_prefix(:isoC), :fragment => "narrower"}, {uri: define.uri})
      file = sparql.to_file
    #Xcopy_file_from_public_files_rename("test", file.basename, sub_dir, "mdr_iso_concept_systems_migration_1.ttl")
    end

  end

  describe "Migration Two" do

    before :all do
      data_files = []
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
    end

    after :all do
      delete_all_public_test_files
    end

    it "migration 2, add SDTM tags" do
      cs = IsoConceptSystem.root
      cdisc = IsoConceptSystem.path(["CDISC"])
      sdtm_std = cdisc.add({label: "SDTM-STD", description: "Information relating to the internal structure of the SDTM standard."})
      sdtm_std_var = sdtm_std.add({label: "Variable", description: "Information relating to the variables within SDTM."})
      sdtm_std_var_dt = sdtm_std_var.add({label: "Datatype", description: "SDTM variable datatypes."})
      sdtm_std_var_dt_char = sdtm_std_var_dt.add({label: "Character", description: "Character datatype"})
      sdtm_std_var_dt_num = sdtm_std_var_dt.add({label: "Numeric", description: "Numeric datatype"})
      sdtm_std_var_compliance = sdtm_std_var.add({label: "Compliance", description: "SDTM variable compliance."})
      sdtm_std_var_compliance_reqd = sdtm_std_var_compliance.add({label: "Required", description: "Any variable that is basic to the identification of a data record (i.e., essential key variables and a topic variable) or is necessary to make the record meaningful. Required variables must always be included in the dataset and cannot be null for any record"})
      sdtm_std_var_compliance_exp = sdtm_std_var_compliance.add({label: "Expected", description: "Any variable necessary to make a record useful in the context of a specific domain. Expected variables may contain some null values, but in most cases will not contain null values for every record. When no data has been collected for an expected variable, however, a null column must still be included in the dataset, and a comment must be included in the define.xml to state that data was not collected."})
      sdtm_std_var_compliance_perm = sdtm_std_var_compliance.add({label: "Permissible", description: "A variable that should be used in a domain as appropriate when collected or derived. Except where restricted by specific domain assumptions, any SDTM Timing and Identifier variables, and any Qualifier variables from the same general observation class are permissible for use in a domain based on that general observation class. The Sponsor can decide whether a Permissible variable should be included as a column when all values for that variable "})
      sdtm_std_var_classified = sdtm_std_var.add({label: "Classification", description: "SDTM variable classifcation."})
      sdtm_std_var_classified_grouping = sdtm_std_var_classified.add({label: "Grouping Qualifier", description: "A grouping qualifier"})
      sdtm_std_var_classified_identifier = sdtm_std_var_classified.add({label: "Identifier", description: "Variables, such as those that identify the study, the subject (individual human or animal or group of individuals) involved in the study, the domain, and the sequence number of the record."})
      sdtm_std_var_classified_topic = sdtm_std_var_classified.add({label: "Topic", description: "Variables which specify the focus of the observation (such as the name of a lab test)."})
      sdtm_std_var_classified_timing = sdtm_std_var_classified.add({label: "Timing", description: "Variables which describe the timing of an observation (such as start date and end date)."})
      sdtm_std_var_classified_qualifier = sdtm_std_var_classified.add({label: "Qualifier", description: "Variables which include additional illustrative text, or numeric values that describe the results or additional traits of the observation (such as units or descriptive adjectives)."})
      sdtm_std_var_classified_rule = sdtm_std_var_classified.add({label: "Rule", description: "Variables which express an algorithm or executable method to define start, end, or looping conditions in the Trial Design model."})
      sdtm_std_var_classified_qualifier_grouping = sdtm_std_var_classified_qualifier.add({label: "Grouping", description: "Qualifiers used to group together a collection of observations within the same domain. Examples include --CAT and --SCAT."})
      sdtm_std_var_classified_qualifier_result = sdtm_std_var_classified_qualifier.add({label: "Result", description: "Qualifiers used to describe the specific results associated with the topic variable in a Findings dataset. They answer the question raised by the topic variable. Result Qualifiers are --ORRES, --STRESC, and --STRESN."})
      sdtm_std_var_classified_qualifier_synonym = sdtm_std_var_classified_qualifier.add({label: "Synonym", description: "Qualifiers used to specify an alternative name for a particular variable in an observation. Examples include --MODIFY and --DECOD, which are equivalent terms for a --TRT or --TERM Topic variable, and --TEST for --TESTCD."})
      sdtm_std_var_classified_qualifier_record = sdtm_std_var_classified_qualifier.add({label: "Record", description: "Qualifiers used to define additional attributes of the observation record as a whole (rather than describing a particular variable within a record). Examples include --REASND, AESLIFE, and all other SAE flag variables in the AE domain; AGE, SEX, and RACE in the DM domain; and --BLFL, --POS, --LOC, --SPEC, and --NAM in a Findings domain."})
      sdtm_std_var_classified_qualifier_variable = sdtm_std_var_classified_qualifier.add({label: "Variable", description: "Qualifiers used to further modify or describe a specific variable within an observation and are only meaningful in the context of the variable they qualify. Examples include --ORRESU, --ORNRHI, and --ORNRLO, all of which are Variable Qualifiers of --ORRES; and --DOSU, which is a Variable Qualifier of --DOSE."})
      
      sparql = Sparql::Update.new
      sparql.default_namespace(cs.uri.namespace)
      sdtm_std.to_sparql(sparql, true)
      sparql.add({uri: cdisc.uri}, {namespace: Uri.namespaces.namespace_from_prefix(:isoC), :fragment => "narrower"}, {uri: sdtm_std.uri})
      [sdtm_std, sdtm_std_var, sdtm_std_var_dt, sdtm_std_var_compliance, sdtm_std_var_classified, sdtm_std_var_classified_qualifier].each do |var|
        var.narrower_objects.each do |x| 
          x.to_sparql(sparql, true)
        end
      end
      file = sparql.to_file
    copy_file_from_public_files_rename("test", file.basename, sub_dir, "mdr_iso_concept_systems_migration_2.ttl")
    end

  end

end