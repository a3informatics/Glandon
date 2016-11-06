module BaseDatatype

	C_CLASS_NAME = "BaseDatatype"

	C_STRING = "string"
	C_INTEGER = "integer"
	C_POSITIVE_INTEGER = "positiveInteger"
	C_BOOLEAN = "boolean"
	C_DATETIME = "dateTime"
	
	@@generic_to_xsd_fragment = 
		{ 
			C_STRING => "string",
			C_INTEGER => "integer",
			C_POSITIVE_INTEGER => "positiveInteger",
			C_BOOLEAN => "boolean",
			C_DATETIME => "dateTime"
		}

	@@full_xsd_to_generic = 
		{ 
			"http://www.w3.org/2001/XMLSchema#string" => C_STRING,
			"http://www.w3.org/2001/XMLSchema#boolean" => C_BOOLEAN,
			"http://www.w3.org/2001/XMLSchema#integer" => C_INTEGER,
			"http://www.w3.org/2001/XMLSchema#positiveInteger" => C_POSITIVE_INTEGER,
			"http://www.w3.org/2001/XMLSchema#dateTime" => C_DATETIME
		}	

	@@label =
		{
			C_STRING => "String",
			C_INTEGER => "Integer",
			C_POSITIVE_INTEGER => "Integer",
			C_BOOLEAN => "Boolean",
			C_DATETIME => "dateTime"
		}

	# Method to get the xsd type given the generic type
	#
  # @param datatype [string] The generic base data type
  # @return [string] The xsd datatype
  def self.to_xsd(datatype)
		result = ""
		if @@generic_to_xsd_fragment.has_key?(datatype)
			result = "#{@@generic_to_xsd_fragment[datatype]}"
		end
		return result
	end
	
	# Method to get the generic type given the xsd type
	#
  # @param uri [string] The xsd base data type
  # @return [string] The generic datatype
  def self.from_xsd(uri)
  	result = ""
  	if @@full_xsd_to_generic.has_key?(uri)
			result = @@full_xsd_to_generic[uri]
		end
		return result
	end
	
	# Method to get the human readable label given the generic type
	#
  # @param datatype [string] The generic base data type
  # @return [string] The xsd datatype
  def self.to_label(datatype)
		result = ""
		if @@generic_to_xsd_fragment.has_key?(datatype)
			result = "#{@@label[datatype]}"
		end
		return result
	end
	
end