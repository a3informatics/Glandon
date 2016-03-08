class BiomedicalConceptCore::Property < IsoConcept

  attr_accessor :alias, :collect, :enabled, :qText, :pText, :datatype, :format,  :bridgPath, :values, :childComplex, :datatypeComplex, :ordinal
  validates_presence_of :alias, :label, :collect, :enabled, :questionText, :promptText, :datatype, :format, :bridgPath, :values, :childComplex, :datatypeComplex, :ordinal

  # Constants
  C_SCHEMA_PREFIX = "cbc"
  C_INSTANCE_PREFIX = "mdrBcs"
  C_CLASS_NAME = "BiomedicalConceptCore::Property"
  C_CID_PREFIX = "BC"
  C_RDF_TYPE = "Property"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  
  def self.find(id, ns)
    #ConsoleLogger::log(C_CLASS_NAME,"find","*****ENTRY*****")
    object = super(id, ns)
    if object.links.exists?(C_SCHEMA_PREFIX, "hasComplexDatatype")
      object.values = nil
      object.childComplex = BiomedicalConceptCore::Datatype.findForChild(object, ns)
      object.datatypeComplex = nil
    else
      values_hash = BiomedicalConceptCore::PropertyValue.findForParent(object, ns)
      object.values = []
      values_hash.each do |key, value|
        object.values[value.ordinal-1] = value 
      end
      if object.links.exists?(C_SCHEMA_PREFIX, "isPropertyOf")
        links = object.links.get(C_SCHEMA_PREFIX, "isPropertyOf")
        if links[0] != ""
          object.datatypeComplex = BiomedicalConceptCore::Datatype.findParent(ModelUtility.extractCid(links[0]),ModelUtility.extractNs(links[0]))
        end
      end
      object.childComplex = nil
      setAttributes(object)
    end
    return object  
  end

  def self.findForParent(object, ns)
    results = super(C_SCHEMA_PREFIX, "hasProperty", object.links, ns)
    return results
  end

  def isComplex?
    return self.childComplex != nil
  end

	def flatten
		#ConsoleLogger::log(C_CLASS_NAME,"flatten","*****ENTRY*****")
		results = Hash.new
		if self.isComplex? 
			self.childComplex.each do |key, item|
				more = item.flatten
				more.each do |iKey, datatype|
					results[iKey] = datatype
				end
			end
		end
		return results
	end

	def to_edit
		#ConsoleLogger::log(C_CLASS_NAME,"flatten","*****ENTRY*****")
		results = Hash.new
		if self.isComplex? 
			self.childComplex.each do |key, item|
				more = item.to_edit
				more.each do |iKey, datatype|
					results[iKey] = datatype
				end
			end
		end
		return results
	end
	
  def to_sparql(parent, ordinal, params, sparql, prefix)
    id = parent + Uri::C_UID_SECTION_SEPARATOR + 'P' + ordinal.to_s
    sparql.triple("", id, "rdf", "type", prefix, "Property")
    sparql.triple("", id, prefix, "isPropertyOf", "", parent.to_s)
    
    if self.isComplex? 
      sparql.triple_primitive_type("", id, prefix, "alias", "*****Something Here*****", "string")
      sparql.triple_primitive_type("", id, prefix, "name", "*****Something Here*****", "string")
      ordinal = 1
      self.childComplex.each do |key, datatype|
        sparql.triple("", id, prefix, "hasComplexDatatype", "", id + Uri::C_UID_SECTION_SEPARATOR + 'DT' + ordinal.to_s)
        ordinal += 1
      end
    else
      property = params[self.id]
      sparql.triple_primitive_type("", id, prefix, "alias", property[:alias], "string")
      sparql.triple_primitive_type("", id, prefix, "ordinal", ordinal.to_s, "positiveInteger")
      sparql.triple_primitive_type("", id, prefix, "qText", property[:qText], "string")
      sparql.triple_primitive_type("", id, prefix, "pText", property[:pText], "string")
      sparql.triple_primitive_type("", id, prefix, "enabled", property[:enabled], "boolean")
      sparql.triple_primitive_type("", id, prefix, "collect", property[:collect], "boolean")
      sparql.triple_primitive_type("", id, prefix, "bridgPath", get_literal("bridgPath"), "string")
      sparql.triple_primitive_type("", id, prefix, "simpleDatatype", get_literal("simpleDatatype"), "string")
      ConsoleLogger::log(C_CLASS_NAME,"to_bc","Property=" + property.to_s)
      if property.has_key?(:values)
        ordinal = 1
        values = property[:values]
        values.each do |key, value|
          sparql.triple("", id, prefix, "hasValue", "", id + Uri::C_UID_SECTION_SEPARATOR + 'PV' + ordinal.to_s)
          ordinal += 1
        end
      end
    end
    
    if self.isComplex? 
      ordinal = 1
      self.childComplex.each do |key, datatype|
        datatype.to_sparql(id, ordinal, params, sparql, prefix)
        ordinal += 1
      end
    else
      property = params[self.id]
      if property.has_key?(:values)
        ordinal = 1
        values = property[:values]
        ConsoleLogger::log(C_CLASS_NAME,"to_sparql","Values=" + values.to_s)
        values.each do |key, value|
          ConsoleLogger::log(C_CLASS_NAME,"to_sparql","Value=" + value.to_s)
          BiomedicalConceptCore::PropertyValue.to_sparql(id, ordinal, value, sparql, prefix)
          ordinal += 1
        end
      end
    end
  end

	def to_minimum
    values = []
    if self.values != nil
      self.values.each do |property_value|
        cli = property_value.cli
        values << {:uri_id => cli.id, :uri_ns => cli.namespace, :identifier => cli.identifier, :useful_1 => cli.notation, :useful_2 => "", :note_type => 0 }
      end
		end
    return {
			:alias => self.alias, :collect => self.collect.to_s, :enabled => self.enabled.to_s, :qText => self.qText, 
			:pText => self.pText, :datatype => self.datatype, :format => self.format, :values => values 
			}
	end
	
private
  
  def get_ref(predicate)
    result = ""
    ref = self.links.get(C_SCHEMA_PREFIX, predicate)
    if ref.length >= 1
      result = ModelUtility::extractCid(ref[0])
    end
    return result
  end

  def get_literal(predicate)
    result = ""
    ref = self.properties.get(C_SCHEMA_PREFIX, predicate)
    if ref.length >= 1
      result = ref[0][:value]
    end
    return result
  end

  def self.setAttributes(object)
    count = 0
    object.label = object.properties.getOnly(C_SCHEMA_PREFIX, "name")[:value]      
    object.alias = object.properties.getOnly(C_SCHEMA_PREFIX, "alias")[:value]      
    object.collect = ModelUtility.toBoolean(object.properties.getOnly(C_SCHEMA_PREFIX, "collect")[:value])      
    object.enabled = ModelUtility.toBoolean(object.properties.getOnly(C_SCHEMA_PREFIX, "enabled")[:value])      
    object.qText = object.properties.getOnly(C_SCHEMA_PREFIX, "qText")[:value]    
    object.pText = object.properties.getOnly(C_SCHEMA_PREFIX, "pText")[:value]  
    object.bridgPath = object.properties.getOnly(C_SCHEMA_PREFIX, "bridgPath")[:value]
    object.ordinal = object.properties.getOnly(C_SCHEMA_PREFIX, "ordinal")[:value]
    #if object.values != nil
    #    count = object.values.values[0].clis.length
    #end
    if object.datatypeComplex != nil
      object.datatype = getDatatype(object.datatypeComplex.datatype, count)  
      object.format = getFormat(object.datatype)  
    else
      object.datatype = ""
      object.format = ""
    end
    #ConsoleLogger::log(C_CLASS_NAME,"setAttributes","datatype=" + object.to_json)
  end

  def self.getFormat(datatype)
    if datatype == "F"
      return "5.1"
    else
      return ""
    end
  end

  def self.getDatatype (parentDatatype, count)
    result = ""
    if count > 0 then
      result = "CL"
    else
      if parentDatatype == "CD"
        result = "CL"
      elsif parentDatatype == "PQR"
        result = "F"
      elsif parentDatatype == "BL"
        result = "BL"
      elsif parentDatatype == "SC"
        result = "CL"
      elsif parentDatatype == "IVL_TS_DATETIME"
        result = "D+T"
      elsif parentDatatype == "TS_DATETIME"
        result = "D+T"
      else
        result = "S"
      end
    end
    #ConsoleLogger::log(C_CLASS_NAME,"getDatatype","Parent=" + parentDatatype + ", Result=" + result + ", Count=" + count.to_s)
    return result 
  end

end