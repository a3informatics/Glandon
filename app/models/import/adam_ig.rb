# Adam IG Importer
#
# @author Dave Iberson-Hurst
# @since 2.21.0
class Import::AdamIg < Import

  include Import::Rectangular
  
  # Configuration. Sets the parameters for the import
  # 
  # @return [Hash] the configuration hash
  def self.configuration
    {
      description: "Import of ADaM Implementation Guide",
      parent_klass: ::AdamIg,
      reader_klass: Excel,
      import_type: :cdisc_adam_ig,
      format: :format,
      version_label: :semantic_version,
      label: "ADaM Implementation Guide"
    }
  end

  # Format. Returns the key for the sheet info
  # 
  # @return [Symbol] the key
  def format(params)
    return :main
  end
  
end