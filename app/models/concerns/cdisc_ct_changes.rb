class CdiscCtChanges

	C_ALL_CT = "All_CT"
	C_ALL_SUB = "All_Submission"
  C_TWO_CT = "Compare_Two_CT"
	C_TWO_CT_IMPACT = "Impact_Two_CT"
  C_CODELIST = "Codelist"
	C_CLASS_NAME = "CdiscCtChanges"
  C_EXTENSION = "yaml"

	# Save a file
  #
  # * *Args*    :
  #   - +type+ -> The file type
  #   - +results+ -> The results
  #   - +params+ -> Parameters (old_version, new_version, codelist)
  # * *Returns* :
  #   - None
  def self.save(type, results, params={})
    outputFile = file_path(type, params)
    File.open(outputFile, "w+") do |f|
      #f.write(results.to_json)
      f.write(results.to_yaml)
    end
	end

	# See if file exisits
  #
  # * *Args*    :
  #   - +type+ -> The file type
  #   - +params+ -> Parameters (old_version, new_version, codelist)
  # * *Returns* :
  #   - Returns true/false
  def self.exists?(type, params={})
		File.exist?(file_path(type, params))
	end

	# Read a file
  #
  # * *Args*    :
  #   - +type+ -> The file type
  #   - +params+ -> Parameters (old_version, new_version, codelist)
  # * *Returns* :
  #   - Returns the JSON object
  def self.read(type, params={})
		#file = File.read(file_path(type, params))
		#json = JSON.parse(file)
    #return json
    return YAML.load_file(file_path(type, params))
	end

  # Get file path
  #
  # * *Args*    :
  # * *Returns* :
  #   - The file path. Set in config file.
  def self.dir_path()
    return APP_CONFIG['cdisc_ct_files']
  end

private

	def self.file_path(type, params)
  	publicDir = dir_path()
  	if type == C_ALL_CT
  		filename = "CDISC_CT_Changes.#{C_EXTENSION}"
  		outputFile = File.join(publicDir, filename)
  	elsif type == C_ALL_SUB
      filename = "CDISC_CT_Submission_Changes.#{C_EXTENSION}"
      outputFile = File.join(publicDir, filename)
    elsif type == C_TWO_CT
  		filename = "CDISC_CT_#{params[:new_version]}_#{params[:old_version]}_Changes.#{C_EXTENSION}"
  		outputFile = File.join(publicDir, filename)
  	elsif type == C_TWO_CT_IMPACT
      filename = "CDISC_CT_#{params[:new_version]}_#{params[:old_version]}_Impact.#{C_EXTENSION}"
      outputFile = File.join(publicDir, filename)
    elsif type == C_CODELIST
  		filename = "CDISC_CT_#{params[:codelist]}_Changes.#{C_EXTENSION}"
  		outputFile = File.join(publicDir, filename)    		
  	else
  		filename = "CDISC_CT_TypeError_Changes.#{C_EXTENSION}"
  		outputFile = File.join(publicDir, filename)    		
  	end
  	return outputFile
  end

end