class AdamIg < ImplementationGuide

  configure rdf_type: "http://www.assero.co.uk/Tabulation#ADaMImplementationGuide",
            uri_suffix: "AIG"

  C_IDENTIFIER = "ADAM IG"

  @@cdisc_ra = nil

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
    ::AdamIgDataset
  end

  # Identifier
  #
  # @return [Hash] the configuration hash
  def self.identifier
    C_IDENTIFIER
  end
  
end
