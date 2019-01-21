require 'rspec'

RSpec::Matchers.define :sparql_results_equal do |expected|
  match { |actual| match? actual, expected }

  match_when_negated { |actual| !match? actual, expected }

  failure_message do |actual|
    "expected that actual -->\n#{actual}\n would be sparql results equal with expected -->\n#{expected}"
  end

  failure_message_when_negated do |actual|
    "expected that actual -->\n#{actual}\n would not be sparql results equal with expected -->\n#{expected}"
  end

  description do
    "sparql equal with #{expected}"
  end

  def match?(actual, expected)
    processed = {}
    return false if !actual[:checks]
    puts "***** Warning, prefix count mismatch. a=#{actual[:prefixes].count} versus e=#{expected[:prefixes].count}*****" if actual[:prefixes].count != expected[:prefixes].count
    return false if actual[:prefixes].count != expected[:prefixes].count
    puts "***** Warning, triple count mismatch. a=#{actual[:triples].count} versus e=#{expected[:triples].count} *****" if actual[:triples].count != expected[:triples].count
    return false if actual[:triples].count != expected[:triples].count
    processed = {}
    actual[:triples].each do |triple|
      processed[triple_key(triple)] = triple
    end
    expected[:prefixes].each do |prefix|
      found = actual[:prefixes].select {|r| r == prefix}
      puts "***** Prefix not found: #{prefix}. *****" if found.count != 1
      return false if found.count != 1
    end
    expected[:triples].each do |item|
      triple = processed[triple_key(item)]
      puts "***** Triple not found: #{triple_key(item)}. *****" if triple.nil?
      return false if triple.nil?
      [:subject, :predicate, :object].each do |t| 
        if item[t] != triple[t]
          puts "***** Triple mismatch. Key: #{triple_key(item)}. Values: #{item[t]} <> #{triple[t]}. *****"
          return false 
        end
      end
    end
  end

  def triple_key(triple)
    return "#{triple[:subject]}.#{triple[:predicate]}.#{triple[:object]}"
  end

end