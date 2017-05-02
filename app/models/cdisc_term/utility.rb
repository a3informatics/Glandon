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
  # @param id [String] the id of the code list item to be compared for changes
  # @return [Hash] a hash containing the identifier, title and the changes across all the versions
  def self.cli_changes(id)
    data = []
    results = []
    identifier = ""
    title = ""
    cdisc_terms = CdiscTerm.all()
    cdisc_terms.each do |ct|
      cli = CdiscCli.find(id, ct.namespace)
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
  # @param id [String] the id of the code list item to be compared for changes
  # @return [Hash] a hash containing the identifier, title and the changes across all the versions
  def self.cl_changes(id)
    data = []
    results = []
    identifier = ""
    title = ""
    cdisc_terms = CdiscTerm.all()
    cdisc_terms.each do |ct|
      cl = CdiscCl.find(id, ct.namespace)
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

  # Previous version. Find the previous version to the trimmed results
  #
  # @param full_results [Array] the full results structure
  # @param trimmed_results [Array] the trimmed results
  # @return [String] the previous version, nil if none.
  def self.previous_version(full_results, trimmed_results)
  	first_version = trimmed_results.first[:version]
  	index = full_results.index {|x| x[:version] == first_version}
  	return nil if index == 0
  	return full_results[index - 1][:version]
  end

  # Next version. Find the next version to the trimmed results
  #
  # @param full_results [Array] the full results structure
  # @param trimmed_results [Array] the trimmed results
  # @return [String] the next version, nil if none.
  def self.next_version(full_results, trimmed_results)
  	first_version = trimmed_results.first[:version]
  	index = full_results.index {|x| x[:version] == first_version}
  	return nil if (index + trimmed_results.length) >= full_results.length
  	return full_results[index + 1][:version]
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
      new_results[key] = { preferred_term: "", identifier: "", notation: "", id: "", status: Array.new(results.length, :not_present)}
    end
    index = 0
    results.each do |result|
      result[:children].each do |key, child|
        new_results[key][:status][index] = child[:status]
        #if child[:status] == :created
          new_results[key][:identifier] = child[:identifier]
          new_results[key][:preferred_term] = child[:preferred_term]
          new_results[key][:notation] = child[:notation]
          new_results[key][:id] = child[:id]
        #end
      end
      index += 1
      result[:children] = {}
    end
    return new_results
  end

end