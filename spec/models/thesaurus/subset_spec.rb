require 'rails_helper'

describe "Thesaurus Subset General" do

	include DataHelpers
  include SparqlHelpers
  include PublicFileHelpers

	def sub_dir
    return "models/thesaurus/subset"
  end

	# Prepares a link between the subset, a managed concept, and a test terminology
  def init_subset(subset)
    ct = Thesaurus.create({label: "Test Terminology", identifier: "TT"})
    mc = ct.add_child({})
    mc = Thesaurus::ManagedConcept.find(mc.id)
    mc.add_link(:is_ordered, subset.uri)
    mc.save
    subset
  end

  before :all do
		NameValue.destroy_all
		NameValue.create(name: "thesaurus_parent_identifier", value: "123")
		NameValue.create(name: "thesaurus_child_identifier", value: "456")
    IsoHelpers.clear_cache
  end

  before :each do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
    load_cdisc_term_versions(1..2)
    load_local_file_into_triple_store(sub_dir, "subsets_input_1.ttl")
    load_local_file_into_triple_store(sub_dir, "subsets_input_2.ttl")
    load_local_file_into_triple_store(sub_dir, "subsets_input_3.ttl")
    load_local_file_into_triple_store(sub_dir, "subsets_input_4.ttl")
    load_local_file_into_triple_store(sub_dir, "subsets_input_5.ttl")
    load_local_file_into_triple_store(sub_dir, "subsets_clone_2.ttl")
    load_local_file_into_triple_store(sub_dir, "subsets_clone_3.ttl")
  end

  after :all do
    delete_all_public_test_files
  end

  # DO NOT DELETE THIS BLOCK. USEFUL TEST DATA CREATION
  # it "creates some test data" do
  #   base_uri = Uri.new(uri: "http://www.example.com/a#b")
  #   tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C66781/V2#C66781_C25301"))
  #   subset = Thesaurus::Subset.new
  #   subset.uri = subset.create_uri(base_uri)
  #   sm_1 = Thesaurus::SubsetMember.new
  #   sm_1.item = tc
  #   sm_1.uri = sm_1.create_uri(base_uri)
  #   sm_2 = Thesaurus::SubsetMember.new
  #   sm_2.item = tc
  #   sm_2.uri = sm_2.create_uri(base_uri)
  #   sm_3 = Thesaurus::SubsetMember.new
  #   sm_3.item = tc
  #   sm_3.uri = sm_3.create_uri(base_uri)
  #   sm_1.member_next = sm_2
  #   sm_2.member_next = sm_3
  #   subset.members = sm_1

  #   sparql = Sparql::Update.new
  #   sparql.default_namespace(subset.uri.namespace)
  #   subset.to_sparql(sparql)
  #   sm_1.to_sparql(sparql)
  #   sm_2.to_sparql(sparql)
  #   sm_3.to_sparql(sparql)
  #   file = sparql.to_file
  #   copy_file_from_public_files_rename("test", file.basename, sub_dir, "subsets_input_1.ttl")
  #end

  it "allows the last member to be found" do
    uri_1 = Uri.new(uri: "http://www.assero.co.uk/TS#54176c59-b800-43f5-99c3-d129cb563b79")
    uri_2 = Uri.new(uri: "http://www.assero.co.uk/TS#f5d17523-104f-412c-a652-b98ae6666666")
    expected = Uri.new(uri: "http://www.assero.co.uk/TSM#c2c707b1-c7a2-4ee5-a9ae-bd63a57c5314")
    subset = Thesaurus::Subset.find(uri_1)
    result = subset.last
    expect(result.uri).to eq(expected)
    subset = Thesaurus::Subset.find(uri_2)
    result = subset.last
    expect(result).to be_nil
  end

  it "allows add a new item to the list, empty" do
    uri_1 = Uri.new(uri: "http://www.assero.co.uk/TS#f5d17523-104f-412c-a652-b98ae6666666")
    subset = init_subset(Thesaurus::Subset.find(uri_1))
    tc_2 = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C66781/V2#C66781_C25529"))
    result = subset.add([tc_2.uri.to_id])
    expect(subset.last.item).to eq(tc_2.uri)
    tc_4 = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C66781/V2#C66781_C29844"))
    result = subset.add([tc_4.uri.to_id])
    expect(subset.last.item).to eq(tc_4.uri)
    actual = subset.list_pagination({offset: 0, count: 10}).map{|x| {ordinal: x[:ordinal], uri: x[:uri]}}
    check_file_actual_expected(actual, sub_dir, "list_pagination_expected_10.yaml")
  end

  it "allows add a new item to the list, 3 items" do
    uri_1 = Uri.new(uri: "http://www.assero.co.uk/TS#54176c59-b800-43f5-99c3-d129cb563b79")
    subset = init_subset(Thesaurus::Subset.find(uri_1))
    tc_2 = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C66781/V2#C66781_C25529"))
    result = subset.add([tc_2.uri.to_id])
    expect(subset.last.item).to eq(tc_2.uri)
    tc_4 = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C66781/V2#C66781_C29844"))
    result = subset.add([tc_4.uri.to_id])
    expect(subset.last.item).to eq(tc_4.uri)
    actual = subset.list_pagination({offset: 0, count: 10}).map{|x| {ordinal: x[:ordinal], uri: x[:uri]}}
    check_file_actual_expected(actual, sub_dir, "list_pagination_expected_11.yaml")
  end

  it "allows add a new item/items to the list, initial 3 items" do
    uri_1 = Uri.new(uri: "http://www.assero.co.uk/TS#e052799d-bd92-472d-8a39-68c582a66834")
    subset = Thesaurus::Subset.find(uri_1)
    mc = Thesaurus::ManagedConcept.find_full(Uri.new(uri: "http://www.acme-pharma.com/C66781S/V1#C66781S"))
    tc_2 = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C66781/V2#C66781_C25529"))
    tc_4 = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C66781/V2#C66781_C29844"))
    expect(mc.narrower.count).to eq(3)
    result = subset.add([tc_2.id, tc_4.id])
    subset = Thesaurus::Subset.find(uri_1)
    mc = Thesaurus::ManagedConcept.find_full(Uri.new(uri: "http://www.acme-pharma.com/C66781S/V1#C66781S"))
    expect(mc.narrower.count).to eq(5)
    last_sm = Thesaurus::SubsetMember.find(Uri.new(uri: "http://www.assero.co.uk/TSM#d224cb14-5282-4641-9d49-2ec4e3b38087"))
    expect(last_sm.member_next).not_to be(nil)  
    last_sm_member_next = Thesaurus::SubsetMember.find(last_sm.member_next)
    expect(last_sm_member_next.item).to eq(tc_2.uri)  
    expect(last_sm_member_next.member_next).not_to be(nil)
    last_sm_member_next_next = Thesaurus::SubsetMember.find(last_sm_member_next.member_next)
    expect(last_sm_member_next_next.item).to eq(tc_4.uri)  
    expect(last_sm_member_next_next.member_next).to eq(nil) 
    actual = subset.list_pagination({offset: 0, count: 10}).map{|x| {ordinal: x[:ordinal], uri: x[:uri]}}
    check_file_actual_expected(actual, sub_dir, "list_pagination_expected_12.yaml")
  end

  it "allows remove an item from the list, front, 3 items" do
    ss_uri_1 = Uri.new(uri: "http://www.assero.co.uk/TS#54176c59-b800-43f5-99c3-d129cb563b79")
    ss = init_subset(Thesaurus::Subset.find(ss_uri_1))
    sm_uri_1 = Uri.new(uri: "http://www.assero.co.uk/TSM#67871de3-5e13-42da-9814-e9fc3ce7b2f3")
    sm_uri_2 = Uri.new(uri: "http://www.assero.co.uk/TSM#a230eecb-1580-4cc9-a1af-5e18a6eb1a19")
    sm_uri_3 = Uri.new(uri: "http://www.assero.co.uk/TSM#c2c707b1-c7a2-4ee5-a9ae-bd63a57c5314")
    sm_1 = Thesaurus::SubsetMember.find(sm_uri_1)
    sm_2 = Thesaurus::SubsetMember.find(sm_uri_2)
    sm_3 = Thesaurus::SubsetMember.find(sm_uri_3)
    result = ss.remove(sm_1.uri.to_id)
    ss = Thesaurus::Subset.find(ss_uri_1)
    sm_2 = Thesaurus::SubsetMember.find(sm_uri_2)
    expect(ss.members).to eq(sm_uri_2)
    expect(sm_2.member_next).to eq(sm_3.uri)
    expect{Thesaurus::SubsetMember.find(sm_uri_1)}.to raise_error(Errors::NotFoundError, "Failed to find #{sm_uri_1} in Thesaurus::SubsetMember.")
    actual = ss.list_pagination({offset: 0, count: 10}).map{|x| {ordinal: x[:ordinal], uri: x[:uri]}}
    check_file_actual_expected(actual, sub_dir, "list_pagination_expected_13.yaml")
  end

  it "allows remove an item from the list, middle, 3 items" do
    ss_uri_1 = Uri.new(uri: "http://www.assero.co.uk/TS#54176c59-b800-43f5-99c3-d129cb563b79")
    ss = init_subset(Thesaurus::Subset.find(ss_uri_1))
    sm_uri_1 = Uri.new(uri: "http://www.assero.co.uk/TSM#67871de3-5e13-42da-9814-e9fc3ce7b2f3")
    sm_uri_2 = Uri.new(uri: "http://www.assero.co.uk/TSM#a230eecb-1580-4cc9-a1af-5e18a6eb1a19")
    sm_uri_3 = Uri.new(uri: "http://www.assero.co.uk/TSM#c2c707b1-c7a2-4ee5-a9ae-bd63a57c5314")
    sm_1 = Thesaurus::SubsetMember.find(sm_uri_1)
    sm_2 = Thesaurus::SubsetMember.find(sm_uri_2)
    sm_3 = Thesaurus::SubsetMember.find(sm_uri_3)
    result = ss.remove(sm_2.uri.to_id)
    ss = Thesaurus::Subset.find(ss_uri_1)
    sm_1 = Thesaurus::SubsetMember.find(sm_uri_1)
    expect(ss.members).to eq(sm_uri_1)
    expect(sm_1.member_next).to eq(sm_3.uri)
    expect{Thesaurus::SubsetMember.find(sm_uri_2)}.to raise_error(Errors::NotFoundError, "Failed to find #{sm_uri_2} in Thesaurus::SubsetMember.")
    actual = ss.list_pagination({offset: 0, count: 10}).map{|x| {ordinal: x[:ordinal], uri: x[:uri]}}
    check_file_actual_expected(actual, sub_dir, "list_pagination_expected_14.yaml")
  end

  it "allows remove an item from the list, end, 3 items" do
    ss_uri_1 = Uri.new(uri: "http://www.assero.co.uk/TS#54176c59-b800-43f5-99c3-d129cb563b79")
    ss = init_subset(Thesaurus::Subset.find(ss_uri_1))
    sm_uri_1 = Uri.new(uri: "http://www.assero.co.uk/TSM#67871de3-5e13-42da-9814-e9fc3ce7b2f3")
    sm_uri_2 = Uri.new(uri: "http://www.assero.co.uk/TSM#a230eecb-1580-4cc9-a1af-5e18a6eb1a19")
    sm_uri_3 = Uri.new(uri: "http://www.assero.co.uk/TSM#c2c707b1-c7a2-4ee5-a9ae-bd63a57c5314")
    sm_1 = Thesaurus::SubsetMember.find(sm_uri_1)
    sm_2 = Thesaurus::SubsetMember.find(sm_uri_2)
    sm_3 = Thesaurus::SubsetMember.find(sm_uri_3)
    result = ss.remove(sm_3.uri.to_id)
    ss = Thesaurus::Subset.find(ss_uri_1)
    sm_1 = Thesaurus::SubsetMember.find(sm_uri_1)
    sm_2 = Thesaurus::SubsetMember.find(sm_uri_2)
    expect(ss.members).to eq(sm_uri_1)
    expect(sm_1.member_next).to eq(sm_2.uri)
    expect(sm_2.member_next).to eq(nil)
    expect{Thesaurus::SubsetMember.find(sm_uri_3)}.to raise_error(Errors::NotFoundError, "Failed to find #{sm_uri_3} in Thesaurus::SubsetMember.")
    actual = ss.list_pagination({offset: 0, count: 10}).map{|x| {ordinal: x[:ordinal], uri: x[:uri]}}
    check_file_actual_expected(actual, sub_dir, "list_pagination_expected_15.yaml")
  end

  it "allows move an item, last to first, 3 items" do
    ss_uri_1 = Uri.new(uri: "http://www.assero.co.uk/TS#54176c59-b800-43f5-99c3-d129cb563b79")
    ss = init_subset(Thesaurus::Subset.find(ss_uri_1))
    sm_uri_1 = Uri.new(uri: "http://www.assero.co.uk/TSM#67871de3-5e13-42da-9814-e9fc3ce7b2f3")
    sm_uri_2 = Uri.new(uri: "http://www.assero.co.uk/TSM#a230eecb-1580-4cc9-a1af-5e18a6eb1a19")
    sm_uri_3 = Uri.new(uri: "http://www.assero.co.uk/TSM#c2c707b1-c7a2-4ee5-a9ae-bd63a57c5314")
    sm_1 = Thesaurus::SubsetMember.find(sm_uri_1)
    sm_2 = Thesaurus::SubsetMember.find(sm_uri_2)
    sm_3 = Thesaurus::SubsetMember.find(sm_uri_3)
    result = ss.move_after(sm_uri_3.to_id, nil)
    ss = Thesaurus::Subset.find(ss_uri_1)
    sm_1 = Thesaurus::SubsetMember.find(sm_uri_1)
    sm_2 = Thesaurus::SubsetMember.find(sm_uri_2)
    sm_3 = Thesaurus::SubsetMember.find(sm_uri_3)
    expect(ss.members).to eq(sm_uri_3)
    expect(sm_3.member_next).to eq(sm_1.uri)
    expect(sm_1.member_next).to eq(sm_2.uri)
    expect(sm_2.member_next).to eq(nil)
    actual = ss.list_pagination({offset: 0, count: 10}).map{|x| {ordinal: x[:ordinal], uri: x[:uri]}}
    check_file_actual_expected(actual, sub_dir, "list_pagination_expected_16.yaml")
  end

  it "allows move an item, first to last, 3 items" do
    ss_uri_1 = Uri.new(uri: "http://www.assero.co.uk/TS#54176c59-b800-43f5-99c3-d129cb563b79")
    ss = init_subset(Thesaurus::Subset.find(ss_uri_1))
    sm_uri_1 = Uri.new(uri: "http://www.assero.co.uk/TSM#67871de3-5e13-42da-9814-e9fc3ce7b2f3")
    sm_uri_2 = Uri.new(uri: "http://www.assero.co.uk/TSM#a230eecb-1580-4cc9-a1af-5e18a6eb1a19")
    sm_uri_3 = Uri.new(uri: "http://www.assero.co.uk/TSM#c2c707b1-c7a2-4ee5-a9ae-bd63a57c5314")
    sm_1 = Thesaurus::SubsetMember.find(sm_uri_1)
    sm_2 = Thesaurus::SubsetMember.find(sm_uri_2)
    sm_3 = Thesaurus::SubsetMember.find(sm_uri_3)
    result = ss.move_after(sm_uri_1.to_id, sm_uri_3.to_id)
    ss = Thesaurus::Subset.find(ss_uri_1)
    sm_1 = Thesaurus::SubsetMember.find(sm_uri_1)
    sm_2 = Thesaurus::SubsetMember.find(sm_uri_2)
    sm_3 = Thesaurus::SubsetMember.find(sm_uri_3)
    expect(ss.members).to eq(sm_uri_2)
    expect(sm_2.member_next).to eq(sm_3.uri)
    expect(sm_3.member_next).to eq(sm_1.uri)
    expect(sm_1.member_next).to eq(nil)
    actual = ss.list_pagination({offset: 0, count: 10}).map{|x| {ordinal: x[:ordinal], uri: x[:uri]}}
    check_file_actual_expected(actual, sub_dir, "list_pagination_expected_17.yaml")
  end

  it "allows move an item, moving the first to middle, 3 items" do
    ss_uri_1 = Uri.new(uri: "http://www.assero.co.uk/TS#54176c59-b800-43f5-99c3-d129cb563b79")
    ss = init_subset(Thesaurus::Subset.find(ss_uri_1))
    sm_uri_1 = Uri.new(uri: "http://www.assero.co.uk/TSM#67871de3-5e13-42da-9814-e9fc3ce7b2f3")
    sm_uri_2 = Uri.new(uri: "http://www.assero.co.uk/TSM#a230eecb-1580-4cc9-a1af-5e18a6eb1a19")
    sm_uri_3 = Uri.new(uri: "http://www.assero.co.uk/TSM#c2c707b1-c7a2-4ee5-a9ae-bd63a57c5314")
    sm_1 = Thesaurus::SubsetMember.find(sm_uri_1)
    sm_2 = Thesaurus::SubsetMember.find(sm_uri_2)
    sm_3 = Thesaurus::SubsetMember.find(sm_uri_3)
    result = ss.move_after(sm_uri_1.to_id, sm_uri_2.to_id)
    ss = Thesaurus::Subset.find(ss_uri_1)
    sm_1 = Thesaurus::SubsetMember.find(sm_uri_1)
    sm_2 = Thesaurus::SubsetMember.find(sm_uri_2)
    sm_3 = Thesaurus::SubsetMember.find(sm_uri_3)
    expect(ss.members).to eq(sm_uri_2)
    expect(sm_2.member_next).to eq(sm_1.uri)
    expect(sm_1.member_next).to eq(sm_3.uri)
    expect(sm_3.member_next).to eq(nil)
    actual = ss.list_pagination({offset: 0, count: 10}).map{|x| {ordinal: x[:ordinal], uri: x[:uri]}}
    check_file_actual_expected(actual, sub_dir, "list_pagination_expected_18.yaml")
    # Leave lines, useful for checing linking here and in other tests
    #triple_store.subject_triples(ss_uri_1)
    #triple_store.subject_triples(sm_uri_2)
    #triple_store.subject_triples(sm_uri_1)
    #triple_store.subject_triples(sm_uri_3)
  end

  it "allows move an item, moving the last to middle, 3 items" do
    ss_uri_1 = Uri.new(uri: "http://www.assero.co.uk/TS#54176c59-b800-43f5-99c3-d129cb563b79")
    ss = init_subset(Thesaurus::Subset.find(ss_uri_1))
    sm_uri_1 = Uri.new(uri: "http://www.assero.co.uk/TSM#67871de3-5e13-42da-9814-e9fc3ce7b2f3")
    sm_uri_2 = Uri.new(uri: "http://www.assero.co.uk/TSM#a230eecb-1580-4cc9-a1af-5e18a6eb1a19")
    sm_uri_3 = Uri.new(uri: "http://www.assero.co.uk/TSM#c2c707b1-c7a2-4ee5-a9ae-bd63a57c5314")
    sm_1 = Thesaurus::SubsetMember.find(sm_uri_1)
    sm_2 = Thesaurus::SubsetMember.find(sm_uri_2)
    sm_3 = Thesaurus::SubsetMember.find(sm_uri_3)
    result = ss.move_after(sm_uri_3.to_id, sm_uri_1.to_id)
    ss = Thesaurus::Subset.find(ss_uri_1)
    sm_1 = Thesaurus::SubsetMember.find(sm_uri_1)
    sm_2 = Thesaurus::SubsetMember.find(sm_uri_2)
    sm_3 = Thesaurus::SubsetMember.find(sm_uri_3)
    expect(ss.members).to eq(sm_uri_1)
    expect(sm_1.member_next).to eq(sm_3.uri)
    expect(sm_3.member_next).to eq(sm_2.uri)
    expect(sm_2.member_next).to eq(nil)
    actual = ss.list_pagination({offset: 0, count: 10}).map{|x| {ordinal: x[:ordinal], uri: x[:uri]}}
    check_file_actual_expected(actual, sub_dir, "list_pagination_expected_19.yaml")
  end

  it "allows move an item, moving the middle to last, 3 items" do
    ss_uri_1 = Uri.new(uri: "http://www.assero.co.uk/TS#54176c59-b800-43f5-99c3-d129cb563b79")
    ss = init_subset(Thesaurus::Subset.find(ss_uri_1))
    sm_uri_1 = Uri.new(uri: "http://www.assero.co.uk/TSM#67871de3-5e13-42da-9814-e9fc3ce7b2f3")
    sm_uri_2 = Uri.new(uri: "http://www.assero.co.uk/TSM#a230eecb-1580-4cc9-a1af-5e18a6eb1a19")
    sm_uri_3 = Uri.new(uri: "http://www.assero.co.uk/TSM#c2c707b1-c7a2-4ee5-a9ae-bd63a57c5314")
    sm_1 = Thesaurus::SubsetMember.find(sm_uri_1)
    sm_2 = Thesaurus::SubsetMember.find(sm_uri_2)
    sm_3 = Thesaurus::SubsetMember.find(sm_uri_3)
    result = ss.move_after(sm_uri_2.to_id, sm_uri_3.to_id)
    ss = Thesaurus::Subset.find(ss_uri_1)
    sm_1 = Thesaurus::SubsetMember.find(sm_uri_1)
    sm_2 = Thesaurus::SubsetMember.find(sm_uri_2)
    sm_3 = Thesaurus::SubsetMember.find(sm_uri_3)
    expect(ss.members).to eq(sm_uri_1)
    expect(sm_1.member_next).to eq(sm_3.uri)
    expect(sm_3.member_next).to eq(sm_2.uri)
    expect(sm_2.member_next).to eq(nil)
    actual = ss.list_pagination({offset: 0, count: 10}).map{|x| {ordinal: x[:ordinal], uri: x[:uri]}}
    check_file_actual_expected(actual, sub_dir, "list_pagination_expected_20.yaml")
  end

  it "return the list of items, paginated" do
    subset_uri_1 = Uri.new(uri: "http://www.assero.co.uk/TS#54176c59-b800-43f5-99c3-d129cbaaaaa1")
    subset = Thesaurus::Subset.find(subset_uri_1)
    actual = subset.list_pagination(offset: "0", count: "10")
    check_file_actual_expected(actual, sub_dir, "list_pagination_expected_1.yaml")
    actual = subset.list_pagination(offset: "0", count: "1")
    check_file_actual_expected(actual, sub_dir, "list_pagination_expected_2.yaml")
    actual = subset.list_pagination(offset: "1", count: "2")
    check_file_actual_expected(actual, sub_dir, "list_pagination_expected_3.yaml")
  end

  it "find_mc"  do
    expect(Thesaurus::ManagedConcept).to receive(:generated_identifier?).twice.and_return(true)
    expect(Thesaurus::ManagedConcept).to receive(:new_identifier).and_return("A000001")
    expected_mc = Thesaurus::ManagedConcept.create
    subset = Thesaurus::Subset.create(parent_uri: expected_mc.uri)
    expected_mc.is_ordered = subset
    expected_mc = Thesaurus::ManagedConcept.find(expected_mc.uri)
    expected_mc.is_ordered = subset
    expected_mc.save
    mc = subset.find_mc
    expect(mc.uri).to eq(expected_mc.uri)
  end

  it "allows delete the subset list" do
    subset_uri_1 = Uri.new(uri: "http://www.assero.co.uk/TS#54176c59-b800-43f5-99c3-d129cb563b79")
    subset = Thesaurus::Subset.find(subset_uri_1)
    ct = Thesaurus.create({label: "Test Terminology", identifier: "TT"})
    mc = ct.add_child({})
    mc = Thesaurus::ManagedConcept.find(mc.id)
    mc.add_link(:is_ordered, subset.uri)
    mc.save
    subset
    result = subset.delete
    expect{Thesaurus::Subset.find(subset.uri)}.to raise_error(Errors::NotFoundError, "Failed to find http://www.assero.co.uk/TS#54176c59-b800-43f5-99c3-d129cb563b79 in Thesaurus::Subset.")
  end

  it "allows add a new item/items to the list" do
    subset = Thesaurus::Subset.find(Uri.new(uri: "http://www.assero.co.uk/TS#e052799d-bd92-472d-8a39-68c582a66834"))
    mc = Thesaurus::ManagedConcept.find_full(Uri.new(uri: "http://www.acme-pharma.com/C66781S/V1#C66781S"))
    tc_2 = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C66781/V2#C66781_C25529"))
    tc_4 = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C66781/V2#C66781_C29844"))
    expect(mc.narrower.count).to eq(3)
    result = subset.add([tc_2.id, tc_4.id])
    subset = Thesaurus::Subset.find(Uri.new(uri: "http://www.assero.co.uk/TS#e052799d-bd92-472d-8a39-68c582a66834"))
    mc = Thesaurus::ManagedConcept.find_full(Uri.new(uri: "http://www.acme-pharma.com/C66781S/V1#C66781S"))
    expect(mc.narrower.count).to eq(5)
    last_sm = Thesaurus::SubsetMember.find(Uri.new(uri: "http://www.assero.co.uk/TSM#d224cb14-5282-4641-9d49-2ec4e3b38087"))
    expect(last_sm.member_next).not_to be(nil)  
    last_sm_member_next = Thesaurus::SubsetMember.find(last_sm.member_next)
    expect(last_sm_member_next.item).to eq(tc_2.uri)  
    expect(last_sm_member_next.member_next).not_to be(nil)
    last_sm_member_next_next = Thesaurus::SubsetMember.find(last_sm_member_next.member_next)
    expect(last_sm_member_next_next.item).to eq(tc_4.uri)  
    expect(last_sm_member_next_next.member_next).to eq(nil) 
  end

  it "allows remove all" do
    subset = Thesaurus::Subset.find(Uri.new(uri: "http://www.assero.co.uk/TS#e052799d-bd92-472d-8a39-68c582a66834"))
    subset_member1 = Thesaurus::SubsetMember.find(Uri.new(uri: "http://www.assero.co.uk/TSM#45d17b77-4920-46e2-94c4-d801ca2251ab"))
    subset_member2 = Thesaurus::SubsetMember.find(Uri.new(uri: "http://www.assero.co.uk/TSM#9f34acbe-2d66-416c-9572-cf03bb77d81a"))
    subset_member3 = Thesaurus::SubsetMember.find(Uri.new(uri: "http://www.assero.co.uk/TSM#d224cb14-5282-4641-9d49-2ec4e3b38087"))
    mc = Thesaurus::ManagedConcept.find_full(Uri.new(uri: "http://www.acme-pharma.com/C66781S/V1#C66781S"))
    expect(mc.narrower.count).to eq(3)
    result = subset.remove_all
    mc = Thesaurus::ManagedConcept.find_full(Uri.new(uri: "http://www.acme-pharma.com/C66781S/V1#C66781S"))
    expect{Thesaurus::SubsetMember.find(subset_member1.uri)}.to raise_error(Errors::NotFoundError, "Failed to find http://www.assero.co.uk/TSM#45d17b77-4920-46e2-94c4-d801ca2251ab in Thesaurus::SubsetMember.")
    expect{Thesaurus::SubsetMember.find(subset_member2.uri)}.to raise_error(Errors::NotFoundError, "Failed to find http://www.assero.co.uk/TSM#9f34acbe-2d66-416c-9572-cf03bb77d81a in Thesaurus::SubsetMember.")
    expect{Thesaurus::SubsetMember.find(subset_member3.uri)}.to raise_error(Errors::NotFoundError, "Failed to find http://www.assero.co.uk/TSM#d224cb14-5282-4641-9d49-2ec4e3b38087 in Thesaurus::SubsetMember.")
    expect(mc.narrower.count).to eq(0)   
  end

  it "delete_subset"  do
    subset_uri_1 = Uri.new(uri: "http://www.assero.co.uk/TS#54176c59-b800-43f5-99c3-d129cb563b79")
    subset = Thesaurus::Subset.find(subset_uri_1)
    result = subset.delete
    expect{Thesaurus::Subset.find(subset.uri)}.to raise_error(Errors::NotFoundError,
        "Failed to find http://www.assero.co.uk/TS#54176c59-b800-43f5-99c3-d129cb563b79 in Thesaurus::Subset.")
  end

  it "validates a valid object" do
    result = Thesaurus::Subset.new
    result.uri = Uri.new(uri: "http://www.assero.co.uk/X/V1#F-ACME_OR_G1_I1")
    expect(result.valid?).to eq(true)
  end

  it "does not validate an invalid object, text label" do
    result = Thesaurus::Subset.new
    result.label = "Draft 123 more tesxt €"
    expect(result.valid?).to eq(false)
  end

  it "allows the object to be initialized from hash" do
    result =
      {
        :uri => "http://www.assero.co.uk/X/V1#F-ACME_OR_G1_I1",
        :id => Uri.new(uri:  "http://www.assero.co.uk/X/V1#F-ACME_OR_G1_I1").to_id,
        :label => "First member",
        :members => "http://www.assero.co.uk/X/V1#M1",
        :rdf_type => "http://www.assero.co.uk/Thesaurus#Subset"
      }
    item = Thesaurus::Subset.from_h(result)
    expect(item.to_h).to eq(result)
  end

  it "allows an object to be exported as SPARQL" do
    sparql = Sparql::Update.new
    item = Thesaurus::Subset.new
    item.label = "TEST"
    item.members = Uri.new({:fragment => "member", :namespace => "http://www.example.com/path"})
    item.uri = Uri.new({:fragment => "parent", :namespace => "http://www.example.com/path"})
    item.to_sparql(sparql)
  #Xwrite_text_file_2(sparql.to_create_sparql, sub_dir, "to_create_sparql_expected.txt")
    check_sparql_no_file(sparql.to_create_sparql, "to_create_sparql_expected.txt")
  end

end

describe "Thesaurus Subset Item List and Clone" do

  include DataHelpers
  include SparqlHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/thesaurus/subset"
  end

  before :all do    
    NameValue.destroy_all
    NameValue.create(name: "thesaurus_parent_identifier", value: "123")
    NameValue.create(name: "thesaurus_child_identifier", value: "456")
    IsoHelpers.clear_cache
  end

  before :each do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
    load_cdisc_term_versions(1..2)
    @cl_1 = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri:"http://www.cdisc.org/C66781/V2#C66781"))
    @tc_1 = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C66781/V2#C66781_C25301"))
    @tc_2 = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C66781/V2#C66781_C25529"))
    @tc_3 = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C66781/V2#C66781_C29846"))
    @tc_4 = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C66781/V2#C66781_C29844"))
    @tc_5 = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C66781/V2#C66781_C29848"))
  end

  after :all do
    delete_all_public_test_files
  end

  it "creates some test data" do
    tc_1 = Thesaurus::ManagedConcept.from_h({
      label: "A subset",
      identifier: "C66781S",
      definition: "A definition",
      notation: "SUB"
    })
    tc_1.preferred_term = Thesaurus::PreferredTerm.new(label:"A subset")
    subset = Thesaurus::Subset.new
    subset.uri = subset.create_uri(tc_1.uri)
    sm_1 = Thesaurus::SubsetMember.new
    sm_1.item = @tc_1
    sm_1.uri = sm_1.create_uri(subset.uri)
    sm_2 = Thesaurus::SubsetMember.new
    sm_2.item = @tc_3
    sm_2.uri = sm_2.create_uri(subset.uri)
    sm_3 = Thesaurus::SubsetMember.new
    sm_3.item = @tc_5
    sm_3.uri = sm_3.create_uri(subset.uri)
    sm_1.member_next = sm_2
    sm_2.member_next = sm_3
    subset.members = sm_1
    sm_1.save
    sm_2.save
    sm_3.save
    subset.save
    tc_1.subsets = @cl_1
    tc_1.is_ordered = subset
    tc_1.narrower << @tc_1
    tc_1.narrower << @tc_3
    tc_1.narrower << @tc_5
    tc_1.set_initial("C66781S")
    sparql = Sparql::Update.new
    sparql.default_namespace(tc_1.uri.namespace)
    tc_1.to_sparql(sparql, true)
    subset.to_sparql(sparql)
    sm_1.to_sparql(sparql)
    sm_2.to_sparql(sparql)
    sm_3.to_sparql(sparql)
    file = sparql.to_file
  #Xcopy_file_from_public_files_rename("test", file.basename, sub_dir, "subsets_clone_1.ttl")
  end

  it "returns list of URIs" do
    base_uri = Uri.new(uri: "http://www.example.com/a#b")
    subset = Thesaurus::Subset.new
    subset.uri = subset.create_uri(base_uri)
    subset.save
    
    # Empty
    actual = subset.list_uris
    expect(actual.count).to eq(0)
    check_file_actual_expected(actual, sub_dir, "list_uris_expected_1.yaml", equate_method: :hash_equal)
    
    # 1 item
    sm_1 = Thesaurus::SubsetMember.new
    sm_1.item = @tc_1
    sm_1.uri = sm_1.create_uri(base_uri)
    sm_1.save
    subset.members = sm_1
    subset.save
    actual = subset.list_uris
    expect(actual.count).to eq(1)
    check_file_actual_expected(actual, sub_dir, "list_uris_expected_2.yaml", equate_method: :hash_equal)
    
    # 2 items
    sm_2 = Thesaurus::SubsetMember.new
    sm_2.item = @tc_2
    sm_2.uri = sm_2.create_uri(base_uri)
    sm_2.save
    sm_1.member_next = sm_2
    sm_1.save
    actual = subset.list_uris
    expect(actual.count).to eq(2)
    check_file_actual_expected(actual, sub_dir, "list_uris_expected_3.yaml", equate_method: :hash_equal)

    # 3 items
    sm_3 = Thesaurus::SubsetMember.new
    sm_3.item = @tc_3
    sm_3.uri = sm_3.create_uri(base_uri)
    sm_3.save
    sm_2.member_next = sm_3
    sm_2.save
    actual = subset.list_uris
    expect(actual.count).to eq(3)
    check_file_actual_expected(actual, sub_dir, "list_uris_expected_4.yaml", equate_method: :hash_equal)
  end

  def check_members(a, e, count)
    actual = a.list_uris.map{|x| x[:uri].to_s}
    expected = e.list_uris.map{|x| x[:uri].to_s}
    expect(actual.count).to eq(count)
    expect(actual).to match_array(expected)
  end

  it "clone, empty" do
    base_uri = Uri.new(uri: "http://www.example.com/a#b0")
    subset = Thesaurus::Subset.new
    subset.uri = subset.create_uri(base_uri)
    subset.save
    cloned = subset.clone
    cloned.uri = Uri.new(uri: "http://www.example.com/a#c0")
    cloned.create_or_update(:create, true)
    check_members(subset, cloned, 0)
  end

  it "clone, 1 item" do
    base_uri = Uri.new(uri: "http://www.example.com/a#b1")
    subset = Thesaurus::Subset.new
    subset.uri = subset.create_uri(base_uri)
    subset.save
    sm_1 = Thesaurus::SubsetMember.new
    sm_1.item = @tc_1
    sm_1.uri = sm_1.create_uri(base_uri)
    sm_1.save
    subset.members = sm_1
    subset.save
    cloned = subset.clone
    cloned.create_or_update(:create, true)
    check_members(subset, cloned, 1)
  end

  it "clone, 2 items" do
    base_uri = Uri.new(uri: "http://www.example.com/a#b2")
    subset = Thesaurus::Subset.new
    subset.uri = subset.create_uri(base_uri)
    subset.save
    sm_1 = Thesaurus::SubsetMember.new
    sm_1.item = @tc_1
    sm_1.uri = sm_1.create_uri(base_uri)
    sm_1.save
    sm_2 = Thesaurus::SubsetMember.new
    sm_2.item = @tc_2
    sm_2.uri = sm_2.create_uri(base_uri)
    sm_2.save
    sm_1.member_next = sm_2
    sm_1.save
    subset.members = sm_1
    subset.save
    cloned = subset.clone
    cloned.uri = Uri.new(uri: "http://www.example.com/a#c2")
    cloned.create_or_update(:create, true)
    check_members(subset, cloned, 2)
  end

  it "clone, 3 items" do    
    base_uri = Uri.new(uri: "http://www.example.com/a#b3")
    subset = Thesaurus::Subset.new
    subset.uri = subset.create_uri(base_uri)
    subset.save
    sm_1 = Thesaurus::SubsetMember.new
    sm_1.item = @tc_1
    sm_1.uri = sm_1.create_uri(base_uri)
    sm_1.save
    sm_2 = Thesaurus::SubsetMember.new
    sm_2.item = @tc_2
    sm_2.uri = sm_2.create_uri(base_uri)
    sm_2.save
    sm_3 = Thesaurus::SubsetMember.new
    sm_3.item = @tc_3
    sm_3.uri = sm_3.create_uri(base_uri)
    sm_3.save
    sm_1.member_next = sm_2
    sm_1.save
    sm_2.member_next = sm_3
    sm_2.save
    subset.members = sm_1
    subset.save
    cloned = subset.clone
    cloned.uri = Uri.new(uri: "http://www.example.com/a#c3")
    cloned.create_or_update(:create, true)
    check_members(subset, cloned, 3)    
  end

end
