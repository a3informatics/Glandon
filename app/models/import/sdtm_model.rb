# SDTM Model Importer
#
# @author Dave Iberson-Hurst
# @since 3.2.0
class Import::SdtmModel < Import

  include Import::Utility
  
  # Configuration. Sets the parameters for the import
  # 
  # @return [Hash] the configuration hash
  def self.configuration
    {
      description: "Import of SDTM Model",
      parent_klass: ::SdtmModel,
      reader_klass: Excel,
      import_type: :cdisc_sdtm_model,
      format: :format,
      version_label: :semantic_version,
      label: "SDTM Model"
    }
  end

  # Format. Returns the key for the sheet info
  # 
  # @return [Symbol] the key
  def format(params)
    return :main
  end
  
end