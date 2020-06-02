require 'rails_helper'
require 'csv'

describe "Import::SponsorTermFormatOne" do
	
	include DataHelpers
  include ImportHelpers
  include PublicFileHelpers
  include SparqlHelpers
  include ThesauriHelpers
  include InstallationHelpers
  
	def sub_dir
    return "models/import/data/sponsor_one/ct"
  end

	before :all do
    select_installation(:thesauri, :sanofi)
  end

  before :each do
    load_files(schema_files, [])
    load_data_file_into_triple_store("mdr_sponsor_one_identification.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems_process.ttl")
    load_cdisc_term_versions(1..62)
    delete_all_public_test_files
  end

  after :each do
    delete_all_public_test_files
  end

  after :all do
    restore_installation(:thesauri)
  end

  def matching_identifiers(db_cli, rank_cli)
    db_a = db_cli.map{|x| x.identifier}
    rank_a = rank_cli.map{|x| x[:code]}
    #puts colourize("Db - Rank=#{db_a - rank_a}", "blue")
    #puts colourize("Rank - Db=#{rank_a - db_a}", "blue")
  end

  def create_ranks(results, version)
    sparql = Sparql::Update.new
    sparql.default_namespace(Thesaurus::Rank.base_uri)
    results.each do |result|
      result[:items].each do |cli|
        cli[:object] = Thesaurus::RankMember.new(item: cli[:cli], rank: cli[:rank])
        cli[:object].uri = cli[:object].create_uri(Thesaurus::RankMember.base_uri)  
      end
      previous = nil
      result[:items].reverse.each do |cli|
        cli[:object].member_next = previous
        previous = cli[:object].uri
      end
      list = Thesaurus::Rank.new(members: result[:items].first[:object].uri)
      list.uri = list.create_uri(result[:cl])  
      sparql.add({uri: result[:cl]}, {prefix: :th, fragment: "isRanked"}, {uri: list.uri})
      list.to_sparql(sparql)
      result[:items].each {|cli| cli[:object].to_sparql(sparql)}
    end
    full_path = sparql.to_file
  #Xcopy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "ranks_V#{version}.ttl")
  end

  def match_cl_items(cl, code_list)
    results = []
    #puts colourize("    #{cl.identifier}", "blue")
    cl.narrower_objects
    items = code_list[:items].sort_by{|x| x[:rank]}
    matching_identifiers(cl.narrower, items)
    items.each do |item|
      #puts colourize("      Looking for #{item[:code]}", "blue")
      cli = match_cli(cl, item)
      return [] unless cli_valid?(cli)
      results << {cli: cli.uri, rank: item[:rank]}
    end
    results
  end

  def cl_valid?(cl_notation, cl_label, cl)
    puts colourize("CL '#{cl_notation}', '#{cl_label}' not found!", "red") if cl.nil?
    !cl.nil?
  end

  def match_cl(notation, long_name)
    saved_cl = []
    puts colourize("CL looking for '#{notation}' & '#{long_name}'", "blue")
    cl = Thesaurus::ManagedConcept.where(notation: notation)
    return nil if cl.count == 0
    if cl.count == 1
      x = cl.first
      y = x.class.find_with_properties(x.uri)
      return y.owned? ? y : nil
    end
    #puts colourize("    Multiple found", "red")
    cl.each do |x|
      y = x.class.find_with_properties(x.uri)
      #puts colourize("      Checking #{x.identifier}, #{y.owner_short_name}", "red")
      #return y if y.owned?
      saved_cl << y if y.owned?
    end
    if saved_cl.empty?
      #puts colourize("    ***** None found *****", "red")
      return nil 
    else
      saved_cl.sort_by{|x| x.version}.last
    end
  end

  def match_cli(cl, item)
    code = item[:code].dup
    cli = cl.narrower.find{|x| x.identifier == code}
    return cli unless cli.nil?
    return nil unless sc_code?(code)
    cl.narrower.find{|x| x.identifier == code[1..-1]}
  rescue => e
    byebug
  end

  def cli_valid?(cli)
    puts colourize("***** CLI not found! *****", "red") if cli.nil?
    !cli.nil?
  end

  def sc_code?(code)
    return true if code.start_with?("SC")
    puts colourize("***** Unrecognized code '#{code}' *****", "red")
    false
  rescue => e
    byebug
  end

  def process_code_lists(code_lists, ignore)
    results = []
    code_lists.each do |code_list|
      next if ignore.include?(code_list[:codelist_short_name])
      cl = match_cl(code_list[:codelist_short_name], code_list[:codelist_long_name])
      next unless cl_valid?(code_list[:codelist_short_name], code_list[:codelist_long_name], cl)
      results << {cl: cl.uri, items: match_cl_items(cl, code_list)}
    end
    results
  end

  def ranked
    query_string = %Q{
      SELECT ?cl ?item ?rank WHERE 
      {
        ?m th:rank ?rank .
        ?m th:item ?item .
        {
          SELECT ?cl ?m WHERE 
          {
            ?cl th:isRanked ?list .
            ?list th:members/th:memberNext* ?mid . 
            ?mid th:memberNext* ?m .
          } GROUP BY ?cl ?m
        }
      } ORDER BY ?cl ?rank
    }
    query_results = Sparql::Query.new.query(query_string, "", [:th]) 
    query_results.by_object_set([:cl, :item, :rank]).map{|x| {code_list: x[:cl].to_s, item: x[:item].to_s, rank: x[:rank]}}
  end

  def check_ranks(code_lists)
    results = []
    code_lists.each do |identifier|
      cls = Thesaurus::ManagedConcept.where(identifier: identifier)
      owned = []
      cls.each do |x|
        y = x.class.find_with_properties(x.uri)
        next unless y.owned? 
        owned << y
      end
      owned.each do |cl|
        ranks = cl.children_pagination({offset: "0", count: "10000"}).map{|x| {identifier: x[:identifier], notation: x[:notation], rank: x[:rank].to_i}}
        results << {
          identifier: cl.identifier, 
          semantic_version: cl.semantic_version, 
          ranked: cl.ranked?,
          children: ranks.sort_by{|x| x[:rank]}
        }
      end
    end
    results
  end

  def check_cls(code_lists, uri)
    puts colourize("\n\nCT: #{uri}\n", "blue")
    results = []
    ct = Thesaurus.find_minimum(uri)
    code_lists.each do |identifier|
      cls = ct.find_by_identifiers([identifier])
      cl = Thesaurus::ManagedConcept.find_minimum(cls[identifier])
      results << cl.uri if cl.owned? 
      puts colourize("CL: #{cl.uri}", cl.owned? ? "blue" : "red")
    end
    results
  end

  def set_extension_no_e(tc)
    source = Thesaurus::ManagedConcept.find_full(tc.id)
    source.narrower_links
    object = source.clone
    object.identifier = "#{source.scoped_identifier}"
    object.extensible = false # Make sure we cannot extend the extension
    object.set_initial(object.identifier)
    object.has_state.registration_status = IsoRegistrationStateV2.released_state
    object.has_state.previous_state = IsoRegistrationStateV2.released_state
    return nil unless object.valid?(:create) && object.create_permitted?
    object.extends = source.uri
    object
  end

  def update_26_ct_refs
    sparql = Sparql::Update.new
    sparql_update = %Q{
      DELETE
      {
        <http://www.sanofi.com/2019_R1/V1#TH> th:isTopConcept <http://www.cdisc.org/C66784/V34#C66784> .
        <http://www.sanofi.com/2019_R1/V1#TH> th:isTopConcept <http://www.cdisc.org/C87162/V33#C87162> .
        <http://www.sanofi.com/2019_R1/V1#TH> th:isTopConcept <http://www.cdisc.org/C66768/V28#C66768> .
        <http://www.sanofi.com/2019_R1/V1#TH> th:isTopConcept <http://www.cdisc.org/C66769/V17#C66769> .
        ?s1 bo:reference <http://www.cdisc.org/C66784/V34#C66784> .
        ?s2 bo:reference <http://www.cdisc.org/C87162/V33#C87162> .
        ?s3 bo:reference <http://www.cdisc.org/C66768/V28#C66768> .
        ?s4 bo:reference <http://www.cdisc.org/C66769/V17#C66769> 
      }      
      INSERT 
      {
        <http://www.sanofi.com/2019_R1/V1#TH> th:isTopConcept <http://www.sanofi.com/C66784/V1#C66784> .
        <http://www.sanofi.com/2019_R1/V1#TH> th:isTopConcept <http://www.sanofi.com/C87162/V1#C87162> .
        <http://www.sanofi.com/2019_R1/V1#TH> th:isTopConcept <http://www.sanofi.com/C66768/V1#C66768> .
        <http://www.sanofi.com/2019_R1/V1#TH> th:isTopConcept <http://www.sanofi.com/C66769/V1#C66769> .
        ?s1 bo:reference <http://www.sanofi.com/C66784/V1#C66784> .
        ?s2 bo:reference <http://www.sanofi.com/C87162/V1#C87162> .
        ?s3 bo:reference <http://www.sanofi.com/C66768/V1#C66768> .
        ?s4 bo:reference <http://www.sanofi.com/C66769/V1#C66769> 
      }
      WHERE 
      {
        <http://www.sanofi.com/2019_R1/V1#TH> th:isTopConceptReference ?s1 .
        ?s1 bo:reference <http://www.cdisc.org/C66784/V34#C66784> .
        <http://www.sanofi.com/2019_R1/V1#TH> th:isTopConceptReference ?s2 .
        ?s2 bo:reference <http://www.cdisc.org/C87162/V33#C87162> .
        <http://www.sanofi.com/2019_R1/V1#TH> th:isTopConceptReference ?s3 .
        ?s3 bo:reference <http://www.cdisc.org/C66768/V28#C66768> .
        <http://www.sanofi.com/2019_R1/V1#TH> th:isTopConceptReference ?s4 .
        ?s4 bo:reference <http://www.cdisc.org/C66769/V17#C66769>
      }      
    }
    sparql.sparql_update(sparql_update, "", [:th, :bo])
  end

  def update_30_ct_refs
    sparql = Sparql::Update.new
    sparql_update = %Q{
      DELETE
      {
        <http://www.sanofi.com/2019_R1/V1#TH> th:isTopConcept <http://www.cdisc.org/C66784/V34#C66784> .
        <http://www.sanofi.com/2019_R1/V1#TH> th:isTopConcept <http://www.cdisc.org/C87162/V33#C87162> .
        <http://www.sanofi.com/2019_R1/V1#TH> th:isTopConcept <http://www.cdisc.org/C66768/V28#C66768> .
        <http://www.sanofi.com/2019_R1/V1#TH> th:isTopConcept <http://www.cdisc.org/C66769/V17#C66769> .
        ?s1 bo:reference <http://www.cdisc.org/C66784/V34#C66784> .
        ?s2 bo:reference <http://www.cdisc.org/C87162/V33#C87162> .
        ?s3 bo:reference <http://www.cdisc.org/C66768/V28#C66768> .
        ?s4 bo:reference <http://www.cdisc.org/C66769/V17#C66769> .
        <http://www.sanofi.com/2020_R1/V1#TH> th:isTopConcept <http://www.cdisc.org/C66768/V28#C66768> .
        <http://www.sanofi.com/2020_R1/V1#TH> th:isTopConcept <http://www.cdisc.org/C66769/V17#C66769> .
        ?s5 bo:reference <http://www.cdisc.org/C66768/V28#C66768> .
        ?s6 bo:reference <http://www.cdisc.org/C66769/V17#C66769> 
      }      
      INSERT 
      {
        <http://www.sanofi.com/2019_R1/V1#TH> th:isTopConcept <http://www.sanofi.com/C66784/V1#C66784> .
        <http://www.sanofi.com/2019_R1/V1#TH> th:isTopConcept <http://www.sanofi.com/C87162/V1#C87162> .
        <http://www.sanofi.com/2019_R1/V1#TH> th:isTopConcept <http://www.sanofi.com/C66768/V1#C66768> .
        <http://www.sanofi.com/2019_R1/V1#TH> th:isTopConcept <http://www.sanofi.com/C66769/V1#C66769> .
        ?s1 bo:reference <http://www.sanofi.com/C66784/V1#C66784> .
        ?s2 bo:reference <http://www.sanofi.com/C87162/V1#C87162> .
        ?s3 bo:reference <http://www.sanofi.com/C66768/V1#C66768> .
        ?s4 bo:reference <http://www.sanofi.com/C66769/V1#C66769> .
        <http://www.sanofi.com/2020_R1/V1#TH> th:isTopConcept <http://www.sanofi.com/C66768/V1#C66768> .
        <http://www.sanofi.com/2020_R1/V1#TH> th:isTopConcept <http://www.sanofi.com/C66769/V1#C66769> .
        ?s5 bo:reference <http://www.sanofi.com/C66768/V1#C66768> .
        ?s6 bo:reference <http://www.sanofi.com/C66769/V1#C66769> 
      }
      WHERE 
      {
        <http://www.sanofi.com/2019_R1/V1#TH> th:isTopConceptReference ?s1 .
        ?s1 bo:reference <http://www.cdisc.org/C66784/V34#C66784> .
        <http://www.sanofi.com/2019_R1/V1#TH> th:isTopConceptReference ?s2 .
        ?s2 bo:reference <http://www.cdisc.org/C87162/V33#C87162> .
        <http://www.sanofi.com/2019_R1/V1#TH> th:isTopConceptReference ?s3 .
        ?s3 bo:reference <http://www.cdisc.org/C66768/V28#C66768> .
        <http://www.sanofi.com/2019_R1/V1#TH> th:isTopConceptReference ?s4 .
        ?s4 bo:reference <http://www.cdisc.org/C66769/V17#C66769> .
        <http://www.sanofi.com/2020_R1/V1#TH> th:isTopConceptReference ?s5 .
        ?s5 bo:reference <http://www.cdisc.org/C66768/V28#C66768> .
        <http://www.sanofi.com/2020_R1/V1#TH> th:isTopConceptReference ?s6 .
        ?s6 bo:reference <http://www.cdisc.org/C66769/V17#C66769>
      }      
    }
    sparql.sparql_update(sparql_update, "", [:th, :bo])
  end

  it "contructs new extensions", :speed => 'slow' do
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V43#TH"))
    sparql = Sparql::Update.new
    sparql.default_namespace(ct.uri.namespace)
    ["C66784", "C87162", "C66768", "C66769"].each do |identifier|
      results = ct.find_by_identifiers([identifier])
  puts "URI: #{results[identifier]}"
      tc = Thesaurus::ManagedConcept.find_minimum(results[identifier])
      new_object = set_extension_no_e(tc)
      new_object.to_sparql(sparql, true)
    end
    full_path = sparql.to_file
  #Xcopy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "rank_extensions_V2-6.ttl")
  end

  it "checks new migration v2.6", :speed => 'slow' do
    write_file = false
    load_data_file_into_triple_store("sponsor_one/ct/CT_V2-6.ttl")
    load_local_file_into_triple_store(sub_dir, "rank_extensions_V2-6.ttl")
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.sanofi.com/2019_R1/V1#TH"))
    count = triple_store.triple_count
    cl_count = count_cl(ct)
    cli_count = count_cli(ct)
    cli_distinct_count = count_distinct_cli(ct)
    update_26_ct_refs
    expect(triple_store.triple_count).to eq(count)
    expect(count_cl(ct)).to eq(cl_count)
    expect(count_cli(ct)).to eq(cli_count)
    expect(count_distinct_cli(ct)).to eq(cli_distinct_count)
    results = []
    ["C66784", "C87162", "C66768", "C66769"].each do |identifier|
      uri = ct.find_by_identifiers([identifier])[identifier]
      tc = Thesaurus::ManagedConcept.find_full(uri).to_h
      results << tc
    end
    check_file_actual_expected(results, sub_dir, "migration_expected_1.yaml", equate_method: :hash_equal, write_file: write_file)
  end

  it "rank extension v2.6", :speed => 'slow' do
    load_data_file_into_triple_store("sponsor_one/ct/CT_V2-6.ttl")
    load_local_file_into_triple_store(sub_dir, "rank_extensions_V2-6.ttl")
    update_26_ct_refs
    config = read_yaml_file(sub_dir, "rank_V2-6.yaml")
    code_lists = config[:codelists]
    ignore = config[:ignore]
    results = process_code_lists(code_lists, ignore)
    create_ranks(results, "2-6")
  end

  it "rank extension v3.0", :speed => 'slow' do
    load_data_file_into_triple_store("sponsor_one/ct/CT_V2-6.ttl")
    load_data_file_into_triple_store("sponsor_one/ct/CT_V3-0.ttl")
    load_local_file_into_triple_store(sub_dir, "rank_extensions_V2-6.ttl")
    update_30_ct_refs
    config = read_yaml_file(sub_dir, "rank_V3-0.yaml")
    code_lists = config[:codelists]
    ignore = config[:ignore]
    results = process_code_lists(code_lists, ignore)
    create_ranks(results, "3-0")
  end

  it "QC check I, Duplicates", :speed => 'slow' do
    write_file = false
    check_hash = Hash.new {|h,k| h[k] = []}
    load_local_file_into_triple_store(sub_dir, "ranks_V2-6.ttl")
    load_local_file_into_triple_store(sub_dir, "ranks_V3-0.ttl")
    update_30_ct_refs
    results = ranked
    results.each do |result|
      key = "#{result[:code_list]}.#{result[:item]}"
      check_hash[key] << result[:rank]
      puts colourize("Duplicate found. '#{result[:code_list]}', '#{result[:item]}' = [#{check_hash[key]}]", "red") if check_hash[key].count > 1
    end
    check_file_actual_expected(results, sub_dir, "ranked_expected_1.yaml", equate_method: :hash_equal, write_file: write_file)
    check_file_actual_expected(check_hash, sub_dir, "ranked_duplicates_expected_1.yaml", equate_method: :hash_equal, write_file: write_file)
  end

  it "QC check II, CLs as Expected", :speed => 'slow' do
    write_file = false
    load_data_file_into_triple_store("sponsor_one/ct/CT_V2-6.ttl")
    load_data_file_into_triple_store("sponsor_one/ct/CT_V3-0.ttl")
    load_local_file_into_triple_store(sub_dir, "ranks_V2-6.ttl")
    load_local_file_into_triple_store(sub_dir, "ranks_V3-0.ttl")
    load_local_file_into_triple_store(sub_dir, "rank_extensions_V2-6.ttl")
    update_30_ct_refs
    code_lists = []
    ["rank_V2-6.yaml", "rank_V3-0.yaml"].each_with_index do |file|
      config = read_yaml_file(sub_dir, file)
      code_lists = code_lists + config[:codelists].map{|x| x[:codelist_code]}
    end
    results = check_ranks(code_lists.uniq!)
    check_file_actual_expected(results, sub_dir, "children_ranked_expected.yaml", equate_method: :hash_equal, write_file: write_file)
  end

  it "QC check III, URIs as Expected", :speed => 'slow' do
    write_file = false
    load_data_file_into_triple_store("sponsor_one/ct/CT_V2-6.ttl")
    load_data_file_into_triple_store("sponsor_one/ct/CT_V3-0.ttl")
    load_local_file_into_triple_store(sub_dir, "ranks_V2-6.ttl")
    load_local_file_into_triple_store(sub_dir, "ranks_V3-0.ttl")
    load_local_file_into_triple_store(sub_dir, "rank_extensions_V2-6.ttl")
    update_30_ct_refs
    code_lists = []
    results = {}
    {"rank_V2-6.yaml" => "http://www.sanofi.com/2019_R1/V1#TH", "rank_V3-0.yaml" => "http://www.sanofi.com/2020_R1/V1#TH"}.each do |file, uri|
      config = read_yaml_file(sub_dir, file)
      code_lists = config[:codelists].map{|x| x[:codelist_code]}
      results[uri] = check_cls(code_lists, Uri.new(uri: uri)).map{|x| x.to_s}
      expect(code_lists.count).to eq(results[uri].count)
    end
    check_file_actual_expected(results, sub_dir, "code_lists_expected.yaml", equate_method: :hash_equal, write_file: write_file)
  end
  
end