# Name Value. Implements simple name value pairs
#
# @author Dave Iberson-Hurst
# @since 2.22.0
class NameValue < ApplicationRecord

  # Next. Next value. Assumes integer and increments after returning the current value
  #
  # @param namem [String] the name key
  # @return [Integer] the next value
  def self.next(name)
    record = NameValue.where("name='#{name}'").lock(true).first
    result = record.value.to_i
    record.value = result + 1
    record.save!
    result
  end

end
