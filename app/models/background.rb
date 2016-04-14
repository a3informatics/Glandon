class Background < ActiveRecord::Base

  C_CLASS_NAME = "Background"

	def importCdiscTerm(params)
    # Create the background job status
    self.update(
    	description: "Import CDISC terminology file(s). Date: " + params[:date] + ", Internal Version: " + params[:version] + ".", 
    	status: "Building manifest file.",
    	started: Time.now())
    # Create manifest file
    manifest = Xml::buildCdiscTermImportManifest(params[:date], params[:version], params[:files])
    # Create the thesaurus (does not actually create the database entries).
    # Entries in DB created as part of the XSLT and load
    self.update(status: "Transforming terminology file.", percentage: 10)
    # Transform the files and upload. Note the quotes around the namespace & II but not version, important!!
    Xslt.execute(manifest, "thesaurus/import/cdisc/cdiscTermImport.xsl", 
      { :UseVersion => params[:version], :Namespace => "'" + params[:ns] + "'", 
        :SI => "'" + params[:si] + "'", :CID => "'" + params[:cid] + "'"}, "CT.ttl")
    # upload the file to the database. Send the request, wait the resonse
    self.update(status: "Loading file into database.", percentage: 50)
    publicDir = Rails.root.join("public","upload")
    outputFile = File.join(publicDir, "CT.ttl")
    response = CRUD.file(outputFile)
    # And report ...
    if response.success?
      self.update(status: "Complete. Successful import.", percentage: 100, complete: true, completed: Time.now())
    else
      self.update(status: "Complete. Unsuccessful import.", percentage: 100, complete: true, completed: Time.now())
    end
  end
  handle_asynchronously :importCdiscTerm

  def compareCdiscTerm(old_term, new_term)
    # Create the background job status
    self.update(
      description: "Detect CDISC Terminology changes, " + new_term.versionLabel + " (V" + new_term.version.to_s + ") to " + old_term.versionLabel + " (V" + old_term.version.to_s + ").", 
      status: "Starting.",
      started: Time.now())
    # Get the CT top level items
    data = Array.new
    total_ct_count = 2
    counts = Hash.new
    counts[:cl_count] = 0
    counts[:ct_count] = 0
    load_cls(data, old_term, counts, total_ct_count)
    ConsoleLogger::log(C_CLASS_NAME, "compareCdiscTerm", "CT Count=" + counts[:ct_count].to_s + ", CL Count=" + counts[:cl_count].to_s)
    load_cls(data, new_term, counts, total_ct_count)
    ConsoleLogger::log(C_CLASS_NAME, "compareCdiscTerm", "CT Count=" + counts[:ct_count].to_s + ", CL Count=" + counts[:cl_count].to_s)
    # Compare
    results = compare(data, counts[:cl_count])
    # Save the results
    version_hash = {:new_version => new_term.version.to_s, :old_version => old_term.version.to_s} 
    CdiscCtChanges.save(CdiscCtChanges::C_TWO_CT, results, version_hash)
    # Finish
    self.update(status: "Comparison complete.", percentage: 100, complete: true, completed: Time.now())
  end
  handle_asynchronously :compareCdiscTerm

  def changesCdiscTerm()
    # Create the background job status
    self.update(
      description: "Detect CDISC Terminology changes, all versions.", 
      status: "Starting.",
      started: Time.now())
    # Get the CT top level items
    data = Array.new
    cdiscTerms = CdiscTerm.all()
    total_ct_count = cdiscTerms.length
    counts = Hash.new
    counts[:cl_count] = 0
    counts[:ct_count] = 0
    cdiscTerms.each do |ct|
      load_cls(data, ct, counts, total_ct_count)
    end
    # Compare
    results = compare(data, counts[:cl_count])
    # Save the results
    CdiscCtChanges.save(CdiscCtChanges::C_ALL_CT, results)
    # Report Status
    self.update(status: "Comparison complete.", percentage: 100, complete: true, completed: Time.now())
  end
  handle_asynchronously :changesCdiscTerm

  def submission_changes_cdisc_term()
    # Create the background job status
    self.update(
      description: "Detect CDISC Terminology submission value changes, all versions.", 
      status: "Starting.",
      started: Time.now())
    # Get the CT top level items
    results = Hash.new
    cdisc_terms = CdiscTerm.all()
    prev_ct = nil
    missing = Array.new
    cdisc_terms.each_with_index do |ct, index|
      key = ct.versionLabel
      missing << key
      if index != 0 
        diffs = CdiscTerm.submission_diff(prev_ct, ct)
        diffs.each do |diff|
          old_id = ModelUtility.extractCid(diff[:old_uri])
          old_ns = ModelUtility.extractNs(diff[:old_uri])
          if results.has_key?(old_id)
            entry = results[old_id]
            result = entry[:result]
            result[key] = diff[:old_notation] + " -> " + diff[:new_notation]
            results[old_id] = entry
          else
            cli = CdiscCli.find(old_id, old_ns)
            entry = {:cli => {:id => old_id, :parent_identifier => diff[:parent_identifier], 
              :identifier => diff[:identifier], :label => cli.preferredTerm}, :result => {}}
            result = entry[:result]
            missing.each do |ver|
              result[ver] = ""
            end
            result[key] = diff[:old_notation] + " -> " + diff[:new_notation]
            results[old_id] = entry
          end
        end
      end
      results.each do |cli, entry|
        result = entry[:result]
        if !result.has_key?(key)
          result[key] = ""
        end
      end
      prev_ct = ct
      p = 95.0 * (index.to_f/cdisc_terms.count.to_f)
      self.update(status: "Checked " + ct.versionLabel + ".", percentage: p.to_i)
    end
    # Save the results
    CdiscCtChanges.save(CdiscCtChanges::C_ALL_SUB, results)
    # Report Status
    self.update(status: "Comparison complete.", percentage: 100, complete: true, completed: Time.now())
  end
  handle_asynchronously :submission_changes_cdisc_term

  def submission_changes_impact(params)
    results = Hash.new
    # Create the background job status
    self.update(
      description: "Detect CDISC Terminology submission value changes impact.", 
      status: "Starting.",
      started: Time.now())
    # Get the CTs
    new_id = params[:new_id]
    new_ns = params[:new_ns]
    old_id = params[:old_id]
    old_ns = params[:old_ns]
    old_ct = CdiscTerm.find(old_id, old_ns, false)
    new_ct = CdiscTerm.find(new_id, new_ns, false)   
    # Get the submission differences  
    diffs = CdiscTerm.submission_diff(old_ct, new_ct)
    # Assess impact
    index = 1
    count = diffs.length
    diffs.each do |diff|
      uri = diff[:old_uri]
      id = ModelUtility.extractCid(uri)
      ns = ModelUtility.extractNs(uri)
      bcs = BiomedicalConcept.impact({:id => id, :namespace => ns})
      bc_results = Array.new  
      if bcs.length > 0
        bcs.each do |bc_id, bc|
          forms = Form.impact({:id => bc.id, :namespace => bc.namespace})
          form_results = Array.new
          forms.each do |form_id, form|
            form_results << {:id => form.id, :ns => form.namespace, :identifier => form.identifier, :label => form.label}
          end
          bc_results << {:id => bc.id, :ns => bc.namespace, :identifier => bc.identifier, :label => bc.label, :forms => form_results}
        end
      else
        form_results = Array.new
        bc_results << {:forms => form_results}
      end
      diff[:bcs] = bc_results
      p = (index.to_f/count.to_f)*100.0
      self.update(status: "Checked " + diff[:identifier] + ".", percentage: p.to_i)
      index += 1
    end
    # Save the results
    CdiscCtChanges.save(CdiscCtChanges::C_TWO_CT_IMPACT, diffs, params)
    # Report Status
    self.update(status: "Impact assessment complete.", percentage: 100, complete: true, completed: Time.now())
  end
  handle_asynchronously :submission_changes_impact

private

  def load_cls(data, ct, counts, total_ct_count)
    # Get the Cls
    cdisc_term = CdiscTerm.find(ct.id, ct.namespace)
    cls = cdisc_term.children
    cls_hash = Hash.new
    cls.each do |cl|
      cls_hash[cl.id] = cl
    end
    temp = {:term => ct, :cls => cls_hash}
    data.push(temp)   
    counts[:cl_count] += cls.length
    # Report Status
    counts[:ct_count] += 1
    p = (counts[:ct_count].to_f / total_ct_count.to_f) * 10.0
    self.update(status: "Loading release of " + ct.versionLabel + ".", percentage: p.to_i)
    return counts
  end

  def compare(data, totalCount)    
    ConsoleLogger::log(C_CLASS_NAME,"compare","*****Entry*****")
    # Do the comparison
    currentCount = 0
    missing = Array.new
    results = Hash.new
    last = data.length - 1
    data.each_with_index do |curr, index|
      ConsoleLogger::log(C_CLASS_NAME,"compare","Index=" + index.to_s)
      currTerm = curr[:term]
      version = currTerm.version
      currCls = curr[:cls]
      key = currTerm.versionLabel
      missing.push(key)
      if index >= 1
        if currCls != nil
          prev = data[index - 1]
          prevTerm = prev[:term]
          prevCls = prev[:cls]
          if prevCls != nil
            clCount = currCls.length
            currCls.each do |clId, currCl|
              ConsoleLogger::log(C_CLASS_NAME,"compare","CL=" + clId)
              if prevCls.has_key?(clId)
                ConsoleLogger::log(C_CLASS_NAME,"compare","Prev CL=" + clId)
                prevCl = prevCls[clId]
                if CdiscCl.diff?(currCl, prevCl)
                  ConsoleLogger::log(C_CLASS_NAME,"compare"," M ")
                  mark = "M"
                else
                  ConsoleLogger::log(C_CLASS_NAME,"compare"," . ")
                  mark = "."
                end
              else
                ConsoleLogger::log(C_CLASS_NAME,"compare","No Prev CL")
                mark = "."
              end
              if results.has_key?(clId)
                clEntry = results[clId]
                result = clEntry[:result]
                result[key] = mark
              else
                result = Hash.new
                missing.each do |mKey|
                  result[mKey] = ""
                end    
                result[key] = mark
                clEntry = Hash.new
                clEntry = {:cl => {:id => currCl.id, :namespace => currCl.namespace, :identifier => currCl.identifier, :label => currCl.label, :notation => currCl.notation}, :result => result }
                results[clId] = clEntry
              end
              # Report Status
              currentCount += 1
              p = 10.0 + ((currentCount.to_f * 85.0)/totalCount.to_f)
              self.update(status: "Checking " + currTerm.versionLabel + " [" + currCl.identifier + ", " + currentCount.to_s + "]", percentage: p.to_i)
            end
          end
        end
      else
        # First item. Build an entry for every member
        if currCls != nil
          currCls.each do |clId, currCl|
            result = Hash.new
            result[key] = "."
            clEntry = Hash.new
            clEntry = {:cl => {:id => currCl.id, :namespace => currCl.namespace, :identifier => currCl.identifier, :label => currCl.label, :notation => currCl.notation}, :result => result }
            results[clId] = clEntry
            # Report Status
            currentCount += 1
            p = 10.0 + ((currentCount.to_f * 85.0)/totalCount.to_f)
            self.update(status: "Checking " + currTerm.versionLabel + " [" + currCl.identifier + ", " + currentCount.to_s + "]", percentage: p.to_i)
          end
        end
      end
    end
    # Run through the entire set of results and check for missing entries.
    # If any found then mark as deleted
    results.each do |clId, clEntry|
      result = clEntry[:result]
      update = false
      missing.each do |mKey|
        if !result.has_key?(mKey)
          result[mKey] = "X"
          update = true
        end
      end 
      if update
        clEntry[:result] = result
      end
    end 
    # And return
    return results 
  end    

end
