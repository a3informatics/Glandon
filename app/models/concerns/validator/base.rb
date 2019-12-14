# Base Validator. Base class
#
# @author Dave Iberson-Hurst
# @since 2.24.0
class Validator::Base < ActiveModel::Validator
  
  def failed(record, message)
    record.errors.add :base, message
    false
  end

end