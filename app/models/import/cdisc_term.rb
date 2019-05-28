# Adam IG Importer
#
# @author Dave Iberson-Hurst
# @since 2.21.0
class Import::CdiscTerm < Import::Rectangular

  C_CLASS_NAME = self.name
  
  C_V1 = "01/01/1900".to_datetime 
  C_V2 = "01/05/2007".to_datetime 
  C_V3 = "01/04/2010".to_datetime 
  C_SHEET_MAP = [{range: (C_V1...C_V2), sheet: :version_1}, {range: (C_V2...C_V3), sheet: :version_2}, {range: (C_V3...DateTime.now.to_date+1), sheet: :version_3}]
  C_DEFAULT = :version_3

  # Configuration. Sets the parameters for the import
  # 
  # @return [Hash] the configuration hash
  def self.configuration
    {
      description: "Import of CDISC Terminology",
      parent_klass: ::CdiscTerm,
      reader_klass: Excel::CdiscTermReader,
      import_type: :cdisc_term,
      sheet_name: :sheet,
      version_label: :date,
      label: "Controlled Terminology"
    }
  end

  # Get the sheet
  #
  # @param [Hash] params a set of parameters
  # @option [String] :date a day date as a string
  # @return [Symbol] the sheet as a symbol. Default to C_DEFAULT if non found.
  def sheet(params)
    result = C_SHEET_MAP.select{|x| x[:range].cover?(params[:date].to_datetime)}
    return C_DEFAULT if result.empty?
    return result.first[:sheet]
  end

end