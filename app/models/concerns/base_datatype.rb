module BaseDatatype

	C_CLASS_NAME = "BaseDatatype"
  C_XML_SCHEMA = "http://www.w3.org/2001/XMLSchema"

	C_STRING = "string"
	C_INTEGER = "integer"
	C_POSITIVE_INTEGER = "positiveInteger"
	C_BOOLEAN = "boolean"
	C_DATETIME = "dateTime"
	C_DATE = "date"
	C_TIME = "time"
	C_FLOAT = "float"
	
	@@map = 
		{ 
			C_STRING => { :xsd_fragment => "string", :xsd => "#{C_XML_SCHEMA}#string", :label => "String", :short_label => "S", :odm => "text", :display => true},
			C_INTEGER => { :xsd_fragment => "integer", :xsd => "#{C_XML_SCHEMA}#integer", :label => "Integer", :short_label => "I", :odm => "integer", :display => true},
			C_POSITIVE_INTEGER => { :xsd_fragment => "positiveInteger", :xsd => "#{C_XML_SCHEMA}#positiveInteger", :label => "Integer", :short_label => "I", :odm => "integer", :display => false},
			C_BOOLEAN => { :xsd_fragment => "boolean", :xsd => "#{C_XML_SCHEMA}#boolean", :label => "Boolean", :short_label => "B", :odm => "boolean", :display => true},
			C_DATETIME => { :xsd_fragment => "dateTime", :xsd => "#{C_XML_SCHEMA}#dateTime", :label => "Datetime", :short_label => "D+T", :odm => "datetime", :display => true},
			C_DATE => { :xsd_fragment => "date", :xsd => "#{C_XML_SCHEMA}#date", :label => "Date", :short_label => "D", :odm => "date", :display => true},
			C_TIME => { :xsd_fragment => "time", :xsd => "#{C_XML_SCHEMA}#time", :label => "Time", :short_label => "T", :odm => "time", :display => true},
			C_FLOAT => { :xsd_fragment => "float", :xsd => "#{C_XML_SCHEMA}#float", :label => "Float", :short_label => "F", :odm => "float", :display => true}
		}

	
	# Method to get the xsd type given the generic type
	#
  # @param datatype [string] The generic base data type
  # @return [string] The xsd datatype
  def self.to_xsd(datatype)
		result = ""
		if @@map.has_key?(datatype)
			result = "#{@@map[datatype][:xsd_fragment]}"
		end
		return result
	end
	
	# Method to get the generic type given the xsd type
	#
  # @param uri [string] The xsd base data type
  # @return [string] The generic datatype
  def self.from_xsd(uri)
  	results = @@map.select{|key, value| value[:xsd] == uri}
  	if results.length > 0
			return results.keys.first.to_s
		end
		return C_STRING
	end
	
	# Method to get the generic type given the xsd type using the fragment only
  #
  # @param [String] fragment the xsd fragment
  # @return [String] The generic datatype
  def self.from_xsd_fragment(fragment)
    uri = UriV3.new(namespace: C_XML_SCHEMA, fragment: fragment)
    results = @@map.select{|key, value| value[:xsd] == uri.to_s}
    if results.length > 0
      return results.keys.first.to_s
    end
    return C_STRING
  end
  
  # Method to get the generic type given the short label
	#
  # @param uri [string] The xsd base data type
  # @return [string] The generic datatype
  def self.from_short_label(uri)
  	results = @@map.select{|key, value| value[:short_label] == uri}
  	if results.length > 0
			return results.keys.first.to_s
		end
		return C_STRING
	end
	
	# Method to get the human readable label given the generic type
	#
  # @param datatype [string] The generic base data type
  # @return [string] The xsd datatype
  def self.to_label(datatype)
		result = ""
		if @@map.has_key?(datatype)
			result = "#{@@map[datatype][:label]}"
		end
		return result
	end
	
	# Method to get the human readable short label given the generic type
	#
  # @param datatype [string] The generic base data type
  # @return [string] The xsd datatype
  def self.to_short_label(datatype)
		result = ""
		if @@map.has_key?(datatype)
			result = "#{@@map[datatype][:short_label]}"
		end
		return result
	end

	# Method to get the human readable short label given the generic type
	#
  # @param datatype [string] The generic base data type
  # @return [string] The xsd datatype
  def self.to_odm(datatype)
		result = ""
		if @@map.has_key?(datatype)
			result = "#{@@map[datatype][:odm]}"
		end
		return result
	end

	# Method to get all displayable generic types
	#
  # @return [array] Array of entries that should be dispayed
  def self.display
		return @@map.select{|key, value| value[:display]}
	end

	# Valid
	#
	# @parma datatype [string] The datatype
	# @return [boolean] True if valid, false otherwise.
	def self.valid?(datatype)
		return @@map.has_key?(datatype)
	end

	# To JSON
	#
	# @return [String] The JSON serialization of the entire map
	def self.to_json
		return @@map.to_json
	end
	
	# Get Map
	#
	# @return [Hash] The map as defined
	def self.get_map
		return @@map
	end
end