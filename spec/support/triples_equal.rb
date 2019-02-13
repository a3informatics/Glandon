require 'rspec'

RSpec::Matchers.define :triples_equal do |expected|
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

  def match?(a, e)
    processed = {}
    actual = a.map {|k,v| v}.flatten
    expected = e.map {|k,v| v}.flatten
    puts "***** Warning, count mismatch. a=#{actual.count} versus e=#{expected.count}*****" if actual.count != expected.count
    return false if actual.count != expected.count
    actual.each do |triple|
      processed[triple_key(triple)] = triple
    end
    expected.each do |item|
      triple = processed[triple_key(item)]
      puts "***** Triple not found: #{triple_key(item)}. *****" if triple.nil?
      return false if triple.nil?
      [:subject, :predicate, :object].each do |t| 
        if item[t].to_s != triple[t].to_s
          puts "***** Triple mismatch. Key: #{triple_key(item)}. Values: #{item[t]} <> #{triple[t]} *****"
          return false 
        end
      end
    end
  end

  def triple_key(triple)
    return "#{triple[:subject]}.#{triple[:predicate]}.#{triple[:object]}"
  end

end