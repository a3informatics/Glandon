class SdtmModel < ManagedCollection

  configure rdf_type: "http://www.assero.co.uk/Tabulation#Model",
            uri_suffix: "M"
  
  C_IDENTIFIER = "SDTM MODEL"

  @@cdisc_ra = nil

  # Find Class. Return a class from within the model
  #
  # @param [String] identifier the identifier required
  # @return [SdtmModel::Class] the class. nil if not found
  def find_class(identifier)
    query_string = %Q{
      SELECT DISTINCT ?s WHERE
      {
        #{self.uri.to_ref} bo:hasManaged/bo:reference ?s .
        ?s isoT:hasIdentifier/isoI:identifier '#{identifier}' 
      } 
    }
    self.class.find_single(query_string, [:isoT, :isoI, :bo])
  end

  # Owner
  #
  # @return [IsoRegistrationAuthority] the owner
  def self.owner
    return @@cdisc_ra if !@@cdisc_ra.nil?
    @@cdisc_ra = IsoRegistrationAuthority.find_by_short_name("CDISC")
    @@cdisc_ra.freeze
  end

  # Child Klass. Return the child class
  #
  # @return [Class] the child class
  def self.child_klass
    ::SdtmClass
  end

  # Identifier
  #
  # @return [Hash] the configuration hash
  def self.identifier
    C_IDENTIFIER
  end

end
