require "nokogiri"

module Xslt

  C_CLASS_NAME = "Xslt"

  # Execute an XSLT
  #
  # @param xml_file [String] The name of the xml file to be processed
  # @param xslt_file [String] The name of the XSLT file
  # @param params [Hash] The parameters to be passed to the XSLT
  # @param [String] out_file The name of the output file
  # @return [Null]
  def Xslt.execute(xml_file, xslt_file, params, out_file)
    publicDir = Rails.root.join("public","upload")
    xsltDir = Rails.root.join("app", "assets", "transforms")
    outputFile = File.join(publicDir, out_file)
    xslt_file = File.join(xsltDir, xslt_file)
    paramString = Array.new
    params.each do |key,value|
      paramString.push key.to_s
      paramString.push value.to_s
    end
    document = Nokogiri::XML(File.open(xml_file))
    template = Nokogiri::XSLT(File.open(xslt_file))
    # Nokogiri transform doesn't seem to handle 'text' translations
    # Appears that transform returns an XMl document
    #transform = template.transform(document, paramString)
    transform = template.apply_to(document, paramString)
    File.open(outputFile, 'w').write(transform)
  end

end
