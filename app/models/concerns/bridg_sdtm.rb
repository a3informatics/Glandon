module BridgSdtm

	C_CLASS_NAME = self.name

	# Method to get SDTM map given BRIDG reference
  #
  # @param bridg [String] the BRIDG reference, the path
  # @return [String] The SDTM mapping if found, others empty string.
  def self.get(bridg)
    return Rails.configuration.bridg_sdtm[bridg.to_sym].dup if Rails.configuration.bridg_sdtm.has_key?(bridg.to_sym)
    return ""
	end
	
  def self.to_bridg(sdtm)
    Rails.configuration.bridg_sdtm.key("#{sdtm}").dup
  end

end