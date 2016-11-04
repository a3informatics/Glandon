class Timestamp

  C_CLASS_NAME = "Timestamp"

  # Initialize
  #
  # @param text [string] Time string
  # @return [null]
  def initialize(text=nil)
    if "#{text}".empty?
      @time = Time.now
    else
      @time = text.to_time
    end
  end

  # Set from timestamp string
  #
  # @param text [string] Time string
  # @return [null]
  def from_timestamp(text)
    @time = text.to_time
  end

  # To Datetime 
  #
  # @return [string] Time formatted as YYYY-MMM-DD, HH:MM
  def to_datetime
    return @time.strftime("%Y-%b-%d, %H:%M").to_s
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

end

    