module SparqlHelpers
  
  def check_sparql(results_filename, expected_filename)
    results = read_sparql_file(test_file_path(sub_dir, results_filename))
    raw_expected = read_sparql_file(test_file_path(sub_dir, expected_filename))
    expect(results[:prefixes].count).to eq(raw_expected[:prefixes].count)
    expect(results[:triples].count).to eq(raw_expected[:triples].count)
    expected = {}
    raw_expected[:triples].each do |triple|
      expected[triple_key(triple)] = triple
    end
    results[:prefixes].each do |prefix|
      found = raw_expected[:prefixes].select {|r| r == prefix}
      expect(found.count).to eq(1)
    end
    results[:triples].each do |item|
      triple = expected[triple_key(item)]
      expect(item[:subject]).to eq(triple[:subject])
      expect(item[:predicate]).to eq(triple[:predicate])
      expect(item[:object]).to eq(triple[:object])
    end
  end

  def read_sparql_file(filename)
    @checks = {insert: false, open: false, close: false}
    results = {prefixes: [], triples: []}
    my_array = File.readlines(filename).map do |line|
      x = line.squish
      if x.start_with?("PREFIX")
        results[:prefixes] << x.strip
      elsif x.start_with?("INSERT DATA")
        check(:insert)
      elsif x.start_with?("{")
        check(:open)
      elsif x.start_with?("}")
        check(:close)
      elsif x.empty?
        # ignore blank line
      else
        items = x.split(" ")
        results[:triples] << {subject: items[0].strip, predicate: items[1].strip, object: items[2].strip}
      end
    end 
    expect(@checks).to eq({insert: true, open: true, close: true})
    return results
  end

  def triple_key(triple)
    return "#{triple[:subject]}.#{triple[:predicate]}.#{triple[:object]}"
  end

  def check(type)
    expect(@checks[type]).to eq(false)
    @checks[type] = true
  end

end