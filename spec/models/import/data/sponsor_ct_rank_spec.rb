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
    puts colourize("Db - Rank=#{db_a - rank_a}", "blue")
    puts colourize("Rank - Db=#{rank_a - db_a}", "blue")
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
  copy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "ranks_V#{version}.ttl")
  end

  def match_cl_items(cl, code_list)
    results = []
    puts colourize("    #{cl.identifier}", "blue")
    cl.narrower_objects
    items = code_list[:items].sort_by{|x| x[:rank]}
    matching_identifiers(cl.narrower, items)
    items.each do |item|
      puts colourize("      Looking for #{item[:code]}", "blue")
      cli = match_cli(cl, item)
      return [] unless cli_valid?(cli)
      results << {cli: cli.uri, rank: item[:rank]}
    end
    results
  end

  def cl_valid?(cl)
    puts colourize("***** CL not found! *****", "red") if cl.nil?
    !cl.nil?
  end

  def match_cl(notation, long_name)
    saved_cl = []
    puts colourize("CL looking for '#{notation}' & '#{long_name}'", "blue")
    cl = Thesaurus::ManagedConcept.where(notation: notation)
    return nil if cl.count == 0
    return cl.first if cl.count == 1
    puts colourize("    Multiple found", "red")
    cl.each do |x|
      y = x.class.find_with_properties(x.uri)
      puts colourize("      Checking #{x.identifier}, #{y.owner_short_name}", "red")
      #return y if y.owned?
      saved_cl << y if y.owned?
    end
    if saved_cl.empty?
      puts colourize("    ***** None found *****", "red")
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

  it "2.6 rank extension", :speed => 'slow' do
    results = []
    load_data_file_into_triple_store("sponsor_one/ct/CT_V2-6.ttl")
    code_lists = read_yaml_file(sub_dir, "rank_V2-6.yaml")
    code_lists.each do |code_list|
      cl = match_cl(code_list[:codelist_short_name], code_list[:codelist_long_name])
      next unless cl_valid?(cl)
      results << {cl: cl.uri, items: match_cl_items(cl, code_list)}
    end
    create_ranks(results, "2-6")
  end

  it "3.0 rank extension", :speed => 'slow' do
    results = []
    load_data_file_into_triple_store("sponsor_one/ct/CT_V2-6.ttl")
    load_data_file_into_triple_store("sponsor_one/ct/CT_V3-0.ttl")
    code_lists = read_yaml_file(sub_dir, "rank_V3-0.yaml")
    code_lists.each do |code_list|
      cl = match_cl(code_list[:codelist_short_name], code_list[:codelist_long_name])
      next unless cl_valid?(cl)
      results << {cl: cl.uri, items: match_cl_items(cl, code_list)}
    end
    create_ranks(results, "3-0")
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

  it "QC check", :speed => 'slow' do
    load_local_file_into_triple_store(sub_dir, "ranks_V2-6.ttl")
    load_local_file_into_triple_store(sub_dir, "ranks_V3-0.ttl")
    results = ranked
    check_file_actual_expected(results, sub_dir, "ranked_expected_1.yaml", equate_method: :hash_equal, write_file: true)
  end

end