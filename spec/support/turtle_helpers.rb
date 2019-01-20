module TurtleHelpers
  
  def check_ttl(results_filename, expected_filename)
    results = read_ttl_file(test_file_path(sub_dir, results_filename))
    raw_expected = read_ttl_file(test_file_path(sub_dir, expected_filename))
    check_ttl_data(results, raw_expected)
  end

  def check_ttl_fix(results_filename, expected_filename, options)
    results = read_ttl_file(test_file_path(sub_dir, results_filename))
    raw_expected = read_ttl_file(test_file_path(sub_dir, expected_filename))
    fix_predicate(results, raw_expected, "<http://www.assero.co.uk/ISO11179Types#lastChangeDate>") if options[:last_change_date]  
    fix_predicate(results, raw_expected,  "<http://www.assero.co.uk/ISO11179Types#creationDate>") if options[:creation_date]  
    check_ttl_data(results, raw_expected)
  end

  def check_ttl_data(results, raw_expected)
    keys = ["subject", "predicate", "object"]
    expect(results.count).to eq(raw_expected.count)
    expected = {}
    raw_expected.each do |triple|
      expected[triple_key(triple)] = triple
    end
    results.each do |item|
      triple = expected[triple_key(item)]
      puts "Result triple not matched: #{item}" if triple.nil?
      expect(triple).to_not be_nil
      expect(item[:subject]).to eq(triple[:subject])
      expect(item[:predicate]).to eq(triple[:predicate])
      expect(item[:object]).to eq(triple[:object])
    end
  end

  def read_ttl_file(filename)
    results = []
    my_array = File.readlines(filename).map do |line|
      x = line.squish
      items = x.split(" ")
      results << { subject: items[0].strip, predicate: items[1].strip, object: items[2].strip}
    end 
    return results
  end

  def triple_key(triple)
    return "#{triple[:subject]}.#{triple[:predicate]}.#{triple[:object]}"
  end

  def extract_predicate(triples, predicate)
    triples.select{|x| x[:predicate] == predicate}.first[:object]
  end

  def set_predicate(triples, predicate, new_date)
    triple = triples.select{|x| x[:predicate] == predicate}
    triple.first[:object] = new_date
  end

  def fix_predicate(results, expected, predicate)
    set_predicate(results, predicate, extract_predicate(expected, predicate))
  end

end