require 'rails_helper'

describe Thesaurus::ManagedConcept do

  include DataHelpers
  include ValidationHelpers
  include SparqlHelpers
  include PublicFileHelpers
  include ThesauriHelpers
  include NameValueHelpers
  include InstallationHelpers
  
  def sub_dir
    return "models/thesaurus/data"
  end

  describe "general tests" do

    def simple_thesaurus_1
      @ra = IsoRegistrationAuthority.find_children(Uri.new(uri: "http://www.assero.co.uk/RA#DUNS123456789"))
      @th_1 = Thesaurus.new
      tc_ = Thesaurus::ManagedConcept.from_h({
          label: "London Heathrow",
          identifier: "A00001",
          definition: "A definition",
          notation: "LHR"
        })
      tc_.synonym << Thesaurus::Synonym.new(label:"Heathrow")
      tc_.synonym << Thesaurus::Synonym.new(label:"LHR")
      tc_.preferred_term = Thesaurus::PreferredTerm.new(label:"London Heathrow")
      tc_a = Thesaurus::UnmanagedConcept.from_h({
          label: "Terminal 5",
          identifier: "A000011",
          definition: "The 5th LHR Terminal",
          notation: "T5"
        })
      tc_a.synonym << Thesaurus::Synonym.new(label:"T5")
      tc_a.synonym << Thesaurus::Synonym.new(label:"Terminal Five")
      tc_a.synonym << Thesaurus::Synonym.new(label:"BA Terminal")
      tc_a.synonym << Thesaurus::Synonym.new(label:"British Airways Terminal")
      tc_a.preferred_term = Thesaurus::PreferredTerm.new(label:"Terminal 5")
      tc_b = Thesaurus::UnmanagedConcept.from_h({
          label: "Terminal 1",
          identifier: "A000012",
          definition: "The oldest LHR Terminal",
          notation: "T1"
        })
      tc_b.preferred_term = Thesaurus::PreferredTerm.new(label:"Terminal 1")
      tc_.narrower << tc_a
      tc_.narrower << tc_b
      tc_.set_initial("A00001")
      @tc_2 = Thesaurus::ManagedConcept.new
      @tc_2.identifier = "A00002"
      @tc_2.definition = "Copenhagen"
      @tc_2.extensible = false
      @tc_2.notation = "CPH"
      @tc_2.set_initial("A00002")
      @th_1.is_top_concept_reference << OperationalReferenceV3::TmcReference.from_h({reference: tc_.uri, local_label: "", enabled: true, ordinal: 1, optional: true})
      @th_1.is_top_concept_reference << OperationalReferenceV3::TmcReference.from_h({reference: @tc_2.uri, local_label: "", enabled: true, ordinal: 2, optional: true})
      @th_1.is_top_concept << tc_.uri
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
      tc_.to_sparql(sparql, true)
      @tc_2.to_sparql(sparql, true)
      full_path = sparql.to_file
    #Xcopy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "thesaurus_airport.ttl")
    end 

  end

  describe "generate extension code list" do

    def build
      @ra = IsoRegistrationAuthority.find_children(Uri.new(uri: "http://www.assero.co.uk/RA#DUNS123456789"))
      tc_ = Thesaurus::ManagedConcept.from_h({
          label: "Epoch Extension",
          identifier: "A00001",
          definition: "Extends Epoch",
          notation: "EPOCH"
        })
      tc_.preferred_term = Thesaurus::PreferredTerm.new(label: "Epoch Extension")
      tc_a = Thesaurus::UnmanagedConcept.from_h({
          label: "So late after anything else",
          identifier: "A00002",
          definition: "So so late",
          notation: "SO SO LATE"
        })
      tc_a.preferred_term = Thesaurus::PreferredTerm.new(label: "Very very late")
      cdisc_uri = Uri.new(uri: "http://www.cdisc.org/C66768/V2#C66768")
      cdisc = Thesaurus::ManagedConcept.find_with_properties(cdisc_uri)
      cdisc.narrower_objects
      tc_.narrower = cdisc.narrower
      tc_.narrower << tc_a
      tc_.extends = cdisc_uri
      tc_.set_initial(tc_.identifier)
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
      sparql.default_namespace(tc_.uri.namespace)
      tc_.to_sparql(sparql, true)
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

  describe "another version" do

    def second_version
      @ra = IsoRegistrationAuthority.find_children(Uri.new(uri: "http://www.assero.co.uk/RA#DUNS123456789"))
      @th_1 = Thesaurus.new
      tc_ = Thesaurus::ManagedConcept.find_with_properties(Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001"))
      tc_.definition = "London Heathrow the UK's busiest airport."
      tc_.synonym_objects
      tc_.preferred_term_objects
      tc_a_old = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
      tc_a = Thesaurus::UnmanagedConcept.from_h({
          label: "Terminal 5",
          identifier: "A000011",
          definition: "Terminal 5, the newest terminal at Heathrow.",
          notation: "T5"
        })
      tc_a.synonym = tc_a_old.synonym
      tc_a.preferred_term = tc_a_old.preferred_term
      tc_b = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001_A000012"))
      tc_c = Thesaurus::UnmanagedConcept.from_h({
          label: "Terminal 2",
          identifier: "A000030",
          definition: "The old Queens Terminal",
          notation: "T2"
        })
      tc_c.preferred_term = Thesaurus::PreferredTerm.new(label:"Terminal 2")
      tc_.narrower << tc_a
      tc_.narrower << tc_b
      tc_.narrower << tc_c
      tc_.set_initial("A00001")
      tc_.update_version(2)
      @tc_2 = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/A00002/V1#A00002"))
      @tc_3 = Thesaurus::ManagedConcept.new
      @tc_3.identifier = "A00003"
      @tc_3.definition = "Basel"
      @tc_3.extensible = false
      @tc_3.notation = "BSL"
      @tc_3.set_initial("A00003")
      @th_1.is_top_concept_reference << OperationalReferenceV3::TmcReference.from_h({reference: tc_.uri, local_label: "", enabled: true, ordinal: 1, optional: true})
      @th_1.is_top_concept_reference << OperationalReferenceV3::TmcReference.from_h({reference: @tc_2.uri, local_label: "", enabled: true, ordinal: 2, optional: true})
      @th_1.is_top_concept_reference << OperationalReferenceV3::TmcReference.from_h({reference: @tc_3.uri, local_label: "", enabled: true, ordinal: 3, optional: true})
      @th_1.is_top_concept << tc_.uri
      @th_1.is_top_concept << @tc_2.uri
      @th_1.is_top_concept << @tc_2.uri
      @th_1.set_initial("AIRPORTS")
      @th_1.update_version(2)
    end

    before :all  do
      IsoHelpers.clear_cache
    end

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_local_file_into_triple_store(sub_dir, "thesaurus_airport.ttl")
    end

    it "file" do
      second_version
      sparql = Sparql::Update.new
      sparql.default_namespace(@th_1.uri.namespace)
      @th_1.to_sparql(sparql, true)
      tc_.to_sparql(sparql, true)
      @tc_3.to_sparql(sparql, true)
      full_path = sparql.to_file
    #Xcopy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "thesaurus_airport_v2.ttl")
    end 

  end

  describe "next state data test" do

    def simple_thesaurus_1
      @ra = IsoRegistrationAuthority.find_children(Uri.new(uri: "http://www.assero.co.uk/RA#DUNS123456789"))
      @th_1 = Thesaurus.new
      @th_1.label = "State Test Terminology"
      tc_ = Thesaurus::ManagedConcept.from_h({
          label: "London Heathrow",
          identifier: "A00001",
          definition: "A definition",
          notation: "LHR"
        })
      tc_.preferred_term = Thesaurus::PreferredTerm.new(label:"London Heathrow")
      tc_.set_initial("A00001")
      @th_1.is_top_concept_reference << OperationalReferenceV3::TmcReference.from_h({reference: tc_.uri, local_label: "", enabled: true, ordinal: 1, optional: true})
      @th_1.is_top_concept << tc_.uri
      @th_1.set_initial("STATE")
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
      tc_.to_sparql(sparql, true)
      full_path = sparql.to_file
    #Xcopy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "thesaurus_sponsor_5_state.ttl")
    end 

  end

  describe "referenced CT data test" do

    def simple_thesaurus_1
      ct = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V2#TH"))
      @ra = IsoRegistrationAuthority.find_children(Uri.new(uri: "http://www.assero.co.uk/RA#DUNS123456789"))
      @th_1 = Thesaurus.new
      @th_1.label = "State Test Terminology"
      tc_ = Thesaurus::ManagedConcept.from_h({
          label: "London Heathrow",
          identifier: "A00001",
          definition: "A definition",
          notation: "LHR"
        })
      tc_.preferred_term = Thesaurus::PreferredTerm.new(label:"London Heathrow")
      tc_.set_initial("A00001")
      @th_1.is_top_concept_reference << OperationalReferenceV3::TmcReference.from_h({reference: tc_.uri, local_label: "", enabled: true, ordinal: 1, optional: true})
      @th_1.is_top_concept << tc_.uri
      @th_1.reference = OperationalReferenceV3.new(reference: ct)
      @th_1.set_initial("STATE")
      @th_1.has_state.registration_status = "Standard"
    end

    before :all  do
      IsoHelpers.clear_cache
    end

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..2)
    end

    it "file" do
      simple_thesaurus_1
      sparql = Sparql::Update.new
      sparql.default_namespace(@th_1.uri.namespace)
      @th_1.to_sparql(sparql, true)
      tc_.to_sparql(sparql, true)
      full_path = sparql.to_file
    #Xcopy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "thesaurus_sponsor_6_referenced.ttl")
    end 

  end

  describe "for ad hoc reports" do

    def simple_thesaurus_1
      ct = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V50#TH"))
      @ra = IsoRegistrationAuthority.find_children(Uri.new(uri: "http://www.assero.co.uk/RA#DUNS123456789"))
      @th_1 = Thesaurus.new
      @th_1.label = "Test Terminology"
      cs_1 = IsoConceptSystem.new
      cs_1.uri = Uri.new(uri: "http://www.assero.co.uk/TAG1")
      cs_2 = IsoConceptSystem.new
      cs_2.uri = Uri.new(uri: "http://www.assero.co.uk/TAG2")
      cs_3 = IsoConceptSystem.new
      cs_3.uri = Uri.new(uri: "http://www.assero.co.uk/TAG3")
      tc_ = Thesaurus::ManagedConcept.from_h({
          label: "London Heathrow",
          identifier: "S00001",
          definition: "A definition",
          notation: "ONCRSR"
        })
      tc_.synonym << Thesaurus::Synonym.new(label:"Heathrow")
      tc_.synonym << Thesaurus::Synonym.new(label:"LHR")
      tc_.preferred_term = Thesaurus::PreferredTerm.new(label:"London Heathrow")
      tc_.add_tags_no_save([cs_1, cs_2])
      tc_a = Thesaurus::UnmanagedConcept.from_h({
          label: "Terminal 5",
          identifier: "S000011",
          definition: "The 5th LHR Terminal",
          notation: "Organ to Heart Weight Ratio"
        })
      tc_a.synonym << Thesaurus::Synonym.new(label:"T5")
      tc_a.synonym << Thesaurus::Synonym.new(label:"Terminal Five")
      tc_a.synonym << Thesaurus::Synonym.new(label:"BA Terminal")
      tc_a.synonym << Thesaurus::Synonym.new(label:"British Airways Terminal")
      tc_a.preferred_term = Thesaurus::PreferredTerm.new(label:"Terminal 5")
      tc_b = Thesaurus::UnmanagedConcept.from_h({
          label: "Terminal 1",
          identifier: "S000012",
          definition: "The oldest LHR Terminal",
          notation: "T1"
        })
      @tc_1b.preferred_term = Thesaurus::PreferredTerm.new(label:"Terminal 1")
      @tc_1b.add_tags_no_save([cs_3]) 
      @tc_1c = Thesaurus::UnmanagedConcept.from_h({
          label: "Health Screening",
          identifier: "S000013",
          definition: "Health Screening Terminal",
          notation: "SCREENING"
        })
      @tc_1c.preferred_term = Thesaurus::PreferredTerm.new(label:"Terminal HS")
      @tc_1c.add_tags_no_save([cs_3]) 
      @tc_1.narrower << @tc_1a
      @tc_1.narrower << @tc_1b
      @tc_1.narrower << @tc_1c
      @tc_1.narrower << Uri.new(uri: "http://www.cdisc.org/C99079/V47#C99079_C125938")
      @tc_1.narrower << Uri.new(uri: "http://www.cdisc.org/C99079/V58#C99079_C99158")            
      @tc_1.set_initial("S00001")
      @tc_2 = Thesaurus::ManagedConcept.new
      @tc_2.identifier = "S00002"
      @tc_2.definition = "Copenhagen"
      @tc_2.extensible = false
      @tc_2.notation = "CPH"
      @tc_2.set_initial("S00002")
      @tc_3 = Thesaurus::ManagedConcept.from_h({
          label: "Epoch Extension",
          identifier: "S00001E",
          definition: "Extends Epoch",
          notation: "EPOCH"
        })
      @tc_3.preferred_term = Thesaurus::PreferredTerm.new(label: "Epoch Extension")
      cdisc_uri = Uri.new(uri: "http://www.cdisc.org/C99079/V58#C99079")
      cdisc = Thesaurus::ManagedConcept.find_with_properties(cdisc_uri)
      cdisc.narrower_objects
      @tc_3.narrower = cdisc.narrower
      @tc_3.extends = cdisc_uri
      @tc_3.set_initial(@tc_3.identifier)
      @tc_4 = Thesaurus::ManagedConcept.from_h({
          label: "Epoch Extension 2",
          identifier: "S00002E",
          definition: "Extends Epoch2",
          notation: "EPOCH"
        })
      @tc_4.preferred_term = Thesaurus::PreferredTerm.new(label: "Epoch Extension2")
      cdisc_uri = Uri.new(uri: "http://www.cdisc.org/C99079/V47#C99079")
      cdisc = Thesaurus::ManagedConcept.find_with_properties(cdisc_uri)
      cdisc.narrower_objects
      @tc_4.narrower = cdisc.narrower
      @tc_4.extends = cdisc_uri
      @tc_4.set_initial(@tc_4.identifier)
      @th_1.is_top_concept_reference << OperationalReferenceV3::TmcReference.from_h({reference: tc_.uri, local_label: "", enabled: true, ordinal: 1, optional: true})
      @th_1.is_top_concept_reference << OperationalReferenceV3::TmcReference.from_h({reference: @tc_2.uri, local_label: "", enabled: true, ordinal: 2, optional: true})
      @th_1.is_top_concept_reference << OperationalReferenceV3::TmcReference.from_h({reference: @tc_3.uri, local_label: "", enabled: true, ordinal: 3, optional: true})
      @th_1.is_top_concept_reference << OperationalReferenceV3::TmcReference.from_h({reference: @tc_4.uri, local_label: "", enabled: true, ordinal: 4, optional: true})
      @th_1.is_top_concept << tc_.uri
      @th_1.is_top_concept << @tc_2.uri
      @th_1.is_top_concept << @tc_3.uri
      @th_1.is_top_concept << @tc_4.uri
      @th_1.reference = OperationalReferenceV3.new(reference: ct)
      @th_1.set_initial("AIRPORTS")
    end

    before :all  do
      IsoHelpers.clear_cache
    end

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..62)
    end

    it "file" do
      simple_thesaurus_1
      sparql = Sparql::Update.new
      sparql.default_namespace(@th_1.uri.namespace)
      @th_1.to_sparql(sparql, true)
      tc_.to_sparql(sparql, true)
      @tc_2.to_sparql(sparql, true)
      @tc_3.to_sparql(sparql, true)
      @tc_4.to_sparql(sparql, true)
      full_path = sparql.to_file
    #Xcopy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "thesaurus_airport_ad_hoc.ttl")
    end 

  end

end