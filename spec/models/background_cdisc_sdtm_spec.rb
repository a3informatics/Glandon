require 'rails_helper'

describe Background do

	include DataHelpers

	def sub_dir
    return "models/background/cdisc_sdtm"
  end

  def all_sdtm_ig_properties
    return [ :Datatype, :Classification, :"Sub Classification", :Ordinal, :"Variable name", :Rule, 
      :"Variable description.", :"Variable prefixed.", :"Controlled Terms or Format", :Notes, :Compliance ] 
  end

  def all_class_properties
    return [ :Datatype, :Classification, :"Sub Classification", :Ordinal, :"Variable name", :Rule, 
      :"Variable description.", :"Variable prefixed." ] 
  end
  
  def all_model_properties
    return [ :Datatype, :Classification, :"Sub Classification", :Ordinal, :"Variable name", :Rule, 
      :"Variable description.", :"Variable prefixed." ] 
  end

  def extra_output
    return true
  end

  def extra_1(index, name, expected, result)
    return false if !extra_output
    expected == result ? flag = "" : flag = "**********"
    puts "Index: #{index}, Name: #{name}: Expected: #{expected}, Result: #{result} #{flag}"
    return !flag.blank?
  end

  def extra_2(index, previous, current)
    puts "Index: #{index}, P: #{previous}"
    puts "Index: #{index}, C: #{current}"
  end

  def versions
    return ["1", "2", "3"]
  end

  def sdtm_model_variable(version, name)
    return SdtmModel::Variable.find("M-CDISC_SDTMMODEL_#{SdtmUtility.replace_prefix(name)}", 
      "http://www.assero.co.uk/MDRSdtmM/CDISC/V#{version}")
  rescue => e
    return nil
  end

  def sdtm_model_class_variable(version, name, klass)
    return SdtmModelDomain::Variable.find("M-CDISC_SDTMMODEL#{klass}_#{SdtmUtility.replace_prefix(name)}", 
      "http://www.assero.co.uk/MDRSdtmMd/CDISC/V#{version}")
  rescue => e
    return nil
  end

  def sdtm_ig_domain_variable(version, name, domain)
    return SdtmIgDomain::Variable.find("IG-CDISC_SDTMIG#{domain}_#{name}", 
      "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V#{version}")
  rescue => e
    return nil
  end

  def item_difference(checks, qualifier="")
    status_map = {:~ => :not_present, :- => :no_change, :C => :created, :U => :updated, :D => :deleted}
    checks.each do |check|
      objects = []
      versions.each { |version| objects << yield(version, check[:name], qualifier) }
      objects.each_with_index do |object, index|
        if index != 0
          result = IsoConcept.difference(objects[index - 1], objects[index], {ignore: ["ordinal"]})
          extra_1(index, check[:name], status_map[check[:result][index]], result[:status])
          expect(result[:status]).to eq(status_map[check[:result][index]])
          result[:results].each do |k, v|
            diff = extra_1(index, k, !check[:properties][index].include?(k), v[:status] == :no_change)
            extra_2(index, v[:previous], v[:current]) if diff
            expect(v[:status] == :no_change).to eq(!check[:properties][index].include?(k))
          end
        end
      end
    end
  end

  def sdtm_model_difference(checks)
    item_difference(checks) { |version, name, ignore| sdtm_model_variable(version, name) }
  end

  def sdtm_model_class_difference(checks, klass)
    item_difference(checks, klass) { |version, name, klass| sdtm_model_class_variable(version, name, klass) }
  end

  def sdtm_ig_domain_difference(checks, domain)
    item_difference(checks, domain) { |version, name, domain| sdtm_ig_domain_variable(version, name, domain) }
  end

	context "SDTM Model" do

    before :all do
      clear_triple_store
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Basic.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Data.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("BusinessOperational.ttl")
      load_schema_file_into_triple_store("BusinessDomain.ttl")
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      load_data_file_into_triple_store("SDTM_Model_1-2.ttl")
      load_data_file_into_triple_store("SDTM_Model_1-3.ttl")
      load_data_file_into_triple_store("SDTM_Model_1-4.ttl")
      load_data_file_into_triple_store("SDTM_IG_3-1-2.ttl")
      load_data_file_into_triple_store("SDTM_IG_3-1-3.ttl")
      load_data_file_into_triple_store("SDTM_IG_3-2.ttl")
      clear_iso_concept_object
    end

    it "SDTM Model Variables, Difference" do
      checks = 
      [ 
        { name: "STUDYID", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "DOMAIN", result: [:C, :U, :-], properties: [[], [:"Variable description."], []] },
        { name: "USUBJID", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "POOLID", result: [:~, :C, :-], properties: [[], all_model_properties, []] },
        { name: "SPDEVID", result: [:~, :~, :C], properties: [[], [], all_model_properties] },
        { name: "--SEQ", result: [:C, :U, :-], properties: [[], [:"Variable description."], []] },
        { name: "--GRPID", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--REFID", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--SPID", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "VISITNUM", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "VISIT", result: [:C, :U, :-], properties: [[], [:"Variable description."], []] },
        { name: "VISITDY", result: [:C, :U, :-], properties: [[], [:"Variable description."], []] },
        { name: "TAETORD", result: [:C, :U, :U], properties: [[], [:"Variable description."], [:"Variable description."]] },
        { name: "EPOCH", result: [:C, :U, :-], properties: [[], [:"Variable description."], []] },
        { name: "--DTC", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--STDTC", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--ENDTC", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--DY", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--STDY", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--ENDY", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--DUR", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--TPT", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--TPTNUM", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--ELTM", result: [:C, :U, :U], properties: [[], [:"Variable description."], [:"Variable description."]] },
        { name: "--TPTREF", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--RFTDTC", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--STRF", result: [:C, :-, :U], properties: [[], [], [:"Variable description."]] },
        { name: "--ENRF", result: [:C, :-, :U], properties: [[], [], [:"Variable description."]] },
        { name: "--EVLINT", result: [:C, :U, :U], properties: [[], [:"Variable description."], [:"Variable description."]] },
        { name: "--EVINTX", result: [:~, :~, :C], properties: [[], [], all_model_properties] },
        { name: "--STRTPT", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--STTPT", result: [:C, :U, :-], properties: [[], [:"Variable description."], []] },
        { name: "--ENRTPT", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--ENTPT", result: [:C, :U, :-], properties: [[], [:"Variable description."], []] },
        { name: "--STINT", result: [:~, :~, :C], properties: [[], [], all_model_properties] },
        { name: "--ENINT", result: [:~, :~, :C], properties: [[], [], all_model_properties] },
        { name: "--DETECT", result: [:~, :C, :-], properties: [[], all_model_properties, []] },
        { name: "--TSTDTL", result: [:~, :~, :C], properties: [[], [], all_class_properties] },
        { name: "--POS", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--NRIND", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--RESCAT", result: [:C, :-, :U], properties: [[], [], [:"Variable description."]] },
        { name: "--XFN", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--NAM", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--LOINC", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--SPEC", result: [:C, :-, :U], properties: [[], [], [:"Variable description."]] },
        { name: "--ANTREG", result: [:~, :C, :-], properties: [[], all_class_properties, []] },
        { name: "--SPCCND", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--SPCUFL", result: [:~, :C, :-], properties: [[], all_class_properties, []] },
        { name: "--METHOD", result: [:C, :-, :U], properties: [[], [], [:"Variable description."]] },
        { name: "--RUNID", result: [:~, :~, :C], properties: [[], [], all_class_properties] },
        { name: "--ANMETH", result: [:~, :~, :C], properties: [[], [], all_class_properties] },
        { name: "--LEAD", result: [:~, :C, :-], properties: [[], all_class_properties, []] },
        { name: "--CSTATE", result: [:~, :C, :-], properties: [[], all_class_properties, []] },
        { name: "--BLFL", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--FAST", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--DRVFL", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--EVAL", result: [:C, :U, :-], properties: [[], [:"Variable description."], []] },
        { name: "--EVALID", result: [:~, :C, :-], properties: [[], all_class_properties, []] },
        { name: "--ACPTFL", result: [:~, :C, :-], properties: [[], all_class_properties, []] },
        { name: "--DTHREL", result: [:C, :-, :U], properties: [[], [], [:"Variable description."]] },
        { name: "--LLOQ", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--ULOQ", result: [:~, :~, :C], properties: [[], [], all_class_properties] },
        { name: "--EXCLFL", result: [:~, :C, :U], properties: [[], all_class_properties, [:"Variable description."]] },
        { name: "--REASEX", result: [:~, :C, :-], properties: [[], all_class_properties, []] },
        { name: "APID", result: [:~, :~, :C], properties: [[], [], all_class_properties] },
        { name: "RSUBJID", result: [:~, :~, :C], properties: [[], [], all_class_properties] },
        { name: "RDEVID", result: [:~, :~, :C], properties: [[], [], all_class_properties] },
        { name: "SREL", result: [:~, :~, :C], properties: [[], [], all_class_properties] },
        { name: "--TERM", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--MODIFY", result: [:C, :-, :U], properties: [[], [], [:"Variable description."]] },
        { name: "--LLT", result: [:~, :C, :-], properties: [[], all_class_properties, []] },
        { name: "--LLTCD", result: [:~, :C, :-], properties: [[], all_class_properties, []] },
        { name: "--DECOD", result: [:C, :-, :U], properties: [[], [], [:"Variable description."]] },
        { name: "--PTCD", result: [:~, :C, :-], properties: [[], all_class_properties, []] },
        { name: "--HLT", result: [:~, :C, :-], properties: [[], all_class_properties, []] },
        { name: "--HLTCD", result: [:~, :C, :-], properties: [[], all_class_properties, []] },
        { name: "--HLGT", result: [:~, :C, :-], properties: [[], all_model_properties, []] }, 
        { name: "--HLGTCD", result: [:~, :C, :-], properties: [[], all_class_properties, []] },
        { name: "--CAT", result: [:C, :U, :-], properties: [[], [:"Variable description."], []] },
        { name: "--SCAT", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--PRESP", result: [:C, :U, :U], properties: [[], [:"Variable description.", :"Sub Classification"], [:"Variable description."]] },
        { name: "--OCCUR", result: [:C, :U, :U], properties: [[], [:"Variable description."], [:"Variable description."]] },
        { name: "--STAT", result: [:C, :U, :U], properties: [[], [:"Variable description."], [:"Variable description."]] },
        { name: "--REASND", result: [:C, :-, :U], properties: [[], [], [:"Variable description."]] },
        { name: "--BODSYS", result: [:C, :U, :-], properties: [[], [:"Variable description."], []] },
        { name: "--BDSYCD", result: [:~, :C, :-], properties: [[], all_model_properties, []] },
        { name: "--SOC", result: [:~, :C, :-], properties: [[], all_model_properties, []] },
        { name: "--SOCCD", result: [:~, :C, :-], properties: [[], all_model_properties, []] },
        { name: "--LOC", result: [:C, :U, :U], properties: [[], [:"Variable description."], [:"Variable description."]] },
        { name: "--PARTY", result: [:~, :~, :C], properties: [[], [], all_class_properties] },
        { name: "--PRTYID", result: [:~, :~, :C], properties: [[], [], all_class_properties] },
        { name: "--SEV", result: [:C, :U, :-], properties: [[], [:"Variable description."], []] },
        { name: "--SER", result: [:C, :U, :U], properties: [[], [:"Variable description."], [:"Variable description."]] },
        { name: "--ACN", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--ACNOTH", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--ACNDEV", result: [:~, :~, :C], properties: [[], [], all_class_properties] },
        { name: "--REL", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--RELNST", result: [:C, :U, :-], properties: [[], [:"Variable description."], []] },
        { name: "--PATT", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--OUT", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--SCAN", result: [:C, :U, :U], properties: [[], [:"Variable description."], [:"Variable description."]] },
        { name: "--SCONG", result: [:C, :U, :U], properties: [[], [:"Variable description."], [:"Variable description."]] },
        { name: "--SDISAB", result: [:C, :U, :U], properties: [[], [:"Variable description."], [:"Variable description."]] },
        { name: "--SDTH", result: [:C, :U, :U], properties: [[], [:"Variable description."], [:"Variable description."]] },
        { name: "--SHOSP", result: [:C, :U, :U], properties: [[], [:"Variable description."], [:"Variable description."]] },
        { name: "--SLIFE", result: [:C, :U, :U], properties: [[], [:"Variable description."], [:"Variable description."]] },
        { name: "--SOD", result: [:C, :U, :U], properties: [[], [:"Variable description."], [:"Variable description."]] },
        { name: "--SMIE", result: [:C, :U, :U], properties: [[], [:"Variable description."], [:"Variable description."]] },
        { name: "--CONTRT", result: [:C, :U, :U], properties: [[], [:"Variable description."], [:"Variable description."]] },
        { name: "--TOX", result: [:C, :-, :U], properties: [[], [], [:"Variable description."]] },
        { name: "--TOXGR", result: [:C, :-, :U], properties: [[], [], [:"Variable description."]] },
        { name: "--OBJ", result: [:C, :U, :U], properties: [[], [:"Variable description."], [:"Variable description."]] },
        { name: "--TESTCD", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--TEST", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--ORRES", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--ORRESU", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--ORNRLO", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--ORNRHI", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--STRESC", result: [:C, :U, :U], properties: [[], [:"Variable description."], [:"Variable description."]] },
        { name: "--STRESN", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--STRESU", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--STNRLO", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--STNRC", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--TRT", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--MOOD", result: [:~, :~, :C], properties: [[], [], all_class_properties] },
        { name: "--INDC", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--CLAS", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--CLASCD", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--DOSE", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--DOSTXT", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--DOSU", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--DOSFRM", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--DOSFRQ", result: [:C, :-, :U], properties: [[], [], [:"Variable description."]] },
        { name: "--DOSTOT", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--DOSRGM", result: [:C, :-, :U], properties: [[], [], [:"Variable description."]] },
        { name: "--ROUTE", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--LOT", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--LAT", result: [:~, :C, :U], properties: [[], all_class_properties, [:"Variable description."]] },
        { name: "--DIR", result: [:~, :C, :U], properties: [[], all_class_properties, [:"Variable description."]] },
        { name: "--PORTOT", result: [:~, :C, :U], properties: [[], all_class_properties, [:"Variable description."]] },
        { name: "--PSTRG", result: [:~, :~, :C], properties: [[], [], all_class_properties] },
        { name: "--PSTRGU", result: [:~, :~, :C], properties: [[], [], all_class_properties] },
        { name: "--TRTV", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--VAMT", result: [:C, :-, :U], properties: [[], [], [:"Variable description."]] },
        { name: "--VAMTU", result: [:C, :-, :U], properties: [[], [], [:"Variable description."]] },
        { name: "--ADJ", result: [:C, :-, :-], properties: [[], [], []] }
      ]
      sdtm_model_difference(checks)      
    end

    it "SDTM Model Class Findings Variables, Difference" do
      checks = 
      [ 
        { name: "STUDYID", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "DOMAIN", result: [:C, :U, :-], properties: [[], [:"Variable description."], []] },
        { name: "USUBJID", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--SEQ", result: [:C, :U, :-], properties: [[], [:"Variable description."], []] },
        { name: "--GRPID", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--REFID", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--SPID", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--TESTCD", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--TEST", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--MODIFY", result: [:C, :-, :U], properties: [[], [], [:"Variable description."]] },
        { name: "--TSTDTL", result: [:~, :~, :C], properties: [[], [], all_class_properties] },
        { name: "--CAT", result: [:C, :U, :-], properties: [[], [:"Variable description."], []] },
        { name: "--SCAT", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--POS", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--BODSYS", result: [:C, :U, :-], properties: [[], [:"Variable description."], []] },
        { name: "--ORRES", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--ORRESU", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--ORNRLO", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--ORNRHI", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--STRESC", result: [:C, :U, :U], properties: [[], [:"Variable description."], [:"Variable description."]] },
        { name: "--STRESN", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--STRESU", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--STNRLO", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--STNRHI", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--STNRC", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--NRIND", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--RESCAT", result: [:C, :-, :U], properties: [[], [], [:"Variable description."]] },
        { name: "--STAT", result: [:C, :U, :U], properties: [[], [:"Variable description."], [:"Variable description."]] },
        { name: "--REASND", result: [:C, :-, :U], properties: [[], [], [:"Variable description."]] },
        { name: "--XFN", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--NAM", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--LOINC", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--SPEC", result: [:C, :-, :U], properties: [[], [], [:"Variable description."]] },
        { name: "--ANTREG", result: [:~, :C, :-], properties: [[], all_class_properties, []] },
        { name: "--SPCCND", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--SPCUFL", result: [:~, :C, :-], properties: [[], all_class_properties, []] },
        { name: "--LOC", result: [:C, :U, :U], properties: [[], [:"Variable description."], [:"Variable description."]] },
        { name: "--LAT", result: [:~, :C, :U], properties: [[], all_class_properties, [:"Variable description."]] },
        { name: "--DIR", result: [:~, :C, :U], properties: [[], all_class_properties, [:"Variable description."]] },
        { name: "--PORTOT", result: [:~, :C, :U], properties: [[], all_class_properties, [:"Variable description."]] },
        { name: "--METHOD", result: [:C, :-, :U], properties: [[], [], [:"Variable description."]] },
        { name: "--RUNID", result: [:~, :~, :C], properties: [[], [], all_class_properties] },
        { name: "--ANMETH", result: [:~, :~, :C], properties: [[], [], all_class_properties] },
        { name: "--LEAD", result: [:~, :C, :-], properties: [[], all_class_properties, []] },
        { name: "--CSTATE", result: [:~, :C, :-], properties: [[], all_class_properties, []] },
        { name: "--BLFL", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--FAST", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--DRVFL", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--EVAL", result: [:C, :U, :-], properties: [[], [:"Variable description."], []] },
        { name: "--EVALID", result: [:~, :C, :-], properties: [[], all_class_properties, []] },
        { name: "--ACPTFL", result: [:~, :C, :-], properties: [[], all_class_properties, []] },
        { name: "--TOX", result: [:C, :-, :U], properties: [[], [], [:"Variable description."]] },
        { name: "--TOXGR", result: [:C, :-, :U], properties: [[], [], [:"Variable description."]] },
        { name: "--SEV", result: [:C, :U, :-], properties: [[], [:"Variable description."], []] },
        { name: "--DTHREL", result: [:C, :-, :U], properties: [[], [], [:"Variable description."]] },
        { name: "--LLOQ", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--ULOQ", result: [:~, :~, :C], properties: [[], [], all_class_properties] },
        { name: "--EXCLFL", result: [:~, :C, :U], properties: [[], all_class_properties, [:"Variable description."]] },
        { name: "--REASEX", result: [:~, :C, :-], properties: [[], all_class_properties, []] },
        { name: "VISITNUM", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "VISIT", result: [:C, :U, :-], properties: [[], [:"Variable description."], []] },
        { name: "VISITDY", result: [:C, :U, :-], properties: [[], [:"Variable description."], []] },
        { name: "TAETORD", result: [:C, :U, :U], properties: [[], [:"Variable description."], [:"Variable description."]] },
        { name: "EPOCH", result: [:C, :U, :-], properties: [[], [:"Variable description."], []] },
        { name: "--DTC", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--STDTC", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--ENDTC", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--DY", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--STDY", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--ENDY", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--DUR", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--TPT", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--TPTNUM", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--ELTM", result: [:C, :U, :U], properties: [[], [:"Variable description."], [:"Variable description."]] },
        { name: "--TPTREF", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--RFTDTC", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--STRF", result: [:C, :-, :U], properties: [[], [], [:"Variable description."]] },
        { name: "--ENRF", result: [:C, :-, :U], properties: [[], [], [:"Variable description."]] },
        { name: "--EVLINT", result: [:C, :U, :U], properties: [[], [:"Variable description."], [:"Variable description."]] },
        { name: "--EVINTX", result: [:~, :~, :C], properties: [[], [], all_class_properties] },
        { name: "--STRTPT", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--STTPT", result: [:C, :U, :-], properties: [[], [:"Variable description."], []] },
        { name: "--ENRTPT", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "--ENTPT", result: [:C, :U, :-], properties: [[], [:"Variable description."], []] },
        { name: "--STINT", result: [:~, :~, :C], properties: [[], [], all_class_properties] },
        { name: "--ENINT", result: [:~, :~, :C], properties: [[], [], all_class_properties] },
        { name: "--DETECT", result: [:~, :C, :-], properties: [[], all_class_properties, []] }
      ]
      sdtm_model_class_difference(checks, "FINDINGS")      
    end

    it "SDTM IG Domain CE Variables, Difference" do
      checks = 
      [ 
        { name: "STUDYID", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "DOMAIN", result: [:C, :U, :-], properties: [[], [:"Variable description.", :"Controlled Terms or Format"], []] },
        { name: "USUBJID", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "CESEQ", result: [:C, :U, :-], properties: [[], [:"Variable description."], []] },
        { name: "CEGRPID", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "CEREFID", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "CESPID", result: [:C, :-, :U], properties: [[], [], [:Notes]] },
        { name: "CETERM", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "CEDECOD", result: [:C, :-, :U], properties: [[], [], [:"Variable description."]] },
        { name: "CECAT", result: [:C, :U, :-], properties: [[], [:"Variable description."], []] },
        { name: "CESCAT", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "CEPRESP", result: [:C, :U, :U], properties: [[], [:"Sub Classification", :"Variable description."], [:"Variable description."]] },
        { name: "CEOCCUR", result: [:C, :U, :U], properties: [[], [:"Variable description."], [:"Variable description."]] },
        { name: "CESTAT", result: [:C, :U, :U], properties: [[], [:"Variable description."], [:"Variable description."]] },
        { name: "CEREASND", result: [:C, :-, :U], properties: [[], [], [:"Variable description."]] },
        { name: "CEBODSYS", result: [:C, :U, :U], properties: [[], [:"Variable description."], [:Notes]] },
        { name: "CESEV", result: [:C, :U, :-], properties: [[], [:"Variable description."], []] },
        { name: "CEDTC", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "CESTDTC", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "CEENDTC", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "CEDY", result: [:C, :U, :-], properties: [[], [:Notes], []] },
        { name: "CESTRF", result: [:C, :-, :U], properties: [[], [], [:"Variable description."]] },
        { name: "CEENRF", result: [:C, :-, :U], properties: [[], [], [:"Variable description."]] },
        { name: "CESTRTPT", result: [:C, :U, :U], properties: [[], [:"Controlled Terms or Format"], [:"Controlled Terms or Format"]] },
        { name: "CESTTPT", result: [:C, :U, :U], properties: [[], [:"Variable description.", :Notes], [:Notes]] },
        { name: "CEENRTPT", result: [:C, :U, :U], properties: [[], [:"Controlled Terms or Format"], [:"Controlled Terms or Format"]] },
        { name: "CEENTPT", result: [:C, :U, :-], properties: [[], [:"Variable description.", :Notes], []] }
      ]
      sdtm_ig_domain_difference(checks, "CE")      
    end

    it "SDTM IG Domain DM Variables, Difference" do
      checks = 
      [ 
        { name: "STUDYID", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "DOMAIN", result: [:C, :U, :-], properties: [[], [:"Variable description.", :"Controlled Terms or Format"], []] },
        { name: "USUBJID", result: [:C, :U, :-], properties: [[], [:Notes], []] },
        { name: "SUBJID", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "RFSTDTC", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "RFENDTC", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "RFXSTDTC", result: [:~, :C, :-],
          properties: 
          [ 
            [], 
            all_sdtm_ig_properties, 
            []
          ] 
        },
        { name: "RFXENDTC", result: [:~, :C, :-],
          properties: 
          [ 
            [], 
            all_sdtm_ig_properties, 
            []
          ] 
        },
        { name: "RFICDTC", result: [:~, :C, :-],
          properties: 
          [ 
            [], 
            all_sdtm_ig_properties, 
            []
          ] 
        },
        { name: "RFPENDTC", result: [:~, :C, :-],
          properties: 
          [ 
            [], 
            all_sdtm_ig_properties, 
            []
          ] 
        },
        { name: "DTHDTC", result: [:~, :C, :-],
          properties: 
          [ 
            [], 
            all_sdtm_ig_properties, 
            []
          ] 
        },
        { name: "DTHFL", result: [:~, :C, :-],
          properties: 
          [ 
            [], 
            all_sdtm_ig_properties, 
            []
          ] 
        },
        { name: "SITEID", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "INVID", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "INVNAM", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "BRTHDTC", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "AGE", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "AGEU", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "SEX", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "RACE", result: [:C, :U, :U], properties: [[], [:Notes], [:Notes]] },
        { name: "ETHNIC", result: [:C, :U, :U], properties: [[], [:Notes], [:Notes]] },
        { name: "ARMCD", result: [:C, :U, :U], properties: [[], [:Notes], [:Notes]] },
        { name: "ARM", result: [:C, :U, :-], properties: [[], [:Notes], []] },
        { name: "ACTARMCD", result: [:~, :C, :U],
          properties: 
          [ 
            [], 
            all_sdtm_ig_properties, 
            [:Notes]
          ] 
        },
        { name: "ACTARM", result: [:~, :C, :U],
          properties: 
          [ 
            [], 
            all_sdtm_ig_properties, 
            [:Notes]
          ] 
        },
        { name: "COUNTRY", result: [:C, :U, :U], properties: [[], [:"Controlled Terms or Format"], [:"Controlled Terms or Format"]] },
        { name: "DMDTC", result: [:C, :-, :-], properties: [[], [], []] },
        { name: "DMDY", result: [:C, :-, :-], properties: [[], [], []] }
      ]
      sdtm_ig_domain_difference(checks, "DM")      
    end

  end

end