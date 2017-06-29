module BridgSdtm

	C_CLASS_NAME = "BridgSdtm"

	# Method to get SDTM map given BRIDG reference
  #
  # @param bridg [String] the BRIDG reference, the path
  # @return [String] The SDTM mapping if found, others empty string.
  def self.get(bridg)
		result = ""
		if Rails.configuration.bridg_sdtm.has_key?(bridg)
			result = "#{Rails.configuration.bridg_sdtm[bridg]}"
		end
		return result
	end
	
end