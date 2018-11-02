class Import::AdamIg < Import::Rectangular

  C_CLASS_NAME = self.name
  
  def description
    "Import of ADaM Implementation Guide"
  end

  def owner
    IsoNamespace.findByShortName("CDISC").shortName
  end

  def import_type
    :adam_ig
  end

  def reader_klass
    Excel::AdamIgReader
  end

  def parent_klass
    ::AdamIg # Make sure using top level class, hence ::
  end

  def identifier
    ::AdamIg::C_IDENTIFIER
  end

end