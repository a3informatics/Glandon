# Adam IG Importer
#
# @author Dave Iberson-Hurst
# @since 2.21.0
class Import::CdiscTerm < Import::Rectangular

  C_V1 = "01/01/1900".to_datetime 
  C_V2 = "01/05/2007".to_datetime 
  C_V3 = "01/09/2008".to_datetime 
  C_V4 = "01/05/2009".to_datetime 
  C_V5 = "01/04/2010".to_datetime 
  C_FORMAT_MAP = [
    {range: (C_V1...C_V2), sheet: :version_1}, 
    {range: (C_V2...C_V3), sheet: :version_2}, 
    {range: (C_V3...C_V4), sheet: :version_3}, 
    {range: (C_V4...C_V5), sheet: :version_4}, 
    {range: (C_V5...DateTime.now.to_date+1), sheet: :version_5}]
  C_DEFAULT = :version_5

  # Configuration. Sets the parameters for the import
  # 
  # @return [Hash] the configuration hash
  def self.configuration
    {
      description: "Import of CDISC Terminology",
      parent_klass: ::CdiscTerm,
      reader_klass: Excel::CdiscTermReader,
      import_type: :cdisc_term,
      format: :format,
      version_label: :date,
      label: "Controlled Terminology"
    }
  end

  # Get the format
  #
  # @param [Hash] params a set of parameters
  # @option [String] :date a day date as a string
  # @return [Symbol] the sheet as a symbol. Default to C_DEFAULT if non found.
  def format(params)
    result = C_FORMAT_MAP.select{|x| x[:range].cover?(params[:date].to_datetime)}
    return C_DEFAULT if result.empty?
    return result.first[:sheet]
  end

end