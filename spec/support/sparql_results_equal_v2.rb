require 'rspec'

RSpec::Matchers.define :sparql_results_equal_v2 do |expected|
  match { |actual| match? actual, expected }

  match_when_negated { |actual| !match? actual, expected }

  failure_message do |actual|
    text = "Following differences were detected:\n"
    @mismatches.each {|x| text += "#{x}\n"}
    text
  end

  failure_message_when_negated do |actual|
    "expected that actual -->\n#{actual}\n would not be sparql results equal with expected -->\n#{expected}"
  end

  description do
    "sparql equal with #{expected}"
  end

  def match?(actual, expected)
    processed = {}
    @actual_refs = {}
    @expected_refs = {}
    @mismatches = []
    return false if !actual[:checks]
    @mismatches << "***** Warning, prefix count mismatch. a=#{actual[:prefixes].count} versus e=#{expected[:prefixes].count}*****" if actual[:prefixes].count != expected[:prefixes].count
    @mismatches << "***** Warning, triple count mismatch. a=#{actual[:triples].count} versus e=#{expected[:triples].count} *****" if actual[:triples].count != expected[:triples].count
    actual[:triples].each do |triple|
      processed[triple_key(triple)] = triple
    end
    actual[:triples].each do |triple|
      map_reference(@actual_refs, triple)
    end
    expected[:triples].each do |triple|
      map_reference(@expected_refs, triple)
    end
    expected[:prefixes].each do |prefix|
      found = actual[:prefixes].select {|r| r == prefix}
      @mismatches << "***** Prefix not found: #{prefix}. *****" if found.count != 1
    end
    expected[:triples].each do |item|
      key = triple_key(item)
      triple = processed[key]
      next if triple.nil? && is_reference?(item)
      next if triple.nil? && is_origin?(item)
      @mismatches << "***** Triple not matched: [#{item[:subject]}, #{item[:predicate]}, #{item[:object]}]. *****" if triple.nil?
    end
    check_references
    @mismatches.empty?
  end

  def triple_key(triple)
    return "#{triple[:subject]}.#{triple[:predicate]}.#{triple[:object]}"
  end

  def map_reference(collection, triple)
    return if !is_reference?(triple)
    collection[triple[:object]] = triple[:object]
  end

  def is_reference?(triple)
    triple[:predicate] == "<http://www.assero.co.uk/BusinessOperational#reference>"
  end

  def is_origin?(triple)
    triple[:predicate] == "<http://www.assero.co.uk/ISO11179Types#origin>"
  end

  def check_references
    reference_count
    reference_match
  end

  def reference_count    
    return if @actual_refs.keys.count == @expected_refs.keys.count
    @mismatches << "***** Reference count mismatch [a: #{@actual_refs.keys.count}, e: #{@expected_refs.keys.count}] *****" 
  end

  def reference_match
    return if references_match?
    add_mismatch(@actual_refs.keys - @expected_refs.keys)
    add_mismatch(@expected_refs.keys - @actual_refs.keys)
  end

  def add_mismatch(items)
    items.each do |item|
      @mismatches << "***** Reference mismatch for {item} *****"
    end
  end

  def references_match?
    return false if !reference_keys_match?
    puts colourize("Matching keys: #{@actual_refs.keys}", "blue") 
    true
  end

  def reference_keys_match?
    @actual_refs.keys - @expected_refs.keys == [] && @expected_refs.keys - @actual_refs.keys == []
  end
  
end