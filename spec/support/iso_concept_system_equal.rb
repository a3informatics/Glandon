require 'rspec'

RSpec::Matchers.define :iso_concept_system_equal do |expected|
  
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
    message
  end

  failure_message_when_negated do |actual|
    message = "expected that actual --> #{actual}\n would not be hash equal with expected --> #{@expected}"
    message
  end

  description do
    "iso concept system equal with #{expected}"
  end

  def differ
    RSpec::Support::Differ.new(
      :object_preparer => lambda { |object| RSpec::Matchers::Composable.surface_descriptions_in(object) },
      :color => RSpec::Matchers.configuration.color?
    )
  end

  def match?(actual, expected)
    return hashes_match?(actual, expected) if expected.is_a?(Hash) && actual.is_a?(Hash)
    return true if expected == actual
    note_error(actual, expected)
  end

  def hashes_match?(actual, expected)
    @actual = actual
    @expected = expected
    return false unless actual.keys.sort == expected.keys.sort
    actual.each do |key, value| 
      next if key == :id || key == :uri
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