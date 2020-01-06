require 'rails_helper'

describe Thesaurus::ManagedConcept do

  include DataHelpers
  include ValidationHelpers
  include SparqlHelpers
  include PublicFileHelpers
  include ThesauriHelpers
  
  def sub_dir
    return "models/thesaurus/data"
  end

  describe "general tests" do

    def simple_thesaurus_1
      @ra = IsoRegistrationAuthority.find_children(Uri.new(uri: "http://www.assero.co.uk/RA#DUNS123456789"))
      @th_1 = Thesaurus.new
      @tc_1 = Thesaurus::ManagedConcept.from_h({
          label: "London Heathrow",
          identifier: "A00001",
          definition: "A definition",
          notation: "LHR"
        })
      @tc_1.synonym << Thesaurus::Synonym.new(label:"Heathrow")
      @tc_1.synonym << Thesaurus::Synonym.new(label:"LHR")
      @tc_1.preferred_term = Thesaurus::PreferredTerm.new(label:"London Heathrow")
      @tc_1a = Thesaurus::UnmanagedConcept.from_h({
          label: "Terminal 5",
          identifier: "A000011",
          definition: "The 5th LHR Terminal",
          notation: "T5"
        })
      @tc_1a.synonym << Thesaurus::Synonym.new(label:"T5")
      @tc_1a.synonym << Thesaurus::Synonym.new(label:"Terminal Five")
      @tc_1a.synonym << Thesaurus::Synonym.new(label:"BA Terminal")
      @tc_1a.synonym << Thesaurus::Synonym.new(label:"British Airways Terminal")
      @tc_1a.preferred_term = Thesaurus::PreferredTerm.new(label:"Terminal 5")
      @tc_1b = Thesaurus::UnmanagedConcept.from_h({
          label: "Terminal 1",
          identifier: "A000012",
          definition: "The oldest LHR Terminal",
          notation: "T1"
        })
      @tc_1b.preferred_term = Thesaurus::PreferredTerm.new(label:"Terminal 1")
      @tc_1.narrower << @tc_1a
      @tc_1.narrower << @tc_1b
      @tc_1.set_initial("A00001")
      @tc_2 = Thesaurus::ManagedConcept.new
      @tc_2.identifier = "A00002"
      @tc_2.definition = "Copenhagen"
      @tc_2.extensible = false
      @tc_2.notation = "CPH"
      @tc_2.set_initial("A00002")
      @th_1.is_top_concept_reference << OperationalReferenceV3::TcReference.from_h({reference: @tc_1.uri, local_label: "", enabled: true, ordinal: 1, optional: true})
      @th_1.is_top_concept_reference << OperationalReferenceV3::TcReference.from_h({reference: @tc_2.uri, local_label: "", enabled: true, ordinal: 2, optional: true})
      @th_1.is_top_concept << @tc_1.uri
      @th_1.is_top_concept << @tc_2.uri
      @th_1.set_initial("AIRPORTS")
    end

    before :all  do
      IsoHelpers.clear_cache
    end

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
    end

    it "file" do
      simple_thesaurus_1
      sparql = Sparql::Update.new
      sparql.default_namespace(@th_1.uri.namespace)
      @th_1.to_sparql(sparql, true)
      @tc_1.to_sparql(sparql, true)
      @tc_2.to_sparql(sparql, true)
      full_path = sparql.to_file
    #Xcopy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "thesaurus_airport.ttl")
    end 

  end

  describe "generate extension code list" do

    def build
      @ra = IsoRegistrationAuthority.find_children(Uri.new(uri: "http://www.assero.co.uk/RA#DUNS123456789"))
      @tc_1 = Thesaurus::ManagedConcept.from_h({
          label: "Epoch Extension",
          identifier: "A00001",
          definition: "Extends Epoch",
          notation: "EPOCH"
        })
      @tc_1.preferred_term = Thesaurus::PreferredTerm.new(label: "Epoch Extension")
      @tc_1a = Thesaurus::UnmanagedConcept.from_h({
          label: "So late after anything else",
          identifier: "A00002",
          definition: "So so late",
          notation: "SO SO LATE"
        })
      @tc_1a.preferred_term = Thesaurus::PreferredTerm.new(label: "Very very late")
      cdisc_uri = Uri.new(uri: "http://www.cdisc.org/C66768/V2#C66768")
      cdisc = Thesaurus::ManagedConcept.find_with_properties(cdisc_uri)
      cdisc.narrower_objects
      @tc_1.narrower = cdisc.narrower
      @tc_1.narrower << @tc_1a
      @tc_1.extends = cdisc_uri
      @tc_1.set_initial(@tc_1.identifier)
    end

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..2)
    end

    after :all do
      delete_all_public_test_files
    end

    it "allows a TC to be exported as SPARQL" do
      sparql = Sparql::Update.new
      build
      sparql.default_namespace(@tc_1.uri.namespace)
      @tc_1.to_sparql(sparql, true)
      full_path = sparql.to_file
    #Xcopy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "thesaurus_extension.ttl")
    end

    it "check for loading" do
      load_local_file_into_triple_store(sub_dir, "thesaurus_extension.ttl")
      uri = Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001")
      tc = Thesaurus::ManagedConcept.find_with_properties(uri)
      tc.extends_links
      expect(tc.identifier).to eq("A00001")
      expect(tc.extends.to_s).to eq("http://www.cdisc.org/C66768/V2#C66768")
    end

  end

end