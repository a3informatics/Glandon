require "nokogiri"

module Xslt

  C_CLASS_NAME = "Xslt"

  def Xslt.execute(xmlFile, xsltFile, params, outFile)
    
    publicDir = Rails.root.join("public","upload")
    xsltDir = Rails.root.join("app","assets","transforms")
    outputFile = File.join(publicDir, outFile)
    xsltFile = File.join(xsltDir, xsltFile)
    
    paramString = Array.new
    params.each do |key,value|
      paramString.push key.to_s
      paramString.push value.to_s
    end
    
    document = Nokogiri::XML(File.open(xmlFile))
    template = Nokogiri::XSLT(File.open(xsltFile))
    
    # Nokogiri transform doesn't seem to handle 'text' translations
    # Appears that transform returns an XMl document
    #transform = template.transform(document, paramString)
    transform = template.apply_to(document, paramString)
    File.open(outputFile, 'w').write(transform)
    
  end
  
  def Xslt.executeXML(xmlFile, xsltFile, params, outFile=nil)
    
    publicDir = Rails.root.join("public","upload")
    xsltDir = Rails.root.join("app","assets","transforms")
    xsltFile = File.join(xsltDir, xsltFile)
    if outFile != nil
      outputFile = File.join(publicDir, outFile)
    end

    paramString = Array.new
    params.each do |key,value|
      paramString.push key.to_s
      paramString.push value.to_s
    end
    
    document = Nokogiri::XML(File.open(xmlFile))
    template = Nokogiri::XSLT(File.open(xsltFile))
    
    # Nokogiri transform to return an XMl document
    transform = template.transform(document, paramString)
    #ConsoleLogger::log(C_CLASS_NAME,"executeXML","Transform=" + transform.to_s )
    #transform = template.apply_to(document, paramString)
    #File.open(outputFile, 'w').write(transform.to_s)
    if outFile != nil
      File.open(outputFile, "wb") do |f|
        transform.write_xml_to f
      end
      return nil
    else
      return transform.to_s
    end
    
  end

end
