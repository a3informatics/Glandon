module BridgSdtm

	# Method to get SDTM map given BRIDG reference
  #
  # @param bridg [String] the BRIDG reference, the path
  # @return [String] The SDTM mapping if found, others empty string.
  def self.get(bridg)
    return Rails.configuration.bridg_sdtm[bridg].dup if Rails.configuration.bridg_sdtm.has_key?(bridg)
    return ""
	end
	
  # To Bridg
  #
  # @param sdtm [String] the sdtm reference
  # @return [String] The BRIDG reference
  def self.to_bridg(sdtm)
    Rails.configuration.bridg_sdtm.key("#{sdtm}").dup
  end

end