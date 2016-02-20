class CdiscCtChanges

	def self.save(results)
    	outputFile = file_path
    	File.open(outputFile, "w+") do |f|
      		f.write(results.to_json)
    	end
	end

	def self.exists?
		File.exist?(file_path)
	end

	def self.read
		file = File.read(file_path)
		return JSON.parse(file)
	end

private

	def self.file_path
		publicDir = Rails.root.join("public","upload")
    	outputFile = File.join(publicDir, "CDISC_CT_Changes.txt")
    	return outputFile
    end

end