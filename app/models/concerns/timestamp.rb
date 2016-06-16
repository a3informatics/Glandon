class Timestamp

  C_CLASS_NAME = "Timestamp"

  # Method replace special characters in the query string.
  def initialize(text=nil)
    if text.nil?
      @time = Time.now
    else
      @time = text.to_time
    end
  end

  def from_timestamp(text)
    @time = text.to_time
  end

  def to_datetime
    return @time.strftime("%Y-%b-%d, %H:%M").to_s
  end

  def to_date
    return @time.strftime("%Y-%b-%d").to_s
  end

  def to_8601
    return @time.iso8601.to_s
  end

end

    