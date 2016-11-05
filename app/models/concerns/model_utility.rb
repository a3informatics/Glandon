require "uri"

module ModelUtility

  C_CLASS_NAME = "ModelUtility"

  def ModelUtility.buildUri(namespace, id)
    IsoUtility.uri_ref(namespace, id)
  end
  
  def ModelUtility.extractCid(uri)
    IsoUtility.extract_cid(uri)
  end
  
  def ModelUtility.extractNs(uri)
    IsoUtility.extract_namespace(uri)
  end
  
  def ModelUtility.getValue(name, uri, node)
    path = "binding[@name='" + name + "']/"
    if uri 
      path = path + "uri"
    else
      path = path + "literal"
    end
    valueArray = node.xpath(path)
    if valueArray.length == 1
      #ConsoleLogger::log(C_CLASS_NAME,"getValue","Result=" + valueArray[0].text)
      return valueArray[0].text
    else
      #ConsoleLogger::log(C_CLASS_NAME,"getValue","Blank result")
      return ""
    end
  end
  
end
