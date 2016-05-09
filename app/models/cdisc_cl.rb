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
  
  def initialize(triples=nil, id=nil)
    if triples.nil?
      super
      self.extensible = false
    else
      super(triples, id)
    end
  end

  def self.find(id, ns, children=true)
    object = super(id, ns, children)
    object.extensible = object.get_extension(C_SCHEMA_PREFIX, "extensible").to_bool
    return object  
  end

  def self.find_from_triples(triples, id)
    object = new(triples, id)
    object.extensible = object.get_extension(C_SCHEMA_PREFIX, "extensible").to_bool
    object.triples = ""
    return object
  end

  def self.diff?(clA, clB)
    result = super(clA, clB)
    if !result && (clA.extensible == clB.extensible)
      #ConsoleLogger::log(C_CLASS_NAME,"diff?","1")
      result = false
      if clA.children.length == 0
        clA = CdiscCl.find(clA.id, clA.namespace)
      end
      clA_hash = clA.children.id_hash
      if clB.children.length == 0
        clB = CdiscCl.find(clB.id, clB.namespace)
      end
      clB_hash = clA.children.id_hash
      if clA.children.length == clB.children.length
        clA_hash.each do |key, cliA|
          if clB_hash.has_key?(key)
            cliB = clB_hash[key]
            if CdiscCli.diff?(cliA, cliB)
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
  
end
