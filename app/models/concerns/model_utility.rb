require "uri"

module ModelUtility

  C_CLASS_NAME = "ModelUtility"

  def ModelUtility.to_boolean(s)
    !!(s =~ /^(true|t|yes|y|1)$/i)
  end
  
  def ModelUtility.validIdentifier?(value, object)
    result = value.match /\A[A-Za-z0-9 ]+\z/ 
    return true if result != nil
    object.errors.add(:identifer, "contains invalid characters or is empty")
    return false
  end

  def ModelUtility.validShortName?(value, object)
    result = value.match /\A[A-Za-z0-9]+\z/ 
    return true if result != nil
    object.errors.add(:short_name, "contains invalid characters or is empty")
    return false
  end

  def ModelUtility.validFreeText?(symbol, value, object)
    result = value.match /^\A[A-Za-z0-9.!?,_ \-()]+\z/ 
    return true if result != nil
    object.errors.add(symbol, "contains invalid characters or is empty")
    return false
  end

  def ModelUtility.validLabel?(value,object)
    return validFreeText?(:label, value, object)
  end

  def ModelUtility.version_namespace(version, ns, org)
    uri = Uri.new
    uri.setUri(ns)
    uri.extendPath(org + "/V" + version.to_s)
    return uri
  end

  def ModelUtility.buildUri(namespace, id)
    uri = Uri.new
    uri.setNsCid(namespace, id)
    return uri.to_ref
  end
  
  def ModelUtility.buildCidIdentifier(prefix, identifier)  
    uri = Uri.new
    uri.setCidNoVersion(prefix, identifier)
    return uri.getCid
  end
  
  def ModelUtility.build_full_cid(prefix, org_name, identifier, version="")  
    uri = Uri.new
    uri.set_full_cid(prefix, org_name, identifier, version)
    return uri.getCid
  end
  
  #def ModelUtility.buildCidIdentifierVersion(prefix, identifer, version)
  #  uri = Uri.new
  #  uid = createUid(identifer)
  #  uri.setCidWithVersion(prefix, uid, version)
  #  return uri.getCid
  #end
  
  #def ModelUtility.buildCid(prefix)
  #  return buildCidUid(prefix, SecureRandom.hex(8))
  #end

  def ModelUtility.cidSwapPrefix(cid, prefix)
    uri = Uri.new
    uri.setCid(cid)
    uri.prefix = prefix
    return uri.getCid
  end
  
  def ModelUtility.cidAddSuffix(cid, suffix)  
    uri = Uri.new
    uri.setCid(cid)
    uri.extendUid(suffix)
    return uri.getCid
  end
  
  def ModelUtility.extractCid(uri)
    object = Uri.new()
    object.setUri(uri)
    return object.getCid()
  end
  
  def ModelUtility.extractNs(uri)
    object = Uri.new()
    object.setUri(uri)
    return object.getNs()
  end
  
  def ModelUtility.extractUid(cid)
    object = Uri.new()
    object.setCid(cid)
    return object.uid()
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
  
  def ModelUtility.toBoolean(value)
    if value == "true"
      return true
    else
      return false
    end
  end

end
