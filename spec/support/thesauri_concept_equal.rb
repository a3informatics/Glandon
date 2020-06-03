require 'rspec'

RSpec::Matchers.define :thesauri_concept_equal do |expected|
  
  match do |actual| 
    @a_all = actual
    @e_all = expected
    match? actual, expected
  end

  #diffable

  match_when_negated { |actual| !match? actual, expected }

  failure_message do |actual|
    message = "Difference detected in:\nActual:\n#{@a_all}\nExpected:\n#{@e_all}"
    message += "\nDiff:" + differ.diff_as_object(@actual, @expected)
    #message += "\nDiff:" + RSpec::Support::Differ.new(@actual, @expected)
    message
  end

  failure_message_when_negated do |actual|
    message = "expected that actual --> #{actual}\n would not be hash equal with expected --> #{@expected}"
    message
  end

  description do
    "hash equal with #{expected}"
  end

  def differ
    RSpec::Support::Differ.new(
      :object_preparer => lambda { |object| RSpec::Matchers::Composable.surface_descriptions_in(object) },
      :color => RSpec::Matchers.configuration.color?
    )
  end

  def match?(actual, expected)
    return arrays_match?(actual, expected) if expected.is_a?(Array) && actual.is_a?(Array)
    return hashes_match?(actual, expected) if expected.is_a?(Hash) && actual.is_a?(Hash)
    return true if expected == actual
    note_error(actual, expected)
  end

  def arrays_match?(actual, expected)
    exp = expected.clone
    actual.each do |a|
      index = exp.find_index { |e| match? a, e }
      return note_error(actual, expected) if index.nil?
      exp.delete_at(index)
    end
    return note_error(actual, expected) if !exp.empty?
    true
  end

  def hashes_match?(actual, expected)
    @actual = actual
    @expected = expected
    return false unless actual.keys.sort == expected.keys.sort
    actual.each do |key, value|
      if key == :preferred_term 
        return false unless pt_match? value, expected[key]
      elsif key == :synonym 
        return false unless s_match? value, expected[key]
      elsif key == :is_ordered
        return false unless rdf_type_match? value, expected[key]
      elsif key == :members 
        return false unless rdf_type_match? value, expected[key]
      else
        return false unless match? value, expected[key]
      end
    end
    true
  end
  
  def note_error(actual, expected)
    @actual = actual
    @expected = expected
    false
  end

  def pt_match?(actual, expected)
    @actual = actual
    @expected = expected
    actual[:label] == expected[:label] #&& actual[:uri] == expected[:uri]
  end

  def rdf_type_match?(actual, expected)
    return true if actual.nil? && expected.nil?
    return false if actual.nil? || expected.nil?
    @actual = actual
    @expected = expected
    actual[:rdf_type] == expected[:rdf_type] # nothing to really check
  end

  def s_match?(actual, expected)
    @actual = actual
    @expected = expected
    synonyms = []
    return false if actual.count != expected.count
    expected.map{|x| synonyms << x[:label]}
    actual.each do |s| 
      return false if !synonyms.include?(s[:label])
    end
    return true
  end

end