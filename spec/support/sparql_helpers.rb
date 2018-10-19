module SparqlHelpers

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

  def fix_last_change_date(results, expected)
    set_date(results[:triples], extract_last_change_date(expected[:triples], "isoT:lastChangeDate"), "isoT:lastChangeDate")
  end

  def fix_creation_date(results, expected)
    set_date(results[:triples], extract_last_change_date(expected[:triples], "isoT:lastChangeDate"), "isoT:creationDate")
  end

private

  def check(results, type)
    results[:checks] = false if type == :insert && @checks != {insert: false, open: false, close: false}
    results[:checks] = false if type == :open && @checks != {insert: true, open: false, close: false}
    results[:checks] = false if type == :close && @checks != {insert: true, open: true, close: false}
    @checks[type] = true
  end

  def extract_last_change_date(triples, predicate)
    triple = triples.select{|x| x[:predicate] == predicate}
    return triple.first[:object]
  end

  def set_date(triples, new_date, predicate)
    triple = triples.select{|x| x[:predicate] == predicate}
    triple.first[:object] = new_date
  end

end