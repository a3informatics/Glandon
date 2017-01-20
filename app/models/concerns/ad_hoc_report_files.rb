class AdHocReportFiles

	C_CLASS_NAME = "AdHocReportFiles"
  C_REPORT_EXTENSION = "yaml"
  C_SPARQL_EXTENSION = "yaml"

  # SPARQL Filename
  #
  # @param label [String] the filename root
  # @results [String] the sparql filename (note no path info)
  def self.report_sparql_filename(label)
    return "#{label_to_filename(label)}_sparql.#{C_SPARQL_EXTENSION}"
  end

  # Results Filename
  #
  # @param label [String] the filename root
  # @results [String] the results filename (note no path info)
  def self.report_results_filename(label)
    return "#{label_to_filename(label)}_results.#{C_REPORT_EXTENSION}"
  end
  
	# CSV Filename
  #
  # @param label [String] the filename root
  # @results [String] the results filename (note no path info)
  def self.report_csv_filename(label)
    return "#{label_to_filename(label)}_results.csv"
  end
  
  # Save a file
  #
  # @param filename [String] the filename with extension but no path
  # @param results [Hash] The results
  # @results [Boolean] true if file saved, false otherwise
  def self.save(filename, results)
    outputFile = file_path(filename)
    File.open(outputFile, "w+") do |f|
      f.write(results.to_yaml)
    end
    return true
  rescue => e
    ConsoleLogger.info(C_CLASS_NAME, "save", "Failed to save file #{filename}. Exception #{e} raised.")
    return false
	end

	# See if file exisits
  #
  # @param filename [String] the filename with extension but no path
  # @results [Boolean] true if the file exists, false otherwise
  def self.exists?(filename)
    File.exist?(file_path(filename))
	end

  # Delete File
  #
  # @param filename [String] the filename with extension but no path
  # @results [Boolean] true if the file deleted, false otherwise
  def self.delete(filename)
    File.delete(file_path(filename))
    return true
  rescue => e
    ConsoleLogger.info(C_CLASS_NAME, "delete", "Failed to delete file #{filename}. Exception #{e} raised.")
    return false
  end

	# Read a file
  #
  # @param filename [String] the filename with extension but no path
  # @results [Hash] a hash containing the file contents
  def self.read(filename)
		return YAML.load_file(file_path(filename))
  rescue => e
    ConsoleLogger.info(C_CLASS_NAME, "read", "Failed to read file #{filename}. Exception #{e} raised.")
    return ""
	end

  # Directory Path. Obtain the directory path.
  #
  # @return [String] the file path where the files are placed
  def self.dir_path()
    return APP_CONFIG['ad_hoc_report_files']
  end

private

	def self.file_path(filename)
  	return File.join(dir_path(), filename)
  end

  def self.label_to_filename(label)
    return label.downcase.strip.gsub(' ', '_').gsub(/[^\w]/, '')
  end

end