class CdiscCl < ThesaurusConcept
  
  attr_accessor :extensible
  
  # Constants
  C_CLASS_PREFIX = "THC"
  C_SCHEMA_PREFIX = "iso25964"
  C_INSTANCE_PREFIX = "mdrTh"
  C_CLASS_NAME = "CdiscCl"
  C_RDF_TYPE = "ThesaurusConcept"

  # Base namespace 
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  
  def self.diff?(clA, clB)
    #ConsoleLogger::log(C_CLASS_NAME,"diff?","*****Entry*****")
    result = super(clA, clB)
    if !result && (clA.extensible == clB.extensible)
      result = false
      if clA.children == nil
        clA.children = CdiscCl.allChildren(clA.id, clA.namespace)
      end
      if clB.children == nil
        clB.children = CdiscCl.allChildren(clB.id, clB.namespace)
      end
      if clA.children.length == clB.children.length
        #ConsoleLogger::log(C_CLASS_NAME,"diff?","A")
        clA.children.each do |key, cliA|
          #ConsoleLogger::log(C_CLASS_NAME,"diff?","B")
          if clB.children.has_key?(key)
            #ConsoleLogger::log(C_CLASS_NAME,"diff?","C")
            cliB = clB.children[key]
            if CdiscCli.diff?(cliA, cliB)
              #ConsoleLogger::log(C_CLASS_NAME,"diff?","D")
              result = true
              break
            end
          else
            result = true
            break
          end
        end  
      else
        result = true
      end
    else
      result = true
    end
    return result
  end
  
  def self.find(id, ns)
    object = super(id, ns)
    if object != nil
      object.extensible = object.properties.getOnly(C_SCHEMA_PREFIX, "extensible")
    end
    return object  
  end

  def self.allTopLevel(id, ns)
    results = super(id, ns)
    results.each do |key, tc|
      tc.extensible = tc.properties.getOnly(C_SCHEMA_PREFIX, "extensible")
    end
    return results  
  end

  def self.allChildren(id, ns)
    results = super(id, ns)
    results.each do |key, tc|
      tc.extensible = tc.properties.getOnly(C_SCHEMA_PREFIX, "extensible")
    end
    return results
  end

end
