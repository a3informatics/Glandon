class Timestamp

  C_CLASS_NAME = "Timestamp"

  # Initialize
  #
  # @param value [String!Time] Time string or object
  # @return [null]
  def initialize(value=nil)
    if value.is_a?(String)
      @time = "#{value}".to_time(:utc)
    elsif value.is_a?(Time) 
      @time = value
    else
      @time = Time.now
    end
  end

  # Set from timestamp string
  #
  # @param value [String!Time] Time string or object
  # @return [null]
  def from_timestamp(value)
    @time = "#{value}".to_time(:utc)
  end

  # To Datetime
  #
  # @return [string] Time formatted as YYYY-MMM-DD, HH:MM
  def to_datetime
    return @time.strftime("%Y-%b-%d, %H:%M").to_s
  end

  # To Audit Datetime
  #
  # @return [string] Time formatted as YYYY-MM-DD, HH:MM:SS.DDD
  def to_audit_datetime
    @time.strftime("%F, %H:%M:%S.%L").to_s
  end

  # To Date
  #
  # @return [string] Time formatted as YYYY-MMM-DD
  def to_date
    return @time.strftime("%Y-%b-%d").to_s
  end

  # To 8601
  #
  # @return [string] Time formatted as YYYY-MM-DDTHH:MM:SS+/-HH:MM
  def to_8601
    return @time.iso8601.to_s
  end

  # ---------
  # Test Only
  # ---------

  if Rails.env.test?

    def time
      @time
    end

  end

end
