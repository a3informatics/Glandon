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

  def changesCdiscTerm()
    
    # Create the background job status
    self.update(
      description: "Detect CDISC Terminology changes, all versions.", 
      status: "Starting.",
      started: Time.now())

    # Get the CT top level items
    data = Array.new
    cdiscTerms = CdiscTerm.all()
    ctCount = cdiscTerms.length
    totalCount = 0
    currentCount = 0
    cdiscTerms.each do |key, ct|

      # Get the Cls
      cls = CdiscCl.allTopLevel(ct.id, ct.namespace)
      temp = {:term => ct, :cls => cls}
      data.push(temp)   
      totalCount += cls.length

      #ConsoleLogger::log(C_CLASS_NAME,"changesCdiscTerm","CT=" + ct.to_json.to_s)
    
      # Report Status
      currentCount += 1
      p = (currentCount / ctCount.to_f) * 10.0
      self.update(status: "Loading release of " + ct.versionLabel + ".", percentage: p.to_i)
    end

    # Do the comparison
    currentCount = 0
    missing = Array.new
    results = Hash.new
    last = data.length - 1
    data.each_with_index do |curr, index|
      currTerm = curr[:term]
      version = currTerm.version
      currCls = curr[:cls]
      key = "V" + version.to_s
      missing.push(key)
      if index >= 1
        if currCls != nil
          prev = data[index - 1]
          prevTerm = prev[:term]
          prevCls = prev[:cls]
          if prevCls != nil
            clCount = currCls.length
            currCls.each do |clId, currCl|
              if prevCls.has_key?(clId)
                prevCl = prevCls[clId]
                if CdiscCl.diff?(currCl, prevCl)
                  mark = "M"
                else
                  mark = "."
                end
              else
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
    
    # Save the results
    CdiscCtChanges.save(results)

    # Report Status
    self.update(status: "Comparison complete.", percentage: 100, complete: true, completed: Time.now())

  end
  handle_asynchronously :changesCdiscTerm

end
