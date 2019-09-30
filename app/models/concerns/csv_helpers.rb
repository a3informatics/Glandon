module CSVHelpers

  # Format. Format CSV output for writing to a file.
  #
  # @param [Array] headers the headers for row 1
  # @param [Array] data array of array of rows
  # @return [Array] the csv structure
  def self.format(headers, data)
    csv_data = CSV.generate do |csv|
      csv << headers
      data.each {|d| csv << d}
    end
    return csv_data
  end

end