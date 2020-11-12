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
      key = triple_key(item)
      triple = processed[key]
      puts "***** Triple not found: #{key}. *****" if triple.nil?
      return false if triple.nil?
      [:subject, :predicate, :object].each do |t| 
        return false if !part_match?(key, triple[t], item[t])
      end
    end
    true
  end

  def part_match?(key, actual, expected)
    return true if actual == expected
    puts "***** Triple mismatch. Key: #{key}. Values: #{item[t]} <> #{triple[t]}. *****"
    false 
  end

  def triple_key(triple)
    return "#{triple[:subject]}.#{triple[:predicate]}.#{triple[:object]}"
  end

  # def is_a_iso8601?(value)
  #   !(value =~ /\A"\d{4}-\d{2}-\d{2}T/).nil?
  # end

  # def iso8601_match?(key, actual, expected)
  #   extracted_actual = iso8601_extract(actual)
  #   extracted_expected = iso8601_extract(expected)
  #   return true if DateTime.parse(extracted_actual) == DateTime.parse(extracted_expected)
  #   return true if iso8601_equal_bar_zone?(vactual, extracted_expected)
  #   puts "***** Triple mismatch. Key: #{key}. Values: #{item[t]} <> #{triple[t]}. *****"
  #   false
  # end

  # def iso8601_extract(value)
  #   local = value.dup.gsub('^^xsd:dateTime', '')
  #   local = local.trim("\"")
  #   local.gsub('%2B', '+')
  # end

  # def iso8601_equal_bar_zone?(actual, expected)
  #   a = DateTime.parse(actual)
  #   e = DateTime.parse(expected)
  #   return false if a.to_date.to_s != e.to_date.to_s
  #   return false if !iso8601_correct_zone?(a)
  #   return false if !iso8601_correct_zone?(e)
  #   true
  # end

  # def iso8601_correct_zone?(value)
  #   return value.zone == "+00:00" || value.zone == "+01:00" || value.zone == "+02:00"
  # end

end