class Background < ActiveRecord::Base

  include CdiscTermUtility
  
  C_CLASS_NAME = "Background"

	
	# Import CDISC Terminology Changes
  #
  # @param [Hash] params Parameters
  # @option params [String] :uri The uri of the term to which the changes relate
  # @option params [String] :version The version of the term to which the changes relate
  # @option params [String] :files Array of files being used 
  # @return [void] no return
  def import_cdisc_term_changes(params)
    start_cdisc_import("Import CDISC terminology change information. Internal Version: #{params[:version]}.")
    results = TermChangeExcel.read_changes(params, errors)
    if self.errors.empty?
    	report_file_successfully_read
      process_cdisc_term_changes_import(params, results)
    else
      report_excel_errors
    end
  rescue => e
		report_import_exception(e)
  end
  handle_asynchronously :import_cdisc_term_changes unless Rails.env.test?

	# Import CDISC SDTM Model
  #
  # @param [Hash] params Parameters
  # @option params [String] :date The release date of the version being created
  # @option params [String] :version The version
  # @option params [String] :version_label The version label 
  # @option params [String] :files Array of files being used 
  # @return [void] no return
  def import_cdisc_sdtm_model(params)
    start_cdisc_import("Import CDISC SDTM Model. Date: #{params[:date]}, Internal Version: #{params[:version]}.")
    results = SdtmExcel.read_model(params, self.errors)
    if self.errors.empty?
    	report_file_successfully_read
      process_cdisc_sdtm_model_import(params, results)
    else
      report_excel_errors
    end
  rescue => e
		report_import_exception(e)
  end
  handle_asynchronously :import_cdisc_sdtm_model unless Rails.env.test?

  # Import CDISC SDTM Implementation Guide
  #
  # @param [Hash] params The parameters
  # @option params [String] :date The release date of the version being created
  # @option params [String] :version The version being created
  # @option params [String] :version_label The version label 
  # @option params [String] :model_uri The URI for the model being used
  # @option params [String] :files Array of files being used 
  # @return [void] no return
  def import_cdisc_sdtm_ig(params)
    start_cdisc_import("Import CDISC SDTM Implementation Guide. Date: #{params[:date]} Internal Version: #{params[:version]}.")
    results = SdtmExcel.read_ig(params, self.errors)
    if self.errors.empty?
    	report_file_successfully_read
      process_cdisc_sdtm_ig_import(params, results)
    else
      report_excel_errors
    end
  rescue => e
		report_import_exception(e)
  end
  handle_asynchronously :import_cdisc_sdtm_ig unless Rails.env.test?

  # Import CDISC Terminology
  #
  # @param [Hash] params The parameters
  # @option params [String] :date The release date of the version being created
  # @option params [String] :version The version being created
  # @option params [String] :files Array of files being used 
  # @option params [String] :ns The namespace into which the terminology is being placed
  # @option params [String] :cid The cid of the terminology
  # @option params [String] :si The CID of the scoped identifier
  # @option params [String] :rs The CID of the registration status
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

  def start_cdisc_import(log_text)
    self.errors.clear
    self.update( description: log_text, status: "Reading file.", started: Time.now())
  end

  def process_cdisc_term_changes_import(params, results)
  	ordinals = {}
  	uri = UriV2.new(uri: params[:uri])
    current_ct = CdiscTerm.find(uri.id, uri.namespace)
    previous = CdiscTerm.all_previous(current_ct.version)
    previous_ct = previous.last
  	sparql = SparqlUpdateV2.new
  	results.each do |result|
  		result[:new_cl].each do |cl|
	  		sources = []
  			parent = find_terminology({identifier: cl}, current_ct)
	  		if !parent.nil?
		  		if result[:new_cli].empty?
		  			sources << parent
		  		else
		  			result[:new_cli].each do |cli|
		  				child = find_terminology_child(parent, cli)
		  				if !child.nil?
								sources << child if !child.nil?
							else
								report_general_error("Failed to find child terminology item [1] with identifier: #{cli}")
								return
							end
						end
					end			
		  		sources.each do |source|
						ordinal = 1
		  			cr = CrossReference.new
						cr.comments = result[:instructions]
						cr.ordinal = get_ordinal(source, ordinals)
						previous = find_terminology({identifier: result[:previous_cl]}, previous_ct)
						if !previous.nil?	
							if result[:previous_cli].empty?
				  			cr.children << create_operational_ref(previous, source, ordinal)
				  		else
				  			result[:previous_cli].each do |cli|
				  				child = find_terminology_child(previous, cli)
		  					if !child.nil?
										cr.children << create_operational_ref(child, source, ordinal)
				  					ordinal += 1
				  				else
										report_general_error("Failed to child find terminology item [2] with identifier: #{cli}")
										return
				  				end
								end
							end	
				  		ref_uri = cr.to_sparql_v2(source.uri, sparql)
							sparql.triple({uri: source.uri}, {:prefix => UriManagement::C_BCR, :id => "crossReference"}, {:uri => ref_uri})
						else
							report_general_error("Failed to find terminology item [3] with identifier: #{result[:previous_cl]}")
							return
						end
					end
				else
					report_general_error("Failed to find terminology item [4] with identifier: #{cl}")
					return
				end
			end
		end			
		load_sparql(sparql, "CDISC_CT_Instructions_V#{current_ct.version}.txt") 
  end

  def process_cdisc_sdtm_model_import(params, results)
  	proceed = true
  	sparql = SparqlUpdateV2.new
   	models = results.select { |hash| hash[:type]=="MODEL" }
    if models.length == 1
      model = SdtmModel.build(models[0][:instance], sparql)
      domains = results.select { |hash| hash[:type]=="MODEL_DOMAIN" }
      domains.each do |domain|
        model_domain = SdtmModelDomain.build(domain[:instance], model, sparql)
  			if model_domain.errors.empty?
  				model.add_domain(model_domain)
  			else
  				report_object_errors("Model Domain error", model_domain)
  				proceed = false
  			end
      end
      if proceed
      	model.domain_refs_to_sparql(sparql) 
      	load_sparql(sparql, "SDTM_Model_#{params[:version_label].gsub('.', '-')}.txt") 
      end
    else
      report_general_error("Multiple SDTM Models detected")
    end
  end

  def process_cdisc_sdtm_ig_import(params, results)
  	proceed = true
  	sparql = SparqlUpdateV2.new
   	uri = UriV2.new(uri: params[:model_uri])
    model = SdtmModel.find(uri.id, uri.namespace)
    igs = results.select { |hash| hash[:type]=="IG" }
    if igs.length == 1
    	ig = SdtmIg.build(results, sparql)
    	if ig.errors.empty?
  			domain_params = results.select { |hash| hash[:type]=="IG_DOMAIN" }
    		domain_params.each do |domain|
      		ig_domain = SdtmIgDomain.build(domain[:instance], model, ig, sparql)
    			if ig_domain.errors.empty?
    				ig.add_domain(ig_domain)
    			else
    				report_object_errors("Implementation Guide Domain error", ig_domain)
    				proceed = false
    			end
  			end
  			if proceed
  				ig.domain_refs_to_sparql(sparql) 
    			load_sparql(sparql, "SDTM_IG_#{params[:version_label].gsub('.', '-')}.txt")
    		end
    	else
    		report_object_errors("Implementation Guide error", ig_domain)
    	end
    else
      report_general_error("Multiple SDTM Implementation Guides detected")
    end
  end

  def load_sparql(sparql, log_file) 
  	result = true
    response = CRUD.update(sparql.to_s)
  	if response.success?
  		PublicFile::save("test", log_file, sparql.to_s) if !Rails.env.production?
    	self.update(status: "Complete. Successful import.", percentage: 100, complete: true, completed: Time.now())
  	else  
    	self.update(status: "Complete. Unsuccessful import, SPARQL error.", percentage: 100, complete: true, completed: Time.now())
    	result = false
  	end
  	return result
  end

  def report_excel_errors
    self.update(status: "Complete. Unsuccessful import. Excel errors: " + self.errors.full_messages.to_sentence, 
    	percentage: 100, complete: true, completed: Time.now())
  end

	def report_import_exception(e)
	  self.update(status: "Complete. Unsuccessful import. Exception detected: #{e.to_s}. Backtrace: #{e.backtrace}", 
	  	percentage: 100, complete: true, completed: Time.now())
	end

	def report_file_successfully_read
		self.update(status: "File successfully read.", percentage: 50, complete: false, completed: Time.now())
  end

  def report_object_errors(text, object)
  	self.update(status: "Complete. Unsuccessful import, #{text}: " + object.errors.full_messages.to_sentence, 
  		percentage: 100, complete: true, completed: Time.now())
 	end

 	def report_general_error(text)
 		self.update(status: "Complete. Unsuccessful import. #{text}.", percentage: 100, complete: true, completed: Time.now())
 	end

 	def find_terminology(params, in_object)
 		tcs = in_object.find_by_property(params)
    return tcs[0] if tcs.length == 1
    return nil
  end

  def get_ordinal(tc, ordinals)
  	uri = tc.uri.to_s
  	ordinals[uri] = 0 if !ordinals.has_key?(uri)
  	ordinals[uri] += 1
		return ordinals[uri]
	end

	def create_operational_ref(term, cross_ref, ordinal)
		return if term.nil?
		oref = OperationalReferenceV2.new
		oref.ordinal = ordinal
		oref.subject_ref = term.uri
		return oref
	end

	def find_terminology_child(parent, identifier)
		return parent.children.find { |c| c.identifier == identifier }
	end

end
