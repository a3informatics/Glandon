class Import::CdiscTerm < Import::Rectangular

  C_CLASS_NAME = self.name
  
  def description
    "Import of CDISC Terminology"
  end

  def owner
    IsoNamespace.findByShortName("CDISC").shortName
  end

  def import_type
    :cdisc_term
  end

  def reader_klass
    Excel::CdiscTermReader
  end

  def parent_klass
    ::CdiscTerm # Make sure using top level class, hence ::
  end

  def identifier
    ::CdiscTerm::C_IDENTIFIER
  end

  def self.next_version
    ::CdiscTerm.next_version
  end

end