require 'rails_helper'

describe Thesaurus do

  include DataHelpers
  include SparqlHelpers
  include TimeHelpers
  include PublicFileHelpers
  include CdiscCtHelpers
  include IsoManagedHelpers
  include ThesauriHelpers
  include IsoManagedHelpers

  def sub_dir
    return "models/thesaurus"
  end

  describe "Main Tests" do

    before :all do
      IsoHelpers.clear_cache
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..50)
    end

    after :all do
      delete_all_public_test_files
    end

    it "returns audit type" do
      th = Thesaurus.find_minimum(Uri.new(uri: "http://www.assero.co.uk/MDRThesaurus/ACME/V1#TH-SPONSOR_CT-1"))
      expect(th.audit_type).to eq("Terminology")
    end

    it "returns the owner" do
      expected = IsoRegistrationAuthority.owner
      th = Thesaurus.find_minimum(Uri.new(uri: "http://www.assero.co.uk/MDRThesaurus/ACME/V1#TH-SPONSOR_CT-1"))
      expect(th.owner.uri).to eq(expected.uri)
    end

    it "allows an object to be initialised" do
      th =Thesaurus.new
      result =
        {
          :rdf_type => "http://www.assero.co.uk/Thesaurus#Thesaurus",
          :id => nil,
          :uri => {},
          :label => "",
          :origin => "",
          :change_description => "",
          :creation_date => "".to_time_with_default.iso8601.to_s,
          :last_change_date => "".to_time_with_default.iso8601.to_s,
          :explanatory_comment => "",
          :has_state => nil,
          :has_identifier => nil,
          :is_top_concept => [],
          :is_top_concept_reference => [],
          :reference => nil,
          :baseline_reference => nil,
          :has_previous_version => nil
        }
      expect(th.to_h).to hash_equal(result)
    end

    it "allows validity of the object to be checked - error" do
      result = Thesaurus.new
      valid = result.valid?
      expect(valid).to eq(false)
      expect(result.errors.count).to eq(3)
      expect(result.errors.full_messages.to_sentence).to eq("Uri can't be blank, Has identifier empty object, and Has state empty object")
    end

    it "allows validity of the object to be checked" do
      th = Thesaurus.new
      ra = IsoRegistrationAuthority.find(Uri.new(uri:"http://www.assero.co.uk/RA#DUNS123456789"))
      th.has_state = IsoRegistrationStateV2.new
      th.has_state.uri = "na"
      th.has_state.by_authority = ra
      th.has_identifier = IsoScopedIdentifierV2.new
      th.has_identifier.uri = "na"
      th.has_identifier.identifier = "HELLO WORLD"
      th.has_identifier.semantic_version = "0.1.0"
      th.uri = "xxx"
      valid = th.valid?
      expect(th.errors.count).to eq(0)
      expect(valid).to eq(true)
    end

    it "allows a Thesaurus to be found" do
      th = Thesaurus.find_full(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"))
      check_file_actual_expected(th.to_h, sub_dir, "find_expected_1.yaml", equate_method: :hash_equal)
    end

    it "allows a Th to be found - error" do
      expect{Thesaurus.find(Uri.new(uri: "http://www.assero.co.uk/MDRThesaurus/ACME/V1#X"))}.to raise_error(Errors::NotFoundError, "Failed to find http://www.assero.co.uk/MDRThesaurus/ACME/V1#X in Thesaurus.")
    end

    it "allows the unique item to be retrived" do
      result = Thesaurus.unique
      check_file_actual_expected(result, sub_dir, "unique_expected_1.yaml", equate_method: :hash_equal)
    end

    it "allows the history to be retrived" do
      results = []
      result = Thesaurus.history(:identifier => "CT", :scope => IsoNamespace.find_by_short_name("CDISC"))
      result.each {|x| results << x.to_h}
      check_file_actual_expected(results, sub_dir, "history_expected_1.yaml", equate_method: :hash_equal, )
    end

    it "allows the current item to be retrived" do
      owner = IsoRegistrationAuthority.owner
      result = Thesaurus.current_uri({:identifier => "CDISC EXT", :scope => IsoRegistrationAuthority.owner.ra_namespace})
      expect(result.to_s).to eq("http://www.assero.co.uk/MDRThesaurus/ACME/V1#TH-SPONSOR_CT-1")
    end

    it "allows a creation of a thesaurus" do
      th = Thesaurus.create({:identifier => "TEST", :label => "Test Thesaurus"})
      expect(th.errors.count).to eq(0)
      check_dates(th, sub_dir, "thesaurus_example_4.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(th.to_h, sub_dir, "thesaurus_example_4.yaml")
    end

    it "allows for a thesaurus to be destroyed" do
      th = Thesaurus.create({:identifier => "TEST1", :label => "Test Thesaurus 1"})
      expect(Thesaurus.find_minimum(th.id).uri.to_s).to eq("http://www.acme-pharma.com/TEST1/V1#TH")
      th.delete
      expect{Thesaurus.find_minimum(th.id)}.to raise_error(Errors::NotFoundError, "Failed to find http://www.acme-pharma.com/TEST1/V1#TH in Thesaurus.")
    end

    it "allows the thesaurus to be exported as SPARQL" do
      th = Thesaurus.find(Uri.new(uri: "http://www.assero.co.uk/MDRThesaurus/ACME/V1#TH-SPONSOR_CT-1"))
      sparql = Sparql::Update.new
      th.to_sparql(sparql, true)
    #Xwrite_text_file_2(sparql.to_create_sparql, sub_dir, "to_sparql_expected_1.txt")
      check_sparql_no_file(sparql.to_create_sparql, "to_sparql_expected_1.txt")
    end

  end

  describe "Terminology Changes" do

    def load_versions(range)
      range.each {|n| load_data_file_into_triple_store("cdisc/ct/CT_V#{n}.ttl")}
    end

    before :all  do
      IsoHelpers.clear_cache
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_sponsor_import.ttl"]
      load_files(schema_files, data_files)
      load_versions(CdiscCtHelpers.version_range)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("thesaurus_sponsor_impact.ttl")
      load_data_file_into_triple_store("thesaurus_sponsor2_impact.ttl")
      load_data_file_into_triple_store("thesaurus_sponsor3_impact.ttl")
      load_data_file_into_triple_store("thesaurus_sponsor5_impact.ttl")
    end

    # it "calculates changes_impact, no deleted items" do
    #   th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V10#TH"))
    #   other_th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V13#TH"))
    #   actual = th.changes_impact(other_th)
    #   check_file_actual_expected(actual, sub_dir, "changes_impact_expected_1.yaml", equate_method: :hash_equal)
    # end

    # it "calculates changes_impact, 1 deleted and 133 updated" do
    #   th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V59#TH"))
    #   other_th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V62#TH"))
    #   actual = th.changes_impact(other_th)
    #   check_file_actual_expected(actual, sub_dir, "changes_impact_expected_2.yaml", equate_method: :hash_equal)
    # end

    # it "calculates changes_impact, 6 deleted and 64 updated" do
    #   th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V58#TH"))
    #   other_th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V59#TH"))
    #   actual = th.changes_impact(other_th)
    #   check_file_actual_expected(actual, sub_dir, "changes_impact_expected_3.yaml", equate_method: :hash_equal)
    # end

    it "calculates changes_impact v2, no deleted items" do
      th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V43#TH"))
      new_th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V59#TH"))
      sponsor = Thesaurus.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/Q4_2019/V1#TH"))
      actual = th.changes_impact_v2(new_th, sponsor)
      check_file_actual_expected(actual, sub_dir, "changes_impact_v2_expected_1.yaml", equate_method: :hash_equal, )
    end

    it "calculates changes_impact v2 II" do
      th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V2#TH"))
      new_th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V13#TH"))
      sponsor = Thesaurus.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/SPONSOR/V1#TH"))
      actual = th.changes_impact_v2(new_th, sponsor)
      check_file_actual_expected(actual, sub_dir, "changes_impact_v2_expected_2.yaml", equate_method: :hash_equal, )
    end

    it "calculates changes_impact v2 III" do
      th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V60#TH"))
      new_th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V62#TH"))
      sponsor = Thesaurus.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/SPONSOR/V1#TH"))
      actual = th.changes_impact_v2(new_th, sponsor)
      check_file_actual_expected(actual, sub_dir, "changes_impact_v2_expected_3.yaml", equate_method: :hash_equal, )
    end

    it "calculates changes_impact v2 IV" do
      th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V59#TH"))
      new_th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V62#TH"))
      sponsor = Thesaurus.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/SPONSOR2/V1#TH"))
      actual = th.changes_impact_v2(new_th, sponsor)
      check_file_actual_expected(actual, sub_dir, "changes_impact_v2_expected_4.yaml", equate_method: :hash_equal, )
    end

    it "report Compare" do
      th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V35#TH"))
      th_to = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V57#TH"))
      actual = Thesaurus.compare_to_csv(th, th_to)
      check_file_actual_expected(actual, sub_dir, "compare_to_csv_expected_1.yaml", equate_method: :hash_equal, )
    end

    it "report Impact" do
      th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V35#TH"))
      new_th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V57#TH"))
      sponsor = Thesaurus.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/SPONSORTHTEST2/V1#TH"))
      actual = Thesaurus.impact_to_csv(th, new_th, sponsor)
      check_file_actual_expected(actual, sub_dir, "impact_to_csv_expected_1.yaml", equate_method: :hash_equal, )
    end

    it "report Impact II" do
      th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V35#TH"))
      new_th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V57#TH"))
      sponsor = Thesaurus.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/SPONSORTHTEST2/V1#TH"))
      actual = Thesaurus.impact_to_csv(th, new_th, sponsor)
      check_file_actual_expected(actual, sub_dir, "impact_to_csv_expected_2.yaml", equate_method: :hash_equal)
    end

    it "calculates changes, window full width" do
      th = CdiscTerm.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"))
      actual = th.changes(61)
      check_file_actual_expected(actual, sub_dir, "changes_expected_6.yaml", equate_method: :hash_equal)
    end

    it "calculates changes, window 4, general" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V10#TH"))
      actual = ct.changes(4)
      check_file_actual_expected(actual, sub_dir, "changes_expected_1.yaml", equate_method: :hash_equal)
    end

    it "calculates changes, window 10, large" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V2#TH"))
      actual = ct.changes(10)
      check_file_actual_expected(actual, sub_dir, "changes_expected_2.yaml", equate_method: :hash_equal)
    end

    it "calculates changes, window 4, first item" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"))
      actual = ct.changes(4)
      check_file_actual_expected(actual, sub_dir, "changes_expected_3.yaml", equate_method: :hash_equal)
    end

    it "calculates changes, window 4, second" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V2#TH"))
      actual = ct.changes(4)
      check_file_actual_expected(actual, sub_dir, "changes_expected_4.yaml", equate_method: :hash_equal)
    end

    it "calculates changes, window 8, second" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V31#TH"))
      actual = ct.changes(8)
      check_file_actual_expected(actual, sub_dir, "changes_expected_5.yaml", equate_method: :hash_equal)
    end

    # it "calculates changes_cdu, window 3 " do
    #   ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V2#TH"))
    #   actual = ct.changes_cdu(3)
    #   check_file_actual_expected(actual, sub_dir, "changes_cdu_expected_1.yaml", equate_method: :hash_equal)
    # end

    # it "calculates changes_cdu, window 3 " do
    #   ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V7#TH"))
    #   actual = ct.changes_cdu(3)
    #   check_file_actual_expected(actual, sub_dir, "changes_cdu_expected_2.yaml", equate_method: :hash_equal)
    # end

    # it "calculates changes_cdu, window 4 " do
    #   ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V13#TH"))
    #   actual = ct.changes_cdu(4)
    #   check_file_actual_expected(actual, sub_dir, "changes_cdu_expected_3.yaml", equate_method: :hash_equal)
    # end

    # it "calculates changes_cdu, window 4 " do
    #   ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V56#TH"))
    #   actual = ct.changes_cdu(4)
    #   check_file_actual_expected(actual, sub_dir, "changes_cdu_expected_4.yaml", equate_method: :hash_equal)
    # end

    # it "calculates changes_cdu, window 3 " do
    #   ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V58#TH"))
    #   actual = ct.changes_cdu(3)
    #   check_file_actual_expected(actual, sub_dir, "changes_cdu_expected_5.yaml", equate_method: :hash_equal)
    # end

    # it "calculates changes_cdu, window 3 " do
    #   ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V47#TH"))
    #   actual = ct.changes_cdu(4)
    #   check_file_actual_expected(actual, sub_dir, "changes_cdu_expected_6.yaml", equate_method: :hash_equal)
    # end

    # it "calculates changes_cdu, window 2" do
    #   ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V60#TH"))
    #   actual = ct.changes_cdu(2)
    #   check_file_actual_expected(actual, sub_dir, "changes_cdu_expected_7.yaml", equate_method: :hash_equal)
    # end

    # it "calculates changes_cdu, window 2" do
    #   ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V61#TH"))
    #   actual = ct.changes_cdu(2)
    #   check_file_actual_expected(actual, sub_dir, "changes_cdu_expected_8.yaml", equate_method: :hash_equal)
    # end

    # it "calculates changes_cdu, window 8, Versions 2014-06-27 and 2015-12-18" do
    #   ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V39#TH"))
    #   actual = ct.changes_cdu(8)
    #   check_file_actual_expected(actual, sub_dir, "changes_cdu_expected_9.yaml", equate_method: :hash_equal)
    # end

    # it "calculates changes_cdu, window 5, Versions 2018-06-29 and 2019-06-28" do
    #   ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V56#TH"))
    #   actual = ct.changes_cdu(5)
    #   check_file_actual_expected(actual, sub_dir, "changes_cdu_expected_10.yaml", equate_method: :hash_equal)
    # end

    # it "calculates changes_cdu, window 2 , Versions 2015-09-25 and 2015-12-18" do
    #   ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V45#TH"))
    #   actual = ct.changes_cdu(2)
    #   check_file_actual_expected(actual, sub_dir, "changes_cdu_expected_11.yaml", equate_method: :hash_equal)
    # end

    # it "calculates changes_cdu, Versions 2011-12-09 and 2014-09-26" do
    #   ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V28#TH"))
    #   actual = ct.changes_cdu(13)
    #   check_file_actual_expected(actual, sub_dir, "changes_cdu_expected_12.yaml", equate_method: :hash_equal)
    # end

  end

  describe "Terminology Submission Changes" do

    def load_versions(range)
      range.each {|n| load_data_file_into_triple_store("cdisc/ct/CT_V#{n}.ttl")}
    end

    before :all  do
      IsoHelpers.clear_cache
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_versions(1..60)
    end

    after :all do
      #
    end

    it "calculates changes, window 4, general" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V10#TH"))
      timer_start
      actual = ct.submission(4)
      timer_stop("V10, 4 versions [0.9s]")
      check_file_actual_expected(actual, sub_dir, "submisson_expected_1.yaml", equate_method: :hash_equal)
    end

    it "calculates changes, window 10, large" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V2#TH"))
      timer_start
      actual = ct.submission(10)
      timer_stop("V2, 10 versions [7.2s]")
      check_file_actual_expected(actual, sub_dir, "submisson_expected_2.yaml", equate_method: :hash_equal)
    end

    it "calculates changes, window 4, first item" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"))
      timer_start
      actual = ct.submission(4)
      timer_stop("V1, 4 versions [6.06s]")
      check_file_actual_expected(actual, sub_dir, "submisson_expected_3.yaml", equate_method: :hash_equal)
    end

    it "calculates changes, window 4, second" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V2#TH"))
      timer_start
      actual = ct.submission(4)
      timer_stop("V2, 4 versions [6.51s]")
      check_file_actual_expected(actual, sub_dir, "submisson_expected_4.yaml", equate_method: :hash_equal)
    end

    it "calculates changes, window 12, large" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V31#TH"))
      timer_start
      actual = ct.submission(12)
      timer_stop("V31, 12 versions [22.7s]")
      check_file_actual_expected(actual, sub_dir, "submisson_expected_5.yaml", equate_method: :hash_equal)
    end

  end

  describe "Child Operations - Read" do

    def load_versions(range)
      range.each {|n| load_data_file_into_triple_store("cdisc/ct/CT_V#{n}.ttl")}
    end

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus.ttl", "thesaurus_new_airports.ttl"]
      load_files(schema_files, data_files)
      load_versions(1..60)
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
    end

    after :all do
      #
    end

    it "get children" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V60#TH"))
      actual = ct.managed_children_pagination(offset: 0, count: 10)
      check_file_actual_expected(actual, sub_dir, "managed_child_pagination_expected_1.yaml")
    end

    it "get children, V1 all items (GLAN-652)" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"))
      actual = ct.managed_children_pagination(offset: 0, count: 100)
      expect(actual.count).to eq(32)
      check_file_actual_expected(actual, sub_dir, "managed_child_pagination_expected_2.yaml")
    end

    it "get children, speed" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V59#TH"))
      timer_start
      (1..100).each {|x| actual = ct.managed_children_pagination(offset: 0, count: 10)}
      timer_stop("100 searches [2.55s]")
    end

    it "get children, tag filter" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V60#TH"))
      actual = ct.managed_children_pagination(offset: 0, count: 10, tags: ["SDTM"])
      check_file_actual_expected(actual, sub_dir, "managed_child_pagination_expected_3.yaml")
    end

    it "get children with indicators, V1 all items" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"))
      actual = ct.managed_children_indicators_paginated(offset: 0, count: 100)
      expect(actual.count).to eq(32)
      check_file_actual_expected(actual, sub_dir, "managed_child_indicators_pagination_expected_1.yaml")
    end

    it "get children with indicators extend and subset, V1 all items" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"))
      ThesauriHelpers.fake_extended(Uri.new(uri: "http://www.cdisc.org/C50399/V1#C50399"), "1")
      ThesauriHelpers.fake_subsetted(Uri.new(uri: "http://www.cdisc.org/C49638/V1#C49638"), "1")
      actual = ct.managed_children_indicators_paginated(offset: 0, count: 100)
      expect(actual.count).to eq(32)
      check_file_actual_expected(actual, sub_dir, "managed_child_indicators_pagination_expected_2.yaml")
    end

    it "get children with indicators extend and subset, V1 all items II" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V2#TH"))
      ThesauriHelpers.fake_extended(Uri.new(uri: "http://www.cdisc.org/C66787/V2#C66787"), "1")
      uri2 = Uri.new(uri: "http://www.cdisc.org/C67154/V2#C67154")
      item = ct.add_extension(uri2.to_id)
      actual = ct.managed_children_indicators_paginated(offset: 0, count: 100)
      expect(actual.count).to eq(35)
      check_file_actual_expected(actual, sub_dir, "managed_child_indicators_pagination_expected_3.yaml", )
    end

    it "get children with indicators CI and CN, V3 all items" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V3#TH"))
      ThesauriHelpers.fake_extended(Uri.new(uri: "http://www.cdisc.org/C66787/V2#C66787"), "1")
      uri2 = Uri.new(uri: "http://www.cdisc.org/C67154/V2#C67154")
      item = ct.add_extension(uri2.to_id)
      uri_2 = Uri.new(uri: "http://www.assero.co.uk/CID")
      allow(SecureRandom).to receive(:uuid).and_return("1234-5678-9012-3300")
      allow(Time).to receive(:now).and_return(Time.parse("Jan 1 12:00:00+01:00 2000"))
      item.add_change_note(user_reference: "xxx1", reference: "ref 1", description: "description 1", context_id: uri_2.to_id)
      allow(SecureRandom).to receive(:uuid).and_return("1234-5678-9012-3456")
      ci = Annotation::ChangeInstruction.create
      ci = Annotation::ChangeInstruction.find(ci.id)
      ci.add_references(previous: [uri2.to_id], current: [])
      actual = ct.managed_children_indicators_paginated(offset: 0, count: 100)
      expect(actual.count).to eq(35)
      check_file_actual_expected(actual, sub_dir, "managed_child_indicators_pagination_expected_4.yaml", equate_method: :hash_equal, )
    end

    it "get children with indicators, speed" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V59#TH"))
      timer_start
      (1..100).each {|x| actual = ct.managed_children_indicators_paginated(offset: 0, count: 10)}
      timer_stop("100 searches [79.95s]")
    end

    it "get children with indicators extend used by thesaurus, GLAN-1285" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V47#TH"))
      s_th = Thesaurus.create({:identifier => "TEST", :label => "Test Thesaurus"})
      uri_1 = Uri.new(uri: "http://www.cdisc.org/C99079/V47#C99079")
      s_th.select_children({id_set: [uri_1.to_id]})
      actual = ct.managed_children_pagination(offset: 0, count: 1000)
      check_file_actual_expected(actual, sub_dir, "select_children_expected_4.yaml", equate_method: :hash_equal, )
      expect(actual.count).to eq(ct.is_top_concept_links.count)
    end

  end

  describe "Child Operations - Write" do

    def load_versions(range)
      range.each {|n| load_data_file_into_triple_store("cdisc/ct/CT_V#{n}.ttl")}
    end

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus.ttl", "thesaurus_new_airports.ttl"]
      load_files(schema_files, data_files)
      #load_versions(1..60)
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
    end

    after :each do
      #
    end

    # Required for manul identifiers
    # it "add child, manual entry" do
    #   ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.assero.co.uk/MDRThesaurus/ACME/V1#TH-SPONSOR_CT-1"))
    #   expect(Thesaurus::ManagedConcept).to receive(:generated_identifier?).and_return(false)
    #   ct.add_child(identifier: "S123")
    #   actual = ct.managed_children_pagination(count: 100, offset: 0)
    #   check_file_actual_expected(actual, sub_dir, "add_child_expected_1.yaml", equate_method: :hash_equal)
    #   item = Thesaurus::ManagedConcept.find_full(Uri.new(uri: "http://www.acme-pharma.com/S123/V1#S123"))
    #   actual = item.to_h
    # #Xwrite_yaml_file(item.to_h, sub_dir, "add_child_expected_2.yaml")
    #   expected = read_yaml_file(sub_dir, "add_child_expected_2.yaml")
    #   expect(actual[:preferred_term][:label]).to eq(expected[:preferred_term][:label])
    #   expected[:preferred_term] = actual[:preferred_term] # Cannot predict URI for the created PT Not_Set
    #   expected[:creation_date] = date_check_now(item.creation_date).iso8601
    #   expected[:last_change_date] = date_check_now(item.last_change_date).iso8601
    #   expect(actual).to hash_equal(expected)
    # end

    it "add child, generated identifier" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.assero.co.uk/MDRThesaurus/ACME/V1#TH-SPONSOR_CT-1"))
      expect(Thesaurus::ManagedConcept).to receive(:generated_identifier?).twice.and_return(true)
      expect(Thesaurus::ManagedConcept).to receive(:new_identifier).and_return("S12345X")
      ct.add_child(identifier: "S123")
      actual = ct.managed_children_pagination(count: 100, offset: 0)
      check_file_actual_expected(actual, sub_dir, "add_child_expected_3.yaml", equate_method: :hash_equal)
      item = Thesaurus::ManagedConcept.find_full(Uri.new(uri: "http://www.acme-pharma.com/S12345X/V1#S12345X"))
      actual = item.to_h
    #Xwrite_yaml_file(actual.to_h, sub_dir, "add_child_expected_4.yaml")
      expected = read_yaml_file(sub_dir, "add_child_expected_4.yaml")
      expect(actual[:preferred_term][:label]).to eq(expected[:preferred_term][:label])
      expected[:preferred_term] = actual[:preferred_term] # Cannot predict URI for the created PT Not_Set
      expected[:creation_date] = date_check_now(item.creation_date).iso8601
      expected[:last_change_date] = date_check_now(item.last_change_date).iso8601
      expect(actual).to hash_equal(expected)
    end

    it "add child and update" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.assero.co.uk/MDRThesaurus/ACME/V1#TH-SPONSOR_CT-1"))
      actual = ct.managed_children_pagination(count: 100, offset: 0)
      count = actual.count
      expect(Thesaurus::ManagedConcept).to receive(:generated_identifier?).twice.and_return(true)
      expect(Thesaurus::ManagedConcept).to receive(:new_identifier).and_return("S12345X")
      ct.add_child(identifier: "S123")
      actual = ct.managed_children_pagination(count: 100, offset: 0)
      expect(actual.count).to eq(count+1)
      item = Thesaurus::ManagedConcept.find_full(Uri.new(uri: "http://www.acme-pharma.com/S12345X/V1#S12345X"))
      item.update(definition: "updated def")
      actual = ct.managed_children_pagination(count: 100, offset: 0)
      expect(actual.count).to eq(count+1)
    end

    it "add child and add PT" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.assero.co.uk/MDRThesaurus/ACME/V1#TH-SPONSOR_CT-1"))
      actual = ct.managed_children_pagination(count: 100, offset: 0)
      count = actual.count
      expect(Thesaurus::ManagedConcept).to receive(:generated_identifier?).twice.and_return(true)
      expect(Thesaurus::ManagedConcept).to receive(:new_identifier).and_return("S12345X")
      ct.add_child
      actual = ct.managed_children_pagination(count: 100, offset: 0)
      expect(actual.count).to eq(count+1)
      item = Thesaurus::ManagedConcept.find_full(Uri.new(uri: "http://www.acme-pharma.com/S12345X/V1#S12345X"))
      item.update(preferred_term: "updated pt")
      actual = ct.managed_children_pagination(count: 100, offset: 0)
      expect(actual.count).to eq(count+1)
      item = Thesaurus::ManagedConcept.find_full(Uri.new(uri: "http://www.acme-pharma.com/S12345X/V1#S12345X"))
      expect(item.to_h[:preferred_term][:label]).to eq("updated pt")
    end

    it "replace child and update" do
      th = Thesaurus.create({:identifier => "TEST", :label => "Test Thesaurus"})
      expect(Thesaurus::ManagedConcept).to receive(:generated_identifier?).twice.and_return(true)
      expect(Thesaurus::ManagedConcept).to receive(:new_identifier).and_return("S1222")
      old_child = th.add_child(identifier: "S1222")
      actual = th.managed_children_pagination(count: 100, offset: 0)
      expect(actual.count).to eq(1)
      check_file_actual_expected(actual, sub_dir, "replace_child_expected_1a.yaml")
      expect(Thesaurus::ManagedConcept).to receive(:generated_identifier?).twice.and_return(true)
      expect(Thesaurus::ManagedConcept).to receive(:new_identifier).and_return("S1333")
      new_child = Thesaurus::ManagedConcept.create
      th.replace_child(old_child, new_child)
      actual = th.managed_children_pagination(count: 100, offset: 0)
      expect(actual.count).to eq(1)
      check_file_actual_expected(actual, sub_dir, "replace_child_expected_1b.yaml")
    end

    # Required for manul identifiers
    # it "allows a child TC to be added - error, invalid identifier" do
    #   ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.assero.co.uk/MDRThesaurus/ACME/V1#TH-SPONSOR_CT-1"))
    #   expect(Thesaurus::ManagedConcept).to receive(:generated_identifier?).and_return(false)
    #   item = ct.add_child(identifier: "S123£%^@")
    #   expect(item.errors.count).to eq(3)
    #   expect(item.errors.full_messages.to_sentence).to eq("Uri is invalid, Has identifier: Identifier contains invalid characters, and Identifier contains a part with invalid characters")
    #   actual = ct.managed_children_pagination(count: 100, offset: 0)
    #   check_file_actual_expected(actual, sub_dir, "add_child_expected_5.yaml", equate_method: :hash_equal)
    # end

  end

  describe "Extensions" do

    def load_versions(range)
      range.each {|n| load_data_file_into_triple_store("cdisc/ct/CT_V#{n}.ttl")}
    end

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus.ttl", "thesaurus_new_airports.ttl"]
      load_files(schema_files, data_files)
      load_versions(1..33)
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
    end

    after :all do
      #
    end

    it "add extension" do
      uri1 = Uri.new(uri: "http://www.acme-pharma.com/AIRPORTS/V1#TH")
      ct = Thesaurus.find_minimum(uri1)
      ct1 = Thesaurus.find_full(uri1)
      ct.is_top_concept_reference_objects
      expect(ct.is_top_concept_reference.count).to eq(2)
      uri2 = Uri.new(uri: "http://www.cdisc.org/C96779/V33#C96779")
      item = ct.add_extension(uri2.to_id)
      result = Thesaurus::ManagedConcept.find_full(Uri.new(uri: "http://www.acme-pharma.com/C96779E/V1#C96779E"))
      source = Thesaurus::ManagedConcept.find_full(Uri.new(uri: "http://www.cdisc.org/C96779/V33#C96779"))
      expect(result.narrower.count).to eq(source.narrower.count)
      expect(result.extends).to eq(source.uri.to_s)
      check_file_actual_expected(result.narrower.map{|x| x.uri.to_s}, sub_dir, "add_extension_expected_2.yaml", equate_method: :hash_equal)
      check_file_actual_expected(source.narrower.map{|x| x.uri.to_s}, sub_dir, "add_extension_expected_2.yaml", equate_method: :hash_equal)
      item = Thesaurus.find_full(uri1)
      item.is_top_concept_objects
      expect(item.is_top_concept_reference.count).to eq(3)
      expect(item.is_top_concept_reference.map{|x| x.reference.to_s}.include?(result.uri.to_s)).to eq(true)
      check_file_actual_expected(item.is_top_concept.map{|x| x.uri.to_s}, sub_dir, "add_extension_expected_1.yaml", equate_method: :hash_equal)
    end

  end

  describe "Complex Finds" do

    def load_versions(range)
      range.each {|n| load_data_file_into_triple_store("cdisc/ct/CT_V#{n}.ttl")}
    end

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus.ttl"]
      load_files(schema_files, data_files)
      load_versions(1..60)
    end

    after :all do
      #
    end

    it "find by identifiers" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V60#TH"))
      actual = ct.find_by_identifiers(["C106655", "C161764"])
      check_file_actual_expected(actual, sub_dir, "find_by_identifiers_expected_1.yaml")
    end

    it "find by identifiers" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V60#TH"))
      actual = ct.find_by_identifiers(["C106655"])
      check_file_actual_expected(actual, sub_dir, "find_by_identifiers_expected_2.yaml")
    end

    it "find_identifier" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V60#TH"))
      actual = ct.find_identifier("C17998").map{|x| {uri: x[:uri].to_s, rdf_type: x[:rdf_type].to_s}}
      check_file_actual_expected(actual, sub_dir, "find_identifier_expected_1.yaml", equate_method: :hash_equal)
      actual = ct.find_identifier("C25308").map{|x| {uri: x[:uri].to_s, rdf_type: x[:rdf_type].to_s}}
      check_file_actual_expected(actual, sub_dir, "find_identifier_expected_2.yaml", equate_method: :hash_equal)
      actual = ct.find_identifier("C25308X").map{|x| {uri: x[:uri].to_s, rdf_type: x[:rdf_type].to_s}}
      check_file_actual_expected(actual, sub_dir, "find_identifier_expected_3.yaml", equate_method: :hash_equal)
    end

  end

  describe "Subsets" do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_new_airports.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..2)
    end

    before :each do
      NameValue.destroy_all
      NameValue.create(name: "thesaurus_parent_identifier", value: "123")
      NameValue.create(name: "thesaurus_child_identifier", value: "456")
    end

    it "add a new subset" do
      thesaurus = Thesaurus.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/AIRPORTS/V1#TH"))
      subsetted_mc_id = "aHR0cDovL3d3dy5jZGlzYy5vcmcvQzY2NzgxL1YyI0M2Njc4MQ=="
      expect(thesaurus.is_top_concept_links.count).to eq(2)
      new_mc = thesaurus.add_subset(subsetted_mc_id)
      expect(thesaurus.is_top_concept_links.count).to eq(3)
      actual = Thesaurus::ManagedConcept.find_minimum(new_mc.id)
      expect(actual.subsets_links.to_s).to eq("http://www.cdisc.org/C66781/V2#C66781")
      expect(actual.is_ordered_objects).not_to be(nil)
      expect(actual.is_ordered_objects.members).to be(nil)
    end

  end

  describe "Clone and New Version" do

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_new_airports_std.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..2)
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
    end

    before :each do
    end

    it "clone thesaurus I" do
      thesaurus = Thesaurus.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/AIRPORTS/V1#TH"))
      actual = thesaurus.clone
      check_file_actual_expected(actual.to_h, sub_dir, "clone_expected_1.yaml", equate_method: :hash_equal)
    end

    it "clone thesaurus II" do
      thesaurus = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"))
      actual = thesaurus.clone
      check_file_actual_expected(actual.to_h, sub_dir, "clone_expected_2.yaml", equate_method: :hash_equal)
    end

    it "create next thesaurus" do
      file = "next_version_expected_1.yaml"
      thesaurus = Thesaurus.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/AIRPORTS/V1#TH"))
      actual = thesaurus.create_next_version
      check_dates(actual, sub_dir, file, :creation_date, :last_change_date)
      check_file_actual_expected(actual.to_h, sub_dir, file, equate_method: :hash_equal)
    end

    it "clone thesaurus, reference" do
      thesaurus = Thesaurus.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/AIRPORTS/V1#TH"))
      ref = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"))
      thesaurus.set_referenced_thesaurus(ref)
      actual = thesaurus.clone
      check_file_actual_expected(actual.to_h, sub_dir, "clone_expected_3.yaml", equate_method: :hash_equal)
    end

  end

  describe "states" do

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_sponsor_5_state.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..2)
    end

    it "rejects state change" do
      thesaurus = Thesaurus.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/STATE/V1#TH"))
      thesaurus.update_status(registration_status: "Standard")
      expect(thesaurus.errors.count).to eq(1)
      expect(thesaurus.errors.full_messages.to_sentence).to eq("Child items are not in the appropriate state.")
      thesaurus = Thesaurus.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/STATE/V1#TH"))
      tc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001"))
      tc.update_status(registration_status: "Candidate")
      thesaurus.update_status(registration_status: "Candidate")
      expect(thesaurus.errors.count).to eq(0)
    end

    it "states" do
      thesaurus = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"))
      actual = thesaurus.managed_children_states
      check_file_actual_expected(actual, sub_dir, "states_expected_1.yaml", equate_method: :hash_equal)
    end

    it "move to next state" do
      thesaurus = Thesaurus.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/STATE/V1#TH"))
      expect(thesaurus.move_to_next_state?).to eq(false)
      tc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001"))
      tc.update_status(registration_status: "Candidate")
      expect(thesaurus.move_to_next_state?).to eq(true)
      tc.update_status(registration_status: "Recorded")
      expect(thesaurus.move_to_next_state?).to eq(true)
      thesaurus.update_status(registration_status: "Recorded")
      expect(thesaurus.move_to_next_state?).to eq(false)
      tc.update_status(registration_status: "Qualified")
      expect(thesaurus.move_to_next_state?).to eq(true)
      thesaurus.update_status(registration_status: "Qualified")
      expect(thesaurus.move_to_next_state?).to eq(false)
      tc.update_status(registration_status: "Standard")
      expect(thesaurus.move_to_next_state?).to eq(true)
      thesaurus.update_status(registration_status: "Standard")
      expect(thesaurus.move_to_next_state?).to eq(false)
    end

  end

  describe "Further Delete" do

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_new_airports_std.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..2)
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
    end

    def th_counts
      { th_count: triple_store.rdf_type_count(Thesaurus.rdf_type),
        mc_count: triple_store.rdf_type_count(Thesaurus::ManagedConcept.rdf_type),
        uc_count: triple_store.rdf_type_count(Thesaurus::UnmanagedConcept.rdf_type)
      }
    end

    it "deletes thesaurus keeps children" do
      th_uri = Uri.new(uri: "http://www.acme-pharma.com/AIRPORTS/V1#TH")
      check_file_actual_expected(th_counts, sub_dir, "delete_checks_expected_1a.yaml")
      th = Thesaurus.find_minimum(th_uri)
      th.delete
      check_file_actual_expected(th_counts, sub_dir, "delete_checks_expected_1b.yaml")
      expect{Thesaurus.find_minimum(th_uri)}.to raise_error(Errors::NotFoundError, "Failed to find http://www.acme-pharma.com/AIRPORTS/V1#TH in Thesaurus.")
    end

    it "adds a child item then deletes thesaurus" do
      uri_check_set =
      [
        { uri: Uri.new(uri: "http://www.acme-pharma.com/AIRPORTS/V1#TH"), present: false},
        { uri: Uri.new(uri: "http://www.acme-pharma.com/AIRPORTS/V1#TH_RS"), present: false},
        { uri: Uri.new(uri: "http://www.acme-pharma.com/AIRPORTS/V1#TH_SI"), present: false},
        { uri: Uri.new(uri: "http://www.acme-pharma.com/AIRPORTS/V1#TH_TCR1"), present: false},
        { uri: Uri.new(uri: "http://www.acme-pharma.com/AIRPORTS/V1#TH_TCR2"), present: false},
        { uri: Uri.new(uri: "http://www.acme-pharma.com/S123A/V1#S123A"), present: true},
        { uri: Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001"), present: true},
        { uri: Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001_RS"), present: true},
        { uri: Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001_SI"), present: true},
        { uri: Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001_A000011"), present: true},
        { uri: Uri.new(uri: "http://www.assero.co.uk/PT#26357de9280b8b1df0049b6923d1bc19ad3f377c"), present: true},
        { uri: Uri.new(uri: "http://www.assero.co.uk/SYN#a39d900d25e54ad5f61dfacf23077413ca49cf5d"), present: true},
        { uri: Uri.new(uri: "http://www.assero.co.uk/SYN#af84b37afa3c3d83b068c072d126f7873553306f"), present: true},
        { uri: Uri.new(uri: "http://www.assero.co.uk/SYN#84951d6f13f0db7aa4b351d1c8afab29a8173201"), present: true},
        { uri: Uri.new(uri: "http://www.assero.co.uk/SYN#af6cf7cee7960bb1f8e33409ad316508e5b4a166"), present: true},
        { uri: Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001_A000012"), present: true},
        { uri: Uri.new(uri: "http://www.assero.co.uk/PT#addfdad3bf63ee038b6f1a4709d275fa30732004"), present: true},
        { uri: Uri.new(uri: "http://www.assero.co.uk/PT#811134c7e968fad493503ef4bb858c4677c29f8a"), present: true},
        { uri: Uri.new(uri: "http://www.assero.co.uk/SYN#79c4ee2a8794ed9263677bae64ea01a6e9bb6472"), present: true},
        { uri: Uri.new(uri: "http://www.assero.co.uk/SYN#e4626aa737c7a6111b853ba4eaf4ee1599bfb7b3"), present: true},
        { uri: Uri.new(uri: "http://www.acme-pharma.com/A00002/V1#A00002"), present: true},
        { uri: Uri.new(uri: "http://www.acme-pharma.com/A00002/V1#A00002_RS"), present: true},
        { uri: Uri.new(uri: "http://www.acme-pharma.com/A00002/V1#A00002_SI"), present: true}
      ]
      th_uri = Uri.new(uri: "http://www.acme-pharma.com/AIRPORTS/V1#TH")
      expected_uri = Uri.new(uri: "http://www.acme-pharma.com/S123A/V1#S123A")
      check_file_actual_expected(th_counts, sub_dir, "delete_checks_expected_2a.yaml")
      th = Thesaurus.find_minimum(th_uri)
      expect(Thesaurus::ManagedConcept).to receive(:generated_identifier?).twice.and_return(true)
      expect(Thesaurus::ManagedConcept).to receive(:new_identifier).and_return("S123A")
      result = th.add_child(identifier: "S123A")
      item = Thesaurus::ManagedConcept.find_minimum(expected_uri)
      check_file_actual_expected(th_counts, sub_dir, "delete_checks_expected_2b.yaml")
      th.delete
      check_file_actual_expected(th_counts, sub_dir, "delete_checks_expected_2c.yaml")
      expect{Thesaurus.find_minimum(th_uri)}.to raise_error(Errors::NotFoundError, "Failed to find http://www.acme-pharma.com/AIRPORTS/V1#TH in Thesaurus.")
      item = Thesaurus::ManagedConcept.find_minimum(expected_uri)
      check_dates(item, sub_dir, "delete_checks_expected_2d.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(item.to_h, sub_dir, "delete_checks_expected_2d.yaml")
      expect(triple_store.check_uris(uri_check_set)).to be(true)
    end

  end

  describe "Upgrade" do

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_new_airports.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..15)
    end

    it "upgrade thesauri, I" do
      s_th = Thesaurus.create({:identifier => "TEST", :label => "Test Thesaurus"})
      t_th_old = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V2#TH"))
      t_th_new = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V5#TH"))
      s_th = Thesaurus.find_minimum(s_th.uri)
      should_upgrade = s_th.set_referenced_thesaurus(t_th_old)
      expect(should_upgrade).to eq(false)
      tc_1 = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C66783/V2#C66783"))
      tc_2 = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C66737/V2#C66737"))
      tc_3 = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001"))
      s_th.select_children({id_set: [tc_1.id, tc_2.id, tc_3.id]})
      should_upgrade = s_th.set_referenced_thesaurus(t_th_new)
      expect(should_upgrade).to eq(true)
      s_th = Thesaurus.find_minimum(s_th.uri)
      s_th.upgrade
      s_th = Thesaurus.find_minimum(s_th.uri)
      s_th.is_top_concept_reference_objects
      s_th.is_top_concept_objects
      s_th.reference_objects
      s_th.baseline_reference_objects
      check_dates(s_th, sub_dir, "update_expected_1.yaml", :last_change_date, :creation_date)
      check_file_actual_expected(s_th.to_h, sub_dir, "update_expected_1.yaml", equate_method: :hash_equal)
    end

    it "upgrade thesauri, II" do
      s_th = Thesaurus.create({:identifier => "TEST", :label => "Test Thesaurus"})
      t_th_old = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V9#TH"))
      t_th_new = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V12#TH"))
      s_th = Thesaurus.find_minimum(s_th.uri)
      should_upgrade = s_th.set_referenced_thesaurus(t_th_old)
      expect(should_upgrade).to eq(false)
      tc_1 = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C25188/V9#C25188"))
      tc_2 = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C74560/V8#C74560"))
      tc_3 = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C66783/V4#C66783"))
      tc_4 = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C66737/V9#C66737"))
      tc_5 = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001"))
      tc_6 = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C71620/V9#C71620"))
      s_th.select_children({id_set: [tc_1.id, tc_2.id, tc_3.id, tc_4.id, tc_5.id, tc_6.id]})
      should_upgrade = s_th.set_referenced_thesaurus(t_th_new)
      expect(should_upgrade).to eq(true)
      s_th = Thesaurus.find_minimum(s_th.uri)
      s_th.upgrade
      s_th = Thesaurus.find_minimum(s_th.uri)
      s_th.is_top_concept_reference_objects
      s_th.is_top_concept_objects
      s_th.reference_objects
      s_th.baseline_reference_objects
      check_dates(s_th, sub_dir, "update_expected_1.yaml", :last_change_date, :creation_date)
      check_file_actual_expected(s_th.to_h, sub_dir, "update_expected_2.yaml", equate_method: :hash_equal)
    end

  end

 describe "Referenced Versions and selection" do

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_new_airports.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..2)
    end

    it "get and set reference thesauri" do
      s_th = Thesaurus.create({:identifier => "TEST", :label => "Test Thesaurus"})
      r_th_1 = Thesaurus.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/AIRPORTS/V1#TH"))
      r_th_2 = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"))
      r_th_3 = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V2#TH"))
      expect(s_th.get_referenced_thesaurus).to eq(nil)
      should_upgrade = s_th.set_referenced_thesaurus(r_th_1)
      expect(should_upgrade).to eq(false)
      expect(s_th.get_referenced_thesaurus.uri).to eq(r_th_1.uri)
      expect(s_th.get_baseline_referenced_thesaurus).to eq(nil)
      s_th = Thesaurus.find_minimum(s_th.uri)
      s_th.reference_objects
      same_uri = s_th.reference.uri
      s_th = Thesaurus.find_minimum(s_th.uri)
      should_upgrade = s_th.set_referenced_thesaurus(r_th_2)
      expect(should_upgrade).to eq(true)
      expect(s_th.get_referenced_thesaurus.uri).to eq(r_th_2.uri)
      expect(s_th.get_baseline_referenced_thesaurus.uri).to eq(r_th_1.uri)
      s_th = Thesaurus.find_minimum(s_th.uri)
      expect(s_th.get_referenced_thesaurus.uri).to eq(r_th_2.uri)
      expect(s_th.get_baseline_referenced_thesaurus.uri).to eq(r_th_1.uri)
      expect(s_th.reference.uri).to eq(same_uri) # Make sure op ref is re-used, i.e same one as first one
      should_upgrade = s_th.set_referenced_thesaurus(r_th_3)
      expect(should_upgrade).to eq(true)
      s_th = Thesaurus.find_minimum(s_th.uri)
      expect(s_th.get_referenced_thesaurus.uri).to eq(r_th_3.uri)
      expect(s_th.get_baseline_referenced_thesaurus.uri).to eq(r_th_1.uri)
      should_upgrade = s_th.set_referenced_thesaurus(r_th_2)
      expect(should_upgrade).to eq(true)
      s_th = Thesaurus.find_minimum(s_th.uri)
      expect(s_th.get_referenced_thesaurus.uri).to eq(r_th_2.uri)
      expect(s_th.get_baseline_referenced_thesaurus.uri).to eq(r_th_1.uri)
      ref = OperationalReferenceV3.find(s_th.reference.uri)
    end

    it "allows for items to be selected" do
      s_th = Thesaurus.create({:identifier => "TEST", :label => "Test Thesaurus"})
      uri_1 = Uri.new(uri: "http://www.cdisc.org/C67152/V2#C67152")
      uri_2 = Uri.new(uri: "http://www.cdisc.org/C66739/V2#C66739")
      uri_3 = Uri.new(uri: "http://www.cdisc.org/C66770/V2#C66770")
      s_th.select_children({id_set: [uri_1.to_id]})
      s_th = Thesaurus.find_minimum(s_th.uri)
      expect(s_th.is_top_concept_reference_objects.count).to eq(1)
      s_th.select_children({id_set: [uri_2.to_id, uri_3.to_id]})
      s_th = Thesaurus.find_minimum(s_th.uri)
      expect(s_th.is_top_concept_reference_objects.count).to eq(3)
      s_th.select_children({id_set: [uri_2.to_id]}) # Duplicate
      s_th = Thesaurus.find_minimum(s_th.uri)
      expect(s_th.is_top_concept_reference_objects.count).to eq(3)
      actual = s_th.managed_children_pagination(offset: 0, count: 10)
      check_file_actual_expected(actual, sub_dir, "select_children_expected_1.yaml", equate_method: :hash_equal)
      tc = Thesaurus::ManagedConcept.find_minimum(uri_1) # MAke sure code lists still present
      tc = Thesaurus::ManagedConcept.find_minimum(uri_2)
      tc = Thesaurus::ManagedConcept.find_minimum(uri_3)
    end

    it "allows for items to be deselected" do
      s_th = Thesaurus.create({:identifier => "TEST", :label => "Test Thesaurus"})
      uri_1 = Uri.new(uri: "http://www.cdisc.org/C67152/V2#C67152")
      uri_2 = Uri.new(uri: "http://www.cdisc.org/C66739/V2#C66739")
      uri_3 = Uri.new(uri: "http://www.cdisc.org/C66770/V2#C66770")
      s_th.select_children({id_set: [uri_1.to_id, uri_2.to_id, uri_3.to_id]})
      s_th = Thesaurus.find_minimum(s_th.uri)
      actual = s_th.managed_children_pagination(offset: 0, count: 10)
      check_file_actual_expected(actual, sub_dir, "deselect_children_expected_1.yaml", equate_method: :hash_equal)
      expect(s_th.is_top_concept_reference_objects.count).to eq(3)
      s_th.deselect_children({id_set: [uri_1.to_id]})
      s_th = Thesaurus.find_minimum(s_th.uri)
      expect(s_th.is_top_concept_reference_objects.count).to eq(2)
      s_th = Thesaurus.find_minimum(s_th.uri)
      actual = s_th.managed_children_pagination(offset: 0, count: 10)
      check_file_actual_expected(actual, sub_dir, "deselect_children_expected_2.yaml", equate_method: :hash_equal)
      s_th.deselect_children({id_set: [uri_2.to_id, uri_3.to_id]})
      expect(s_th.is_top_concept_reference_objects.count).to eq(0)
      s_th = Thesaurus.find_minimum(s_th.uri)
      actual = s_th.managed_children_pagination(offset: 0, count: 10)
      check_file_actual_expected(actual, sub_dir, "deselect_children_expected_3.yaml", equate_method: :hash_equal)
      tc = Thesaurus::ManagedConcept.find_minimum(uri_1) # MAke sure code lists still present
      tc = Thesaurus::ManagedConcept.find_minimum(uri_2)
      tc = Thesaurus::ManagedConcept.find_minimum(uri_3)
    end

    it "allows for all items to be deselected" do
      s_th = Thesaurus.create({:identifier => "TEST", :label => "Test Thesaurus"})
      uri_1 = Uri.new(uri: "http://www.cdisc.org/C67152/V2#C67152")
      uri_2 = Uri.new(uri: "http://www.cdisc.org/C66739/V2#C66739")
      uri_3 = Uri.new(uri: "http://www.cdisc.org/C66770/V2#C66770")
      s_th.select_children({id_set: [uri_1.to_id, uri_2.to_id, uri_3.to_id]})
      s_th = Thesaurus.find_minimum(s_th.uri)
      s_th.deselect_all_children
      s_th = Thesaurus.find_minimum(s_th.uri)
      actual = s_th.managed_children_pagination(offset: 0, count: 10)
      check_file_actual_expected(actual, sub_dir, "deselect_all_children_expected_1.yaml", equate_method: :hash_equal)
      tc = Thesaurus::ManagedConcept.find_minimum(uri_1) # MAke sure code lists still present
      tc = Thesaurus::ManagedConcept.find_minimum(uri_2)
      tc = Thesaurus::ManagedConcept.find_minimum(uri_3)
    end

    it "valid reference" do
      s_th = Thesaurus.create({:identifier => "TEST", :label => "Test Thesaurus"})
      r_th_1 = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"))
      r_th_2 = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V2#TH"))
      expect(s_th.get_referenced_thesaurus).to eq(nil)
      s_th = s_th.valid_reference?(r_th_1)
      expect(s_th.errors.empty?).to eq(true)
      s_th.set_referenced_thesaurus(r_th_1)
      s_th = Thesaurus.find_minimum(s_th.uri)
      s_th.reference_objects
      s_th = s_th.valid_reference?(r_th_2)
      expect(s_th.errors.empty?).to eq(true)
      s_th.set_referenced_thesaurus(r_th_2)
      s_th = Thesaurus.find_minimum(s_th.uri)
      s_th.reference_objects
      s_th = s_th.valid_reference?(r_th_1)
      expect(s_th.errors.full_messages).to eq(["The reference thesaurus must be a later version than the current one is (#{r_th_2.version_label})."])
    end

  end

  describe "impact data test" do

    def load_versions(range)
      range.each {|n| load_data_file_into_triple_store("cdisc/ct/CT_V#{n}.ttl")}
    end

    def simple_thesaurus_1
      @ra = IsoRegistrationAuthority.find_children(Uri.new(uri: "http://www.assero.co.uk/RA#DUNS123456789"))
      @th_1 = Thesaurus.new
      @tc_1 = Thesaurus::ManagedConcept.from_h({
          label: "London Heathrow",
          identifier: "A00001",
          definition: "A definition",
          notation: "LHR"
        })
      @tc_1a = Thesaurus::UnmanagedConcept.from_h({
          label: "Terminal 5",
          identifier: "A000011",
          definition: "The 5th LHR Terminal",
          notation: "T5"
        })
      # @tc_1b = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C161617/V60#C161617_C161666"))
      @tc_1.narrower << @tc_1a
      # @tc_1.narrower << @tc_1b
      @tc_1.set_initial("A00001")

      @tc_2 = Thesaurus::ManagedConcept.new
      @tc_2.identifier = "A00002"
      @tc_2.definition = "Copenhagen"
      @tc_2.extensible = false
      @tc_2.notation = "CPH"
      @tc_2.set_initial("A00002")
      @cl_1 = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri:"http://www.cdisc.org/C66787/V50#C66787"))
      @th_1.is_top_concept_reference << OperationalReferenceV3::TmcReference.from_h({reference: @tc_1.uri, local_label: "", enabled: true, ordinal: 1, optional: true})
      @th_1.is_top_concept_reference << OperationalReferenceV3::TmcReference.from_h({reference: @tc_2.uri, local_label: "", enabled: true, ordinal: 2, optional: true})
      @th_1.is_top_concept_reference << OperationalReferenceV3::TmcReference.from_h({reference: @cl_1.uri, local_label: "", enabled: true, ordinal: 3, optional: true})

      @th_1.is_top_concept << @tc_1.uri
      @th_1.is_top_concept << @tc_2.uri
      @th_1.is_top_concept << @cl_1.uri
      @th_1.set_initial("SPONSOR2")
    end

    before :all  do
      IsoHelpers.clear_cache
    end

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_versions(CdiscCtHelpers.version_range)
      # @cl_1 = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri:"http://www.cdisc.org/C66781/V2#C66781"))
      # @tc_1 = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C66781/V2#C66781_C25301"))
      # @tc_2 = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C66781/V2#C66781_C25529"))
      # @tc_3 = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C66781/V2#C66781_C29846"))
      # @tc_4 = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C66781/V2#C66781_C29844"))
      # @tc_5 = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C66781/V2#C66781_C29848"))
      @cl_1 = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri:"http://www.cdisc.org/C66787/V50#C66787"))
      # @tc_1 = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C161617/V60#C161617_C161666"))
    end

    it "file" do
      simple_thesaurus_1
      sparql = Sparql::Update.new
      sparql.default_namespace(@th_1.uri.namespace)
      @th_1.to_sparql(sparql, true)
      @tc_1.to_sparql(sparql, true)
      @tc_2.to_sparql(sparql, true)
      full_path = sparql.to_file
    #Xcopy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "thesaurus_sponsor_3_impact.ttl")
    end

  end

  describe "Delete References" do

    def load_versions(range)
      range.each {|n| load_data_file_into_triple_store("cdisc/ct/CT_V#{n}.ttl")}
    end


    before :all  do
      IsoHelpers.clear_cache
    end

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_new_airports.ttl"]
      load_files(schema_files, data_files)
      load_versions(CdiscCtHelpers.version_range)
    end

    it "create, delete and create thesaurus setting references" do
      s_th = Thesaurus.create({:identifier => "TEST", :label => "Test Thesaurus"})
      r_th_1 = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V52#TH"))
      r_th_2 = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V58#TH"))
      expect(s_th.get_referenced_thesaurus).to eq(nil)
      s_th.set_referenced_thesaurus(r_th_1)
      expect(s_th.get_referenced_thesaurus.uri).to eq(r_th_1.uri)
      expect(s_th.get_baseline_referenced_thesaurus).to eq(nil)
      s_th = Thesaurus.find_minimum(s_th.uri)
      s_th.reference_objects
      same_uri = s_th.reference.uri
      s_th = Thesaurus.find_minimum(s_th.uri)
      s_th.set_referenced_thesaurus(r_th_2)
      expect(s_th.get_referenced_thesaurus.uri).to eq(r_th_2.uri)
      expect(s_th.get_baseline_referenced_thesaurus.uri).to eq(r_th_1.uri)
      s_th = Thesaurus.find_minimum(s_th.uri)
      expect(s_th.get_referenced_thesaurus.uri).to eq(r_th_2.uri)
      expect(s_th.get_baseline_referenced_thesaurus.uri).to eq(r_th_1.uri)
      expect(s_th.reference.uri).to eq(same_uri)
      expect(Thesaurus.find_minimum(s_th.id).uri.to_s).to eq("http://www.acme-pharma.com/TEST/V1#TH")
      s_th.delete
      expect{Thesaurus.find_minimum(s_th.id)}.to raise_error(Errors::NotFoundError, "Failed to find http://www.acme-pharma.com/TEST/V1#TH in Thesaurus.")
      s_th = Thesaurus.create({:identifier => "TEST", :label => "Test Thesaurus"})
      expect(s_th.get_referenced_thesaurus).to eq(nil)
      s_th.set_referenced_thesaurus(r_th_1)
      expect(s_th.get_referenced_thesaurus.uri).to eq(r_th_1.uri)
    end

    it "delete thesaurus, check reference and baseline reference" do
      uri_check_set =
      [
        { uri: Uri.new(uri: "http://www.acme-pharma.com/TEST/V1#TH"), present: false},
        { uri: Uri.new(uri: "http://www.acme-pharma.com/TEST/V1#TH_RS"), present: false},
        { uri: Uri.new(uri: "http://www.acme-pharma.com/TEST/V1#TH_SI"), present: false},
        { uri: Uri.new(uri: "http://www.acme-pharma.com/TEST/V1#TH_R1"), present: false}, #reference
        { uri: Uri.new(uri: "http://www.cdisc.org/CT/V58#TH"), present: true},
        { uri: Uri.new(uri: "http://www.acme-pharma.com/TEST/V1#TH_R2"), present: false}, #baseline_reference
        { uri: Uri.new(uri: "http://www.cdisc.org/CT/V52#TH"), present: true},
        { uri: Uri.new(uri: "http://www.assero.co.uk/RA#DUNS123456789"), present: true},
        { uri: Uri.new(uri: "http://www.assero.co.uk/NS#ACME"), present: true}

      ]
      s_th = Thesaurus.create({:identifier => "TEST", :label => "Test Thesaurus"})
      r_th_1 = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V52#TH"))
      r_th_2 = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V58#TH"))
      s_th.set_referenced_thesaurus(r_th_1)
      s_th = Thesaurus.find_minimum(s_th.uri)
      s_th.reference_objects
      s_th = Thesaurus.find_minimum(s_th.uri)
      s_th.set_referenced_thesaurus(r_th_2)
      s_th.delete
      expect{Thesaurus.find_minimum(s_th.id)}.to raise_error(Errors::NotFoundError, "Failed to find http://www.acme-pharma.com/TEST/V1#TH in Thesaurus.")
      expect(triple_store.check_uris(uri_check_set)).to be(true)
    end

  end

end
