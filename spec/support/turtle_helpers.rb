module TurtleHelpers
  
  def check_ttl(results_filename, expected_filename)
    keys = ["subject", "predicate", "object"]
    results = read_ttl_file(test_file_path(sub_dir, expected_filename))
    raw_expected = read_ttl_file(test_file_path(sub_dir, expected_filename))
    expect(results.count).to eq(raw_expected.count)
    expected = {}
    raw_expected.each do |triple|
      expected[triple_key(triple)] = triple
    end
    results.each do |item|
      triple = expected[triple_key(item)]
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

end