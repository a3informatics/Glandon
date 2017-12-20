require 'rails_helper'

describe ConceptDifference do

  include DataHelpers
  include TimeHelpers

  def sub_dir
    return "models/concerns/concept_difference"
  end

  context "Terminology Tests" do
  
    before :all do
      clear_triple_store
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Basic.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Data.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("ISO25964.ttl")
      load_schema_file_into_triple_store("CDISCTerm.ttl")
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      load_test_file_into_triple_store("CT_V39.ttl")
      load_test_file_into_triple_store("CT_V40.ttl")
      load_test_file_into_triple_store("CT_V41.ttl")
      clear_iso_concept_object
    end

    it "CLs different object, different" do
      cl_1 = CdiscCl.find("CL-C66741", "http://www.assero.co.uk/MDRThesaurus/CDISC/V40")
      cl_2 = CdiscCl.find("CL-C66741", "http://www.assero.co.uk/MDRThesaurus/CDISC/V41")
      result = ConceptDifference.diff?(cl_1, cl_2)
      expect(result).to eq(true)    
    puts result
    end

    it "CLs different object, same" do
      cl_1 = CdiscCli.find("CLI-C66741_C84372", "http://www.assero.co.uk/MDRThesaurus/CDISC/V40")
      cl_2 = CdiscCli.find("CLI-C66741_C84372", "http://www.assero.co.uk/MDRThesaurus/CDISC/V41")
      result = ConceptDifference.difference(cl_1, cl_2, {ignore: ["synonym"]})
      #expect(result).to eq(false)    
      puts result
    end
    
    it "CLs different object, same" do
      cl_1 = CdiscCli.find("CLI-C66741_C84372", "http://www.assero.co.uk/MDRThesaurus/CDISC/V40")
      cl_2 = CdiscCli.find("CLI-C66741_C84372", "http://www.assero.co.uk/MDRThesaurus/CDISC/V41")
      result = ConceptDifference.difference(cl_1, cl_2, {ignore: ["synonym"]})
      #expect(result).to eq(false)    
      puts result
    end

    it "CLs different object with children, same" do
      cl_1 = CdiscCl.find("CL-C101843", "http://www.assero.co.uk/MDRThesaurus/CDISC/V39")
      cl_2 = CdiscCl.find("CL-C101843", "http://www.assero.co.uk/MDRThesaurus/CDISC/V39")
      result = ConceptDifference.diff_with_children?(cl_1, cl_2, "identifier")
      expect(result).to eq(false)    
    end
    
    it "CL difference object, same" do
      cl_1 = CdiscCl.find("CL-C101843", "http://www.assero.co.uk/MDRThesaurus/CDISC/V39")
      cl_2 = CdiscCl.find("CL-C101843", "http://www.assero.co.uk/MDRThesaurus/CDISC/V39")
      result = ConceptDifference.difference(cl_1, cl_2)
      #expect(result).to eq("")    
    end
    
    it "CL difference object with children, same" do
      cl_1 = CdiscCl.find("CL-C101843", "http://www.assero.co.uk/MDRThesaurus/CDISC/V39")
      cl_2 = CdiscCl.find("CL-C101843", "http://www.assero.co.uk/MDRThesaurus/CDISC/V39")
      result = ConceptDifference.difference_with_children(cl_1, cl_2, "identifier")
    puts result
      #expect(result).to eq("")    
    end

    it "CLs different object, different" do
      cl_1 = CdiscCl.find("CL-C66741", "http://www.assero.co.uk/MDRThesaurus/CDISC/V40")
      cl_2 = CdiscCl.find("CL-C66741", "http://www.assero.co.uk/MDRThesaurus/CDISC/V41")
      result = ConceptDifference.difference_with_children(cl_1, cl_2, "identifier")
      #expect(result).to eq(true)    
    puts result
    end

    it "CLs different object with children, different" do
      cl_1 = CdiscCl.find("CL-C65047", "http://www.assero.co.uk/MDRThesaurus/CDISC/V40")
      cl_2 = CdiscCl.find("CL-C65047", "http://www.assero.co.uk/MDRThesaurus/CDISC/V41")
      result = ConceptDifference.diff_with_children?(cl_1, cl_2, "identifier")
      expect(result).to eq(true)    
    end
    
    it "CL difference object, different" do
      cl_1 = CdiscCl.find("CL-C65047", "http://www.assero.co.uk/MDRThesaurus/CDISC/V40")
      cl_2 = CdiscCl.find("CL-C65047", "http://www.assero.co.uk/MDRThesaurus/CDISC/V41")
      result = ConceptDifference.difference(cl_1, cl_2)
      #expect(result).to eq("")    
    end
    
    it "CL difference object with children, different" do
      cl_1 = CdiscCl.find("CL-C65047", "http://www.assero.co.uk/MDRThesaurus/CDISC/V40")
      cl_2 = CdiscCl.find("CL-C65047", "http://www.assero.co.uk/MDRThesaurus/CDISC/V41")
      result = ConceptDifference.difference_with_children(cl_1, cl_2, "identifier")
      #expect(result).to eq("")    
    end

    it "CL difference object, different" do
      cl_1 = CdiscCl.find("CL-65047", "http://www.assero.co.uk/MDRThesaurus/CDISC/V40")
      cl_2 = CdiscCl.find("CL-65047", "http://www.assero.co.uk/MDRThesaurus/CDISC/V41")
      result = ConceptDifference.difference(cl_1, cl_2)
      #expect(result).to eq("")    
    end

    it "CL difference object with children, different" do
      cl_1 = CdiscCl.find("CL-C65047", "http://www.assero.co.uk/MDRThesaurus/CDISC/V40")
      cl_2 = CdiscCl.find("CL-C65047", "http://www.assero.co.uk/MDRThesaurus/CDISC/V41")
      result = ConceptDifference.difference_with_children(cl_1, cl_2, "identifier")
    puts result
      #expect(result).to eq("")    
    end

  end

  context "SDTM Model Tests" do
  
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
      @uri_link = UriV2.new(uri: "http://www.assero.co.uk/BusinessDomain#includesVariable")
      @uri_identifier = UriV2.new(uri: "http://www.assero.co.uk/BusinessDomain#name")
    end

    it "Model difference with children, different" do
      i_1 = SdtmModel.find("M-CDISC_SDTMMODEL", "http://www.assero.co.uk/MDRSdtmM/CDISC/V2")
      i_2 = SdtmModel.find("M-CDISC_SDTMMODEL", "http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
      time_now("Start Model diff")
      result = ConceptDifference.difference_with_children(i_1, i_2, "name")
      time_now("End")
      #expect(result).to eq("")    
    end

    it "Model difference with children, different, ignore ordinal" do
      i_1 = SdtmModel.find("M-CDISC_SDTMMODEL", "http://www.assero.co.uk/MDRSdtmM/CDISC/V2")
      i_2 = SdtmModel.find("M-CDISC_SDTMMODEL", "http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
      time_now("Start Model diff")
      result = ConceptDifference.difference_with_children(i_1, i_2, "name", {ignore: ["ordinal"]})
      time_now("End")
      #expect(result).to eq("")    
    end

    it "Model Class difference with children, different" do
      i_1 = SdtmModelDomain.find("M-CDISC_SDTMMODELEVENTS", "http://www.assero.co.uk/MDRSdtmMd/CDISC/V2")
      i_2 = SdtmModelDomain.find("M-CDISC_SDTMMODELEVENTS", "http://www.assero.co.uk/MDRSdtmMd/CDISC/V3")
      time_now("Start Model Class diff with children")
      result = ConceptDifference.difference_with_children(i_1, i_2, "name")
      time_now("End")
      #expect(result).to eq("")    
    end

    it "IG Domain difference with children, different" do
      i_1 = SdtmIgDomain.find("IG-CDISC_SDTMIGDM", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V1")
      i_2 = SdtmIgDomain.find("IG-CDISC_SDTMIGDM", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V2")
      time_now("Start IG Domain diff with children")
      result = ConceptDifference.difference_with_children(i_1, i_2, "name")
      time_now("End")
      puts result
      #expect(result).to eq("")    
    end

    it "IG Domain difference with children, different, ignore ordinal" do
      i_1 = SdtmIgDomain.find("IG-CDISC_SDTMIGDM", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V1")
      i_2 = SdtmIgDomain.find("IG-CDISC_SDTMIGDM", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V2")
      time_now("Start IG Domain diff with children")
      result = ConceptDifference.difference_with_children(i_1, i_2, "name", {ignore: ["ordinal"]})
      time_now("End")
      puts result
      #expect(result).to eq("")    
    end

  end
end