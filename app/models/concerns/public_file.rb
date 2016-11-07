class PublicFile

	# Save a file in the specified subdir of Public
  #
  # @param sub_dir [string] The sub directory
  # @param filename [string] The filename
  # @return null
  def self.save(sub_dir, filename, results)
		publicDir = Rails.root.join("public", sub_dir)
	  outputFile = File.join(publicDir, filename)
		File.open(outputFile, "w+") do |f|
	  	f.write(results.to_s)
		end
	end

end