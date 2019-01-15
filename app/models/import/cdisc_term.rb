class Import::CdiscTerm < Import::Rectangular

  C_CLASS_NAME = self.name
  
  def self.configuration
    {
      description: "Import of CDISC Terminology",
      parent_klass: ::CdiscTerm,
      reader_klass: Excel::CdiscTermReader,
      import_type: :cdisc_term,
      sheet_name: :main,
      version_label: :date,
      label: "CDISC Terminology"
    }
  end

end