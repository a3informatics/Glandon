require 'rspec'

RSpec::Matchers.define :hash_equal do |expected|
  
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
    return iso8601_match?(actual, expected) if is_a_iso8601?(expected) && is_a_iso8601?(actual)
    return true if expected == actual
    note_error(actual, expected)
  end

  def is_a_iso8601?(value)
    !(value =~ /\A\d{4}-\d{2}-\d{2}T/).nil?
  end

  def iso8601_match?(actual, expected)
    return true if DateTime.parse(actual) == DateTime.parse(expected)
    return true if iso8601_equal_bar_zone?(actual, expected)
    note_error(actual, expected)
  end

  def iso8601_equal_bar_zone?(actual, expected)
    a = DateTime.parse(actual)
    e = DateTime.parse(expected)
    return false if a.to_date.to_s != e.to_date.to_s
    return false if !iso8601_correct_zone?(a)
    return false if !iso8601_correct_zone?(e)
    true
  end

  def iso8601_correct_zone?(value)
    return value.zone == "+00:00" || value.zone == "+01:00" || value.zone == "+02:00"
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
      return false unless match? value, expected[key]
    end
    true
  end
  
  def note_error(actual, expected)
    @actual = actual
    @expected = expected
    false
  end

end