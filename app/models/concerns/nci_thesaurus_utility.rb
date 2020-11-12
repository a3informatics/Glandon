module NciThesaurusUtility

  C_CLASS_NAME = self.name
  C_C_CODE = "C[0-9]{3,6}"

  # C Code? Is the text a valid NCIt c code
  #
  # @param [String] text the text to be checked
  # @return [Boolean] true if valie
  def self.c_code?(text)
    return text =~ /\A#{C_C_CODE}\z/ ? true : false
  end
end

    