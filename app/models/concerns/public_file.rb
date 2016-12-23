class PublicFile

	# Save a file in the specified subdir of Public
  #
  # @param sub_dir [string] The sub directory
  # @param filename [string] The filename
  # @return null
  def self.save(sub_dir, filename, results)
		public_dir = Rails.root.join("public", sub_dir)
	  output_file = File.join(public_dir, filename)
		File.open(output_file, "wb") do |f|
	  	f.write(results.to_s)
		end
		return output_file
	end

end