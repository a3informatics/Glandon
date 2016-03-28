class BiomedicalConceptCore::Property < IsoConceptNew

  attr_accessor :alias, :collect, :enabled, :qText, :pText, :simpleDatatype, :datatype, :format,  :bridgPath, :values, :childComplex, :datatypeComplex, :ordinal
  validates_presence_of :alias, :label, :collect, :enabled, :qText, :pText, :simpleDatatype, :datatype, :format, :bridgPath, :values, :childComplex, :datatypeComplex, :ordinal

  # Constants
  C_SCHEMA_PREFIX = "cbc"
  C_INSTANCE_PREFIX = "mdrBcs"
  C_CLASS_NAME = "BiomedicalConceptCore::Property"
  C_CID_PREFIX = "BC"
  C_RDF_TYPE = "Property"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  
  def initialize(triples=nil, id=nil)
    self.values = Array.new
    self.childComplex = nil
    self.datatypeComplex = nil
    if triples.nil?
      super
      self.alias = ""
      self.collect = false
      self.enabled = false
      self.qText = ""
      self.pText = ""
      self.datatype = ""
      self.format = ""
      self.bridgPath = ""
      self.ordinal = 0
    else
      self.alias = ""
      self.collect = false
      self.enabled = false
      self.qText = ""
      self.pText = ""
      self.datatype = ""
      self.format = ""
      self.bridgPath = ""
      self.ordinal = 0
      super(triples, id)    
    end
  end

  def self.find(id, ns, children=true)
    object = super(id, ns)
    if children
      children_from_triples(object, object.triples, id)
    end
    object.triples = ""
    return object  
  end

  def self.find_from_triples(triples, id)
    #ConsoleLogger::log(C_CLASS_NAME,"find_from_triples","*****ENTRY*****")
    object = new(triples, id)
    children_from_triples(object, triples, id)
    object.triples = ""
    return object
  end

  def isComplex?
    return self.childComplex != nil
  end

	def flatten
		#ConsoleLogger::log(C_CLASS_NAME,"flatten","*****ENTRY*****")
		results = Array.new
		if self.isComplex? 
			self.childComplex.each do |item|
				more = item.flatten
				more.each do |datatype|
					results << datatype
				end
			end
		end
		return results
	end

	def to_edit
		#ConsoleLogger::log(C_CLASS_NAME,"flatten","*****ENTRY*****")
		results = Array.new
		if self.isComplex? 
			self.childComplex.each do |item|
				more = item.to_edit
				more.each do |datatype|
					results << datatype
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
      # TODO: This needs to be made better. Array versus hash handling. Currently an array.
      properties = params.select {|key, item| item[:id] == self.id}
      property = properties.values[0]
      #ConsoleLogger::log(C_CLASS_NAME,"to_bc","Property=" + property.to_s)
      sparql.triple_primitive_type("", id, prefix, "alias", property[:alias], "string")
      sparql.triple_primitive_type("", id, prefix, "ordinal", ordinal.to_s, "positiveInteger")
      sparql.triple_primitive_type("", id, prefix, "qText", property[:qText], "string")
      sparql.triple_primitive_type("", id, prefix, "pText", property[:pText], "string")
      sparql.triple_primitive_type("", id, prefix, "enabled", property[:enabled], "boolean")
      sparql.triple_primitive_type("", id, prefix, "collect", property[:collect], "boolean")
      sparql.triple_primitive_type("", id, prefix, "bridgPath", self.bridgPath.to_s, "string")
      sparql.triple_primitive_type("", id, prefix, "simpleDatatype", self.simpleDatatype.to_s, "string")
      #ConsoleLogger::log(C_CLASS_NAME,"to_bc","Property=" + property.to_s)
      if property.has_key?(:values)
        ordinal = 1
        values = property[:values]
        values.each do |value|
          sparql.triple("", id, prefix, "hasValue", "", id + Uri::C_UID_SECTION_SEPARATOR + 'PV' + ordinal.to_s)
          ordinal += 1
        end
      end
    end  
    if self.isComplex? 
      ordinal = 1
      self.childComplex.each do |datatype|
        datatype.to_sparql(id, ordinal, params, sparql, prefix)
        ordinal += 1
      end
    else
      property = params.select {|key, item| item[:id] == self.id}
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
			:id => self.id, :alias => self.alias, :collect => self.collect.to_s, :enabled => self.enabled.to_s, :qText => self.qText, 
			:pText => self.pText, :datatype => self.datatype, :format => self.format, :values => values 
			}
	end
	
private
  
  def self.children_from_triples(object, triples, id)
    #ConsoleLogger::log(C_CLASS_NAME,"children_from_triples","*****ENTRY*****")
    if object.link_exists?(C_SCHEMA_PREFIX, "hasComplexDatatype")
      #ConsoleLogger::log(C_CLASS_NAME,"children_from_triples","Complex")
      object.values = nil
      links = object.get_links(C_SCHEMA_PREFIX, "hasComplexDatatype")
      object.childComplex = BiomedicalConceptCore::Datatype.find_for_child(triples, links)
      object.datatypeComplex = nil
    else
      #ConsoleLogger::log(C_CLASS_NAME,"children_from_triples","Simple")
      object.childComplex = nil
      links = object.get_links(C_SCHEMA_PREFIX, "hasValue")
      values = BiomedicalConceptCore::PropertyValue.find_for_parent(triples, links)
      values.sort! {|item| item.ordinal }
      object.values = values
      count = object.values.length

      if object.link_exists?(C_SCHEMA_PREFIX, "isPropertyOf")
        links = object.get_links(C_SCHEMA_PREFIX, "isPropertyOf")
        object.datatypeComplex = BiomedicalConceptCore::Datatype.find_parent(triples, ModelUtility.extractCid(links[0]))
        object.datatype = getDatatype(object.datatypeComplex.datatype, count)  
        object.format = getFormat(object.datatype)  
      end
    end
    return object  
  end

  def get_ref(predicate)
    result = ""
    ref = self.links.get(C_SCHEMA_PREFIX, predicate)
    if ref.length >= 1
      result = ModelUtility::extractCid(ref[0])
    end
    return result
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