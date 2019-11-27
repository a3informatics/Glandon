module SparqlHelpers

  @@predicate_map = 
    {
      last_change_date: {expanded: "<http://www.assero.co.uk/ISO11179Types#lastChangeDate>", prefixed: "isoT:lastChangeDate"},
      creation_date: {expanded: "<http://www.assero.co.uk/ISO11179Types#creationDate>", prefixed: "isoT:creationDate"},
      effective_date: {expanded: "<http://www.assero.co.uk/ISO11179Registration#effectiveDate>", prefixed: "isoR:effectiveDate"},
      until_date: {expanded: "<http://www.assero.co.uk/ISO11179Registration#untilDate>", prefixed: "isoR:untilDate"}
    }

  def check_sparql(results_filename, expected_filename)
    actual = read_sparql_file(results_filename)
    expected = read_sparql_file(expected_filename)
    expect(actual).to sparql_results_equal(expected)
  end

  def check_sparql_no_file(sparql, expected_filename, options={})
    actual_filename = "CHECK_SPARQL_#{DateTime.now.strftime('%Q')}.ttl"
    write_text_file_2(sparql, sub_dir, actual_filename)
    actual = read_sparql_file(actual_filename)
    expected = read_sparql_file(expected_filename)
    delete_data_file(sub_dir, actual_filename)
    fixes(actual, expected, options) if !options.empty?
    expect(actual).to sparql_results_equal(expected)
  end

  def check_ttl(results_filename, expected_filename)
    actual = read_ttl_file(results_filename)
    expected = read_ttl_file(expected_filename)
    expect(actual).to sparql_results_equal(expected)
  end

  def check_ttl_fix(results_filename, expected_filename, options)
    actual = read_ttl_file(results_filename)
    expected = read_ttl_file(expected_filename)
    fixes(actual, expected, options)
    expect(actual).to sparql_results_equal(expected)
  end

=begin
  def check_ttl_versus_triples(results_filename, expected_filename)
    actual = read_ttl_file(results_filename)
    expected = read_triple_file(expected_filename)
    expect(actual).to sparql_results_equal(expected)
  end
=end

  def check_triples(results_filename, expected_filename)
    actual = read_triple_file(results_filename)
    expected = read_triple_file(expected_filename)
    expect(actual).to sparql_results_equal(expected)
  end

  def check_triples_fix(results_filename, expected_filename, options)
    actual = read_triple_file(results_filename)
    expected = read_triple_file(expected_filename)
    fixes(actual, expected, options)
    expect(actual).to sparql_results_equal(expected)
  end

  def fixes(actual, expected, options)
    fix_predicate(actual, expected, :last_change_date) if options[:last_change_date]  
    fix_predicate(actual, expected, :creation_date) if options[:creation_date]  
    fix_predicate(actual, expected, :effective_date) if options[:effective_date]  
    fix_predicate(actual, expected, :until_date) if options[:until_date]  
  end

  def read_sparql_file(filename)
    @checks = {insert: false, open: false, close: false}
    results = {prefixes: [], triples: [], checks: true}
    my_array = File.readlines(test_file_path(sub_dir, filename)).map do |line|
      x = line.squish
      if x.start_with?("PREFIX")
        results[:prefixes] << x.strip
      elsif x.start_with?("INSERT DATA")
        check(results, :insert)
      elsif x.start_with?("{")
        check(results, :open)
      elsif x.start_with?("}")
        check(results, :close)
      elsif x.empty?
        # ignore blank line
      else
        items = x.split(" ")
        results[:triples] << {subject: items[0].strip, predicate: items[1].strip, object: items[2].strip}
      end
    end 
    @checks.each {|key,value| results[:checks] = false if !value}
    return results
  end

  def read_ttl_file(filename)
    results = {prefixes: [], triples: [], checks: true}
    subject = ""
    my_array = File.readlines(test_file_path(sub_dir, filename)).map do |line|
      x = line.squish
      if x.upcase.start_with?("@PREFIX")
        results[:prefixes] << x.strip
      elsif x.start_with?("#")
        #
      elsif x.start_with?(".")
        #
      elsif x.empty?
        # ignore blank line
      elsif x.end_with?(";")
        items = x.match(/(?<predicate>[\S]*) (?<object>[\S| ]*) \;/)
        results[:triples] << {subject: subject, predicate: items[:predicate].strip, object: items[:object].strip}
      else
        subject = x.strip
      end
    end 
    expand(results)
    return results
  end

  def read_triple_file(filename)
    results = []
    my_array = File.readlines(test_file_path(sub_dir, filename)).map do |line|
      x = line.squish
      items = x.split(" ")
      results << {subject: items[0].strip, predicate: items[1].strip, object: items[2].strip}
    end 
    return results = {prefixes: [], triples: results, checks: true}
  end

  def fix_predicate(results, expected, r_field)
    set_predicate(results[:triples], r_field, "2019-01-01 12:13:14 +0200") # Set a dummy date, don't extract
    set_predicate(expected[:triples], r_field, "2019-01-01 12:13:14 +0200") 
  end

private

  def check(results, type)
    results[:checks] = false if type == :insert && @checks != {insert: false, open: false, close: false}
    results[:checks] = false if type == :open && @checks != {insert: true, open: false, close: false}
    results[:checks] = false if type == :close && @checks != {insert: true, open: true, close: false}
    @checks[type] = true
  end

  #def extract_predicate(triples, predicate_type)
  #  triple = triples.select{|x| x[:predicate] == @@predicate_map[predicate_type][:expanded]}
  #  triple = triples.select{|x| x[:predicate] == @@predicate_map[predicate_type][:prefixed]} if triple.empty?
  #  triple.first[:object]
  #end

  def set_predicate(triples, predicate_type, new_date)
    found_triples = triples.select{|x| x[:predicate] == @@predicate_map[predicate_type][:expanded]}
    found_triples = triples.select{|x| x[:predicate] == @@predicate_map[predicate_type][:prefixed]} if found_triples.empty?
    found_triples.each {|x| x[:object] = new_date}
  end

  def expand(results)
    map = {}
    default_namespace = ""
    results[:prefixes].each do |item|
      parts = item.match(/@prefix (?<prefix>.*): <(?<namespace>.*)#>/)
      parts[:prefix].empty? ? default_namespace = parts[:namespace] : map[parts[:prefix]] = parts[:namespace]
    end
    results[:triples].each do |triple|
      triple.each do |key, item|
        next if item.start_with?("<")
        next if item.start_with?("\"")
        parts = item.split(":")
        if parts[0].empty?
          triple[key] = "<#{default_namespace}##{parts[1]}>" 
        else
          triple[key] = map.key?(parts[0]) ? "<#{map[parts[0]]}##{parts[1]}>" : "<??????????##{parts[1]}>"
        end
      end
    end
  end

end