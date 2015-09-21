require "nokogiri"

module Xslt

  def Xslt.execute(xmlFile, xsltFile, params, outFile)
  
    p "XSLT XML=" + xmlFile
    p "XSLT XSLT=" + xsltFile
    p "XSLT params=" + params.to_s
    p "XSLT Output=" + outFile
    
    publicDir = Rails.root.join("public","upload")
    xsltDir = Rails.root.join("app","assets","transforms")
    outputFile = File.join(publicDir, outFile)
    xsltFile = File.join(xsltDir, xsltFile)
    
    p "XSLT XML=" + xmlFile
    p "XSLT XSLT=" + xsltFile
    p "XSLT Output=" + outputFile
    
    paramString = Array.new
    params.each do |key,value|
      paramString.push key.to_s
      paramString.push value.to_s
    end
    
    p "XSLT Param=" + paramString.to_s
    
    document = Nokogiri::XML(File.read(xmlFile))
    template = Nokogiri::XSLT(File.read(xsltFile))
    # Nokogiri transform doesn't seem to handle 'text' translations
    # Appears that transform returns an XMl document
    #transform = template.transform(document, paramString)
    transform = template.apply_to(document, paramString)
    File.open(outputFile, 'w').write(transform)
    
  end

  private
  
end
