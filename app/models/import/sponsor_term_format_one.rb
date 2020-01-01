# Sponsor Term Format 1 Importer
#
# @author Dave Iberson-Hurst
# @since 2.25.0
class Import::SponsorTermFormatOne < Import::Rectangular

  C_V2 = "01/01/1900".to_datetime 
  C_V3 = "01/06/2019".to_datetime 
  C_FORMAT_MAP = [
    {range: (C_V2...C_V3), sheet: :version_2}, 
    {range: (C_V3...DateTime.now.to_date+1), sheet: :version_3}]
  C_DEFAULT = :version_3

  # Configuration. Sets the parameters for the import
  # 
  # @return [Hash] the configuration hash
  def self.configuration
    {
      description: "Import of Sponsor Terminology",
      parent_klass: ::Thesaurus,
      reader_klass: Excel::SponsorTermFormatOneReader,
      import_type: :sponsor_term_format_one,
      format: :format,
      version_label: :date,
      label: "Controlled Terminology"
    }
  end

  # Get the format
  #
  # @param [Hash] params a set of parameters
  # @option [String] :date a day date as a string
  # @return [Symbol] the format as a symbol. Default to C_DEFAULT if non found.
  def format(params)
    result = C_FORMAT_MAP.select{|x| x[:range].cover?(params[:date].to_datetime)}
    return C_DEFAULT if result.empty?
    return result.first[:sheet]
  end

end