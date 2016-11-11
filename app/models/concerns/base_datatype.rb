module BaseDatatype

	C_CLASS_NAME = "BaseDatatype"

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
			C_STRING => { :xsd_fragment => "string", :xsd => "http://www.w3.org/2001/XMLSchema#string", :label => "String", :short_label => "S", :odm => "text", :display => true},
			C_INTEGER => { :xsd_fragment => "integer", :xsd => "http://www.w3.org/2001/XMLSchema#integer", :label => "Integer", :short_label => "I", :odm => "integer", :display => true},
			C_POSITIVE_INTEGER => { :xsd_fragment => "positiveInteger", :xsd => "http://www.w3.org/2001/XMLSchema#positiveInteger", :label => "Integer", :short_label => "I", :odm => "integer", :display => false},
			C_BOOLEAN => { :xsd_fragment => "boolean", :xsd => "http://www.w3.org/2001/XMLSchema#boolean", :label => "Boolean", :short_label => "B", :odm => "boolean", :display => true},
			C_DATETIME => { :xsd_fragment => "dateTime", :xsd => "http://www.w3.org/2001/XMLSchema#dateTime", :label => "Datetime", :short_label => "D+T", :odm => "dataTime", :display => true},
			C_DATE => { :xsd_fragment => "date", :xsd => "http://www.w3.org/2001/XMLSchema#date", :label => "Date", :short_label => "D", :odm => "date", :display => true},
			C_TIME => { :xsd_fragment => "time", :xsd => "http://www.w3.org/2001/XMLSchema#time", :label => "Time", :short_label => "T", :odm => "time", :display => true},
			C_FLOAT => { :xsd_fragment => "float", :xsd => "http://www.w3.org/2001/XMLSchema#float", :label => "Float", :short_label => "F", :odm => "float", :display => true}
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

end