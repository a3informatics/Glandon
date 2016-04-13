class CdiscCtChanges

	C_ALL_CT = "All_CT"
	C_ALL_SUB = "All_Submission"
    C_TWO_CT = "Two_CT"
	C_CODELIST = "Codelist"
	C_CLASS_NAME = "CdiscCtChanges"

	def self.save(type, results, params={})
    	#ConsoleLogger::log(C_CLASS_NAME, "save", "*****ENTRY*****")
    	#ConsoleLogger::log(C_CLASS_NAME, "save", "Type=" + type.to_s + ", params=" + params.to_s)
    	outputFile = file_path(type, params)
    	File.open(outputFile, "w+") do |f|
      		f.write(results.to_json)
    	end
	end

	def self.exists?(type, params={})
		File.exist?(file_path(type, params))
	end

	def self.read(type, params={})
		file = File.read(file_path(type, params))
		return JSON.parse(file)
	end

    # Be very careful, this is dangerous!!!!
    #def self.delete()
    #    publicDir = dir_path()
    #    #FileUtils.rm_rf(Dir.glob(publicDir + '/*'))
    #end

private

	def self.file_path(type, params)
		#ConsoleLogger::log(C_CLASS_NAME, "file_path", "*****ENTRY*****")
    	#ConsoleLogger::log(C_CLASS_NAME, "file_path", "Type=" + type.to_s + ", params=" + params.to_s)
    	publicDir = dir_path()
    	if type == C_ALL_CT
    		filename = "CDISC_CT_Changes.txt"
    		outputFile = File.join(publicDir, filename)
    	elsif type == C_ALL_SUB
            filename = "CDISC_CT_Submission_Changes.txt"
            outputFile = File.join(publicDir, filename)
        elsif type == C_TWO_CT
    		filename = "CDISC_CT_" + params[:new_version] + "_" + params[:old_version] + "_Changes.txt"
    		outputFile = File.join(publicDir, filename)
    	elsif type == C_CODELIST
    		filename = "CDISC_CT_" + params[:codelist] + "_Changes.txt"
    		outputFile = File.join(publicDir, filename)    		
    	else
    		filename = "CDISC_CT_TypeError_Changes.txt"
    		outputFile = File.join(publicDir, filename)    		
    	end
    	return outputFile
    end

    def self.dir_path()
        return Rails.root.join("public","results")
    end
end