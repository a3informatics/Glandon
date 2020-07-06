require 'rails_helper'
require 'rake'

describe 'R3.1.0 schema migration' do
 
  before :all do
    Rails.application.load_tasks  
  end

  def sub_dir
    return "tasks/r3_1_0/update"
  end

  describe 'R3.1.0 schema migration' do
    
    before :all do
      clear_triple_store
      load_local_file_into_triple_store(sub_dir, "sponsor_one_1.nq.gz")
      @ct_26 = Thesaurus.find_minimum(Uri.new(uri: "http://www.sanofi.com/2019_R1/V1#TH"))
      @ct_30 = Thesaurus.find_minimum(Uri.new(uri: "http://www.sanofi.com/2020_R1/V1#TH"))
      Rake::Task['r3_1_0:schema'].invoke
      Rake::Task['r3_1_0:data'].invoke
    end

    def check_triple(triples, predicate, value)
      expect(triples.find{|x| x[:p] == predicate.to_s}[:o]).to eq(value)
    end

    def check_updated
      {"C66784" => 23, "C87162" => 24, "C66768" => 24, "C66769" => 21}.each do |k, v|
        triples = triple_store.subject_triples(Uri.new(uri: "http://www.sanofi.com/#{k}/V1##{k}"))
        expect(triples.count).to eq(v)
      end
    end

    def check_new
      expected = 
      [
        Uri.new(uri: "http://www.sanofi.com/C66784/V1#C66784"),
        Uri.new(uri: "http://www.sanofi.com/C87162/V1#C87162"),
        Uri.new(uri: "http://www.sanofi.com/C66768/V1#C66768"),
        Uri.new(uri: "http://www.sanofi.com/C66769/V1#C66769")
      ]
      check_against(["C66784", "C87162", "C66768", "C66769"], expected, @ct_26)
      expected = 
      [
        Uri.new(uri: "http://www.sanofi.com/C66768/V1#C66768"),
        Uri.new(uri: "http://www.sanofi.com/C66769/V1#C66769")
      ]
      check_against(["C66768", "C66769"], expected, @ct_30)
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

    it 'check new' do
      check_new
    end

    it 'check ranks' do
      code_lists = []
      ["rank_V2-6.yaml", "rank_V3-0.yaml"].each_with_index do |file|
        config = read_yaml_file(import_dir, file)
        code_lists = code_lists + config[:codelists].map{|x| x[:codelist_code]}
      end
      results = check_ranks(code_lists.uniq!)
      check_file_actual_expected(results, sub_dir, "children_ranked_expected.yaml", equate_method: :hash_equal)
    end

    it 'check counts' do
      code_lists = []
      results = {}
      {"rank_V2-6.yaml" => @ct_26.uri, "rank_V3-0.yaml" => @ct_30.uri}.each do |file, uri|
        config = read_yaml_file(import_dir, file)
        code_lists = config[:codelists].map{|x| x[:codelist_code]}
        results[uri.to_s] = check_cls(code_lists, uri).map{|x| x.to_s}
        expect(code_lists.count).to eq(results[uri.to_s].count)
      end
      check_file_actual_expected(results, import_dir, "code_lists_expected.yaml", equate_method: :hash_equal)
      {"2-6" => {uri: @ct_26.uri, count: 334824}, "3-0" => {uri: @ct_30.uri, count: 479350}}.each do |version, data|
        subject_count = {}
        triples = triple_store.subject_triples_tree(data[:uri]) # Reading all triples as a test.
        triple_by_subject = triple_store.triples_to_subject_hash(triples)
        triple_by_subject.each{|k,v| subject_count[k] = v.count}
        check_file_actual_expected(subject_count, sub_dir, "subject_count_#{version}_expected.yaml", equate_method: :hash_equal)
        expect(triples.count).to eq(data[:count])
      end
    end

  end

end