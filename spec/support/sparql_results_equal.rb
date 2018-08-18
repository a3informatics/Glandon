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
    return false if actual[:prefixes].count != expected[:prefixes].count
    return false if actual[:triples].count != expected[:triples].count
    processed = {}
    expected[:triples].each do |triple|
      processed[triple_key(triple)] = triple
    end
    actual[:prefixes].each do |prefix|
      found = expected[:prefixes].select {|r| r == prefix}
      return false if found.count != 1
    end
    actual[:triples].each do |item|
      triple = processed[triple_key(item)]
      return false if triple.nil?
      [:subject, :predicate, :object].each {|t| return false if item[t] != triple[t]}
    end
  end

  def triple_key(triple)
    return "#{triple[:subject]}.#{triple[:predicate]}.#{triple[:object]}"
  end

end