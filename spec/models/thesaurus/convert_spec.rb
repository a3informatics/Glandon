require 'rails_helper'

describe Thesaurus do

  include DataHelpers
  include PublicFileHelpers
  include SparqlHelpers
  include ThesauriHelpers

  def sub_dir
    return "models/thesaurus/convert"
  end

  def replace_thesaurus_references(triples)
    triples.each do |triple|
      triple[:object] = replace_old_reference(triple[:object]).to_ref if triple[:object].start_with?("<http://www.assero.co.uk/MDRThesaurus/CDISC/V")
    end
  end

  def read_triples(filename)
    results = []
    full_path = Rails.root.join "db/load/test/#{filename}"
    my_array = File.readlines(full_path).map do |line|
      begin
        items = line.match(/\A(?<subject>[\S]+)[\s]+(?<predicate>[\S]+)[\s]+(?<object>"*[\S| ]+"*)[\s]+./)
        results << {subject: items[:subject].strip, predicate: items[:predicate].strip, object: items[:object].strip}
      rescue => e
        byebug
      end
    end 
    return results
  end

  def write_triples(triples, filename, refs=false)
    full_path = test_file_path(sub_dir, filename)
    File.open(full_path, "w+") do |f|
      if refs
        triples.each do |triple| 
          object = triple[:object].is_a?(Uri) ? triple[:object].to_ref : "\"#{triple[:object]}\""
          f << "#{triple[:subject].to_ref} #{triple[:predicate].to_ref} #{object} .\n"
        end
      else
        triples.each {|triple| f << "#{triple[:subject]} #{triple[:predicate]} #{triple[:object]} .\n"}
      end
    end
  end

  describe "triple files" do

    before :all do
      schema_files = 
      [
        "ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", 
        "ISO11179Concepts.ttl", "BusinessOperational.ttl", "thesaurus.ttl"
      ]
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions((1..59))
    end

    after :all do
      delete_all_public_test_files
    end

    it "replaces references" do
      replace_old_reference("<http://www.assero.co.uk/MDRThesaurus/CDISC/V42#CLI-C71620_C41139>")
      replace_old_reference("<http://www.assero.co.uk/MDRThesaurus/CDISC/V42#CLI-C66770_C49668>")
    end

    it "converts files" do
      files = 
      [
        # "form_crf_test_1.ttl", 
        # "form_example_fields.ttl",
        # "ACME_ANNO 2_1.ttl",
        # "ACME_ANNO 3_1.ttl",      
        # "ACME_ANNO 4_1.ttl",      
        # "ACME_ANNO_1.ttl",      
        # "ACME_BC C17634_2.ttl",      
        # "ACME_BC C25206_1.ttl",      
        # "ACME_BC C25206_4.ttl",      
        # "ACME_BC C25208_1.ttl",      
        # "ACME_BC C25208_2.ttl",      
        # "ACME_BC C25298_1.ttl",      
        # "ACME_BC C25299_1.ttl",      
        # "ACME_BC C25347_1.ttl",      
        # "ACME_BC C49677_1.ttl",      
        # "ACME_BC C81255_1.ttl",      
        # "ACME_VS Domain.ttl",      
        # "ACME_LB Domain.ttl",      
        # "ACME_Topic.ttl",
        # "form_example_general.ttl",
        # "form_example_vs_baseline_new.ttl",
        #"form_example_dm1.ttl"
      ]
      files.each do |filename|
  puts "***** Processing #{filename} *****"
        triples = read_triples(filename)
        replace_thesaurus_references(triples)
        write_triples(triples, filename)
      end
    end

  end

  describe "turtle files" do

    def load_definitions
      schema_files = 
      [
        "ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", 
        "ISO11179Concepts.ttl", "BusinessOperational.ttl", "thesaurus.ttl"
      ]
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions((1..59))
    end

    before :all do
    end

    after :all do
      delete_all_public_test_files
    end

    it "converts ttl files" do
      files = 
      [
        #"BC.ttl"
      ]
      files.each do |filename|
        clear_triple_store
        full_path = Rails.root.join "db/load/test/#{filename}"
        CRUD.file (full_path)
        query_string = "SELECT ?subject ?predicate ?object WHERE {?subject ?predicate ?object}"
        query_results = Sparql::Query.new.query(query_string, "", [])
        triples = query_results.by_object_set([:subject, :predicate, :object])
        load_definitions
        triples.each do |triple|
          next if triple[:object].is_a?(String)
          triple[:object] = replace_old_reference(triple[:object].to_ref) if triple[:object].to_ref.start_with?("<http://www.assero.co.uk/MDRThesaurus/CDISC/V")
        end
        write_triples(triples, filename, true)
      end
    end

  end

  describe "generate test thesaurus" do

    def build
      @ra = IsoRegistrationAuthority.find_children(Uri.new(uri: "http://www.assero.co.uk/RA#DUNS123456789"))
      @th_1 = Thesaurus.new
      @th_1.label = "CDISC Extensions"
      @tc_1 = Thesaurus::ManagedConcept.from_h({
          label: "Vital Sign Test Codes Extension",
          identifier: "A00001",
          definition: "A set of additional Vital Sign Test Codes to extend the CDISC set.",
          notation: "VSTEST"
        })
      @tc_1.preferred_term = Thesaurus::PreferredTerm.new(label: "Vital Sign Test Codes Extension")
      @tc_1a = Thesaurus::UnmanagedConcept.from_h({
          label: "APGAR Score",
          identifier: "A00002",
          definition: "An APGAR Score",
          notation: "APGAR"
        })
      @tc_1a.preferred_term = Thesaurus::PreferredTerm.new(label: "APGAR Score")
      @tc_1b = Thesaurus::UnmanagedConcept.from_h({
          label: "Mid upper arm circumference",
          identifier: "A00003",
          definition: "The measurement of the mid upper arm circumference",
          notation: "MUAC"
        })
      @tc_1b.preferred_term = Thesaurus::PreferredTerm.new(label: "Mid upper arm circumference")
      @tc_1.narrower << @tc_1a
      @tc_1.narrower << @tc_1b
      @tc_2 = Thesaurus::ManagedConcept.new
      @tc_2.identifier = "A00010"
      @tc_2.label = "Ethnic Subgroup" 
      @tc_2.definition = "Ethnic Subgroup Def"
      @tc_2.extensible = false
      @tc_2.notation = "ETHNIC SUBGROUP"
      @tc_2.preferred_term = Thesaurus::PreferredTerm.new(label: "Ethnic Subgroup")

      @tc_2a = Thesaurus::ManagedConcept.new
      @tc_2a.identifier = "A00011"
      @tc_2a.label = "Ethnic Subgroup 1" 
      @tc_2a.definition = "Ethnic Subgroup 1 Def"
      @tc_2a.extensible = false
      @tc_2a.notation = "ETHNIC SUBGROUP [1]"
      @tc_2a.preferred_term = Thesaurus::PreferredTerm.new(label: "Ethnic Subgroup 1")
      @tc_2.narrower << @tc_2a
      @tc_3 = Thesaurus::ManagedConcept.new
      @tc_3.identifier = "A00020"
      @tc_3.label = "Race Extension" 
      @tc_3.definition = "Extension to Race Code List"
      @tc_3.extensible = false
      @tc_3.notation = "RACE OTHER"
      @tc_3.preferred_term = Thesaurus::PreferredTerm.new(label: "Race Extension")
      @tc_3a = Thesaurus::ManagedConcept.new
      @tc_3a.identifier = "A00021"
      @tc_3a.label = "Other or mixed race" 
      @tc_3a.definition = "Other or mixed race"
      @tc_3a.extensible = false
      @tc_3a.notation = "OTHER OR MIXED"
      @tc_3a.preferred_term = Thesaurus::PreferredTerm.new(label: "Other or mixed race")
      @tc_3.narrower << @tc_3a
      @tc_1.set_initial(@tc_1.identifier)
      @tc_2.set_initial(@tc_2.identifier)
      @tc_3.set_initial(@tc_3.identifier)
      @th_1.is_top_concept_reference << OperationalReferenceV3::TcReference.from_h({reference: @tc_1.uri, local_label: "", enabled: true, ordinal: 1, optional: true})
      @th_1.is_top_concept_reference << OperationalReferenceV3::TcReference.from_h({reference: @tc_2.uri, local_label: "", enabled: true, ordinal: 2, optional: true})
      @th_1.is_top_concept_reference << OperationalReferenceV3::TcReference.from_h({reference: @tc_3.uri, local_label: "", enabled: true, ordinal: 3, optional: true})
      @th_1.set_initial("CDISC EXT")
      @th_1.has_identifier.semantic_version = "1.0.0"
      @th_1.has_state.registration_status = "Standard"
    end

    before :all do
      schema_files = 
      [
        "ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", 
        "ISO11179Concepts.ttl", "BusinessOperational.ttl", "thesaurus.ttl"
      ]
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
    end

    after :all do
      delete_all_public_test_files
    end

    it "allows a TC to be exported as SPARQL" do
      sparql = Sparql::Update.new
      build
      sparql.default_namespace(@th_1.uri.namespace)
      @th_1.to_sparql(sparql, true)
      @tc_1.to_sparql(sparql, true)
      @tc_2.to_sparql(sparql, true)
      @tc_3.to_sparql(sparql, true)
      full_path = sparql.to_file
    #Xcopy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "thesaurus_concept_new_2.ttl")
    end

    it "check for loading" do
      load_local_file_into_triple_store(sub_dir, "thesaurus_concept_new_2.ttl")
      uri = Uri.new(uri: "http://www.acme-pharma.com/CDISC_EXT/V1#TH")
      th_x = Thesaurus.find_minimum(uri)
      children = th_x.managed_children_pagination(offset:0, count:10)
      expect(children.count).to eq(3)
      expect(children.first[:identifier]).to eq("A00001")
      expect(children.last[:identifier]).to eq("A00020")
    end

  end

end