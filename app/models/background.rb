class Background < ActiveRecord::Base

  include CdiscTermUtility
  
  C_CLASS_NAME = "Background"

	
	# Import CDISC SDTM Model
  #
  # @param [Hash] params Parameters
  # @option [String] :date The release date of the version being created
  # @option [String] :version The version being created
  # @option [String] :files Array of files being used 
  # @return [void] no return
  def import_cdisc_sdtm_model(params)
    sparql = SparqlUpdateV2.new
    self.errors.clear
    self.update(
      description: "Import CDISC SDTM Model. Date: #{params[:date]}, Internal Version: #{params[:version]}.", 
      status: "Reading file.",
      started: Time.now())
    results = SdtmExcel.read_model(params, self.errors)
    if self.errors.count == 0
      self.update(status: "File successfully read.", percentage: 50, complete: false, completed: Time.now())
      models = results.select { |hash| hash[:type]=="MODEL" }
      if models.length == 1
        model = SdtmModel.build_and_sparql(models[0][:instance], sparql)
        ordinal = 1
        domains = results.select { |hash| hash[:type]=="MODEL_DOMAIN" }
        domains.each do |domain|
          model_domain = SdtmModelDomain.build_and_sparql(domain[:instance], sparql, model)
          ordinal += 1
        end
        PublicFile::save("test", "SDTM_Model_#{params[:version_label].gsub('.', '-')}.txt", sparql.to_s) if Rails.env.test?
        response = CRUD.update(sparql.to_s)
        if response.success?
          self.update(status: "Complete. Successful import.", percentage: 100, complete: true, completed: Time.now())
        else  
          self.update(status: "Complete. Unsuccessful import, SPARQL error.", percentage: 100, complete: true, completed: Time.now())
        end
      else
        self.update(status: "Complete. Unsuccessful import, multiple models. ", percentage: 100, complete: true, completed: Time.now())
      end
    else
      self.update(status: "Complete. Unsuccessful import. " + self.errors.full_messages.to_sentence, percentage: 100, complete: true, completed: Time.now())
    end
  rescue => e
    self.update(status: "Complete. Unsuccessful import. Exception detected: #{e.to_s}. Backtrace: #{e.backtrace}", percentage: 100, complete: true, completed: Time.now())
  end
  handle_asynchronously :import_cdisc_sdtm_model unless Rails.env.test?

  # Import CDISC SDTM Implementation Guide
  #
  # @param [Hash] params Parameters
  # @option [String] :date The release date of the version being created
  # @option [String] :version The version being created
  # @option [String] :files Array of files being used 
  # @return [void] no return
  def import_cdisc_sdtm_ig(params)
    sparql = SparqlUpdateV2.new
    self.errors.clear
    self.update(
      description: "Import CDISC SDTM Implementation Guide. Date: " + params[:date] + ", Internal Version: " + params[:version] + ".", 
      status: "Reading file.",
      started: Time.now())
    results = SdtmExcel.read_ig(params, self.errors)
    if self.errors.empty?
      self.update(status: "File successfully read.", percentage: 50, complete: false, completed: Time.now())
      uri = UriV2.new(uri: params[:model_uri])
      model = SdtmModel.find(uri.id, uri.namespace)
      ig_params = results.select { |hash| hash[:type]=="IG" }
      domain_params = results.select { |hash| hash[:type]=="IG_DOMAIN" }
      if !ig_params.empty?
      	ig = SdtmIg.build(ig_params[0][:instance])
      	if ig.create_permitted? && ig.errors.empty?
      		ig.to_sparql_v2 
        	domain_params.each do |domain|
          	ig_domain = SdtmIgDomain.build(domain[:instance], model)
        		if ig_domain.create_permitted? && ig_domain.errors.empty?
        			ig_domain.to_sparql_v2
        		else
      		  	self.update(status: "Complete. Unsuccessful import, domain error: " + ig_domain.errors.full_messages.to_sentence, percentage: 100, complete: true, completed: Time.now())
        		end
      		end
        	PublicFile::save("upload", "SDTM_IG_#{params[:version_label].gsub('.', '-')}.txt", sparql.to_s) if Rails.env.test?
        	response = CRUD.update(sparql.to_s)
        	if response.success?
          	self.update(status: "Complete. Successful import.", percentage: 100, complete: true, completed: Time.now())
        	else  
          	self.update(status: "Complete. Unsuccessful import, SPARQL error.", percentage: 100, complete: true, completed: Time.now())
        	end
        else
        	self.update(status: "Complete. Unsuccessful import, IG error: " + ig.errors.full_messages.to_sentence, percentage: 100, complete: true, completed: Time.now())
        end
      else
        self.update(status: "Complete. Unsuccessful import. " + self.errors.full_messages.to_sentence, percentage: 100, complete: true, completed: Time.now())
      end
    else
      self.update(status: "Complete. Unsuccessful import. " + self.errors.full_messages.to_sentence, percentage: 100, complete: true, completed: Time.now())
    end
  rescue => e
    self.update(status: "Complete. Unsuccessful import. Exception detected: #{e.to_s}. Backtrace: #{e.backtrace}", percentage: 100, complete: true, completed: Time.now())
  end
  handle_asynchronously :import_cdisc_sdtm_ig unless Rails.env.test?

  # Import CDISC Terminology
  #
  # @param params [Hash] Parameters
  # @option opts [String] :date The release date of the version being created
  # @option opts [String] :version The version being created
  # @option opts [String] :files Array of files being used 
  # @option opts [String] :ns The namespace into which the terminology is being placed
  # @option opts [String] :cid The cid of the terminology
  # @option opts [String] :si The CID of the scoped identifier
  # @option opts [String] :rs The CID of the registration status
  # @return null No return, kicks off the background job
  def import_cdisc_term(params)
    # Create the background job status
    self.update(
    	description: "Import CDISC terminology file(s). Date: #{params[:date]}, Internal Version: #{params[:version]}.", 
    	status: "Building manifest file.",
    	started: Time.now())
    # Create manifest file
    manifest = build_cdisc_term_import_manifest(params[:date], params[:version], params[:files])
    # Create the thesaurus (does not actually create the database entries).
    # Entries in DB created as part of the XSLT and load
    self.update(status: "Transforming terminology file.", percentage: 10)
    # Transform the files and upload. Note the quotes around the namespace & II but not version, important!!
    filename = "CT_V#{params[:version]}.ttl"
    Xslt.execute(manifest, "thesaurus/import/cdisc/cdiscTermImport.xsl", 
      { :UseVersion => "#{params[:version]}", :Namespace => "'#{params[:ns]}'", 
        :SI => "'#{params[:si]}'", :RS => "'#{params[:rs]}'", :CID => "'#{params[:cid]}'" }, filename)
    # upload the file to the database. Send the request, wait the resonse
    self.update(status: "Loading file into database.", percentage: 50)
    publicDir = Rails.root.join("public","upload")
    outputFile = File.join(publicDir, filename)
    response = CRUD.file(outputFile)
    # And report ...
    if response.success?
      self.update(status: "Complete. Successful import.", percentage: 100, complete: true, completed: Time.now())
    else
      self.update(status: "Complete. Unsuccessful import.", percentage: 100, complete: true, completed: Time.now())
    end
  rescue => e
    self.update(status: "Complete. Unsuccessful import. Exception detected: #{e.to_s}. Backtrace: #{e.backtrace}", percentage: 100, complete: true, completed: Time.now())
  end
  handle_asynchronously :import_cdisc_term unless Rails.env.test?

  # Compare CDISC Terminology
  #
  # @param cdisc_terms [Array] Array of the terminologies to be compared
  # @param all [Boolean] All or two items to be compared. Defaults to false
  # @return null No return, kicks off the background job
  def compare_cdisc_term(cdisc_terms, all=false)
    version_labels = cdisc_terms.map {|x| "#{x.versionLabel}"}.join ', '
    self.update(
      description: "Detect CDISC Terminology changes, versions: #{version_labels}.", 
      status: "Starting.",
      started: Time.now())
    data = Array.new
    total_ct_count = cdisc_terms.length
    counts = Hash.new
    counts[:cl_count] = 0
    counts[:ct_count] = 0
    cdisc_terms.each do |term|
      load_term(data, term, counts, total_ct_count)
    end
    results = term_changes(data, counts[:cl_count])
    if all
      CdiscCtChanges.save(CdiscCtChanges::C_ALL_CT, results)
    else
      version_hash = {:new_version => cdisc_terms[1].version.to_s, :old_version => cdisc_terms[0].version.to_s} 
      CdiscCtChanges.save(CdiscCtChanges::C_TWO_CT, results, version_hash)
    end
    self.update(status: "Complete. Successful comparison.", percentage: 100, complete: true, completed: Time.now())
  rescue => e
    self.update(status: "Complete. Unsuccessful comparison. Exception detected: #{e.to_s}. Backtrace: #{e.backtrace}", percentage: 100, complete: true, completed: Time.now())
  end
  handle_asynchronously :compare_cdisc_term unless Rails.env.test?

  # Compare CDISC Terminology. Compares all versions
  #
  # @return null No return, kicks off the background job
  def changes_cdisc_term()
    cdisc_terms = CdiscTerm.all()
    compare_cdisc_term(cdisc_terms, true)
  end

  # Compare Submission Values (notation field). Compares all versions
  #
  # @return null No return, kicks off the background job
  def submission_changes_cdisc_term()
    # start
    self.update(
      description: "Detect CDISC Terminology submission value changes, all versions.", 
      status: "Starting.",
      started: Time.now())
    # Get the changes
    prev_ct = nil
    results = []
    cdisc_terms = CdiscTerm.all()
    cdisc_terms.each_with_index do |ct, index|
      results << { version_label: ct.versionLabel, version: ct.version, children: {} }
      if index != 0 
        results[index][:children] = CdiscTerm.submission_difference(prev_ct, ct)
      end
      prev_ct = ct
      p = 90.0 * (index.to_f/cdisc_terms.count.to_f)
      self.update(status: "Checked " + ct.versionLabel + ".", percentage: p.to_i)
    end
    # Format the results
    check = {}
    list = []
    versions = []
    transformed_results = {}
    results.each do |result|
      list = list | result[:children].keys
      versions << { version_label: result[:version_label], version: result[:version] }
    end
    list.each do |key|
      transformed_results[key] = { parent_identifier: "", label: "", preferred_term: "", notation: "", result: Array.new(versions.length, { previous: "", current: "", status: :no_change }) }
    end
    index = 0
    results.each do |result|
      result[:children].each do |key, child|
        if !check.has_key?(CdiscTermUtility.cli_key(child[:parent_identifier], child[:identifier]))
          transformed_results[key][:identifier] = child[:identifier]
          transformed_results[key][:parent_identifier] = child[:parent_identifier]
          transformed_results[key][:label] = child[:label]
          transformed_results[key][:notation] = child[:result][:previous]
          transformed_results[key][:preferred_term] = child[:preferred_term]
          transformed_results[key][:id] = child[:previous_uri].id
          check[CdiscTermUtility.cli_key(child[:parent_identifier], child[:identifier])] = true
        end      
        transformed_results[key][:result][index] = child[:result]
        transformed_results[key][:result][index][:status] = :updated
      end
      index += 1
    end
    # Finish up.
    transformed_results = transformed_results.sort.to_h
    CdiscCtChanges.save(CdiscCtChanges::C_ALL_SUB, { :versions => versions, :children => transformed_results })
    self.update(status: "Complete. Successful comparison.", percentage: 100, complete: true, completed: Time.now())
  rescue => e
    self.update(status: "Complete. Unsuccessful comparison. Exception detected: #{e.to_s}. Backtrace: #{e.backtrace}", percentage: 100, complete: true, completed: Time.now())
  end
  handle_asynchronously :submission_changes_cdisc_term unless Rails.env.test?

  # Assess impact of submission values (notation field) changes. Compares two versions
  #
  # @return null No return, kicks off the background job
  def submission_changes_impact(params)
    self.update(
      description: "Detect CDISC Terminology submission value changes impact.", 
      status: "Starting.",
      started: Time.now())
    old_ct = CdiscTerm.find(params[:old_id], params[:old_ns], false)
    new_ct = CdiscTerm.find(params[:new_id], params[:new_ns], false)   
    results = CdiscTerm.submission_difference(old_ct, new_ct)
    self.update(status: "Differences detected.", percentage: 50)
    index = 0
    items = []
    results.each do |key, entry|
      result = IsoConcept.links_to(entry[:previous_uri].id, entry[:previous_uri].namespace)
      items += linked_from(result)
      p = 50.0 + ((index.to_f/results.count.to_f) * 50.0)
      self.update(status: "Checked impact of change to #{key}.", percentage: p.to_i)
      index += 1
    end
    CdiscCtChanges.save(CdiscCtChanges::C_TWO_CT_IMPACT, items, params)
    self.update(status: "Complete. Successful impact assessment.", percentage: 100, complete: true, completed: Time.now())
  rescue => e
    self.update(status: "Complete. Unsuccessful impact assessment. Exception detected: #{e.to_s}. Backtrace: #{e.backtrace}", percentage: 100, complete: true, completed: Time.now())
  end
  handle_asynchronously :submission_changes_impact unless Rails.env.test?

  # Run an ad-hoc report
  #
  # @return [Null] no return, kicks off the background job
  def ad_hoc_report(report)
    results = []
    self.update(
      description: "Run ad-hoc report: #{report.label}", 
      status: "Starting.",
      started: Time.now())
    definition = AdHocReportFiles.read(report.sparql_file)
    response = CRUD.query(definition[:query])
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      entry = []
      definition[:columns].each do |key, column_def|
        variable = key.sub('?', '')
        is_uri = column_def[:type].upcase == "URI" ? true : false
        entry << ModelUtility.getValue(variable, is_uri, node)
      end
      results << entry
    end
    column_labels = []
    definition[:columns].each do |key, entry|
      value = []
      value << entry[:label]
      column_labels << value
    end
    dt_hash = { columns: column_labels, data: results }
    AdHocReportFiles.save(report.results_file, dt_hash)
    self.update(status: "Complete. Successful ad-hoc report.", percentage: 100, complete: true, completed: Time.now())
  rescue => e
    self.update(status: "Complete. Unsuccessful ad-hoc report. Exception detected: #{e.to_s}. Backtrace: #{e.backtrace}", percentage: 100, complete: true, completed: Time.now())
  end
  handle_asynchronously :ad_hoc_report unless Rails.env.test?

private

  # Builds the CDISC Terminology import manifest file
  def build_cdisc_term_import_manifest(date, version, files)
    builder = Nokogiri::XML::Builder.new(:encoding => 'utf-8') do |xml|
      xml.CDISCTerminology() {
        xml.Update(:date => date, :version => version) {
          files.each do |file|
            xml.File(:filename => file) 
          end
        }
      }
    end
    path = PublicFile.save("upload", "cdiscImportManifest.xml", builder.to_xml)
    return path
  end

  # Load a single version of the terminology.
  def load_term(data, ct, counts, total_ct_count)
    cdisc_term = CdiscTerm.find(ct.id, ct.namespace)
    data << {:term => cdisc_term}
    counts[:cl_count] += cdisc_term.children.length
    counts[:ct_count] += 1
    p = (counts[:ct_count].to_f / total_ct_count.to_f) * 10.0
    self.update(status: "Loaded release of #{ct.versionLabel}.", percentage: p.to_i)
    return counts
  end

  # Determine the changes across the terminologies.
  def term_changes(data, total_count)
  	current_count = 0
    results = []
    prev_term = nil
    data.each_with_index do |curr, index|
      curr_term = curr[:term]
      if index >= 1
        prev_term = data[index - 1][:term]
      end
      result = CdiscTerm.difference(prev_term, curr_term) 
      result[:version] = curr_term.version
      result[:date] = curr_term.versionLabel
      results << result
      current_count += curr_term.children.length
      p = 10.0 + ((current_count.to_f * 90.0)/total_count.to_f)
      self.update(status: "Checked #{curr_term.versionLabel} [#{current_count} of #{total_count}].", percentage: p.to_i)
    end
    return results
  end

  def linked_from(results)
    items = []
    results.each do |result|
      if !result[:local]
        mi = IsoManaged.find_parent(result[:uri].id, result[:uri].namespace)
        items += mi.find_links_from_to(from=false)
      end
    end
    return items
  end

end
