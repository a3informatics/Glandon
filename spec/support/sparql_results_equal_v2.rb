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
    @mismatches = []
    processed = {}
    return false if !actual[:checks]
    @mismatches << "***** Warning, prefix count mismatch. a=#{actual[:prefixes].count} versus e=#{expected[:prefixes].count}*****" if actual[:prefixes].count != expected[:prefixes].count
    @mismatches << "***** Warning, triple count mismatch. a=#{actual[:triples].count} versus e=#{expected[:triples].count} *****" if actual[:triples].count != expected[:triples].count
    actual[:triples].each do |triple|
      processed[triple_key(triple)] = triple
    end
    expected[:prefixes].each do |prefix|
      found = actual[:prefixes].select {|r| r == prefix}
      @mismatches << "***** Prefix not found: #{prefix}. *****" if found.count != 1
    end
    expected[:triples].each do |item|
      key = triple_key(item)
      triple = processed[key]
      @mismatches << "***** Triple not matched: [#{item[:subject]}, #{item[:predicate]}, #{item[:object]}]. *****" if triple.nil?
    end
    @mismatches.empty?
  end

  def triple_key(triple)
    return "#{triple[:subject]}.#{triple[:predicate]}.#{triple[:object]}"
  end

end