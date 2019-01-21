module SparqlHelpers

  def check_ttl(results_filename, expected_filename)
    actual = read_ttl_file(results_filename)
    expected = read_ttl_file(expected_filename)
    expect(actual).to sparql_results_equal(expected)
  end

  def check_ttl_fix(results_filename, expected_filename, options)
    actual = read_ttl_file(test_file_path(sub_dir, results_filename))
    expected = read_ttl_file(test_file_path(sub_dir, expected_filename))
    fix_predicate(actual, expected, :last_change_date) if options[:last_change_date]  
    fix_predicate(actual, expected, :creation_date) if options[:creation_date]  
    expect(actual).to sparql_results_equal(expected)
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

  def fix_predicate(results, r_field, expected, e_field)
    map = {last_change_date: "<http://www.assero.co.uk/ISO11179Types#lastChangeDate>", creation_date: "<http://www.assero.co.uk/ISO11179Types#creationDate>"}
    set_predicate(results, map[r_field], extract_predicate(expected, map[e_field]))
  end

private

  def check(results, type)
    results[:checks] = false if type == :insert && @checks != {insert: false, open: false, close: false}
    results[:checks] = false if type == :open && @checks != {insert: true, open: false, close: false}
    results[:checks] = false if type == :close && @checks != {insert: true, open: true, close: false}
    @checks[type] = true
  end

  def extract_predicate(triples, predicate)
    triples.select{|x| x[:predicate] == predicate}.first[:object]
  end

  def set_predicate(triples, predicate, new_date)
    triple = triples.select{|x| x[:predicate] == predicate}
    triple.first[:object] = new_date
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