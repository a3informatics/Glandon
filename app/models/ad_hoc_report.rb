class AdHocReport < ActiveRecord::Base

	# Standard Active Record model

	# Create Report
  # Note: Not named create so as not to override
  #
  # @param filename [String] the report definiton file
  # @return [AdHocReport] the created object, contains errors, zero indicates success
  def self.create_report(params)
    object = self.new
    params[:files].reject!(&:blank?)
    filename = params[:files][0]
		definition = YAML.load_file(filename)
	  if check_definition(definition)
      new_filename = AdHocReportFiles.report_sparql_filename(definition[:label])
      if !AdHocReportFiles.exists?(new_filename)
        object.label = definition[:label]
  		  object.background_id = 0
	   	  object.active = false
	 	    object.sparql_file = AdHocReportFiles.report_sparql_filename(definition[:label])
        object.results_file = AdHocReportFiles.report_results_filename(definition[:label])
        AdHocReportFiles.save(object.sparql_file, definition) # Save the definition in the correct location
        object.save
      else
        object.errors.add(:base, "Report was not created. The report already exists")
      end
    else
      object.errors.add(:base, "Report was not created. The SPARQL file did not contain the correct format")
    end
    return object
  rescue Errno::ENOENT
    object.errors.add(:base, "Report was not created. The report definition file did not exist")
    return object
  rescue Psych::SyntaxError 
    object.errors.add(:base, "Report was not created. The SPARQL file contained a syntax error")
    return object
  end

  # Destroy Report
  # Note: Not named destroy so as not to override
  #
  # @return [Null] no return
  def destroy_report
    result = AdHocReportFiles.delete(self.sparql_file)
    result = AdHocReportFiles.delete(self.results_file)
    self.destroy
  end

  # Parameters? Does this report have parameters?
  #
  # @return [Boolean] true if parameters, false otherwise
  def parameters?
    definition = read_definition
    definition[:parameters].any?
  end

  # Parameters. Get the parameters.
  #
  # @return [Array] the parameters
  def parameters
    definition = read_definition
    definition[:parameters]
  end

  # Parameter. Get the parameter
  #
  # @return [Hash] the first parameter
  def parameter
    parameters.first
  end

  # Run A Report
  #
  # @return [Null] no return
  def run(params)
    self.last_run = Time.now
    dt_hash = { columns: [], data: [] }
    AdHocReportFiles.save(self.results_file, dt_hash)
    job = Background.create
    self.background_id = job.id
    self.active = true
    self.save
    #job.ad_hoc_report(self)
    definition = read_definition
    job.start("Run ad-hoc report: #{definition[:label]}", "Starting...") {self.execute(params)}
  end

  # Report Running
  #
  # @return [Boolean] true if running, false otherwise
  def running?
    result = false
    if self.background_id != -1
      job = Background.find(self.background_id)
      result = !job.complete 
    end
    self.active = result
    self.background_id = -1 if !result
    self.save
    return result
  end

  # Report Columns
  #
  # @return [Hash] the column hash
  def columns
    definition = read_definition
    return definition[:columns] if self.class.check_definition(definition)
    return {}
  end

  # To CSV
  #
  # @return [Object] the CSV serialization
  def to_csv
    dt_result = read_results
    if dt_result.blank?
      dt_result = { columns: [["No Results Error"]], data: [["No Results Error"]] }
    end
    csv_data = CSV.generate do |csv|
      headers = []
      dt_result[:columns].each { |x| headers << x.first }
      csv << headers
      dt_result[:data].each do |x|
        csv << x
      end
    end
    return csv_data
  end

  # Execute an ad-hoc report
  #
  # @return [Void] no return
  def execute(params)
    results = []
    definition = read_definition
    job = Background.find(self.background_id)
    sparql_query = get_query(params)
    query_results = Sparql::Query.new.query(sparql_query, "", [])
    triples = query_results.by_object_set(definition[:columns].keys)
    triples.each do |triple|
      entry = []
      definition[:columns].each do |key, column_def|
        entry << "#{triple[key.to_sym]}"
      end
      results << entry
    end
    column_labels = []
    definition[:columns].each do |key, entry|
      column_labels << [entry[:label]]
    end
    dt_hash = { columns: column_labels, data: results }
    AdHocReportFiles.save(self.results_file, dt_hash)
    job.end("Complete. Successful ad-hoc report.")
  rescue => e
    job.exception("Complete. Unsuccessful ad-hoc report. Exception detected.", e)
  end
  handle_asynchronously :execute unless Rails.env.test?

private

  # Return the query, substitute params if present
  def get_query(params)
    definition = read_definition
    query = definition[:query].dup
    return query if !self.parameters? || params.empty?
    # Note: Only setup for one parameter
    query.sub! '[[[parameter_1]]]', Uri.new(id: params.first).to_ref
    query
  end

  # Check the file structure
  def self.check_definition(definition)
    return false if definition.blank?
    result = definition.key?(:type) &&
      definition.key?(:parameters) &&
      definition.key?(:label) &&
      definition.key?(:columns) &&
      definition.key?(:query) &&
      definition[:type] == "Ad Hoc Report Definition"
    return result
  rescue => e
    return false
  end

  def read_definition
    AdHocReportFiles.read(self.sparql_file).deep_symbolize_keys
  rescue => e
    Errors.application_error(self.class.name, __method__.to_s, "Error reading ad hoc report definition file.")
  end

  def read_results
    AdHocReportFiles.read(self.results_file)
  end

end
