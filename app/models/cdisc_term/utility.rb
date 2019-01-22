class CdiscTerm::Utility

  C_CLASS_NAME = "CdiscTerm::Utility"

  # Compare Code List item
  #
  # @param ct [CdiscTerm] the current terminology
  # @param previous [CdiscCli] the previous code list 
  # @param current [CdiscCli] the current code list
  # @return [Hash] the result hash
  def self.compare_cli(ct, previous, current)
    result = CdiscCli.difference(previous, current)
    result[:version] = ct.version
    result[:date] = ct.versionLabel
    return result
  end

  # Compare Code List
  #
  # @param ct [CdiscTerm] the current terminology
  # @param previous [CdiscCl] the previous code list 
  # @param current [CdiscCl] the current code list
  # @return [Hash] the result hash
  def self.compare_cl(ct, previous, current)
    result = CdiscCl.difference(previous, current)
    result[:version] = ct.version
    result[:date] = ct.versionLabel
    return result
  end

  # Code List Item Changes for given id
  #
  # @param [UriV3] uri the uri for the code list item 
  # @return [Hash] a hash containing the identifier, title and the changes across all the versions
  def self.cli_changes(uri)
    data = []
    results = []
    identifier = ""
    title = ""
    root_cli = CdiscCli.find(uri.fragment, uri.namespace)
    root_cli.set_parent if !root_cli.nil?
    cdisc_terms = CdiscTerm.all()
    cdisc_terms.each do |ct|
      #cli = CdiscCli.find(id, ct.namespace)
      cli = root_cli.nil? ? nil : CdiscCl.find_child(root_cli.parentIdentifier, root_cli.identifier, ct.namespace)
      data << {:term => ct, :cli => cli}
    end
    set = false
    prev_cli = nil
    data.each_with_index do |curr, index|
      cli = curr[:cli]
      if !cli.nil? && !set
        #@id = cli.id
        identifier = cli.identifier
        title = cli.preferredTerm
      end
      if index >= 1
        prev_cli = data[index - 1][:cli]
      end
      results << compare_cli(curr[:term], prev_cli, cli)
    end
    return { identifier: identifier, title: title, results: results }
  end

  # Code List Changes for given id
  #
  # @param [UriV3] uri the uri for the code list item 
  # @return [Hash] a hash containing the identifier, title and the changes across all the versions
  def self.cl_changes(uri)
    data = []
    results = []
    identifier = ""
    title = ""
    root_cl = CdiscCl.find(uri.fragment, uri.namespace, false)
    cdisc_terms = CdiscTerm.all()
    cdisc_terms.each do |ct|
      #cl = CdiscCl.find(id, ct.namespace)
      cl = root_cl.nil? ? nil : CdiscCl.find_by_identifier(root_cl.identifier, ct.namespace)
      data << {:term => ct, :cl => cl}
    end
    set = false
    prev_cl = nil
    data.each_with_index do |curr, index|
      cl = curr[:cl]
      if !cl.nil? && !set
        #@id = cl.id
        identifier = cl.identifier
        title = cl.preferredTerm
        set = true
      end
      if index >= 1
        prev_cl = data[index - 1][:cl]
      end
      results << compare_cl(curr[:term], prev_cl, cl)
    end
    return { identifier: identifier, title: title, results: results }
  end


  # Trim result array structure
  #
  # @param results [Array] the results structure to be trimmed
  # @param first_version [Integer] the first version to be seen
  # @param length [Integer] the length
  # @return [Array] the resulting structure
  def self.trim_results(results, first_version, length)
  	if first_version.blank?
  		return results[-length .. -1] if results.length >= length
  	else
   		first = results.index {|x| x[:version] == first_version}
  		return results[first .. (first + length - 1)] if !first.nil?
  	end
  	return results
  end

  # Trim submission result array structure
  #
  # @param results [Array] the results structure to be trimmed
  # @param first_version [Integer] the first version to be seen
  # @param length [Integer] the length
  # @return [Array] the resulting structure
  def self.trim_submission_results(results, first_version, length)
  	if first_version.blank?
  		if results[:versions].length >= length
  			start_index = -length
  			end_index = -1
  			trim_results = process_submission_results(results, start_index, end_index)
  			return trim_results
  		end
  	else
   		first = results[:versions].index {|x| x[:version] == first_version}
   		if !first.nil?
  			start_index = first
  			end_index = first + length - 1
  			trim_results = process_submission_results(results, start_index, end_index)
  			return trim_results
  		end
  	end
  	return results
  end

  # Previous version. Find the previous version to the trimmed results
  #
  # @param version_array [Array] the array cotaining the versions
  # @param first_version [Integer] the first version being displayed
  # @return [String] the previous version, nil if none.
  def self.previous_version(version_array, first_version)
  	index = version_array.index {|x| x[:version] == first_version}
  	return nil if index == 0
  	return version_array[index - 1][:version]
  end

  # Next version. Find the next version to the trimmed results
  #
  # @param version_array [Array] the array cotaining the versions
  # @param first_version [Integer] the first version being displayed
  # @param displayed_length [Integer] the length of results being displayed
  # @param max_length [Integer] the length of the whole results
  # @return [String] the next version, nil if none.
  def self.next_version(version_array, first_version, displayed_length, max_length)
  	index = version_array.index {|x| x[:version] == first_version}
  	return nil if (index + displayed_length) >= max_length
  	return version_array[index + 1][:version]
  end

  # Transpose result into hash structure
  #
  # @param results [Array] the results to be transposed
  # @return [Hash] the resulting structure
  def self.transpose_results(results)
    list = []
    new_results = {}
    results.each do |result|
      children = result[:children]
      list = list | children.keys
    end
    list.each do |key|
      new_results[key] = { preferred_term: "", identifier: "", notation: "", id: "", namespace: "", 
        status: Array.new(results.length, :not_present)}
    end
    index = 0
    results.each do |result|
      result[:children].each do |key, child|
        new_results[key][:status][index] = child[:status]
        new_results[key][:identifier] = child[:identifier]
        new_results[key][:preferred_term] = child[:preferred_term]
        new_results[key][:notation] = child[:notation]
        new_results[key][:id] = child[:id]
        new_results[key][:namespace] = child[:namespace]
      end
      index += 1
      result[:children] = {}
    end
    return new_results
  end

private

	# Process the submission results.
	def self.process_submission_results(results, start_index, end_index)
		trim_results = {}
		trim_results[:versions] = results[:versions][start_index .. end_index]
		trim_results[:children] = {}
		results[:children].each do |key, child|
			if submission_changed(child, start_index, end_index)
				result = child.deep_dup
				result[:result] = result[:result][start_index .. end_index]
				trim_results[:children][key] = result
			end
		end
		return trim_results
	end

	# Has submission value changed.
  def self.submission_changed(child, start_index, end_index)
		child[:result][start_index .. end_index].each do |result|
			return true if result[:status] != :no_change
		end
		return false
	end

end