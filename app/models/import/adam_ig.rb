class Import::AdamIg < Import::Rectangular

  C_CLASS_NAME = self.name
  
  def self.configuration
    {
      description: "Import of ADaM Implementation Guide",
      parent_klass: ::AdamIg,
      reader_klass: Excel::AdamIgReader,
      import_type: :cdisc_adam_ig,
      sheet_name: :main,
      version_label: :semantic_version,
      label: "ADaM Implementation Guide"
    }
  end

end